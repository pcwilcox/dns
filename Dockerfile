FROM alpine:3.18.3

LABEL org.opencontainers.image.authors="Pete Wilcox <pete@pcwilcox.com>"
LABEL org.opencontainers.image.url="https=//hub.docker.com/r/pcwilcox/dns"
LABEL org.opencontainers.image.documentation="https=//github.com/pcwilcox/dns/wiki"
LABEL org.opencontainers.image.source="https=//github.com/pcwilcox/dns"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.ref.name="dns"
LABEL org.opencontainers.image.title="DNS"
LABEL org.opencontainers.image.description="Recursive, caching DNS resolver using dnsmasq and Unbound"
LABEL org.opencontainers.image.base.digest="sha256=7e01a0d0a1dcd9e539f8e9bbd80106d59efbdf97293b3d38f5d7a34501526cdb"
LABEL org.opencontainers.image.base.name="hub.docker.com/alpine/alpine:3.18.3"

ENV ROOT_HINT https://www.internic.net/domain/named.cache
ENV NO_BLOCKLIST 0

# Install syslog, unbound and dnsmasq
RUN apk update \
 && apk add --no-cache \
    "unbound>=1.17" \
    "dnsmasq>=2.89" \
    "dnsmasq-dnssec>=2.89" \
    "logrotate>=3.21" \
 && apk cache clean \
 && mkdir -p /config/unbound /config/dnsmasq /config/hosts /config/block

COPY logrotate.conf /etc/logrotate.d/dns.conf
COPY resolv.conf /etc/resolv.conf
COPY unbound.conf /etc/unbound/unbound.conf
COPY dnsmasq.conf /etc/dnsmasq.conf
COPY entrypoint.sh /entrypoint.sh

VOLUME /config

EXPOSE 53

ENTRYPOINT [ "/entrypoint.sh" ]
