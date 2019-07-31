import json
import base64
import os
from typing import Dict, Any
from tablestore import OTSClient, Row

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


def update(client: OTSClient, user_id: str, data: Dict[str, Any]) -> Dict[str, Any]:
    primary_key = {"id": user_id}
    attributes = {k: v for k, v in data.items() if k != "id"}
    print("Primary key: ", primary_key)
    print("Attributes: ", attributes)
    row = to_row(primary_key, attributes)
    client.put_row(OTS_TABLE_NAME, row)
    return {"statusCode": 200, "body": extract_row(row)}


def handler(raw_event: RawEvent, context: Context) -> str:
    print("Got event:", raw_event)

    event = json.loads(raw_event)

    client = OTSClient(
        OTS_ENDPOINT,
        context.credentials.access_key_id,
        context.credentials.access_key_secret,
        OTS_INSTANCE_NAME,
        sts_token=context.credentials.security_token,
    )

    result: Dict[str, Any]
    method = event["httpMethod"].upper()

    user_id = event["headers"]["X-User-Id"]
    if method == "GET":
        result = get(client, user_id)
    elif method == "POST" or method == "PUT":
        body = event["body"]
        if event["isBase64Encoded"]:
            body = base64.b64decode(body)

        result = update(client, user_id, json.loads(body))
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


def to_row(pk: Dict[str, Any], attr: Dict[str, Any]) -> Row:
    primary_key = [(k, v) for k, v in pk.items()]
    attribute_columns = [(k, v) for k, v in attr.items() if k not in pk]
    return Row(primary_key, attribute_columns=attribute_columns)


def not_found() -> Dict[str, Any]:
    return {"statusCode": 404}
