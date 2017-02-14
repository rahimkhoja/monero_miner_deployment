#!/bin/sh
# Monero Miner Deployment
# By Rahim Khoja (rahimk@khojacorp.com)

# Default Wallet Address & Pool Host Values
defaultwal=42VxjBpfi4TS6KFjNrrKo3QLcyK7gBGfM9w7DxmGRcocYnEbJ1hhZWXfaHJtCXBxnL74DpkioPSivjRYU8qkt59s3EaHUU3
defaulthost=monero.hiive.biz:3333

# Get Wallet Address
finish="-1"
while [ "$finish" = '-1' ]
  do
    finish="1"
    read -p "Enter Monero Wallet Address [$defaultwal]: " WALLET
    WALLET=${WALLET:-$defaultwal}
    echo
    read -p "Wallet Address is: $WALLET [y/n]? " answer

    if [ "$answer" = '' ];
    then
      answer=""
    else
      case $answer in
        y | Y | yes | YES ) answer="y";;
        n | N | no | NO ) answer="n"; finish="-1";;
        *) finish="-1";
           echo -n 'Invalid Response\n';
       esac
    fi
done
echo

# Get Pool Address
finish="-1"
while [ "$finish" = '-1' ]
  do
    finish="1"
    read -p "Enter Monero Pool Host [$defaulthost]: " MINEHOST
    MINEHOST=${MINEHOST:-$defaulthost}
    echo
    read -p "Monero Pool is: $MINEHOST [y/n]? " answer

    if [ "$answer" = '' ];
    then
      answer=""
    else
      case $answer in
        y | Y | yes | YES ) answer="y";;
        n | N | no | NO ) answer="n"; finish="-1";;
        *) finish="-1";
           echo -n 'Invalid Response\n';
       esac
    fi
done

# Confirm Install
echo "Monero Wallet Address: $WALLET"
echo "Monero Pool Host: $MINEHOST"

read -p "Are you sure you want to continue? (y/n)?" CONT
if [  "$CONT" != "y" ]; then
  echo "Exiting!"
  exit 1;
fi
echo
echo "Installing Monero Miner"
  
# Update & Upgrade Apt
sudo apt-get -y update && sudo apt-get -y upgrade

# Install Required Packages via APT
sudo apt-get -y install git wget build-essential autotools-dev libcurl3 automake autoconf pkg-config libcurl4-openssl-dev libjansson-dev libssl-dev libgmp-dev make g++

# Download Latest Source of Wold9466 Miner
git clone https://github.com/wolf9466/cpuminer-multi

# Download Latest Source of Tpruvot Miner
# This runs a little slower than Wolf from my tests
# git clone https://github.com/tpruvot/cpuminer-multi

# Change to Miner Directory
cd cpuminer-multi/

# Remove Last Miner Compile Attempt 
sudo make clean

# Compile Miner
./autogen.sh
CFLAGS="-march=native" ./configure
make

# Install Miner
sudo make install

# Change to Monero Miner Deployment Directory
cd ..

# Copy Miner Service File
sudo /bin/bash -c "cp $(pwd -P)/monero-miner.service /lib/systemd/system/"

# Update Miner Systemd Service File With Wallet & Pool Information
sudo sed -i "s/walletaddress/$WALLET/" /lib/systemd/system/monero-miner.service
sudo sed -i "s/mineaddress/$MINEHOST/" /lib/systemd/system/monero-miner.service

# Reload Systemd Services
sudo systemctl daemon-reload

# Enable & Start the Miner
sudo systemctl enable monero-miner.service
sudo systemctl start monero-miner.service

# Install Complete
echo "Install Complete!"
