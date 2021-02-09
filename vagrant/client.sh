export DEBIAN_FRONTEND=noninteractive
# Startup commands go here

sudo ip addr add 192.168.1.2/30 dev enp0s8
sudo ip link set dev enp0s8 up

sudo ip route add 192.168.2.0/30 via 192.168.1.1

# XORG installation
sudo apt-get update
sudo apt-get -y install xorg

# Google Chrome installations
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - 
sudo sh -c 'echo "deb https://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
sudo apt-get update
sudo apt-get -y install google-chrome-stable
sudo apt-get -y install firefox # to be removed

# (Google) Lighthouse installation
sudo apt-get -y install nodejs npm
sudo npm install n -g
sudo n stable
sudo npm install -g lighthouse