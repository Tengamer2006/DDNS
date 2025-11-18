#!/bin/bash
set -e

echo "[INFO] Instalando Kea..."
apt-get update
apt-get install -y kea-dhcp4-server kea-dhcp-ddns-server

KEA_DIR="/etc/kea"

# Respaldar y copiar configs
echo "[INFO] Respaldando y copiando configuraciones..."
for file in kea-dhcp4.conf kea-dhcp-ddns.conf keys.conf; do
  if [ -f "$KEA_DIR/$file" ]; then
    mv "$KEA_DIR/$file" "$KEA_DIR/$file.old"
  fi
  cp "/vagrant/kea-config/$file" "$KEA_DIR/$file"
done

# Ajustar permisos
echo "[INFO] Ajustando permisos..."
chown _kea:_kea $KEA_DIR/*
chmod 644 $KEA_DIR/*

# Validar configuración
echo "[INFO] Validando configuración Kea..."
kea-dhcp4 -t "$KEA_DIR/kea-dhcp4.conf" || true
kea-dhcp-ddns -t "$KEA_DIR/kea-dhcp-ddns.conf" || true

# Reiniciar servicios
echo "[INFO] Reiniciando servicios Kea..."
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable kea-dhcp4-server
systemctl enable kea-dhcp-ddns-server
systemctl restart kea-dhcp4-server
systemctl restart kea-dhcp-ddns-server

systemctl status kea-dhcp4-server --no-pager
systemctl status kea-dhcp-ddns-server --no-pager
