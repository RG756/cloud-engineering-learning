import json
import sys
import os
from unittest.mock import patch, MagicMock

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'lambda'))

# boto3のDynamoDB接続をモックに差し替え
@patch('boto3.resource')
def test_get_items_returns_200(mock_boto):
    mock_table = MagicMock()
    mock_table.scan.return_value = {'Items': []}
    mock_boto.return_value.Table.return_value = mock_table

    import index
    event = {"httpMethod": "GET", "pathParameters": None, "body": None}
    response = index.lambda_handler(event, {})
    assert response["statusCode"] == 200

@patch('boto3.resource')
def test_response_has_cors_header(mock_boto):
    mock_table = MagicMock()
    mock_table.scan.return_value = {'Items': []}
    mock_boto.return_value.Table.return_value = mock_table

    import index
    event = {"httpMethod": "GET", "pathParameters": None, "body": None}
    response = index.lambda_handler(event, {})
    assert "Access-Control-Allow-Origin" in response["headers"]

@patch('boto3.resource')
def test_invalid_method_returns_400(mock_boto):
    import index
    event = {"httpMethod": "PATCH", "pathParameters": None, "body": None}
    response = index.lambda_handler(event, {})
    assert response["statusCode"] == 400