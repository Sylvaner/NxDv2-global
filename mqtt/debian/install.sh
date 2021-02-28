#!/bin/sh

if [ $(id -u) != 0 ]; then 
  echo "Error: This script must be executed with privilegied user"
  exit 1
fi

# Vérifie si l'utilisateur nextdom existe et le créé si nécessaire
if ! id -u "nextdom" > /dev/null 2>&1; then
  echo ">>> Création de l'utilisateur nextdom"
  adduser --system --group nextdom
fi

# Vérifie si le fichier de configuration existe et le créé si nécessaire
if ! [ -f /etc/nextdom/nextdom.conf ]; then
  echo ">>> Copy configuration file"
  mkdir -p /etc/nextdom
  cp -fr nextdom.conf /etc/nextdom/nextdom.conf
  chown nextdom:nextdom -R /etc/nextdom
fi

. /etc/nextdom/nextdom.conf
apt-get install -y mosquitto mosquitto-clients

if [ ! -e "/etc/mosquitto/mosquitto.passwd" ]; then
	MOSQUITTO_PASSWORD_FILE="/etc/mosquitto/mosquitto.passwd"
	echo "user $MQTT_USER
topic readwrite #" > /etc/mosquitto/acl.conf
	echo "password_file $MOSQUITTO_PASSWORD_FILE
allow_anonymous false" > /etc/mosquitto/conf.d/security.conf
	touch $MOSQUITTO_PASSWORD_FILE
	mosquitto_passwd -b $MOSQUITTO_PASSWORD_FILE $MQTT_USER $MQTT_PASSWORD
fi
systemctl daemon-reload
systemctl enable mosquitto
systemctl start mosquitto

