FROM alpine:latest

# Install deps
RUN apk add --no-cache \
    wireguard-tools \
    wireguard-go \
    curl \
    ca-certificates \
    gcc \
    make \
    musl-dev

# Microsocks
RUN curl -fsSL https://github.com/rofl0r/microsocks/archive/refs/heads/master.tar.gz | tar xz \
    && cd microsocks-master \
    && make \
    && make install \
    && cd .. && rm -rf microsocks-master \
    && apk del gcc make musl-dev

# Install WGCF from github
RUN curl -fsSL https://github.com/ViRb3/wgcf/releases/download/v2.2.30/wgcf_2.2.30_linux_amd64 -o /usr/local/bin/wgcf \
    && chmod +x /usr/local/bin/wgcf

# Setup working directory
WORKDIR /data

# Copy config
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Port
EXPOSE 1080

# RUN
ENTRYPOINT ["/entrypoint.sh"]
