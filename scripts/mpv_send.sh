#!/bin/bash
# Debug : log ce qui est reçu
read CMD
echo "[$(date)] CMD RECUE: $CMD" >> /tmp/mpv_send_debug.log
echo "$CMD" | /usr/bin/socat - UNIX-CONNECT:/tmp/mdmusic
