FROM alpine:latest

# Install deps
RUN apk add --no-cache \
    coredns \
    grep \
    iproute2 \
    iptables \
    ip6tables \
    iputils \
    net-tools \
    nftables \
    openresolv \
    wireguard-tools \
    libcap-utils \
    kmod \
    curl \
    ca-certificates \
    gcc \
    make \
    musl-dev \
    jq

# Fix src_valid_mark error
RUN sed -i 's|\[\[ $proto == -4 \]\] && cmd sysctl -q net\.ipv4\.conf\.all\.src_valid_mark=1|[[ $proto == -4 ]] \&\& [[ $(sysctl -n net.ipv4.conf.all.src_valid_mark) != 1 ]] \&\& cmd sysctl -q net.ipv4.conf.all.src_valid_mark=1|' /usr/bin/wg-quick

# Install and build microsocks
RUN curl -fsSL https://github.com/rofl0r/microsocks/archive/refs/heads/master.tar.gz | tar xz \
    && cd microsocks-master && make && make install \
    && cd .. && rm -rf microsocks-master

# Install latest wgcf from github
ARG TARGETARCH
RUN echo "BUILD ARCH TARGET: $TARGETARCH"
RUN LATEST_VERSION=$(curl -s https://api.github.com/repos/ViRb3/wgcf/releases/latest | jq -r .tag_name | sed 's/v//') && \
    if [ "$TARGETARCH" = "arm64" ]; then ARCH="arm64"; else ARCH="amd64"; fi && \
    curl -fsSL "https://github.com/ViRb3/wgcf/releases/download/v${LATEST_VERSION}/wgcf_${LATEST_VERSION}_linux_${ARCH}" -o /usr/local/bin/wgcf && \
    chmod +x /usr/local/bin/wgcf

# Cleanup
RUN apk del gcc make musl-dev jq

# Setup working directory
WORKDIR /data

# Copy config
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Port
EXPOSE 1080

# RUN
ENTRYPOINT ["/entrypoint.sh"]
