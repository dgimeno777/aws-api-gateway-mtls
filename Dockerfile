FROM amazonlinux:latest

# Update image and install dependencies
RUN yum update -y\
 && yum install -y shadow-utils zlib zlib-devel bzip2-devel openssl-devel sqlite-devel readline-devel




COPY ./mtls_authorizer/pyproject.toml ${LAMBDA_TASK_ROOT}
COPY ./mtls_authorizer/poetry.toml ${LAMBDA_TASK_ROOT}

RUN poetry config virtualenvs.in-project false \
 && poetry install --no-interaction

# Copy function code
COPY ./mtls_authorizer/mtls_authorizer/ ${LAMBDA_TASK_ROOT}

# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
CMD [ "app.handler" ]