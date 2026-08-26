FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs

RUN curl -fsSL https://go.dev/dl/go1.26.5.linux-amd64.tar.gz -o /tmp/go.tar.gz && \
    rm -rf /usr/local/go && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz

ENV PATH="/usr/local/go/bin:${PATH}"

WORKDIR /opt

RUN git clone https://github.com/devforth/OnLogs.git

WORKDIR /opt/OnLogs/application/frontend

RUN npm install && \
    npm run build

RUN cp -r dist /opt/OnLogs/application/backend/dist

WORKDIR /opt/OnLogs/application/backend

RUN go build -o /usr/local/bin/onlogs .

EXPOSE 8798

COPY tools/start.sh /start.sh
RUN chmod +x /start.sh

ENTRYPOINT ["/start.sh"]
