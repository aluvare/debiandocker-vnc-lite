FROM debian:stable AS debian-amd64-builder
RUN DEBIAN_FRONTEND=noninteractive apt update
RUN DEBIAN_FRONTEND=noninteractive apt -y install make git wget curl gcc g++

RUN cd /tmp && \
	wget https://go.dev/dl/go1.20.1.linux-amd64.tar.gz && \
	tar -C /usr/local -xzf go1.20.1.linux-amd64.tar.gz && \
	export PATH=$PATH:/usr/local/go/bin

ARG wg_go_tag=0.0.20220316
ARG wg_tools_tag=v1.0.20210914

RUN git clone https://git.zx2c4.com/wireguard-go && \
    cd wireguard-go && \
    git checkout $wg_go_tag && \
    export PATH=$PATH:/usr/local/go/bin && \
    make && \
    make install

ENV WITH_WGQUICK=yes
RUN git clone https://git.zx2c4.com/wireguard-tools && \
    cd wireguard-tools && \
    git checkout $wg_tools_tag && \
    cd src && \
    make && \
    make install

FROM debian:stable AS debian-arm64-builder
RUN DEBIAN_FRONTEND=noninteractive apt update
RUN DEBIAN_FRONTEND=noninteractive apt -y install make git wget curl gcc g++

RUN cd /tmp && \
	wget https://go.dev/dl/go1.20.1.linux-arm64.tar.gz && \
	tar -C /usr/local -xzf go1.20.1.linux-arm64.tar.gz && \
	export PATH=$PATH:/usr/local/go/bin

ARG wg_go_tag=0.0.20220316
ARG wg_tools_tag=v1.0.20210914

RUN git clone https://git.zx2c4.com/wireguard-go && \
    cd wireguard-go && \
    git checkout $wg_go_tag && \
    export PATH=$PATH:/usr/local/go/bin && \
    make && \
    make install

ENV WITH_WGQUICK=yes
RUN git clone https://git.zx2c4.com/wireguard-tools && \
    cd wireguard-tools && \
    git checkout $wg_tools_tag && \
    cd src && \
    make && \
    make install

FROM debian:stable AS debian-amd64
COPY --from=debian-amd64-builder /usr/bin/wireguard-go /usr/bin/wg* /usr/bin/

FROM debian:stable AS debian-arm64
COPY --from=debian-arm64-builder /usr/bin/wireguard-go /usr/bin/wg* /usr/bin/

FROM debian-${TARGETARCH} AS final
RUN DEBIAN_FRONTEND=noninteractive apt update
RUN DEBIAN_FRONTEND=noninteractive apt -y install xfce4 supervisor jq curl chromium vim sudo tigervnc-standalone-server dbus-x11 docker.io

RUN adduser --disabled-password --gecos '' user
RUN usermod -a -G sudo,docker user

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN chsh -s /bin/bash

RUN mkdir -p /scripts /etc/wireguard
ADD supervisor.conf.d/ /etc/supervisor/conf.d/
ADD launcher.sh /scripts/launcher.sh
RUN touch /root/.ICEauthority && chown user.user /root/.ICEauthority

WORKDIR /home/user

ENV SHELL=/bin/bash

RUN sed -i "s/allowed_users*/allowed_users = anybody/g" /etc/X11/Xwrapper.config
HEALTHCHECK --interval=30s --timeout=5s CMD nc -vz 127.0.0.1 5900

ENTRYPOINT bash /scripts/launcher.sh
