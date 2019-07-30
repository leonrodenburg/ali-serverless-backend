import json
import os
from typing import Dict, Any
from tablestore import OTSClient

RawEvent = str
Event = Dict[str, Any]
RawContext = str
Context = Dict[str, Any]

OTS_ENDPOINT = os.environ["OTS_ENDPOINT"]
OTS_INSTANCE_NAME = os.environ["OTS_INSTANCE_NAME"]
OTS_TABLE_NAME = os.environ["OTS_TABLE_NAME"]


def get(client: OTSClient, user_id: str) -> Dict[str, Any]:
    primary_key = [("userId", user_id)]
    _, row, _ = client.get_row(OTS_TABLE_NAME, primary_key, [])
    if row:
        return {"statusCode": 200, "body": row.attribute_columns}
    else:
        return not_found()


def handler(raw_event: RawEvent, raw_context: RawContext) -> str:
    print("Got event:", raw_event)
    print("Got context:", raw_context)

    event = json.loads(raw_event)
    context = json.loads(raw_context)

    client = OTSClient(
        OTS_ENDPOINT,
        context["credentials"]["accessKeyId"],
        context["credentials"]["accessKeySecret"],
        OTS_INSTANCE_NAME,
    )

    result: Dict[str, Any]
    method = event["httpMethod"].upper()

    if method == "GET":
        result = get(client, event["headers"]["X-User-Id"])
    else:
        result = {"statusCode": 405, "body": {"error": "Method Not Allowed"}}

    response = {**result, "isBase64Encoded": False}

    return json.dumps(response)


def not_found() -> Dict[str, Any]:
    return {"statusCode": 404}
