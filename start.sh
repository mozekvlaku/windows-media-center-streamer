#!/bin/bash
set -e

# --- ffmpeg grab přímo z VNC ---
# uprav IP a port podle tvého Windows XP VM
VNC_HOST="192.168.102.49"
VNC_PORT="5988"

# vytvoř HLS výstupní adresář
mkdir -p /var/www/llhls

# ffmpeg: VNC -> HLS
ffmpeg -hide_banner -loglevel info \
  -f vnc -r 30 -i ${VNC_HOST}:${VNC_PORT} \
  -c:v libx264 -preset ultrafast -tune zerolatency -g 60 -keyint_min 30 \
  -sc_threshold 0 -b:v 2500k -maxrate 3000k -bufsize 5000k \
  -c:a aac -b:a 96k \
  -f hls \
  -hls_time 0.5 -hls_list_size 6 -hls_flags delete_segments+append_list+omit_endlist \
  -hls_segment_filename /var/www/llhls/seg_%03d.ts \
  /var/www/llhls/stream.m3u8 &

# spust nginx
nginx -g 'daemon off;'