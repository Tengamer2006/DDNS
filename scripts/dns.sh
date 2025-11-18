#!/bin/bash
set -e

echo "[INFO] Instalando Bind9..."
apt-get update
apt-get install -y bind9 bind9-utils bind9-dnsutils

BIND_DIR="/etc/bind"
ZONE_DIR="/var/lib/bind"

# Respaldar y copiar configuraciones
echo "[INFO] Respaldando y copiando configuraciones..."
for file in named.conf named.conf.local named.conf.options keys.conf named.conf.root-hints; do
  if [ -f "/vagrant/bind-config/$file" ]; then
    if [ -f "$BIND_DIR/$file" ]; then
      mv "$BIND_DIR/$file" "$BIND_DIR/$file.old"
    fi
    cp "/vagrant/bind-config/$file" "$BIND_DIR/$file"
  else
    echo "[WARN] El fichero $file no existe en bind-config, se omite."
  fi
done

# Respaldar y copiar ficheros de zona
echo "[INFO] Respaldando y copiando ficheros de zona..."
for zone in /vagrant/bind-config/db.*; do
  fname=$(basename "$zone")
  if [ -f "$ZONE_DIR/$fname" ]; then
    mv "$ZONE_DIR/$fname" "$ZONE_DIR/$fname.old"
  fi
  cp "$zone" "$ZONE_DIR/$fname"
done

# Corregir saltos de línea finales
echo "[INFO] Corrigiendo saltos de línea finales..."
for zone in $ZONE_DIR/db.*; do
  sed -i -e '$a\' "$zone"
done

# Ajustar permisos
echo "[INFO] Ajustando permisos de configuración y zonas..."
chown bind:bind $BIND_DIR/*.conf $ZONE_DIR/db.*
chmod 644 $BIND_DIR/*.conf $ZONE_DIR/db.*

# Validar existencia y contenido de named.conf
echo "[INFO] Validando existencia de named.conf..."
if [ ! -s "$BIND_DIR/named.conf" ]; then
  echo "[ERROR] El fichero named.conf no existe o está vacío."
  exit 1
fi

# Validar sintaxis de configuración
echo "[INFO] Validando sintaxis de configuración Bind..."
named-checkconf "$BIND_DIR/named.conf"

# Validar zonas
for zonefile in $ZONE_DIR/db.*; do
  fname=$(basename "$zonefile")
  named-checkzone "$fname" "$zonefile" || true
done

# Verificar directorio de logs
echo "[INFO] Verificando directorio de logs..."
mkdir -p /var/log/named
chown bind:bind /var/log/named

# Reiniciar Bind manualmente
echo "[INFO] Reiniciando Bind manualmente..."
pkill named || true
sleep 2
/usr/sbin/named -u bind -f -c "$BIND_DIR/named.conf" &

sleep 2
echo "[INFO] Verificando proceso activo de named..."
ps -ef | grep named | grep -v grep

echo "[INFO] Verificando escucha en puerto 53..."
ss -tulnp | grep :53 || echo "[WARN] Bind no está escuchando en el puerto 53"

sudo systemctl start bind9.service