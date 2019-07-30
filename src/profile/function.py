import json
import os
from typing import Dict, Any
from tablestore import OTSClient

RawEvent = str
Event = Dict[str, Any]
Context = Any

OTS_ENDPOINT = os.environ["OTS_ENDPOINT"]
OTS_INSTANCE_NAME = os.environ["OTS_INSTANCE_NAME"]
OTS_TABLE_NAME = os.environ["OTS_TABLE_NAME"]


def get(client: OTSClient, user_id: str) -> Dict[str, Any]:
    primary_key = [("id", user_id)]
    _, row, _ = client.get_row(OTS_TABLE_NAME, primary_key, [])
    if row:
        return {"statusCode": 200, "body": extract_row(row)}
    else:
        return not_found()


def handler(raw_event: RawEvent, context: Context) -> str:
    print("Got event:", raw_event)

    event = json.loads(raw_event)

    client = OTSClient(
        OTS_ENDPOINT,
        context.credentials.access_key_id,
        context.credentials.access_key_secret,
        OTS_INSTANCE_NAME,
        sts_token=context.credentials.security_token
    )

    result: Dict[str, Any]
    method = event["httpMethod"].upper()

    if method == "GET":
        result = get(client, event["headers"]["X-User-Id"])
    else:
        result = {"statusCode": 405, "body": {"error": "Method Not Allowed"}}

    response = {**result, "isBase64Encoded": False}

    return json.dumps(response)


def extract_row(row: Any) -> Dict[str, Any]:
    result = {}

    for pk in row.primary_key:
        result[pk[0]] = pk[1]

    for att in row.attribute_columns:
        result[att[0]] = att[1]

    return result


def not_found() -> Dict[str, Any]:
    return {"statusCode": 404}
