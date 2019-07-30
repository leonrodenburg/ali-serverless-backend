import json
from typing import Dict, Any

RawEvent = str
Event = Dict[str, Any]
Context = Dict[str, Any]


def get(event: Event) -> Dict[str, Any]:
    return {
        "statusCode": 200,
        "body": {
            "success": True
        }
    }


def handler(raw_event: RawEvent, context: Context) -> str:
    print("Got event:", raw_event)

    event = json.loads(raw_event)

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
