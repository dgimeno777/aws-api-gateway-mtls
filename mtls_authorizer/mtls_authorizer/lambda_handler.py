from loguru import logger
from cryptography.x509.ocsp import OCSPCertStatus
from .ocsp import get_ocsp_cert_status
from .iam import IAMPolicyEffect, IAM_POLICY_VERSION


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
    event_client_cert_pem = event["requestContext"]["identity"]["clientCert"]["clientCertPem"]

    # Get OCSP status
    client_cert_status = get_ocsp_cert_status(event_client_cert_pem)

    # Get auth_policy effect permission
    auth_policy_effect = IAMPolicyEffect.ALLOW if client_cert_status is OCSPCertStatus.GOOD else IAMPolicyEffect.DENY

    # Construct auth policy for return
    auth_policy = {
        "policyDocument": {
            "Version": IAM_POLICY_VERSION,
            "Statement": [
                {
                    "Action": "execute-api:Invoke",
                    "Effect": auth_policy_effect.value,
                    "Resource": event_method_arn,
                }
            ]
        }
    }

    return auth_policy
