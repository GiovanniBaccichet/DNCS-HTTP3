# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  config.vm.box_check_update = false
  config.ssh.forward_agent = true
  config.ssh.forward_x11 = true
  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--usb", "on"]
    vb.customize ["modifyvm", :id, "--usbehci", "off"]
    vb.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
    vb.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]
    vb.customize ["modifyvm", :id, "--nicpromisc4", "allow-all"]
    vb.customize ["modifyvm", :id, "--nicpromisc5", "allow-all"]
    vb.cpus = 2
  end

  # ROUTER

  config.vm.define "router" do |router|
    router.vm.box = "ubuntu/bionic64"
    router.vm.hostname = "router"
    router.vm.network "private_network", virtualbox__intnet: "broadcast_router-client", auto_config: false
    router.vm.network "private_network", virtualbox__intnet: "broadcast_router-web-server", auto_config: false
    router.vm.network "private_network", virtualbox__intnet: "broadcast_router-video-server", auto_config: false
    router.vm.provision "shell", path: "vagrant/router.sh"
    router.vm.provider "virtualbox" do |vb|
      vb.memory = 256
    end
  end

  # HOST: WEB-SERVER

  config.vm.define "web-server" do |webserver|
    webserver.vm.box = "ubuntu/bionic64"
    webserver.vm.hostname = "web-server"
    webserver.vm.network "private_network", virtualbox__intnet: "broadcast_router-web-server", auto_config: false
    webserver.vm.provision "shell", path: "vagrant/web-server.sh"
    webserver.vm.provision "shell", path: "vagrant/web-docker_run.sh"
    webserver.vm.provider "virtualbox" do |vb|
      vb.memory = 512
    end
  end

  # HOST: VIDEO-SERVER

  config.vm.define "video-server" do |videoserver|
    videoserver.vm.box = "ubuntu/bionic64"
    videoserver.vm.hostname = "video-server"
    videoserver.vm.network "private_network", virtualbox__intnet: "broadcast_router-server", auto_config: false
    videoserver.vm.provision "shell", path: "vagrant/video-server.sh"
    videoserver.vm.provision "shell", path: "vagrant/video-docker_run.sh"
    videoserver.vm.provider "virtualbox" do |vb|
      vb.memory = 1024
    end
  end

  # HOST: CLIENT

  config.vm.define "client" do |client|
    client.vm.box = "ubuntu/bionic64"
    client.vm.hostname = "client"
    client.vm.network "private_network", virtualbox__intnet: "broadcast_router-client", auto_config: false
    client.vm.provision "shell", path: "vagrant/client.sh"
    client.vm.provider "virtualbox" do |vb|
      vb.memory = 1024
    end
  end

end
