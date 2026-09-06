import json
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'lambda'))

import index

def test_get_items_returns_200():
    event = {"httpMethod": "GET", "pathParameters": None, "body": None}
    response = index.lambda_handler(event, {})
    assert response["statusCode"] == 200

def test_response_has_cors_header():
    event = {"httpMethod": "GET", "pathParameters": None, "body": None}
    response = index.lambda_handler(event, {})
    assert "Access-Control-Allow-Origin" in response["headers"]

def test_invalid_method_returns_400():
    event = {"httpMethod": "PATCH", "pathParameters": None, "body": None}
    response = index.lambda_handler(event, {})
    assert response["statusCode"] == 400