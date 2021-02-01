# Docker for install test
FROM debian:buster-slim
COPY entrypoint.sh /entrypoint.sh
COPY install.sh /install.sh
RUN apt-get update && apt-get install -y curl && \
    curl -sL https://deb.nodesource.com/setup_15.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g --unsafe-perm node-red && \
    apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/ && \
    chmod +x entrypoint.sh && \
    chmod +x install.sh && \
    ./install.sh && \
    apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/node-red", "--max-old-space-size=128", "--userDir=/root/.node-red"]
