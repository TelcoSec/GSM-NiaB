sudo apt update -y
sudo apt upgrade -y
sudo apt install -y git vim curl python-is-python3 autoconf libtool libosmocore  
sudo apt-get install -y libusb-1.0-0-dev libboost-dev g++ cmake libsqlite3-dev
sudo apt-get install -y libuhd-dev uhd-host liburing* libpcsclite* gnutls* libortp-dev libosmo-sccp*  libdbi* htop libedit* libxml2-dev asterisk
sudo apt-get install -y libsoapysdr-dev libi2c-dev libusb-1.0-0-dev ibwxgtk* freeglut3-dev gnuplot libghc-tls* libmnl-dev libsctp-dev
sudo apt install -y libpcsclite-dev libtalloc-dev libortp-dev libsctp-dev libmnl-dev libdbi-dev libdbd-sqlite3 libsqlite3-dev sqlite3 libc-ares-dev libxml2-dev libssl-dev
sudo apt install libdbi-dev libdbd-sqlite3 libortp-dev build-essential libtool autoconf autoconf-archive automake git-core pkg-config libtalloc-dev libpcsclite-dev libpcap-dev

## create folder
mkdir 2G-Packages
cd 2G-Packages
## talloc* failing here
# https://osmocom.org/projects/cellular-infrastructure/wiki/OpenBSC_with_Asterisk
# https://www.atlantic.net/vps-hosting/how-to-install-asterisk-and-freepbx-on-ubuntu/
# https://stackoverflow.com/questions/47198565/asterisk-compilation
git clone https://gitea.osmocom.org/cellular-infrastructure/osmo-trx.git
git clone https://gitea.osmocom.org/cellular-infrastructure/osmo-bts.git
git clone git://git.osmocom.org/openbsc.git




## OpenBSC with Asterisk using LimeSDR 

sudo add-apt-repository -y ppa:myriadrf/drivers
sudo apt-get update -y





## LimeSuite
git clone https://github.com/myriadrf/LimeSuite.git
cd LimeSuite
mkdir buildir && cd buildir
cmake ../
make -j4
sudo make install
sudo ldconfig
cd ..
cd  udev-rules
sudo sh ./install.sh
cd ../..




sudo apt-get install -y libsofia-sip-ua-glib-dev
sudo apt-get install -y build-essential libtool libortp-dev dahdi-source libsctp-dev shtool autoconf automake git-core pkg-config make gcc libosmo-gsup-client*



git clone https://gitea.osmocom.org/osmocom/libosmocore
cd libosmocore
autoreconf -fi && ./configure && make -j5 && sudo make install
cd ..





git clone https://gitea.osmocom.org/osmocom/libosmo-abis
cd libosmo-abis
autoreconf -fi
./configure
make -j5
sudo make install
cd ..



## https://osmocom.org/projects/cellular-infrastructure/wiki/Osmocom_Network_In_The_Box
## https://osmocom.org/projects/osmonitb/wiki/OsmoNITB
## https://osmocom.org/projects/cellular-infrastructure/wiki/OsmoNITB_migration_guide
## https://osmocom.org/projects/cellular-infrastructure/wiki/OpenBSC_with_Asterisk
## https://gist.github.com/shamrin/8b2d6c1493c70544c39e
## https://osmocom.org/projects/cellular-infrastructure/wiki/Latest_Builds
## https://github.com/miraliumre/gsm/blob/master/README.md

##LigGTPNL
git clone https://gitea.osmocom.org/cellular-infrastructure/libgtpnl
cd libgtpnl/
autoreconf -fi && ./configure && make -j5 && sudo make install
cd ..





git clone https://gitea.osmocom.org/osmocom/libosmo-abis
cd libosmo-abis
autoreconf -fi && ./configure && make -j5 && sudo make install
cd ..




git clone https://gitea.osmocom.org/osmocom/libosmo-netif
cd libosmo-netif
autoreconf -fi && ./configure && make -j5 && sudo make install && cd ..


git clone https://gitea.osmocom.org/osmocom/libosmo-sccp
cd libosmo-sccp
autoreconf -fi && ./configure && make -j5 && sudo make install && cd ..




git clone https://gitea.osmocom.org/cellular-infrastructure/libsmpp34
cd libsmpp34
autoreconf -fi && ./configure && make -j5 && sudo make install && cd ..




git clone https://gitea.osmocom.org/cellular-infrastructure/osmo-ggsn
cd osmo-ggsn
autoreconf -fi && ./configure && make -j5 && sudo make install && cd ..




git clone https://gitea.osmocom.org/cellular-infrastructure/openbsc
cd openbsc/openbsc
sudo apt install -y talloc*
autoreconf -fi && ./configure --enable-smpp --enable-osmo-bsc --enable-nat && make -j5 && sudo make install && sudo ldconfig && cd ..



cd osmo
git clone https://gitea.osmocom.org/cellular-infrastructure/osmo-bts
cd osmo-bts
autoreconf -fi
./configure --enable-trx
make
sudo make install
sudo ldconfig

# Asterix
git clone https://github.com/asterisk/asterisk.git
cd asterisk
./configure --with-jansson-bundled
make
sudo make install
make samples



sudo su
apt-get update
apt-get install autoconf
cd /usr/src/asterisk/contrib/scripts
./install_prereq install


cd /usr/asterisk
./bootstrap.sh
./configure <your fancy options>
make menuconfig
make
make install
make samples
make config
