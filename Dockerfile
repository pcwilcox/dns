FROM alpine:3.18.3

LABEL org.opencontainers.image.authors="Pete Wilcox <pete@pcwilcox.com>"
LABEL org.opencontainers.image.url="https://hub.docker.com/r/pcwilcox/dns"
LABEL org.opencontainers.image.documentation="https://github.com/pcwilcox/dns/wiki"
LABEL org.opencontainers.image.source="https://github.com/pcwilcox/dns"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.ref.name="dns"
LABEL org.opencontainers.image.title="DNS"
LABEL org.opencontainers.image.description="Recursive, caching DNS resolver using dnsmasq and Unbound"
LABEL org.opencontainers.image.base.digest="sha256:7e01a0d0a1dcd9e539f8e9bbd80106d59efbdf97293b3d38f5d7a34501526cdb"
LABEL org.opencontainers.image.base.name="hub.docker.com/alpine/alpine:3.18.3"



# Install unbound and dnsmasq
RUN apk update \
 && apk add --no-cache \
    "unbound>=1.17" \
    "dnsmasq>=2.89" \
    "dnsmasq-dnssec>=2.89" \
 && apk cache clean \
 && mkdir -p /etc/unbound/unbound.conf.d \
 && mkdir -p /etc/dnsmasq.d

# Download root hints
ADD https://www.internic.net/domain/named.cache /etc/unbound/root.hints

COPY unbound.conf /etc/unbound/unbound.conf
COPY dnsmasq.conf /etc/dnsmasq.conf
COPY entrypoint.sh /entrypoint.sh
COPY resolv.conf /etc/resolv.conf

VOLUME /etc/unbound/unbound.conf.d/
VOLUME /etc/dnsmasq.d/


ENTRYPOINT [ "/entrypoint.sh" ]
