#!/bin/bash
# Debug : log ce qui est reçu
echo "[$(date)] CMD RECUE: $1" >> "$HOME/mpv_send_debug.log"
read CMD
echo "[$(date)] CMD STDIN: $CMD" >> "$HOME/mpv_send_debug.log"
echo "$CMD" | /usr/bin/socat - UNIX-CONNECT:/tmp/mdmusic
