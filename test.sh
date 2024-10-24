#!/bin/bash
rm -rf /opt/GSM
mkdir /opt/GSM
cd /opt/GSM
apt update && sudo apt upgrade -y
apt install -y libusb-1.0-0-dev libuhd-dev uhd-host cmake autoconf make
git clone https://github.com/pothosware/SoapySDR
cd /opt/GSM/SoapySDR
mkdir build && cd build && cmake .. && make -j4 && make install && ldconfig
cd /opt/GSM
sudo apt install -y libtool
git clone https://github.com/pothosware/SoapyUHD
cd /opt/GSM/SoapyUHD
mkdir build && cd build && cmake .. && make -j4 && make install && ldconfig
cd /opt/GSM
git clone https://github.com/myriadrf/LimeSuite
cd /opt/GSM/LimeSuite
cd build && cmake .. && make -j4 && make install && ldconfig
cd /opt/GSM
echo “export UHD_MODULE_PATH=/usr/lib/uhd/modules” >> /root/.bashrc
sudo apt install -y cpufrequtils
sudo apt install -y libsctp-dev libconfig++-dev libconfig-dev libmbedtls-dev
cd /opt/GSM
apt install -y libtalloc-dev libgnutls28-dev libmnl-dev
git clone https://github.com/osmocom/libosmocore
cd /opt/GSM/libosmocore
autoreconf -fi && ./configure && make -j4 && make install && ldconfig
cd /opt/GSM
apt install -y libortp-dev
git clone https://github.com/osmocom/libosmo-abis
cd /opt/GSM/libosmo-abis
autoreconf -fi && ./configure –disable-dahdi && make -j4 && make install && ldconfig
cd /opt/GSM
git clone https://github.com/osmocom/libosmo-netif
cd /opt/GSM/libosmo-netif
autoreconf -fi && ./configure && make -j4 && make install && ldconfig
cd /opt/GSM
git clone https://github.com/osmocom/osmo-hlr
apt install -y libsqlite3-dev
cd /opt/GSM/osmo-hlr
autoreconf -fi && ./configure && make -j4 && make install && ldconfig
cd /opt/GSM
git clone https://github.com/osmocom/osmo-mgw
cd /opt/GSM/osmo-mgw
autoreconf -fi && ./configure && make -j4 && make install && ldconfig
cd /opt/GSM
git clone git://git.osmocom.org/libgtpnl.git
cd /opt/GSM/libgtpnl
autoreconf -fi && ./configure && make -j4 && make install && ldconfig
cd /opt/GSM
git clone https://github.com/osmocom/libosmo-sccp
cd /opt/GSM/libosmo-sccp
autoreconf -fi && ./configure && make -j4 && make install && ldconfig
cd /opt/GSM
git clone https://github.com/osmocom/osmo-ggsn
cd /opt/GSM/osmo-ggsn
autoreconf -fi && ./configure –enable-gtp-linux && make -j4 && make install && ldconfig
cd /opt/GSM
apt install -y libc-ares-dev
git clone https://github.com/osmocom/osmo-sgsn
cd /opt/GSM/osmo-sgsn
autoreconf -fi && ./configure && make -j4 && make install && ldconfig
cd /opt/GSM
git clone https://github.com/osmocom/osmo-msc
apt install -y libdbi-dev
cd /opt/GSM/osmo-msc
autoreconf -fi && ./configure && make -j4 && make install && ldconfig
cd /opt/GSM
git clone https://github.com/osmocom/osmo-bsc
cd /opt/GSM/osmo-bsc
autoreconf -fi && ./configure && make -j4 && make install && ldconfig
cd /opt/GSM
apt install -y libsofia-sip-ua-glib-dev
git clone https://github.com/osmocom/osmo-sip-connector
cd /opt/GSM/osmo-sip-connector
autoreconf -fi && ./configure && make -j4 && make install && ldconfig
cd /opt/GSM
git clone https://github.com/osmocom/osmo-trx
cd /opt/GSM/osmo-trx
git checkout 1.1.0
autoreconf -fi && ./configure –with-lms && make -j4 && make install && ldconfig
cd /opt/GSM
git clone https://github.com/osmocom/osmo-bts
cd /opt/GSM/osmo-bts
git checkout 1.1.0
autoreconf -fi && ./configure –enable-trx && make -j4 && make install && ldconfig
cd /opt/GSM
git clone https://github.com/bbaranoff/osmocom-nitb-standalone /etc/osmocom
cp -r /usr/local/bin/. /usr/bin
apt install libdbd-sqlite3
mkdir /var/lib/osmocom
wget https://raw.githubusercontent.com/bbaranoff/PImpMyPi/main/osmo-msc.service
cp osmo-msc.service /lib/systemd/system/osmo-msc.service
systemctl daemon-reload
cd /etc/osmocom
./osmo-all enable
cd /opt/GSM
update-alternatives –set gcc /usr/bin/gcc-10
cd /opt/GSM
wget http://downloads.asterisk.org/pub/telephony/asterisk/releases/asterisk-11.25.3.tar.gz
tar zxvf asterisk-11.25.3.tar.gz
cd /opt/GSM/asterisk-11.25.3
apt install libncurses-dev libxml2-dev
./configure
make
make install
make config
ldconfig
cd /etc/asterisk
rm extensions.conf
wget https://raw.githubusercontent.com/bbaranoff/PImpMyPi/main/extensions.conf
rm sip.conf
wget https://raw.githubusercontent.com/bbaranoff/PImpMyPi/main/sip.conf




cd /etc/osmocom
sudo ./osmo-all
sudo osmo-trx-lms
sudo osmo-bts-trx