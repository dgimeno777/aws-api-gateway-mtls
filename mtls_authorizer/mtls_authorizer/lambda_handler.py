import json
from loguru import logger


AUTH_POLICY_VERSION = "2012-10-17"

def lambda_handler(event, context):
    """
    Handles an AWS Lambda request
    :param event: the event
    :param context: the context
    """
    logger.info(f"Event: {event}")
    logger.info(f"Context: {context}")

    auth_policy = {
        "context": context,
        "principalId": "",
        "policyDocument": {
            "Version": AUTH_POLICY_VERSION,
            "Statement": []
        }
    }


    return auth_policy
