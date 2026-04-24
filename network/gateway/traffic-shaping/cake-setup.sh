#!/bin/bash
# CAKE QoS — mitigate bufferbloat on the WAN interface
# Adjust BANDWIDTH to slightly below your actual line rate

BANDWIDTH=18Mbit
WAN_INTERFACE="${WAN_INTERFACE:-enp2s0f0}"

modprobe sch_cake
tc qdisc replace dev "$WAN_INTERFACE" root cake bandwidth "$BANDWIDTH" besteffort triple-isolate nat

echo "CAKE applied on $WAN_INTERFACE ($BANDWIDTH)"
tc qdisc show dev "$WAN_INTERFACE"
