FROM alpine:latest
RUN apk add --no-cache ca-certificates tzdata wget
RUN wget https://github.com/enablesd/mieru/releases/latest/download/mieru-linux-amd64 -O /usr/local/bin/mita && \
    chmod +x /usr/local/bin/mita

COPY mita.json /etc/mita/mita.json

EXPOSE 7860
WORKDIR /etc/mita

CMD ["mita", "server", "--config", "/etc/mita/mita.json"]
