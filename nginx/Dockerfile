FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -subj "/C=MA/ST=Rabat/L=Rabat/O=42/OU=1337/CN=aakherra.42.fr"

# Copy your custom nginx configuration file into the container
COPY conf/nginx.conf /etc/nginx/sites-available/default

# Start NGINX in the foreground so the container doesn't instantly exit
CMD ["nginx", "-g", "daemon off;"]
