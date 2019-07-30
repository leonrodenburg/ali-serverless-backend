import json
from typing import Dict, Any

Event = Dict[str, Any]
Context = Dict[str, Any]


def handler(event: Event) -> str:
    print("Got event:", event)

    response = {
        "isBase64Encoded": False,
        "statusCode": 200,
        "body": {
            "success": True
        }
    }

    return json.dumps(response)
