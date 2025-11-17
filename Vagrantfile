Vagrant.configure("2") do |config|

  # Carpeta compartida para TSIG key
  config.vm.synced_folder "./shared", "/vagrant_shared"

  # -------------------------------
  # DNS SERVER
  # -------------------------------
  config.vm.define "dns-server" do |dns|
    dns.vm.box = "ubuntu/jammy64"
    dns.vm.hostname = "dns-server"
    dns.vm.network "private_network", ip: "192.168.58.10"
    dns.vm.provision "shell", path: "dns-setup.sh"
  end

  # -------------------------------
  # DHCP SERVER
  # -------------------------------
  config.vm.define "dhcp-server" do |dhcp|
    dhcp.vm.box = "ubuntu/jammy64"
    dhcp.vm.hostname = "dhcp-server"
    dhcp.vm.network "private_network", ip: "192.168.58.20"
    dhcp.vm.provision "shell", path: "dhcp-setup.sh"
  end

  # -------------------------------
  # CLIENT
  # -------------------------------
  config.vm.define "client" do |client|
    client.vm.box = "ubuntu/jammy64"
    client.vm.hostname = "client1"
    client.vm.network "private_network", ip: "192.168.58.101"
  end

end
