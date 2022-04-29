FROM python:3.10-slim as mtls_authorizer

# Update image and install dependencies
RUN apt-get update -y \
 && apt-get install -y \
    openssl libssl-dev\
 && apt-get update -y

# Install pyenv
ENV HOME /src/

# Set workdir
RUN mkdir $HOME
WORKDIR $HOME

# Install poetry
RUN pip install --upgrade pip \
 && pip install poetry

# Copy poetry files
COPY pyproject.toml poetry.lock ./

# Install python dependencies
RUN poetry config virtualenvs.create false \
 && poetry install --no-interaction

# Copy lambda files
ADD https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie ./aws-lambda-rie
COPY lambda_entry_script.sh ./

# Copy function code
COPY mtls_authorizer ./mtls_authorizer/

# Recursive 755 permissions
RUN chmod -R 755 ./

# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
ENTRYPOINT [ "./lambda_entry_script.sh"]
