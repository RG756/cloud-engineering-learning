import json
import sys
import os
from unittest.mock import patch, MagicMock

os.environ['TABLE_NAME'] = 'test-table'
os.environ['CHAT_HISTORY_TABLE_NAME'] = 'test-chat-history'
os.environ['AWS_DEFAULT_REGION'] = 'ap-northeast-1'

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'lambda'))

import index

def test_get_items_returns_200():
    with patch.object(index, 'table') as mock_table:
        mock_table.scan.return_value = {'Items': []}
        event = {"httpMethod": "GET", "pathParameters": None, "body": None}
        response = index.handler(event, {})  # ← handler に変更
        assert response["statusCode"] == 200

def test_response_has_cors_header():
    with patch.object(index, 'table') as mock_table:
        mock_table.scan.return_value = {'Items': []}
        event = {"httpMethod": "GET", "pathParameters": None, "body": None}
        response = index.handler(event, {})  # ← handler に変更
        assert "Access-Control-Allow-Origin" in response["headers"]

def test_invalid_method_returns_400():
    with patch.object(index, 'table') as mock_table:
        event = {"httpMethod": "PATCH", "pathParameters": None, "body": None}
        response = index.handler(event, {})  # ← handler に変更
        assert response["statusCode"] == 400

def test_ask_bedrock_returns_200():
    """
    POST /ask が正常に200を返すことを確認する。
    Phase 4: CloudWatch put_metric_data と X-Ray subsegment もモック。
    """
    # Bedrock レスポンスのモック
    mock_bedrock_response = {
        "body": MagicMock(
            read=MagicMock(return_value=json.dumps({
                "content": [{"text": "東京は日本の首都です。"}],
                "amazon-bedrock-guardrailAction": "NONE",
            }).encode())
        )
    }

    with patch.object(index, 'bedrock') as mock_bedrock, \
         patch('boto3.client') as mock_boto3_client:

        # bedrock.invoke_model のモック
        mock_bedrock.invoke_model.return_value = mock_bedrock_response

        # cloudwatch.put_metric_data のモック（Phase 4 追加）
        mock_cloudwatch = MagicMock()
        mock_boto3_client.return_value = mock_cloudwatch

        event = {
            "httpMethod": "POST",
            "path": "/ask",
            "pathParameters": None,
            "body": json.dumps({"question": "東京はどこですか？"}),
        }
        response = index.handler(event, {})

        assert response["statusCode"] == 200
        body = json.loads(response["body"])
        assert "answer" in body
        assert "session_id" in body

        # put_metric_data が呼ばれたことを確認（Phase 4 検証）
        mock_cloudwatch.put_metric_data.assert_called_once()
        call_kwargs = mock_cloudwatch.put_metric_data.call_args[1]
        assert call_kwargs["Namespace"] == "Custom/BedrockAI"
        metric_names = [m["MetricName"] for m in call_kwargs["MetricData"]]
        assert "BedrockLatency" in metric_names
        assert "BedrockErrors" in metric_names