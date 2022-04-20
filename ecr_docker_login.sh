#!/bin/bash

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
ENV_FILEPATH=$SCRIPT_DIR/.env

# Load .env if it exists
if [ -f $ENV_FILEPATH ]
then
    echo "Using .env file environment variables"
    source $ENV_FILEPATH
fi

aws ecr get-login-password --region ${AWS_REGION} --profile aws_api_gateway_mtls | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
