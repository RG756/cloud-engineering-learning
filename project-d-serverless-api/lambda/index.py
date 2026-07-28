"""
Project D: Serverless CRUD API - Lambda Handler
Handles Create, Read, Update, Delete operations on DynamoDB.
Supports both API Gateway proxy integration and direct Lambda invoke.

Session 3: Added structured logging and improved error handling.
"""

import json
import boto3
import logging
import os
import uuid
from datetime import datetime

# Structured logging setup
logger = logging.getLogger()
logger.setLevel(os.environ.get("LOG_LEVEL", "INFO"))

# Initialize DynamoDB resource
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["TABLE_NAME"])


def handler(event, context):
    """
    Main Lambda handler.
    Routes requests based on HTTP method and path (API Gateway proxy integration).
    Also supports direct invoke with 'action' field for backward compatibility.
    """
    try:
        # Log every incoming request for CloudWatch visibility
        if "httpMethod" in event:
            logger.info(json.dumps({
                "message": "API Request",
                "method": event["httpMethod"],
                "path": event.get("path", ""),
                "sourceIp": (event.get("requestContext", {})
                             .get("identity", {}).get("sourceIp", "unknown")),
            }))
            return route_http(event)

        # Direct invoke format (backward compatibility with Session 1)
        action = event.get("action", "")
        logger.info(json.dumps({
            "message": "Direct Invoke",
            "action": action,
        }))

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


def route_http(event):
    """Route based on HTTP method and path."""
    method = event["httpMethod"]
    path = event.get("path", "")
    
    # Extract item ID from path: /items/{id}
    path_params = event.get("pathParameters") or {}
    item_id = path_params.get("id")

    # Parse JSON body for POST/PUT
    body = {}
    if event.get("body"):
        body = json.loads(event["body"])

    # Routing
    if method == "GET" and item_id:
        return api_response(200, get_item(item_id))
    elif method == "GET":
        return api_response(200, list_items())
    elif method == "POST":
        return api_response(201, create_item(body))
    elif method == "PUT" and item_id:
        return api_response(200, update_item(item_id, body))
    elif method == "DELETE" and item_id:
        return api_response(200, delete_item(item_id))
    else:
        return api_response(400, {"error": f"Unsupported: {method} {path}"})


def create_item(data):
    """Create a new item in DynamoDB."""
    item = {
        "id": str(uuid.uuid4()),
        "name": data.get("name", "Unnamed"),
        "price": data.get("price", 0),
        "created_at": datetime.now().isoformat(),
    }
    table.put_item(Item=item)
    return item


def get_item(item_id):
    """Get a single item by ID. Raises ItemNotFoundError if missing."""
    result = table.get_item(Key={"id": item_id})
    item = result.get("Item")
    if not item:
        raise ItemNotFoundError(item_id)
    return item


class ItemNotFoundError(Exception):
    """Raised when a requested item does not exist in DynamoDB."""
    def __init__(self, item_id):
        self.item_id = item_id
        super().__init__(f"Item not found: {item_id}")


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
    values[":updated_at"] = datetime.now().isoformat()

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
    