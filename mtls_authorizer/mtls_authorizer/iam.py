from enum import Enum

IAM_POLICY_VERSION = "2012-10-17"


class IAMPolicyEffect(Enum):
    """ IAM Policy Effect Enum """
    ALLOW = "Allow"
    DENY = "Deny"
