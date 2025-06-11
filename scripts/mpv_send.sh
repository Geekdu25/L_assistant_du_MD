#!/bin/bash
read CMD
CMD=$(echo "$CMD" | tr -d '\r')
echo "[$(date)] CMD STDIN: $CMD" >> "$HOME/mpv_send_debug.log"
echo "$CMD" | /usr/bin/socat - UNIX-CONNECT:/tmp/mdmusic
