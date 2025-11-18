#!/bin/bash

echo "--- Instalando KEA DHCP ---"
apt-get update
apt-get install -y kea-dhcp4-server kea-ctrl-agent kea-dhcp-ddns-server

echo "--- Configurando KEA DHCP4 ---"
cat <<EOF > /etc/kea/kea-dhcp4.conf
{
{
"Dhcp4": {
    "interfaces-config": {
        "interfaces": ["eth1"]
    },

    "lease-database": {
        "type": "memfile",
        "lfc-interval": 3600
    },

    "valid-lifetime": 4000,
    "renew-timer": 1000,
    "rebind-timer": 2000,

    "dhcp-ddns": {
        "enable-updates": true,
        "server-ip": "127.0.0.1",
        "server-port": 53001
    },

    "ddns-send-updates": true,
    "ddns-qualifying-suffix": "alexten",

    "ddns-override-client-update": true,
    "ddns-override-no-update": true,
    "ddns-replace-client-name": "when-not-present",
    "ddns-generated-prefix": "dhcp",

    "subnet4": [
        {
            "id": 1,
            "subnet": "192.168.60.0/24",
            "pools": [ { "pool": "192.168.60.50 - 192.168.60.150" } ],

            "option-data": [
                { "name": "routers", "data": "192.168.60.3" },
                { "name": "domain-name-servers", "data": "192.168.60.3" },
                { "name": "domain-name", "data": "alexten" }
            ]
        }
    ]
}
}
EOF

echo "--- Configurando KEA DDNS ---"
cat <<EOF > /etc/kea/kea-dhcp-ddns.conf
{
"DhcpDdns": {
  "ip-address": "127.0.0.1",
  "port": 53001,

  "tsig-keys": [
      {
          "name": "clave-ddns",
          "algorithm": "hmac-sha256",
          "secret": "PpvsYbdwLocZh5lKY934HHbjoOshT5X5s5RmN2FlflU="
      }
  ],

  "forward-ddns": {
      "ddns-domains": [
          {
              "name": "alexten.",
              "key-name": "clave-ddns",
              "dns-servers": [ { "ip-address": "192.168.60.3" } ]
          }
      ]
  },

  "reverse-ddns": {
      "ddns-domains": [
          {
              "name": "60.168.192.in-addr.arpa.",
              "key-name": "clave-ddns",
              "dns-servers": [ { "ip-address": "192.168.60.3" } ]
          }
      ]
  },

  "loggers": [
    {
        "name": "kea-dhcp-ddns",
        "output-options": [ { "output": "stdout" } ],
        "severity": "INFO"
    }
  ]
}
}
EOF

echo "--- Permisos y Reinicio ---"
chown -R _kea:_kea /etc/kea
chmod 755 /etc/kea
systemctl restart kea-dhcp-ddns-server
systemctl restart kea-dhcp4-server