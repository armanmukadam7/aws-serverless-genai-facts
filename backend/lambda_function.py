import os
import boto3  # pyright: ignore[reportMissingImports]
import random
import json

# Fetch environment variables set by Terraform with fallback defaults
TABLE_NAME = os.environ.get("TABLE_NAME", "CloudFacts")
BEDROCK_MODEL_ID = os.environ.get(
    "BEDROCK_MODEL_ID", "anthropic.claude-3-5-sonnet-20240620-v1:0"
)

# Initialize DynamoDB resource and Bedrock runtime client
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(TABLE_NAME)
bedrock = boto3.client("bedrock-runtime")


def lambda_handler(event, context):
    # Fetch all facts from DynamoDB
    response = table.scan()
    items = response.get("Items", [])

    if not items:
        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "GET, OPTIONS",
                "Access-Control-Allow-Headers": "Content-Type",
            },
            "body": json.dumps({"fact": "No facts available in DynamoDB."}),
        }

    # Select a base fact at random
    fact = random.choice(items)["FactText"]

    # Construct a model-agnostic Bedrock Converse request.
    messages = [
        {
            "role": "user",
            "content": [{
                "text": (
                    "Take this cloud computing fact and make it fun and engaging in "
                    f"1-2 sentences maximum. Keep it short and witty: {fact}"
                )
            }],
        }
    ]

    try:
        resp = bedrock.converse(
            modelId=BEDROCK_MODEL_ID,
            messages=messages,
            inferenceConfig={"maxTokens": 100, "temperature": 0.7},
        )

        content = resp.get("output", {}).get("message", {}).get("content", [])
        witty_fact = next(
            (block["text"].strip() for block in content if block.get("text")),
            "",
        )

        if not witty_fact or len(witty_fact) > 300:
            witty_fact = fact
            generated_by = "dynamodb-fallback"
        else:
            generated_by = "bedrock"

    except Exception as e:
        print(f"Bedrock error: {e}")
        witty_fact = fact
        generated_by = "dynamodb-fallback"

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "GET, OPTIONS",
            "Access-Control-Allow-Headers": "Content-Type",
        },
        "body": json.dumps({"fact": witty_fact, "generatedBy": generated_by}),
    }