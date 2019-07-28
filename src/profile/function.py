import json


def handler(event, context):
    print("Got event:", event)

    response = {
        "isBase64Encoded": False,
        "statusCode": 200,
        "body": {
            "success": True
        }
    }

    return json.dumps(response)
