#!/bin/bash

# Remove debian nodejs (to old)
apt-get remove -y nodejs
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
cd db/debian
./install.sh
cd ../..
cd mqtt/debian
./install.sh
cd ../..
cd nodered/debian
./install.sh
cd ../..
cd api/debian
./build.sh
./install.sh
cd ../..
cd logic/debian
./build.sh
./install.sh
cd ../..

