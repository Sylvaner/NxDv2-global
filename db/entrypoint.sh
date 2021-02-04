#!/bin/bash
if [ ! -e "/data/db/nextdomstate" ]; then
	sed -i 's#/var/lib/mongodb#/data/db#g' /etc/mongod.conf
	sed -i 's#127.0.0.1#0.0.0.0#g' /etc/mongod.conf
	echo "security:" >> /etc/mongod.conf
	echo "  authorization: enabled" >> /etc/mongod.conf
	### Utilisation d'un point de montage en mémoire pour les données volatiles
	ln -s /nextdomstate /data/db/nextdomstate
	chown -R mosquitto:mosquitto /var/lib/mosquitto
	mongod --directoryperdb --dbpath /data/db &
	### Lancement de la base pour exécuter les commandes de création des utilisateurs
	MONGO_TEMP_PID=$!
	sleep 10
	mongo nextdom --eval "db.createUser({user: '"${DB_USER}"', pwd: '"${DB_PASSWORD}"', roles: [ { role: 'clusterAdmin', db: 'admin' },{ role: 'readAnyDatabase', db: 'admin' },'readWrite']})"
	mongo nextdomstate --eval "db.createUser({user: '"${DB_USER}"', pwd: '"${DB_PASSWORD}"', roles: [ { role: 'clusterAdmin', db: 'admin' },{ role: 'readAnyDatabase', db: 'admin' },'readWrite']})"
	sleep 10
	kill -s KILL $MONGO_TEMP_PID
fi
exec "$@"
