#!/bin/bash
if [ -z "${AWS_LAMBDA_RUNTIME_API}" ]; then
  exec /home/lambda/aws-lambda-rie python -m awslambdaric $@
else
  exec python -m awslambdaric $@
fi
