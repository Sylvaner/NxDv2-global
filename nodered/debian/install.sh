#!/bin/sh

if [ $(id -u) != 0 ]; then 
  echo "Error: This script must be executed with privilegied user"
  exit 1
fi

# Vérifie si l'utilisateur nextdom existe et le créé si nécessaire
if ! id -u "nextdom" > /dev/null 2>&1; then
  echo ">>> Création de l'utilisateur nextdom"
  adduser --system --shell /bin/sh --group nextdom
fi

# Vérifie si le fichier de configuration existe et le créé si nécessaire
if ! [ -f /etc/nextdom/nextdom.conf ]; then
  echo ">>> Copy configuration file"
  mkdir -p /etc/nextdom
  cp -fr nextdom.conf /etc/nextdom/nextdom.conf
  chown nextdom:nextdom -R /etc/nextdom
fi

if ! [ -x "$(command -v node)" ]; then
  echo ">>> Install node"
  curl -fsSL https://deb.nodesource.com/setup_15.x | bash -
  apt-get install -y nodejs
fi

if [ -x "$(command -v systemctl)" ]; then
  echo ">>> Create and enable service in SystemD"
  cp nextdom-nodered.service /etc/systemd/system/
  systemctl daemon-reload
  systemctl enable nextdom-nodered
  NODE_RED_START="systemctl start nextdom-nodered"  
  NODE_RED_STOP="systemctl stop nextdom-nodered"  
else
  echo ">>> Create and enable service in init.d"
  cp -fr nextdom-nodered /etc/init.d/
  update-rc.d nextdom-nodered defaults
  update-rc.d nextdom-nodered enable
  NODE_RED_START="service nextdom-nodered start"
  NODE_RED_STOP="service nextdom-nodered stop"
fi

echo ">>> Installing Node-REd"
npm install -g --unsafe-perm node-red

eval $NODE_RED_START
echo ">>> Initialise config files"
sleep 20
eval $NODE_RED_STOP
echo ">>> Create credentials"
sed -i 's/\/\/credentialSecret/credentialSecret/g' /home/nextdom/.node-red/settings.js
if [ -f /dev/random ]; then
  CREDENTIAL_SECRET=$(head -c24 < /dev/random | base64)
elif [ -f /dev/urandom ]; then
  CREDENTIAL_SECRET=$(head -c24 < /dev/urandom | base64)
else
  CREDENTIAL_SECRET=$(echo $RANDOM$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM)
fi
sed -i "s/a-secret-key/$CREDENTIAL_SECRET/g" /home/nextdom/.node-red/settings.js
eval $NODE_RED_START
sleep 20
echo ">>> Create MQTT broker"
NODERED_REV=$(curl --silent -X GET -H "Node-RED-API-Version: v2" http://localhost:1880/flows | sed -rn 's/^.*"rev":"(.*)".*/\1/p')
curl --silent -d '{
  "flows": [
    {
      "id":"77777777.777777",
      "type":"mqtt-broker",
      "name":"NextDom Broker",
      "broker":"'"${MQTT_HOST}"'",
      "port":"'"${MQTT_PORT}"'",
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
        "user":"'"${MQTT_USER}"'",
        "password":"'"${MQTT_PASSWORD}"'"
      }
    }
  ],
  "rev":"'"${NODERED_REV}"'"
}' -H "Content-Type: application/json" -H "Node-RED-API-Version: v2" -H "Node-RED-Deployment-Type: full" -X POST http://localhost:1880/flows > /dev/null
