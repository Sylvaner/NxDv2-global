FROM debian:buster-slim
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y mosquitto mosquitto-clients
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x entrypoint.sh
RUN echo "#!/bin/sh" > /start.sh && \
    echo "service mosquitto start" >> /start.sh && \
    echo "touch /var/log/mosquitto/mosquitto.log" >> /start.sh && \
    echo "chown mosquitto:mosquitto /var/log/mosquitto/mosquitto.log" >> /start.sh && \
    echo "chown mosquitto:mosquitto -R /var/lib/mosquitto" >> /start.sh && \
    echo "tail -f /var/log/mosquitto/mosquitto.log" >> /start.sh && \
    chmod +x start.sh && \
    apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/start.sh"]
