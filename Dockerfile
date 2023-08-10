FROM alpine:3.18.3

LABEL org.opencontainers.image.authors="Pete Wilcox <pete@pcwilcox.com>" \
      org.opencontainers.image.url="https://hub.docker.com/r/pcwilcox/dns" \
      org.opencontainers.image.documentation="https://github.com/pcwilcox/dns" \
      org.opencontainers.image.source="https://github.com/pcwilcox/dns" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.ref.name="dns" \
      org.opencontainers.image.title="DNS" \
      org.opencontainers.image.description="Recursive, caching DNS resolver using dnsmasq and Unbound" \
      org.opencontainers.image.base.digest="sha256=7e01a0d0a1dcd9e539f8e9bbd80106d59efbdf97293b3d38f5d7a34501526cdb" \
      org.opencontainers.image.base.name="hub.docker.com/alpine/alpine:3.18.3"

ENV ROOT_URL=https://www.internic.net/domain/named.cache \
   NO_BLOCKLIST=0 \
   TEST=0

# Install unbound, dnsmasq, and utilities
RUN apk update \
 && apk add --no-cache \
    "unbound>=1.17" \
    "dnsmasq>=2.89" \
    "dnsmasq-dnssec>=2.89" \
    "logrotate>=3.21" \
    "bind-tools>=9.18.16" \
 && apk cache clean \
 && mkdir -p /config/unbound /config/dnsmasq /config/hosts

COPY logrotate.conf /etc/logrotate.d/dns.conf
COPY resolv.conf /etc/resolv.conf
COPY unbound.conf /etc/unbound/unbound.conf
COPY dnsmasq.conf /etc/dnsmasq.conf
COPY entrypoint.sh /entrypoint.sh

VOLUME /config

EXPOSE 53

ENTRYPOINT [ "/entrypoint.sh" ]
