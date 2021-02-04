FROM debian:buster-slim
COPY entrypoint.sh /entrypoint.sh
# Hack pour que l'installeur de mongodb ne bloque pas sur l'absence de systemd
RUN ln -s /bin/true /bin/systemctl && \
    apt-get update && apt-get upgrade -y && apt-get install -y wget gnupg && \
    wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add - && \
    echo "deb http://repo.mongodb.org/apt/debian buster/mongodb-org/4.4 main" | tee /etc/apt/sources.list.d/mongodb-org-4.4.list && \
    apt-get update && \
    apt-get install -y mongodb-org && \
    mkdir -p /data/db && \
    chmod +x /entrypoint.sh && \
    apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/
ENTRYPOINT ["bash", "-x", "/entrypoint.sh"]
CMD ["mongod", "--directoryperdb", "--auth", "-f", "/etc/mongod.conf"]
