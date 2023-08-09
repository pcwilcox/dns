# Docker dns

Simple DNS server in Docker using dnsmasq and Unbound.

## Why?

dnsmasq is great for its performance, especially its caching. Adding Unbound as a recursive resolver helps improve security. Read more [here](https://docs.pi-hole.net/guides/dns/unbound/).

## Usage

The container works out of the box with some sensible default settings. dnsmasq is deployed on port 53 and set to use Unbound as its upstream resolver.

### docker cli

```sh
docker create \
    --name=dns \
    -p 53:53 \
    -v </path/to/config>:/config \
    pcwilcox/dns:latest
```

### docker compose

```yml
---
version: "3.8"
services:
    dns:
        image: pcwilcox/dns:latest
        container_name: dns
        volumes:
            - /path/to/config:/config # Optional, used for config customization
        ports:
            - 53:53 # DNS port
        restart: unless-stopped
```

## Configuration

The container looks in the (optional) `/config` directory for user-supplied files as detailed below.

### Unbound

Unbound will include `*.conf` files from `/config/unbound` at launch. Read the [documentation](https://unbound.docs.nlnetlabs.nl/en/latest/) for details on how to do this. By default the container will use the following config:

```conf
server:
    use-syslog: no
    username: root
    prefetch: yes
    serve-expired: yes
    serve-expired-ttl: 86400
    serve-expired-client-timeout: 1800
    log-queries: yes
    do-ip6: no
    prefer-ip6: no
    use-caps-for-id: no
    tls-cert-bundle: /etc/ssl/certs/ca-certificates.crt
    port: 5335
    interface-automatic: yes
    trust-anchor-file: /etc/unbound/root.key
    auto-trust-anchor-file: /etc/unbound/root.key
    root-hints: /etc/unbound/root.hints
    chroot: ""

include: "/config/unbound/*.conf"
```

### dnsmasq

dnsmasq will include `*.conf` files from `/config/dnsmasq` at launch. Read the [documentation](https://dnsmasq.org/docs/dnsmasq-man.html) for details on how to do this. By default it uses the following config:

```conf
port=53
domain-needed
bogus-priv
dnssec
conf-file=/usr/share/dnsmasq/trust-anchors.conf
dnssec-check-unsigned
no-resolv
server=localhost#5335
expand-hosts
cache-size=1000
log-queries
conf-dir=/config/dnsmasq/
log-async=25
log-facility=/config/dns.log
user=root
group=root
addn-hosts=/config/hosts/
```

## Hosts and ad blocking

dnsmasq will look in `/config/hosts` for additional [hosts files](https://www.man7.org/linux/man-pages/man5/hosts.5.html) and use them for DNS resolution. You can place hard-coded host entries here, and you can also place adblock lists here to enable ad blocking. By default, the container will download a sensible default adblock list from [Stephen Black](https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts) - this can be disabled by setting the environment variable `NO_BLOCKLIST=1` when running the container.

## Logging

Both unbound and dnsmasq output to `/config/dns.log` and logrotate has been configured to rotate it daily.
