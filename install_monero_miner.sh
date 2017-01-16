# Update & Upgrade Apt

sudo apt-get update && sudo apt-get -y upgrade

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
