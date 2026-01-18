# WARP Proxy Alpine

[![Docker Pulls](https://img.shields.io/docker/pulls/adierebel/warp-proxy)](https://hub.docker.com/r/adierebel/warp-proxy/tags)

## Usage

### Start the container

To run the WARP client in Docker, just write the following content to `docker-compose.yml` and run `docker-compose up -d`.

```yaml
version: "3"

services:
  warp:
    image: adierebel/warp-proxy
    container_name: warp
    restart: always
    device_cgroup_rules:
      - 'c 10:200 rwm'
    ports:
      - "1080:1080" # [host]:[container]
    cap_add:
      - MKNOD
      - AUDIT_WRITE
      - NET_ADMIN
    sysctls:
      - net.ipv6.conf.all.disable_ipv6=0
      - net.ipv4.conf.all.src_valid_mark=1
    volumes:
      - ./warp-config:/data
```

Try it out to see if it works:

```bash
curl --socks5-hostname 127.0.0.1:1080 https://cloudflare.com/cdn-cgi/trace
```

If the output contains `warp=on`, the container is working properly. If the output contains `warp=off`, it means that the container failed to connect to the WARP service.
