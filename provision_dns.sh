#!/bin/bash

echo "--- [DNS] Instalando BIND9 ---"
apt-get update
apt-get install -y bind9 bind9-utils

echo "--- [DNS] Configurando named.conf.local ---"
# Aquí no hay variables $, así que EOF normal vale, pero 'EOF' es más seguro.
cat <<'EOF' > /etc/bind/named.conf.local
key "clave-ddns" {
    algorithm hmac-sha256;
    secret "PpvsYbdwLocZh5lKY934HHbjoOshT5X5s5RmN2FlflU=";
};

zone "alexten" {
    type master;
    file "/var/lib/bind/db.alexten";
    allow-update { key "clave-ddns"; };
};

zone "60.168.192.in-addr.arpa" {
    type master;
    file "/var/lib/bind/db.192.168.60";
    allow-update { key "clave-ddns"; };
};
EOF

echo "--- [DNS] Configurando Opciones ---"
cat <<'EOF' > /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";

    forwarders {
        8.8.8.8;
        8.8.4.4;
    };

    // Desactivamos DNSSEC para evitar problemas en laboratorio
    dnssec-validation no;

    // Importante: Escuchar en tu IP y permitir consultas de tu red
    listen-on { 127.0.0.1; 192.168.60.3; };
    allow-query { any; };

    listen-on-v6 { none; };
};
EOF

echo "--- [DNS] Creando Archivos de Zona ---"
# IMPORTANTE: Usamos 'EOF' con comillas para proteger el $TTL

# Zona Directa
cat <<'EOF' > /var/lib/bind/db.alexten
$TTL    604800
@       IN      SOA     ns1.alexten. root.alexten. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      ns1.alexten.
@       IN      A       192.168.60.3
ns1     IN      A       192.168.60.3
server  IN      A       192.168.60.3
router  IN      A       192.168.60.254
EOF

# Zona Inversa
cat <<'EOF' > /var/lib/bind/db.192.168.60
$TTL    604800
@       IN      SOA     ns1.alexten. root.alexten. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      ns1.alexten.
3       IN      PTR     ns1.alexten.
EOF

echo "--- [DNS] Ajustando Permisos y Reiniciando ---"
# BIND necesita escribir en /var/lib/bind para los archivos .jnl del DDNS
chown bind:bind /var/lib/bind/db.*
chmod 664 /var/lib/bind/db.*
chmod 775 /var/lib/bind/

# Reiniciamos el servicio
systemctl restart bind9