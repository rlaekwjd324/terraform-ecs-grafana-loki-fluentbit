FROM grafana/loki:main-a05744a-arm64

COPY loki-config.yaml /etc/loki/config.yaml

CMD ["-config.file=/etc/loki/config.yaml"]