#!/bin/bash
set -e

# Actualizar e instalar ISC-DHCP-Server
sudo apt update
sudo apt install -y isc-dhcp-server

# Copiar la clave TSIG generada desde el DNS (manual o vía shared folder)
# Por simplicidad, se recrea la misma clave aquí (en práctica usar la misma que DNS)
sudo tsig-keygen -a hmac-sha256 ddns-key > /etc/dhcp/ddns.key
#Guardar clave en variable
KEY_SECRET=$(grep secret /etc/dhcp/ddns.key | awk '{print $2}' | tr -d '";')

sudo tee /etc/dhcp/ddns.key > /dev/null <<EOF
key "ddns-key" {
    algorithm hmac-sha256;
    secret "$KEY_SECRET";
};
EOF

# Configurar dhcpd.conf
sudo tee /etc/dhcp/dhcpd.conf > /dev/null <<EOF
include "/etc/dhcp/ddns.key";

option domain-name "pablo.test";
option domain-name-servers 192.168.58.10, 8.8.8.8;
default-lease-time 86400;
max-lease-time 691200;
option routers 192.168.58.1;

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

# Reiniciar servicio DHCP
sudo systemctl restart isc-dhcp-server
sudo systemctl enable isc-dhcp-server
