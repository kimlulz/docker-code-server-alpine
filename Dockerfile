# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-alpine:3.21

# set version label
ARG BUILD_DATE
ARG VERSION
ARG CODE_RELEASE
LABEL build_version="LulzLabs version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="kimlulz"

# environment settings
ENV HOME="/config"

# install runtime dependencies
RUN \
  echo "**** install runtime dependencies ****" && \
  apk update && apk add --no-cache \
    bash \
    curl \
    git \
    libatomic \
    nano \
    net-tools \
    sudo \
    tar && \
  echo "**** install code-server ****" && \
  if [ -z ${CODE_RELEASE+x} ]; then \
    CODE_RELEASE=$(curl -sX GET https://api.github.com/repos/coder/code-server/releases/latest \
      | awk '/tag_name/{print $4;exit}' FS='[""]' | sed 's|^v||'); \
  fi && \
  mkdir -p /app/code-server && \
  curl -o \
    /tmp/code-server.tar.gz -L \
    "https://github.com/coder/code-server/releases/download/v${CODE_RELEASE}/code-server-${CODE_RELEASE}-linux-amd64.tar.gz" && \
  tar xf /tmp/code-server.tar.gz -C \
    /app/code-server --strip-components=1 && \
  printf "LulzLabs version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \
  echo "**** clean up ****" && \
  rm -rf \
    /tmp/* \
    /var/cache/apk/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 8443
