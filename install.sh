
sudo apt update -y
sudo apt install git vim curl python-is-python3 autoconf libtool libosmocore talloc* liburing* libpcsclite* gnutls* libortp-dev libosmo-sccp* libsmpp34* libdbi* htop libedit* libxml2-dev




git clone https://gitea.osmocom.org/cellular-infrastructure/osmo-trx.git
sudo apt-get install --no-install-recommends libusb-1.0-0-dev libboost-dev
sudo apt-get install libuhd-dev uhd-host





git clone https://gitea.osmocom.org/cellular-infrastructure/osmo-bts.git



git clone git://git.osmocom.org/openbsc.git




## OpenBSC with Asterisk using LimeSDR 

sudo add-apt-repository -y ppa:myriadrf/drivers
sudo apt-get update -y

## install core library and build dependencies
sudo apt-get install git g++ cmake libsqlite3-dev -y

## install hardware support dependencies
sudo apt-get install libsoapysdr-dev libi2c-dev libusb-1.0-0-dev -y

## install graphics dependencies
sudo apt-get install ibwxgtk* freeglut3-dev gnuplot -y

## install other dependency
sudo apt-get install libghc-tls* libmnl-dev libsctp-dev -y


## LimeSuite
git clone https://github.com/myriadrf/LimeSuite.git
cd LimeSuite
mkdir buildir && cd buildir
cmake ../
make -j4
sudo make install
sudo ldconfig

cd LimeSuite/udev-rules
sudo sh ./install.sh





sudo apt-get install libsofia-sip-ua-glib-dev
sudo apt-get install build-essential libtool libortp-dev dahdi-source libsctp-dev shtool autoconf automake git-core pkg-config make gcc libosmo-gsup-client*


git clone https://gitea.osmocom.org/osmocom/libosmo-abis
cd libosmo-abis
autoreconf -fi
./configure
make -j5
sudo make install


##LigGTPNL
git clone https://gitea.osmocom.org/cellular-infrastructure/libgtpnl
autoreconf -fi && ./configure && make && make install


cd osmo
git clone https://gitea.osmocom.org/osmocom/libosmocore
cd libosmocore
autoreconf -fi
./configure
make -j5
sudo make install


cd osmo
git clone https://gitea.osmocom.org/osmocom/libosmo-abis
cd libosmo-abis
autoreconf -fi
./configure
make -j5
sudo make install

cd osmo
git clone https://gitea.osmocom.org/osmocom/libosmo-netif
cd libosmo-netif
autoreconf -fi
./configure
make -j5
sudo make install
cd osmo
git clone https://gitea.osmocom.org/osmocom/libosmo-sccp
cd libosmo-sccp
autoreconf -fi
./configure
make -j5
sudo make install
cd osmo
git clone https://gitea.osmocom.org/cellular-infrastructure/libsmpp34
cd libsmpp34
autoreconf -fi
./configure
make
sudo make install
cd osmo
git clone https://gitea.osmocom.org/cellular-infrastructure/osmo-ggsn
cd osmo-ggsn
autoreconf -fi
./configure
make -j5
sudo make install
cd osmo
git clone https://gitea.osmocom.org/cellular-infrastructure/openbsc
cd openbsc/openbsc
autoreconf -fi
./configure --enable-smpp --enable-osmo-bsc --enable-nat
make -j5
sudo make install $$ sudo ldconfig
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


