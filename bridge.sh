#!/bin/bash

# Define bridge names
BRIDGES=("nokia-br-dummy1" "nokia-br-dummy2" "nokia-br-dummy3" "nokia-br-dummy4" "nokia-br-11" "nokia-br-12" "nokia-br-13" "nokia-br-14" "nokia-br-21" "nokia-br-22" "nokia-br-23" "nokia-br-24")

# Function to create bridges and update iptables and ip6tables
create_bridges() {
    # Set default policies to ACCEPT for iptables and ip6tables
    iptables -P INPUT ACCEPT
    iptables -P OUTPUT ACCEPT
    iptables -P FORWARD ACCEPT

    ip6tables -P INPUT ACCEPT
    ip6tables -P OUTPUT ACCEPT
    ip6tables -P FORWARD ACCEPT

    for br in "${BRIDGES[@]}"; do
        echo "Creating bridge $br"
        ip link add name "$br" type bridge
        ip link set "$br" up
        ip link set dev "$br" mtu 9000  # Set to maximum MTU

        # Disable multicast snooping on the bridge
        echo 0 > /sys/devices/virtual/net/"$br"/bridge/multicast_snooping
        echo 2 > /sys/devices/virtual/net/"$br"/bridge/multicast_router

        # Disable STP on the bridge
        ip link set dev "$br" type bridge stp_state 0

        # Accept all IPv4 and IPv6 traffic on the bridge
        iptables -I FORWARD -i "$br" -j ACCEPT
        iptables -I FORWARD -o "$br" -j ACCEPT

        ip6tables -I FORWARD -i "$br" -j ACCEPT
        ip6tables -I FORWARD -o "$br" -j ACCEPT
    done
}

# Function to destroy bridges and revert iptables and ip6tables changes
destroy_bridges() {
    for br in "${BRIDGES[@]}"; do
        echo "Destroying bridge $br"
        ip link set "$br" down
        ip link delete "$br" type bridge

        # Revert iptables and ip6tables changes for IPv4 and IPv6
        iptables -D FORWARD -i "$br" -j ACCEPT
        iptables -D FORWARD -o "$br" -j ACCEPT

        ip6tables -D FORWARD -i "$br" -j ACCEPT
        ip6tables -D FORWARD -o "$br" -j ACCEPT
    done
}

# Main script logic
case $1 in
    deploy)
        create_bridges
        ;;
    destroy)
        destroy_bridges
        ;;
    *)
        echo "Usage: $0 {deploy|destroy}"
        exit 1
        ;;
esac

exit 0
