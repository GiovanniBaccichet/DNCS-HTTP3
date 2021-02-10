export DEBIAN_FRONTEND=noninteractive

# Installing OpenVSwitch

apt-get update
apt-get install -y tcpdump
apt-get install -y openvswitch-common openvswitch-switch apt-transport-https ca-certificates curl software-properties-common

# Startup commands for switch go here

sudo ovs-vsctl add-br switch

sudo ovs-vsctl add-port switch enp0s8
sudo ovs-vsctl add-port switch enp0s9
sudo ovs-vsctl add-port switch enp0s10

sudo ip link set dev enp0s8 up
sudo ip link set dev enp0s9 up
sudo ip link set dev enp0s10 up