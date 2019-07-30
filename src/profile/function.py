import json
from typing import Dict, Any

Event = Dict[str, Any]
Context = Dict[str, Any]


def get(event: Event) -> Dict[str, Any]:
    return {
        "statusCode": 200,
        "body": {
            "success": True
        }
    }


def handler(event: Event, context: Context) -> str:
    print("Got event:", event)

    result: Dict[str, Any]
    method = event["httpMethod"].upper()

    if method == 'GET':
        result = get(event)
    else:
        result = {
            "statusCode": 405,
            "body": {
                "error": "Method Not Allowed"
            }
        }

    response = {
        **result,
        "isBase64Encoded": False,
    }

    return json.dumps(response)
