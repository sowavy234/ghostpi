FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
    python3 python3-pip \
    device-tree-compiler \
    plymouth plymouth-themes \
    imagemagick \
    git \
    qemu-user-static \
    binfmt-support \
    dosfstools \
    fdisk \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build
