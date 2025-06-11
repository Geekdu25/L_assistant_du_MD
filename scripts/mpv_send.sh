#!/bin/bash
read CMD
echo "RAW CMD: $CMD" >> "$HOME/mpv_send_debug.log"
hexdump -C <<< "$CMD" >> "$HOME/mpv_send_debug.log"
echo "CMD STDIN: $CMD" >> "$HOME/mpv_send_debug.log"
echo "$CMD" | /usr/bin/socat - UNIX-CONNECT:/tmp/mdmusic

