#!/bin/bash

usage(){
    echo "$@"
}

if [ $EUID -ne 0 ]; then
  usage "Must run as root!"
  exit 1
fi

init_iface(){
  echo "Bringing interface $2 up with address 10.0.0.1/24"
  ifconfig $2 up 10.0.0.1 netmask 255.255.255.0
}

nat_setting(){
  iptables --flush
  iptables --table nat --flush
  iptables --delete-chain
  iptables --table nat --delete-chain
  iptables --table nat --append POSTROUTING --out-interface $1 -j MASQUERADE
  iptables --append FORWARD --in-interface $2 -j ACCEPT
}

ip_forward(){
  sysctl -w net.ipv4.ip_forward=1
}

DNSMASQ_CONF="/home/ric/virtual-ap/dnsmasq.conf"
DNSMASQ_PID_FILE="/home/ric/virtual-ap/dnsmasq.pid"
HOSTAPD_CONF="/home/ric/virtual-ap/hostapd.conf"
HOSTAPD_PID_FILE="/home/ric/virtual-ap/hostapd.pid"

nmcli nm wifi off
rfkill unblock wlan
init_iface $@
[ -z "$(ps -e|grep dnsmasq)" ] && killall dnsmasq
[ -f $DNSMASQ_PID_FILE ] && \
        echo "dnsmasq already running" || \
        dnsmasq -C $DNSMASQ_CONF -x $DNSMASQ_PID_FILE

nat_setting $@
ip_forward
[ -f $HOSTAPD_PID_FILE ] && \
	echo "hostapd already running" || \
	hostapd -B -P $HOSTAPD_PID_FILE $HOSTAPD_CONF
