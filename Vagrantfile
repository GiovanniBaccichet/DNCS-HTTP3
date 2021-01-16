# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  config.vm.box_check_update = false
  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--usb", "on"]
    vb.customize ["modifyvm", :id, "--usbehci", "off"]
    vb.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
    vb.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]
    vb.customize ["modifyvm", :id, "--nicpromisc4", "allow-all"]
    vb.customize ["modifyvm", :id, "--nicpromisc5", "allow-all"]
    vb.cpus = 1
  end

  # ROUTER

  config.vm.define "router" do |router1|
    router1.vm.box = "ubuntu/bionic64"
    router1.vm.hostname = "router"
    router1.vm.network "private_network", virtualbox__intnet: "broadcast_router-south", auto_config: false
    router1.vm.network "private_network", virtualbox__intnet: "broadcast_router-inter", auto_config: false
    router1.vm.provision "shell", path: "router.sh"
    router1.vm.provider "virtualbox" do |vb|
      vb.memory = 256
    end
  end

  # SWITCH

  config.vm.define "switch" do |switch|
    switch.vm.box = "ubuntu/bionic64"
    switch.vm.hostname = "switch"
    switch.vm.network "private_network", virtualbox__intnet: "broadcast_router-south-1", auto_config: false
    switch.vm.network "private_network", virtualbox__intnet: "broadcast_client", auto_config: false
    switch.vm.network "private_network", virtualbox__intnet: "broadcast_server", auto_config: false
    switch.vm.provision "shell", path: "switch.sh"
    switch.vm.provider "virtualbox" do |vb|
      vb.memory = 256
    end
  end

  # HOST: CLIENT

  config.vm.define "client" do |hosta|
    hosta.vm.box = "ubuntu/bionic64"
    hosta.vm.hostname = "client"
    hosta.vm.network "private_network", virtualbox__intnet: "broadcast_client", auto_config: false
    hosta.vm.provision "shell", path: "client.sh"
    hosta.vm.provider "virtualbox" do |vb|
      vb.memory = 256
    end
  end

  # HOST: SERVER

  config.vm.define "server" do |hostb|
    hostb.vm.box = "ubuntu/bionic64"
    hostb.vm.hostname = "server"
    hostb.vm.network "private_network", virtualbox__intnet: "broadcast_server", auto_config: false
    hostb.vm.provision "shell", path: "server.sh"
    hostb.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
    end
  end
end
