# debiandocker-vnc-lite

debiandocker-vnc-lite is a Docker image to provide a VNC interface to access Debian XFCE desktop environment. (Forked from kalidocker-vnc-lite)

## Quick Start

Run the docker container and access with port using VNC `5900`

```shell
docker run -it -p 5900:5900 ghcr.io/aluvare/debiandocker-vnc-lite/debiandocker-vnc-lite
```

## Using web access

Run this docker-compose file and access using a browser to the port 8080

```
version: "2.3"
services:
  debian:
    image: ghcr.io/aluvare/debiandocker-vnc-lite/debiandocker-vnc-lite
    restart: always
    healthcheck:
      interval: 10s
      retries: 12
      test: nc -vz 127.0.0.1 5900
  novnc:
    image: ghcr.io/aluvare/easy-novnc/easy-novnc
    restart: always
    depends_on:
      - debian
    command: --addr :8080 --host debian --port 5900 --basic-ui --no-url-password --novnc-params "resize=remote"
    ports:
      - "8080:8080"
```

## Using docker inside the desktop

First of all, you need to install `https://github.com/nestybox/sysbox` in the docker host.
 
After that, you need to add this line to the debian docker-compose config:

```
    runtime: sysbox-runc
    environment:
      - "DOCKER=true"
```
