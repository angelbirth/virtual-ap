#!/bin/bash
HOSTAPD_PID_FILE="/home/ric/virtual-ap/hostapd.pid"
DNSMASQ_PID_FILE="/home/ric/virtual-ap/dnsmasq.pid"
if [ -f $HOSTAPD_PID_FILE ]; then
  HOSTAPD_PID=`cat $HOSTAPD_PID_FILE`
  echo "Killing hostapd (PID $HOSTAPD_PID)..."
  kill -9 $HOSTAPD_PID
  rm $HOSTAPD_PID_FILE
fi

if [ -f $DNSMASQ_PID_FILE ]; then
  DNSMASQ_PID=`cat $DNSMASQ_PID_FILE`
  echo "Killing dnsmasq (PID $DNSMASQ_PID)..."
  kill -9 $DNSMASQ_PID
  rm $DNSMASQ_PID_FILE
fi

nmcli nm wifi on
