# # 기본 이미지로부터 시작합니다.
# FROM grafana/grafana:latest

# # Grafana Configuration 파일을 복사합니다.
# COPY grafana-config.yaml /etc/grafana/config.yaml

# # 컨테이너를 실행할 때 Grafana Configuration 파일을 사용하도록 설정합니다.
# CMD ["--config=/etc/grafana/config.yaml"]

FROM grafana/grafana:latest

RUN mkdir -p /etc/grafana/provisioning/datasources
COPY ./datasource.yaml /etc/grafana/provisioning/datasources/

RUN mkdir -p /etc/grafana/provisioning/alerting
COPY ./alerting.yaml /etc/grafana/provisioning/alerting/

RUN mkdir -p /etc/grafana/provisioning/dashboards
COPY ./dashboard.yaml /etc/grafana/provisioning/dashboards/

ENTRYPOINT [ "/run.sh" ]