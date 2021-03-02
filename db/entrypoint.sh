#!/bin/bash
if grep -q "127.0.0.1" "/etc/mongod.conf"; then
	sed -i 's#/var/lib/mongodb#/data/db#g' /etc/mongod.conf
	sed -i 's#127.0.0.1#0.0.0.0#g' /etc/mongod.conf
	### Utilisation d'un point de montage en mémoire pour les données volatiles
	ls -al /data/db
	if [[ ! -f /data/db/nextdomstate ]]; then
		ln -s /nextdomstate /data/db/nextdomstate
	fi
	### Test si plusieurs fichiers sont présents
	if [[ $(ls -1q /data/db/ | wc -l) -lt 2 ]]; then
		mongod --directoryperdb --dbpath /data/db &
		### Lancement de la base pour exécuter les commandes de création des utilisateurs
		MONGO_TEMP_PID=$!
		sleep 10
		mongo nextdom --eval "db.createUser({user: '"${DB_USER}"', pwd: '"${DB_PASSWORD}"', roles: [ { role: 'clusterAdmin', db: 'admin' },{ role: 'readAnyDatabase', db: 'admin' },'readWrite']})"
		mongo nextdomstate --eval "db.createUser({user: '"${DB_USER}"', pwd: '"${DB_PASSWORD}"', roles: [ { role: 'clusterAdmin', db: 'admin' },{ role: 'readAnyDatabase', db: 'admin' },'readWrite']})"
		sleep 10
		kill -s KILL $MONGO_TEMP_PID
		echo "security:" >> /etc/mongod.conf
		echo "  authorization: enabled" >> /etc/mongod.conf
	else
		mongod --directoryperdb --dbpath /data/db --repair
	fi
fi
exec "$@"
