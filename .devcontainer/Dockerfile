FROM alpine:3.21

# Instalar dependencias necesarias
RUN apk update && apk add --no-cache \
    bash \
    curl \
    gcompat \
    git \
    github-cli \
    jq \
    libc6-compat \
    libstdc++ \
    make \
    nodejs \
    npm \
    openssh \
    pre-commit \
    py3-pip \
    unzip \
    && rm -rf /var/cache/apk/*

# Establecer directorio de trabajo
WORKDIR /workspace
