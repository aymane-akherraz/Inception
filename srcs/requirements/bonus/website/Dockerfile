FROM debian:bookworm

RUN apt update && \
    apt install -y nginx && \
    rm -rf /var/lib/apt/lists/*

COPY html/ /var/www/html/

EXPOSE 80

ENTRYPOINT ["nginx", "-g", "daemon off;"]
