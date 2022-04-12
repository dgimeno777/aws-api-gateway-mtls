import json
from loguru import logger


def lambda_handler(event, context):
    """
    Handles an AWS Lambda request
    :param event: the event
    :param context: the context
    """
    logger.info(f"Event: {event}")
    return {
        "statusCode": 200,
        "body": json.dumps("hello response")
    }
