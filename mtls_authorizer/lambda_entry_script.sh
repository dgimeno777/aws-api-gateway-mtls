#!/bin/bash
if [ -z "${AWS_LAMBDA_RUNTIME_API}" ]; then
  exec /src/aws-lambda-rie python -m awslambdaric $@
else
  exec python -m awslambdaric $@
fi
