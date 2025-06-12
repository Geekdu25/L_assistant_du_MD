#!/bin/bash
echo "$1" | base64 --decode | socat - UNIX-CONNECT:/tmp/mdmusic
