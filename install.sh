
# Debian 12 - RPI4
## 15/10/2024




sudo hostnamectl set-hostname 2g-b0x.telecom.rfs

sudo apt install extrepo
sudo extrepo enable osmocom-latest
sudo apt update -y
sudo apt install -y telnet iptables git limesuite bladerf python3-pip python3-flask
sudo apt install -y osmo-hlr osmo-msc osmo-mgw osmo-stp osmo-bsc osmo-ggsn osmo-sgsn osmo-bts-trx osmo-trx-lms osmo-pcu osmo-cbc osmo-cbc-utils
sudo apt install libhackrf-dev hackrf gr-gsm -y
sudo apt install libdbi-dev libdbd-sqlite3 libortp-dev build-essential libtool autoconf autoconf-archive automake git-core pkg-config libtalloc-dev libpcsclite-dev libpcap-dev



# Asterix
# Docs https://docs.asterisk.org/
git clone https://github.com/asterisk/asterisk.git
cd asterisk
sudo apt install uuid-dev libedit* libxml2 libxml2-dev libsqlite3-dev
./configure --with-jansson-bundled
make
sudo make install
sudo make config
sudo make samples
sudo make basic-pbx
sudo make install-logrotate

sudo systemctl enable asterisk
sudo systemctl restart asterisk


sudo apt-get install build-essential cmake gawk gcc g++ gfortran git texinfo bison  wget bzip2 libncurses-dev libssl-dev openssl zlib1g-dev


sudo apt-get install -y \
    cmake \
    autoconf \
    libtool \
    pkg-config \
    build-essential \
    python3-docutils \
    libcppunit-dev \
    swig \
    doxygen \
    liblog4cpp5-dev \
    python3-scipy \
    python-gtk* \
    gnuradio-dev \
    gr-osmosdr \
    libosmocore-dev