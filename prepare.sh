#!/bin/bash
if [[ -d logic ]]; then
	cd logic
	git pull
	cd ..
else
	git clone https://github.com/Sylvaner/NxDv2-logic logic
fi
if [[ -d api ]]; then
	cd api
	git pull
	cd ..
else
	git clone https://github.com/Sylvaner/NxDv2-api api
fi
cp -fr .env logic/.env
cp -fr .env api/.env
cp -fr .env db/.env
cp -fr .env nodered/.env
cp -fr .env mqtt/.env
docker network create nextdom
#docker-compose --file db/docker-compose.yml up -d --build
#docker-compose --file nodered/docker-compose.yml up -d --build 
#docker-compose --file mqtt/docker-compose.yml up -d --build 
docker-compose up -d --build
