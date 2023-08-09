#!/bin/sh
/bin/mkdir -p /config/unbound /config/hosts /config/dnsmasq
/usr/bin/wget $ROOT_HINT -O /etc/unbound/root.hints
[ $NO_BLOCKLIST ] || /usr/bin/wget https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts -O /config/hosts/StevenBlack
/usr/sbin/unbound-anchor -a "/etc/unbound/root.key"
/usr/sbin/dnsmasq --test || exit 1
/usr/sbin/unbound-checkconf || exit 1
/usr/sbin/unbound -c /etc/unbound/unbound.conf
/usr/sbin/dnsmasq
/usr/bin/tail -F /config/dns.log
