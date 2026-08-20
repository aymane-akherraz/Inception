FROM debian:bookworm

RUN apt update && \
    apt install vsftpd -y && \
    rm -rf /var/lib/apt/lists/*

COPY conf/vsftp.conf /etc/vsftpd.conf
COPY tools/setup.sh /setup.sh

RUN chmod +x /setup.sh

EXPOSE 21

ENTRYPOINT ["/setup.sh"]
