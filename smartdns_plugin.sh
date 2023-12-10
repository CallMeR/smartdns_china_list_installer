#!/bin/bash
set -e

WORKDIR="$(mktemp -d)"
CONFDIR="/etc/smartdns.d"
SERVERS=(223.5.5.5 119.29.29.29 114.114.114.114 114.114.115.115)
GROUP=(accelerate)
# Others: 223.6.6.6 119.28.28.28
# Not using best possible CDN pop: 1.2.4.8 210.2.4.8
# Broken?: 180.76.76.76

CONF_WITH_SERVERS=(accelerated-domains.china google.china apple.china)
CONF_WITH_GROUP=(server-group.china)
CONF_SIMPLE=(bogus-nxdomain.china)

echo "Checking whether the configuration folder exists..."
if [ ! -d "$CONFDIR" ]; then
  mkdir -p "$CONFDIR"
fi

echo "Downloading latest configurations..."
git clone --depth=1 https://gitee.com/felixonmars/dnsmasq-china-list.git "$WORKDIR"
#git clone --depth=1 https://pagure.io/dnsmasq-china-list.git "$WORKDIR"
#git clone --depth=1 https://github.com/felixonmars/dnsmasq-china-list.git "$WORKDIR"
#git clone --depth=1 https://bitbucket.org/felixonmars/dnsmasq-china-list.git "$WORKDIR"
#git clone --depth=1 https://gitlab.com/felixonmars/dnsmasq-china-list.git "$WORKDIR"
#git clone --depth=1 https://e.coding.net/felixonmars/dnsmasq-china-list.git "$WORKDIR"
#git clone --depth=1 https://codehub.devcloud.huaweicloud.com/dnsmasq-china-list00001/dnsmasq-china-list.git "$WORKDIR"
#git clone --depth=1 http://repo.or.cz/dnsmasq-china-list.git "$WORKDIR"

echo "Removing old configurations..."
for _conf in "${CONF_WITH_SERVERS[@]}" "${CONF_WITH_GROUP[@]}" "${CONF_SIMPLE[@]}"; do
  rm -f "$CONFDIR/$_conf"*.conf
done

echo "Installing new configurations..."
for _conf in "${CONF_WITH_SERVERS[@]}" "${CONF_WITH_GROUP[@]}" "${CONF_SIMPLE[@]}"; do
  if [[ "${CONF_WITH_SERVERS[@]}" =~ $_conf ]]; then
    sed -En 's|^server=/([^/]*)/114.114.114.114$|\1|p' "$WORKDIR/$_conf.conf" | grep -Ev '^#' > "$WORKDIR/$_conf.step1.raw"
    sed -En "s/(.*)/nameserver \\/\\1\\/${GROUP[@]}/p" "$WORKDIR/$_conf.step1.raw" > "$WORKDIR/$_conf.step2.raw"
    cp "$WORKDIR/$_conf.step2.raw" "$CONFDIR/$_conf.${GROUP[@]}.conf"
  fi

  if [[ "${CONF_WITH_GROUP[@]}" =~ $_conf ]]; then
    for _server in "${SERVERS[@]}"; do
      echo "server $_server -group ${GROUP[@]} -exclude-default-group" >> "$WORKDIR/$_conf.raw"
    done
    cp "$WORKDIR/$_conf.raw" "$CONFDIR/${CONF_WITH_GROUP[@]}.${GROUP[@]}.conf"
  fi

  if [[ "${CONF_SIMPLE[@]}" =~ $_conf ]]; then
    sed -e "s|=| |" "$WORKDIR/$_conf.conf" > "$WORKDIR/$_conf.raw"
    cp "$WORKDIR/$_conf.raw" "$CONFDIR/$_conf.${GROUP[@]}.conf"
  fi
done

echo "Restarting smartdns service..."
if hash systemctl 2>/dev/null; then
  systemctl restart smartdns
elif hash service 2>/dev/null; then
  service smartdns restart
elif hash rc-service 2>/dev/null; then
  rc-service smartdns restart
elif hash busybox 2>/dev/null && [[ -d "/etc/init.d" ]]; then
  /etc/init.d/smartdns restart
else
  echo "Now please restart smartdns since I don't know how to do it."
fi

echo "Cleaning up..."
rm -r "$WORKDIR"

