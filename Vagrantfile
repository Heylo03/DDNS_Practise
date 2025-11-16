Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"

  # DNS Server
  config.vm.define "dns-server" do |dns|
    dns.vm.hostname = "dns-server"
    dns.vm.network "private_network", ip: "192.168.58.10"
    dns.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
    end
    dns.vm.provision "shell", path: "provision_dns.sh"
  end

  # DHCP Server
  config.vm.define "dhcp-server" do |dhcp|
    dhcp.vm.hostname = "dhcp-server"
    dhcp.vm.network "private_network", ip: "192.168.58.20"
    dhcp.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
    end
    dhcp.vm.provision "shell", path: "provision_dhcp.sh"
  end

  # Cliente
  config.vm.define "c1" do |c1|
    c1.vm.hostname = "c1"
    c1.vm.network "private_network", type: "dhcp"
    c1.vm.provider "virtualbox" do |vb|
      vb.memory = "512"
      vb.cpus = 1
    end
    c1.vm.provision "shell", inline: <<-SHELL
      sudo apt update
      sudo apt install -y isc-dhcp-client dnsutils
    SHELL
  end
end
