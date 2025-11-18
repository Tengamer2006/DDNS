#!/bin/bash

echo "--- Configurando Cliente DHCP ---"
# Aseguramos que envíe el hostname
echo 'send host-name = gethostname();' >> /etc/dhcp/dhclient.conf

# Matar dhclient por si acaso y pedir IP fresca en eth1
dhclient -r
dhclient -v eth1