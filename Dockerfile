FROM ubuntu:22.04

ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV DEBIAN_FRONTEND=noninteractive

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
    libsqlite3-dev \
    software-properties-common \
    vim


RUN add-apt-repository ppa:deadsnakes/ppa

RUN apt install python3.9-dev -y

RUN apt install -y python3-pip \
    python3.9-distutils

RUN python3.9 -m pip install --upgrade pip

RUN python3.9 --version

RUN curl -LO "https://github.com/bazelbuild/bazelisk/releases/download/v1.18.0/bazelisk-linux-amd64" \
    && chmod +x ./bazelisk-linux-amd64 \
    && mv ./bazelisk-linux-amd64 /usr/local/bin/bazel





