"""
Project F: Bedrock AI API - Lambda Handler
Handles CRUD operations (from Project D) and AI chat via Amazon Bedrock.

Phase 2: Added DynamoDB chat history, improved endpoint design,
         and strengthened error handling.
"""

import json
import boto3
import logging
import os
import uuid
import time
from datetime import datetime, timezone, timedelta
from botocore.exceptions import ClientError

# ---------------------------------------------------------------------------
# Clients & configuration
# ---------------------------------------------------------------------------
bedrock = boto3.client("bedrock-runtime", region_name="ap-northeast-1")
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["TABLE_NAME"])
chat_table = dynamodb.Table(os.environ["CHAT_HISTORY_TABLE_NAME"])

BEDROCK_MODEL_ID = "jp.anthropic.claude-haiku-4-5-20251001-v1:0"
# Guardrails設定
GUARDRAIL_ID      = os.environ.get("GUARDRAIL_ID", "")
GUARDRAIL_VERSION = os.environ.get("GUARDRAIL_VERSION", "DRAFT")
CHAT_TTL_DAYS = 30  # 会話履歴の保持期間

# Timezone
UTC = timezone.utc
JST = timezone(timedelta(hours=9))

# Structured logging
logger = logging.getLogger()
logger.setLevel(os.environ.get("LOG_LEVEL", "INFO"))


# ---------------------------------------------------------------------------
# Main handler
# ---------------------------------------------------------------------------
def handler(event, context):
    """
    Main Lambda handler.
    Routes HTTP requests from API Gateway proxy integration.
    Also supports direct invoke with 'action' field for backward compatibility.
    """
    try:
        if "httpMethod" in event:
            logger.info(json.dumps({
                "message": "API Request",
                "method": event["httpMethod"],
                "path": event.get("path", ""),
                "sourceIp": (event.get("requestContext", {})
                             .get("identity", {}).get("sourceIp", "unknown")),
            }))
            return route_http(event)

        # Direct invoke (backward compatibility)
        action = event.get("action", "")
        logger.info(json.dumps({"message": "Direct Invoke", "action": action}))

        if action == "create":
            return api_response(201, create_item(event))
        elif action == "get":
            return api_response(200, get_item(event["id"]))
        elif action == "list":
            return api_response(200, list_items())
        elif action == "update":
            return api_response(200, update_item(event["id"], event))
        elif action == "delete":
            return api_response(200, delete_item(event["id"]))
        else:
            return api_response(400, {"error": f"Unknown action: {action}"})

    except GuardrailsBlockedError as e:
        logger.warning("Guardrails blocked request")
        return api_response(400, {"error": str(e)})

    except ItemNotFoundError as e:
        logger.warning(f"Item not found: {e.item_id}")
        return api_response(404, {"error": str(e)})

    except json.JSONDecodeError as e:
        logger.warning(f"Invalid JSON in request body: {e}")
        return api_response(400, {"error": "Invalid JSON in request body"})

    except KeyError as e:
        logger.warning(f"Missing required field: {e}")
        return api_response(400, {"error": f"Missing required field: {str(e)}"})

    except Exception as e:
        logger.error(json.dumps({
            "message": "Unhandled Error",
            "error": str(e),
            "type": type(e).__name__,
        }))
        return api_response(500, {"error": "Internal server error"})


# ---------------------------------------------------------------------------
# HTTP routing
# ---------------------------------------------------------------------------
def route_http(event):
    """Route based on HTTP method and path."""
    method = event["httpMethod"]
    path = event.get("path", "")
    path_params = event.get("pathParameters") or {}
    item_id = path_params.get("id")

    body = {}
    if event.get("body"):
        body = json.loads(event["body"])

    if method == "GET" and item_id:
        return api_response(200, get_item(item_id))
    elif method == "GET":
        return api_response(200, list_items())
    elif method == "POST" and path == "/ask":
        return api_response(200, ask_bedrock(body))
    elif method == "POST":
        return api_response(201, create_item(body))
    elif method == "PUT" and item_id:
        return api_response(200, update_item(item_id, body))
    elif method == "DELETE" and item_id:
        return api_response(200, delete_item(item_id))
    else:
        return api_response(400, {"error": f"Unsupported: {method} {path}"})


