#!/bin/bash
set -e

echo "[DHCP] Instalando paquetes..."
sudo apt update
sudo apt install -y isc-dhcp-server bind9utils

# Copiar TSIG key desde DNS
sudo cp /vagrant_shared/ddns.key /etc/dhcp/ddns.key
KEY_SECRET=$(awk '/secret/ {print $2}' /etc/dhcp/ddns.key | tr -d '";')

sudo tee /etc/dhcp/ddns.key > /dev/null <<EOF
key "ddns-key" {
    algorithm hmac-sha256;
    secret "$KEY_SECRET";
};
EOF

# Configuración dhcpd.conf
sudo tee /etc/dhcp/dhcpd.conf > /dev/null <<EOF
include "/etc/dhcp/ddns.key";

option domain-name "pablo.test";
option domain-name-servers 192.168.58.10;
default-lease-time 86400;
max-lease-time 691200;

ddns-update-style interim;
ddns-domainname "pablo.test.";
ddns-rev-domainname "58.168.192.in-addr.arpa.";

subnet 192.168.58.0 netmask 255.255.255.0 {
  range 192.168.58.100 192.168.58.200;
  option routers 192.168.58.1;
  option domain-name-servers 192.168.58.10;
  option domain-name "pablo.test";

  zone pablo.test. {
    primary 192.168.58.10;
    key "ddns-key";
  }

  zone 58.168.192.in-addr.arpa. {
    primary 192.168.58.10;
    key "ddns-key";
  }
}
EOF

sudo systemctl restart isc-dhcp-server
sudo systemctl enable isc-dhcp-server

sudo chmod 600 /etc/dhcp/ddns.key
sudo chown root:root /etc/dhcp/ddns.key


echo "[DHCP] Configuración completada."
