#!/bin/sh

/usr/sbin/unbound-anchor -a "/etc/unbound/root.key"
/usr/sbin/dnsmasq --test || exit 1
/usr/sbin/unbound-checkconf || exit 1
/usr/sbin/unbound
/usr/sbin/dnsmasq
