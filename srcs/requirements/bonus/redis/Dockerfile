FROM debian:bookworm

RUN apt update && \
    apt install redis-server -y && \
    rm -rf /var/lib/apt/lists/*

COPY conf/redis.conf /etc/redis/redis.conf

EXPOSE 6379

ENTRYPOINT ["redis-server", "/etc/redis/redis.conf"]
