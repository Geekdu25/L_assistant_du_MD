#!/bin/bash

# Usage: ./mpv_send.sh '{"command": ["cycle", "pause"]}'
# Envoie la commande à mpv via le socket IPC /tmp/mdmusic

# Chemin absolu vers socat (adapte si besoin)
SOCAT="/usr/bin/socat"
SOCKET="/tmp/mdmusic"

# Facultatif : log de la commande reçue pour debug
# echo "[$(date)] CMD: $1" >> /tmp/mpv_send_debug.log

if [ -z "$1" ]; then
  echo "Erreur : aucune commande JSON fournie !" >&2
  exit 1
fi

# Envoi la commande à mpv via socat
echo "$1" | "$SOCAT" - UNIX-CONNECT:"$SOCKET"
