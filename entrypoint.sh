#!/bin/sh

ROOT_KEY=/etc/unbound/root.key
ROOT_FILE=/etc/unbound/root.hints
BLACK_URL=https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
BLACK_FILE=/config/hosts/StevenBlack

echo "Verifying directories"
for dir in "/config" "/config/unbound" "/config/hosts" "/config/dnsmasq"; do
    if [ -d "$dir" ]; then
        if [ ! -w "$dir" ]; then
            echo "Error: incorrect permissions on $dir" | /usr/bin/tee -a /config/dns.log
            exit 1
        fi
    else
        /bin/mkdir -vp "$dir"
    fi
done

echo "Installing root hints file"
if ! /usr/bin/wget -q "$ROOT_URL" -O "$ROOT_FILE"; then
    echo "Error: problem downloading root hints" | /usr/bin/tee -a /config/dns.log
    exit 1
fi

if [ ! -s "$ROOT_FILE" ]; then
    echo "Error: root.hints not found" | /usr/bin/tee -a /config/dns.log
    exit 1
fi

if [ -z "$NO_BLOCKLIST" ]; then
    echo "Installing blocklist" | /usr/bin/tee -a /config/dns.log
    /usr/bin/wget "$BLACK_URL" -O "$BLACK_FILE"
fi

echo "Creating trust anchor" | /usr/bin/tee -a /config/dns.log
/usr/sbin/unbound-anchor -a "$ROOT_KEY" -r "$ROOT_FILE"

echo "Verifying dnsmasq config" | /usr/bin/tee -a /config/dns.log
if ! /usr/sbin/dnsmasq --test; then
    echo "Error: dnsmasq configuration error" | /usr/bin/tee -a /config/dns.log
    exit 1
fi

echo "Verifying unbound config" | /usr/bin/tee -a /config/dns.log
if ! /usr/sbin/unbound-checkconf; then
    echo "Error: unbound configuration error" | /usr/bin/tee -a /config/dns.log
    exit 1
fi

echo "Checks complete, starting services" | /usr/bin/tee -a /config/dns.log
/usr/sbin/unbound -c /etc/unbound/unbound.conf | /usr/bin/tee -a /config/dns.log

if ! /usr/bin/pgrep unbound >/dev/null; then
    echo "Error running unbound, check logs" | /usr/bin/tee -a /config/dns.log
    exit 1
fi

/usr/sbin/dnsmasq

if ! /usr/bin/pgrep dnsmasq >/dev/null; then
    echo "Error running dnsmasq, check logs" | /usr/bin/tee -a /config/dns.log
    exit 1
fi

if [ -n "$TEST" ]; then
    if ! /usr/bin/dig +short ns @127.0.0.1 -p 5335 . >/dev/null; then
        echo "Error querying unbound" | /usr/bin/tee -a /config/dns.log
        exit 1
    fi
    if ! /usr/bin/dig +short ns @127.0.0.1 -p 53 . >/dev/null; then
        echo "Error querying dnsmasq" | /usr/bin/tee -a /config/dns.log
        exit 1
    fi
    echo "Tests complete" | /usr/bin/tee -a /config/dns.log
    exit 0
fi

/usr/bin/tail -F /config/dns.log
