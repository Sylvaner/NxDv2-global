#!/bin/sh

if [ ! -e "/etc/mosquitto/mosquitto.passwd" ]; then
	MOSQUITTO_PASSWORD_FILE="/etc/mosquitto/mosquitto.passwd"
	echo "user $MQTT_USER
topic readwrite #" > /etc/mosquitto/acl.conf
	echo "password_file $MOSQUITTO_PASSWORD_FILE
allow_anonymous false" > /etc/mosquitto/conf.d/security.conf
	touch $MOSQUITTO_PASSWORD_FILE
	mosquitto_passwd -b $MOSQUITTO_PASSWORD_FILE $MQTT_USER $MQTT_PASSWORD
fi
exec $@
