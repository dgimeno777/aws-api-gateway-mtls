FROM amazonlinux as mtls_authorizer

# Update image and install dependencies
RUN yum update -y \
 && yum install -y \
    git shadow-utils tar gcc gcc-c++ glibc-devel make zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel \
    openssl11-devel tk-devel libffi-devel xz-devel python python-devel g++

# Add non-root user
RUN useradd lambda
USER lambda

# Set workdir
WORKDIR /home/lambda

# Install pyenv
ENV HOME /home/lambda
ENV PYENV_ROOT $HOME/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH
RUN git clone https://github.com/pyenv/pyenv.git $HOME/.pyenv

# Install python & upgrade
RUN pyenv install 3.10.3
RUN pyenv global 3.10.3
RUN pip install --upgrade pip

# Install poetry
RUN pip install poetry

# Copy poetry files
COPY ./mtls_authorizer/pyproject.toml ./
COPY ./mtls_authorizer/poetry.lock ./

# Install python dependencies
RUN poetry config virtualenvs.create false \
 && poetry install --no-interaction

# Copy lambda files
ADD https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie-arm64 ./aws-lambda-rie
COPY ./mtls_authorizer/lambda_entry_script.sh ./

# Copy function code
COPY ./mtls_authorizer/mtls_authorizer/ ./mtls_authorizer/

# Recursive 755 permissions
USER root
RUN chmod -R 755 ./
USER lambda

# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
ENTRYPOINT [ "./lambda_entry_script.sh"]
