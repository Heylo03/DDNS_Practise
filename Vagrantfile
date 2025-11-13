Vagrant.configure("2") do |config|
  # Imagen base común
  config.vm.box = "ubuntu/jammy64"
  # Red privada común a todas las VMs
  config.vm.network "private_network", ip: "192.168.58.1", virtualbox__intnet: "ddns_lab", auto_network: false
  # Servidor DNS - BIND9
  config.vm.define "dns" do |dns|
    dns.vm.hostname = "dns.example.test"
    dns.vm.network "private_network", ip: "192.168.58.10", virtualbox__intnet: "ddns_lab"
    dns.vm.provider "virtualbox" do |vb|
      vb.name = "DNS_Server"
      vb.memory = 512
    end
  end
  # Servidor DHCP - ISC DHCP Server
  config.vm.define "dhcp" do |dhcp|
    dhcp.vm.hostname = "dhcp.example.test"
    dhcp.vm.network "private_network", ip: "192.168.58.11", virtualbox__intnet: "ddns_lab"
    dhcp.vm.provider "virtualbox" do |vb|
      vb.name = "DHCP_Server"
      vb.memory = 512
    end
    dhcp.vm.provision "shell", inline: <<-SHELL
      apt-get update -y
      apt-get install -y isc-dhcp-server dnsutils
      systemctl enable isc-dhcp-server
    SHELL
  end
  #Cliente
    config.vm.define "cliente" do |cli|
    cli.vm.hostname = "cliente"
    cli.vm.network "private_network", virtualbox__intnet: "ddns_lab", auto_config: false, type: "dhcp"
    cli.vm.provider "virtualbox" do |vb|
      vb.name = "Cliente_DHCP"
      vb.memory = 256
    end
    cli.vm.provision "shell", inline: <<-SHELL
      apt-get update -y
      apt-get install -y net-tools iputils-ping dnsutils isc-dhcp-client
      dhclient -v eth1 || true
    SHELL
  end
end
