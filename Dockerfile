FROM debian:latest
WORKDIR /opt/ldap-proxy
COPY scripts/entrypoint.sh /entrypoint.sh
RUN apt-get update && apt-get install -y stunnel4 \
  && rm -rf /var/lib/apt/lists/* && \
  echo "ENABLED=1" >> /etc/default/stunnel4 && \
  useradd -u 8888 stunnel && \
  chown -R stunnel:stunnel /etc/stunnel && \
  chmod +x /entrypoint.sh

USER stunnel

ENTRYPOINT [ "/entrypoint.sh" ]