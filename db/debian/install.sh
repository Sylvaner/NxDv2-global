#!/bin/sh

DB_PATH=/var/nextdom/data/db

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

# Vérifie si le serveur mongo est installé (exécutable mongod)
if ! [ -x "$(command -v mongod)" ]; then
  # Charge le fichier de configuration
  . /etc/nextdom/nextdom.conf
  echo ">>> Install mongodb"
  if [ ! -f /etc/apt/sources.list.d/mongodb-org-4.4.list ]; then
    apt-get install -y wget gnupg 
    wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add - 
    echo "deb http://repo.mongodb.org/apt/debian buster/mongodb-org/4.4 main" | tee /etc/apt/sources.list.d/mongodb-org-4.4.list 
  fi
  apt-get update 
  apt-get install -y mongodb-org 

  echo ">>> Config mongodb"
  sed -i 's#/var/lib/mongodb#'$DB_PATH'#g' /etc/mongod.conf
  echo ">>> Init mongodb"
  mkdir -p $DB_PATH
  chown -R mongodb:mongodb $DB_PATH
  # Premier lancement sans la sécurité
  systemctl daemon-reload
  systemctl enable mongod
  systemctl start mongod
  sleep 20
  echo ">>> Create user"
  mongo nextdom --eval "db.createUser({user: '"${DB_USER}"', pwd: '"${DB_PASSWORD}"', roles: [ { role: 'clusterAdmin', db: 'admin' },{ role: 'readAnyDatabase', db: 'admin' },'readWrite']})"
  mongo nextdomstate --eval "db.createUser({user: '"${DB_USER}"', pwd: '"${DB_PASSWORD}"', roles: [ { role: 'clusterAdmin', db: 'admin' },{ role: 'readAnyDatabase', db: 'admin' },'readWrite']})"
  systemctl stop mongod
  sleep 20
  echo ">>> Secure MongoDB"
  if ! grep -q "authorization: enabled" /etc/mongod.conf; then
    echo "security:" >> /etc/mongod.conf
    echo "  authorization: enabled" >> /etc/mongod.conf
  fi
  systemctl start mongod
else
  echo "Error: MongoDb is already installed"
  exit 1
fi
