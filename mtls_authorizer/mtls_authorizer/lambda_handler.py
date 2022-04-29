import os
from loguru import logger
from cryptography.x509.ocsp import OCSPCertStatus
from mtls_authorizer.ocsp import get_ocsp_cert_status
from mtls_authorizer.iam import (
    IAMPolicyEffect,
    IAM_POLICY_VERSION,
    generate_request_api_invoke_resource
)


AWS_REGION = os.environ["AWS_REGION"]


def lambda_handler(event, context):
    """
    Handles an AWS Lambda request
    :param event: the event
    :param context: the context
    """
    logger.info(f"Event: {event}")
    logger.info(f"Context: {context}")

    # Get values from event
    event_account_id = event["requestContext"]["accountId"]
    event_api_id = event["requestContext"]["apiId"]
    event_stage = event["requestContext"]["stage"]
    event_client_cert_pem = event["requestContext"]["identity"]["clientCert"]["clientCertPem"]

    # Get OCSP status
    client_cert_status = get_ocsp_cert_status(event_client_cert_pem)

    # Get auth_policy effect permission
    auth_policy_effect = IAMPolicyEffect.ALLOW if client_cert_status is OCSPCertStatus.GOOD else IAMPolicyEffect.DENY

    # Construct auth policy for return
    auth_policy_resource = generate_request_api_invoke_resource(
        aws_region=AWS_REGION,
        aws_account_id=event_account_id,
        api_gateway_id=event_api_id,
        api_gateway_stage=event_stage
    )
    auth_policy = {
        "policyDocument": {
            "Version": IAM_POLICY_VERSION,
            "Statement": [
                {
                    "Action": "execute-api:Invoke",
                    "Effect": auth_policy_effect.value,
                    "Resource": auth_policy_resource,
                }
            ],
        }
    }

    return auth_policy
