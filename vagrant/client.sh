export DEBIAN_FRONTEND=noninteractive
# Startup commands go here

sudo ip addr add 192.168.1.2/30 dev enp0s8
sudo ip link set dev enp0s8 up

sudo ip route add 192.168.2.0/30 via 192.168.1.1