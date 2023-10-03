#FROM quay.io/pypa/manylinux_2_28_x86_64
FROM python:3.9-slim


RUN  apt-get update && apt-get install -y \
    clang \
    curl \
    git \
    vim \
    build-essential \
    libffi-dev \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev

# Install pyenv
RUN curl https://pyenv.run | bash

# Set environment variables for pyenv
ENV PYENV_ROOT /root/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH

# Install multiple versions of Python
#RUN pyenv install 3.11
#RUN pyenv install 3.10
#RUN pyenv install 3.9
#RUN pyenv global 3.9

# Confirm installation
RUN python --version
RUN pyenv versions
RUN curl -LO "https://github.com/bazelbuild/bazelisk/releases/download/v1.18.0/bazelisk-linux-amd64" \
    && chmod +x ./bazelisk-linux-amd64 \
    && mv ./bazelisk-linux-amd64 /usr/local/bin/bazel



