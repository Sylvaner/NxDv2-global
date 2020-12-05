#!/bin/sh
git clone https://github.com/Sylvaner/NxDv2-logic logic
git clone https://github.com/Sylvaner/NxDv2-rest rest
cp -fr .env logic/.env
cp -fr .env rest/.env
docker-compose up -d