# ---------------------------------------------------------------------------
# Bedrock AI endpoint  (/ask)
# ---------------------------------------------------------------------------
def ask_bedrock(data):
    """
    Call Amazon Bedrock Claude model and save conversation history to DynamoDB.

    Request body:
        question   (str, required): User's question
        session_id (str, optional): Session ID for conversation continuity.
                                    Auto-generated if omitted.

    Response:
        question   (str): Echo of the question
        answer     (str): Bedrock's response
        session_id (str): Session ID (use this for follow-up questions)
        model      (str): Model ID used
        asked_at   (str): Timestamp in JST (ISO8601)
    """
    # --- Input validation ---
    question = data.get("question", "").strip()
    if not question:
        raise ValueError("'question' is required and must not be empty")
    if len(question) > 1000:
        raise ValueError("'question' must be 1000 characters or less")

    session_id = data.get("session_id") or str(uuid.uuid4())

    # --- Call Bedrock ---
    cloudwatch = boto3.client("cloudwatch", region_name="ap-northeast-1")
    start_time = time.perf_counter()
    bedrock_error = False

    try:
        try:
            response = bedrock.invoke_model(
                modelId=BEDROCK_MODEL_ID,
                guardrailIdentifier=GUARDRAIL_ID,
                guardrailVersion=GUARDRAIL_VERSION,
                body=json.dumps({
                    "anthropic_version": "bedrock-2023-05-31",
                    "max_tokens": 512,
                    "messages": [{"role": "user", "content": question}],
                })
            )
        except ClientError as e:
            bedrock_error = True
            error_code = e.response["Error"]["Code"]
            logger.error(json.dumps({
                "message": "Bedrock ClientError",
                "error_code": error_code,
                "error": str(e),
            }))
            if error_code == "ThrottlingException":
                raise BedrockThrottlingError()
            raise

        result = json.loads(response["body"].read())

        # Guardrailsによるブロック判定
        if result.get("amazon-bedrock-guardrailAction") == "INTERVENED":
            logger.warning(json.dumps({
                "message": "Guardrails blocked the response",
                "session_id": session_id,
                "question": question[:100],
            }))
            raise GuardrailsBlockedError()

        answer = result["content"][0]["text"]

    finally:
        # --- Publish custom metrics to CloudWatch (best-effort) ---
        latency_ms = (time.perf_counter() - start_time) * 1000
        try:
            cloudwatch.put_metric_data(
                Namespace="Custom/BedrockAI",
                MetricData=[
                    {
                        "MetricName": "BedrockLatency",
                        "Value": latency_ms,
                        "Unit": "Milliseconds",
                        "Dimensions": [
                            {"Name": "ModelId", "Value": BEDROCK_MODEL_ID}
                        ],
                    },
                    {
                        "MetricName": "BedrockErrors",
                        "Value": 1 if bedrock_error else 0,
                        "Unit": "Count",
                        "Dimensions": [
                            {"Name": "ModelId", "Value": BEDROCK_MODEL_ID}
                        ],
                    },
                ],
            )
            logger.info(json.dumps({
                "message": "Custom metrics published",
                "latency_ms": round(latency_ms, 2),
                "bedrock_error": bedrock_error,
            }))
        except Exception as e:
            logger.error(json.dumps({
                "message": "Failed to publish custom metrics",
                "error": str(e),
            }))

    # --- Timestamps ---
    now_utc = datetime.now(UTC)
    timestamp_utc = now_utc.isoformat()
    asked_at_jst = now_utc.astimezone(JST).isoformat()
    expires_at = int((now_utc + timedelta(days=CHAT_TTL_DAYS)).timestamp())

    # --- Save to DynamoDB (best-effort) ---
    try:
        chat_table.put_item(Item={
            "session_id": session_id,
            "timestamp": timestamp_utc,
            "question": question,
            "answer": answer,
            "model_id": BEDROCK_MODEL_ID,
            "expires_at": expires_at,
        })
        logger.info(json.dumps({
            "message": "Chat history saved",
            "session_id": session_id,
        }))
    except Exception as e:
        logger.error(json.dumps({
            "message": "Failed to save chat history",
            "error": str(e),
            "session_id": session_id,
        }))

    return {
        "question": question,
        "answer": answer,
        "session_id": session_id,
        "model": BEDROCK_MODEL_ID,
        "asked_at": asked_at_jst,
    }

# ---------------------------------------------------------------------------
# CRUD operations (Project D)
# ---------------------------------------------------------------------------
def create_item(data):
    """Create a new item in DynamoDB."""
    item = {
        "id": str(uuid.uuid4()),
        "name": data.get("name", "Unnamed"),
        "price": data.get("price", 0),
        "created_at": datetime.now(UTC).isoformat(),
    }
    table.put_item(Item=item)
    return item


def get_item(item_id):
    """Get a single item by ID."""
    result = table.get_item(Key={"id": item_id})
    item = result.get("Item")
    if not item:
        raise ItemNotFoundError(item_id)
    return item


def list_items():
    """List all items (Scan)."""
    result = table.scan()
    return result.get("Items", [])


def update_item(item_id, data):
    """Update an existing item."""
    update_parts = []
    values = {}

    if "name" in data:
        update_parts.append("#n = :name")
        values[":name"] = data["name"]
    if "price" in data:
        update_parts.append("price = :price")
        values[":price"] = data["price"]

    if not update_parts:
        return {"error": "No fields to update"}

    update_parts.append("updated_at = :updated_at")
    values[":updated_at"] = datetime.now(UTC).isoformat()

    table.update_item(
        Key={"id": item_id},
        UpdateExpression="SET " + ", ".join(update_parts),
        ExpressionAttributeValues=values,
        ExpressionAttributeNames={"#n": "name"},
    )
    return {"message": "Updated", "id": item_id}


def delete_item(item_id):
    """Delete an item by ID."""
    table.delete_item(Key={"id": item_id})
    return {"message": "Deleted", "id": item_id}


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
def api_response(status_code, body):
    """Build API Gateway proxy integration response."""
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
        },
        "body": json.dumps(body, default=str),
    }


class ItemNotFoundError(Exception):
    """Raised when a requested item does not exist in DynamoDB."""
    def __init__(self, item_id):
        self.item_id = item_id
        super().__init__(f"Item not found: {item_id}")


class BedrockThrottlingError(Exception):
    """Raised when Bedrock returns ThrottlingException."""
    def __init__(self):
        super().__init__("Bedrock is currently busy. Please try again later.")

class GuardrailsBlockedError(Exception):
    """Raised when Bedrock Guardrails blocks the input or output."""
    def __init__(self):
        super().__init__("この質問にはお答えできません。")