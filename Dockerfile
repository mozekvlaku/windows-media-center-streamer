FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    xvfb \
    chromium-browser \
    ffmpeg \
    nginx \
    curl \
    x11vnc \
    && apt-get clean

# nastav nginx
COPY nginx/default.conf /etc/nginx/sites-available/default

# pracovní adresář pro HLS
RUN mkdir -p /var/www/llhls
WORKDIR /var/www/llhls

# start script
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 80 6080

CMD ["/start.sh"]