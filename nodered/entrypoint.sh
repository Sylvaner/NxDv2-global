#!/bin/bash

if [ ! -e "/root/.node-red/settings.js" ]; then
	service node-red start
	echo "Initialise config files"
	sleep 20
	service node-red stop
	echo "Create credentials"
	sed -i 's/\/\/credentialSecret/credentialSecret/g' /root/.node-red/settings.js
	CREDENTIAL_SECRET=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w30 | head -n1)
	sed -i "s/a-secret-key/$CREDENTIAL_SECRET/g" /root/.node-red/settings.js
	service node-red start
	sleep 20
	echo "Create MQTT broker"
	NODERED_REV=$(curl --silent -X GET -H "Node-RED-API-Version: v2" http://localhost:1880/flows | sed -rn 's/^.*"rev":"(.*)".*/\1/p')
	curl --silent -d '{
  "flows": [
    {
      "id":"77777777.777777",
      "type":"mqtt-broker",
      "name":"NextDom Broker",
      "broker":"localhost",
      "port":"1883",
      "clientid":
      "nextdom-nodered",
      "usetls":false,
      "compatmode":false,
      "keepalive":"60",
      "cleansession":true,
      "birthTopic":"",
      "birthQos":"0",
      "birthPayload":"",
      "closeTopic":"",
      "closeQos":"0",
      "closePayload":"",
      "willTopic":"",
      "willQos":"0",
      "willPayload":"",
      "credentials":{
        "user":"'"${MOSQUITTO_USER}"'",
        "password":"'"${MOSQUITTO_PASSWORD}"'"
      }
    }
  ],
  "rev":"'"${NODERED_REV}"'"
}' -H "Content-Type: application/json" -H "Node-RED-API-Version: v2" -H "Node-RED-Deployment-Type: full" -X POST http://localhost:1880/flows > /dev/null
	service node-red stop
fi
exec $@
