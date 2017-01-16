#!/bin/sh

echo $PWD

# Update & Upgrade Apt

sudo apt-get -y update && sudo apt-get -y upgrade

# get git to install it

sudo apt-get install git wget

# dependencies

sudo apt-get install build-essential autotools-dev autoconf libcurl3 libcurl4-gnutls-dev

# download latest version

git clone https://github.com/wolf9466/cpuminer-multi

cd cpuminer-multi/

# compile

./autogen.sh

CFLAGS="-march=native" ./configure

make

#install

sudo make install

# return to install dir

cd ..

# Copy Service File

sudo /bin/bash -c "cp $(pwd -P)/monero-miner.service /lib/systemd/system/"

# Reload Systemd Services
sudo systemctl daemon-reload

# Enable and Start the Miner

sudo systemctl enable monero-miner.service
sudo systemctl start monero-miner.service
