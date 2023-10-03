FROM quay.io/pypa/manylinux_2_28_x86_64


RUN yum update && yum install -y dnf
RUN yum install -y clang
RUN curl -LO "https://github.com/bazelbuild/bazelisk/releases/download/v1.18.0/bazelisk-linux-amd64" \
    && chmod +x ./bazelisk-linux-amd64 \
    && mv ./bazelisk-linux-amd64 /usr/local/bin/bazel


