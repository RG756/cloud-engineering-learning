import json
import sys
import os
from unittest.mock import patch, MagicMock

os.environ['TABLE_NAME'] = 'test-table'
os.environ['AWS_DEFAULT_REGION'] = 'ap-northeast-1'

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'lambda'))

import index

def test_get_items_returns_200():
    with patch.object(index, 'table') as mock_table:
        mock_table.scan.return_value = {'Items': []}
        event = {"httpMethod": "GET", "pathParameters": None, "body": None}
        response = index.lambda_handler(event, {})
        assert response["statusCode"] == 200

def test_response_has_cors_header():
    with patch.object(index, 'table') as mock_table:
        mock_table.scan.return_value = {'Items': []}
        event = {"httpMethod": "GET", "pathParameters": None, "body": None}
        response = index.lambda_handler(event, {})
        assert "Access-Control-Allow-Origin" in response["headers"]

def test_invalid_method_returns_400():
    with patch.object(index, 'table') as mock_table:
        event = {"httpMethod": "PATCH", "pathParameters": None, "body": None}
        response = index.lambda_handler(event, {})
        assert response["statusCode"] == 400