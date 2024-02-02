#!/bin/bash

# Define bridge names
BRIDGES=("nokia-br-dummy" "nokia-br-11" "nokia-br-12" "nokia-br-13" "nokia-br-14" "nokia-br-21" "nokia-br-22" "nokia-br-23" "nokia-br-24")

# Function to create bridges
create_bridges() {
    for br in "${BRIDGES[@]}"; do
        echo "Creating bridge $br"
        ip link add name "$br" type bridge
        ip link set "$br" up
        ip link set dev "$br" mtu 9000  # Set to maximum MTU
    done
}

# Function to destroy bridges
destroy_bridges() {
    for br in "${BRIDGES[@]}"; do
        echo "Destroying bridge $br"
        ip link set "$br" down
        ip link delete "$br" type bridge
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
