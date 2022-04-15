from loguru import logger

# Constants
AUTH_POLICY_VERSION = "2012-10-17"


def lambda_handler(event, context):
    """
    Handles an AWS Lambda request
    :param event: the event
    :param context: the context
    """
    logger.info(f"Event: {event}")
    logger.info(f"Context: {context}")

    # Get method path of event
    event_method_arn = event["methodArn"]

    # Construct auth policy for return
    auth_policy = {
        "policyDocument": {
            "Version": AUTH_POLICY_VERSION,
            "Statement": [
                {
                    "Action": "execute-api:Invoke",
                    "Effect": "Allow",
                    "Resource": event_method_arn,
                }
            ]
        }
    }

    return auth_policy
