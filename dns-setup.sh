#!/bin/bash
set -e

echo "[DNS] Instalando paquetes..."
sudo apt update
sudo apt install -y bind9 bind9utils dnsutils

# Crear clave TSIG si no existe
if [ ! -f /vagrant_shared/ddns.key ]; then
    echo "[DNS] Generando TSIG..."
    sudo tsig-keygen -a hmac-sha256 ddns-key > /vagrant_shared/ddns.key
fi

sudo cp /vagrant_shared/ddns.key /etc/bind/ddns.key
KEY_SECRET=$(awk '/secret/ {print $2}' /etc/bind/ddns.key | tr -d '";')

# Configuración de named.conf.options
sudo tee /etc/bind/named.conf.options > /dev/null <<EOF
key "ddns-key" {
    algorithm hmac-sha256;
    secret "$KEY_SECRET";
};

options {
    directory "/var/cache/bind";
    recursion yes;
    dnssec-validation auto;
    listen-on { 192.168.58.10; };
    listen-on-v6 { none; };
};

EOF

# Configuración de named.conf.local
sudo tee /etc/bind/named.conf.local > /dev/null <<EOF
zone "pablo.test" {
    type master;
    file "/etc/bind/db.pablo.test";
    allow-update { key "ddns-key"; };
};

zone "58.168.192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.192";
    allow-update { key "ddns-key"; };
};

EOF

# Archivos de zona
sudo tee /etc/bind/db.pablo.test > /dev/null <<EOF
\$TTL 604800
@   IN  SOA dns-server.pablo.test. admin.pablo.test. (
        2
        604800
        86400
        2419200
        604800 )
;
@       IN  NS      dns-server.pablo.test.
dns-server IN A      192.168.58.10
EOF

sudo tee /etc/bind/db.192 > /dev/null <<EOF
\$TTL 604800
@       IN      SOA     dns-server.pablo.test. admin.pablo.test. (
                        2
                        604800
                        86400
                        2419200
                        604800 )
;
@       IN      NS      dns-server.pablo.test.
EOF

# Verificar y reiniciar BIND
sudo named-checkconf
sudo named-checkzone pablo.test /etc/bind/db.pablo.test
sudo named-checkzone 58.168.192.in-addr.arpa /etc/bind/db.192

sudo systemctl restart named
sudo systemctl enable named

sudo chmod 600 /etc/bind/ddns.key
sudo chown root:bind /etc/bind/ddns.key




echo "[DNS] Configuración completada."
