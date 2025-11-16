#!/bin/bash
set -e

# Actualizar e instalar BIND9
sudo apt update
sudo apt install -y bind9 bind9utils bind9-doc dnsutils

# Generar clave TSIG
sudo tsig-keygen -a hmac-sha256 ddns-key > /etc/bind/ddns.key
KEY_SECRET=$(grep secret /etc/bind/ddns.key | awk '{print $2}' | tr -d '";')

# Configurar named.conf.options
sudo tee /etc/bind/named.conf.options > /dev/null <<EOF
options {
    directory "/var/cache/bind";
    recursion yes;
    allow-query { any; };
    dnssec-validation auto;
    auth-nxdomain no;
    listen-on { any; };

    key "ddns-key" {
        algorithm hmac-sha256;
        secret "$KEY_SECRET";
    };
};
EOF

# Configurar la zona en named.conf.local
sudo tee /etc/bind/named.conf.local > /dev/null <<EOF
zone "pablo.test" IN {
    type master;
    file "/etc/bind/db.example.test";
    allow-update { key "ddns-key"; };
};

zone "58.168.192.in-addr.arpa" IN {
    type master;
    file "/etc/bind/db.192";
    allow-update { key "ddns-key"; };
};
EOF

# Verificar y reiniciar BIND9
sudo named-checkconf
sudo named-checkzone example.test /etc/bind/db.example.test
sudo named-checkzone 58.168.192.in-addr.arpa /etc/bind/db.192
sudo systemctl restart bind9
sudo systemctl enable bind9
