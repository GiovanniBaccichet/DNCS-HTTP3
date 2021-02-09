export DEBIAN_FRONTEND=noninteractive
# Startup commands go here

# Networking
sudo ip addr add 192.168.2.4/30 dev enp0s8
sudo ip link set dev enp0s8 up

sudo ip route add 192.168.1.0/30 via 192.168.2.1

# Docker installation
sudo apt-get update
sudo apt-get -y install docker.io
sudo systemctl start docker
sudo systemctl enable docker