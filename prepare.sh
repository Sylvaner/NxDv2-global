#!/bin/bash
if [[ -d logic ]]; then
	cd logic
	git pull
	cd ..
else
	git clone https://github.com/Sylvaner/NxDv2-logic logic
fi
cd logic
npm install
cd ..
if [[ -d api ]]; then
	cd api
	git pull
	cd ..
else
	git clone https://github.com/Sylvaner/NxDv2-api api
fi
cd api
npm install
cd ..
cp -fr .env logic/.env
cp -fr .env api/.env
cp -fr .env db/.env
cp -fr .env nodered/.env
cp -fr .env mqtt/.env
docker network create nextdom
docker-compose up -d --build
