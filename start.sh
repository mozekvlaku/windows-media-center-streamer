#!/bin/bash
set -e

# spust X server
Xvfb :1 -screen 0 1280x720x24 &
export DISPLAY=:1

# spust Chromium na noVNC URL
chromium-browser --no-sandbox --disable-gpu --kiosk "$NOVNC_URL" &

sleep 5

# spust ffmpeg grab z X displayu → HLS
ffmpeg -hide_banner -loglevel info \
  -f x11grab -r 30 -s 1280x720 -i :1.0 \
  -c:v libx264 -preset ultrafast -tune zerolatency -g 60 -keyint_min 30 \
  -sc_threshold 0 -b:v 2500k -maxrate 3000k -bufsize 5000k \
  -c:a aac -b:a 96k \
  -f hls \
  -hls_time 0.5 -hls_list_size 6 -hls_flags delete_segments+append_list+omit_endlist \
  -hls_segment_filename /var/www/llhls/seg_%03d.ts \
  /var/www/llhls/stream.m3u8 &

# spust nginx
nginx -g 'daemon off;'