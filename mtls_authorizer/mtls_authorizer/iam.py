from enum import Enum

IAM_POLICY_VERSION = "2012-10-17"


class IAMPolicyEffect(Enum):
    """ IAM Policy Effect Enum """
    ALLOW = "Allow"
    DENY = "Deny"


def generate_request_api_invoke_resource(
    aws_region: str, aws_account_id: str, api_gateway_id: str, api_gateway_stage: str
) -> str:
    """
    Generates an api gateway invoke resource from the given arguments
    :param aws_region: AWS Region
    :param aws_account_id: AWS Account ID
    :param api_gateway_id: API Gateway ID
    :param api_gateway_stage: API Gateway Stage name
    :return: an invoke resource as a string
    """
    return f"arn:aws:execute-api:{aws_region}:{aws_account_id}:{api_gateway_id}/{api_gateway_stage}/*"
