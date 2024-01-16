# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "debian/bullseye64"

 config.vm.provider "virtualbox" do |vb|
    vb.memory = "256"  #RAM
    vb.linked_clone = true
end #provider

config.vm.define "ns1" do |debian|
  debian.vm.hostname = "ns1"
    #Network card, private network mode
    debian.vm.network :private_network, ip: "192.168.57.10"
  debian.vm.provision "shell", path: "provision.sh"
end

config.vm.define "ns2" do |debian|
  debian.vm.hostname = "ns2"
   #Network card, private network mode
    debian.vm.network :private_network, ip: "192.168.57.11"
  debian.vm.provision "shell", path: "provision.sh"
end

end