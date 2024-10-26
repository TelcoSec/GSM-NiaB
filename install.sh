
# Debian 12 / Ubuntu 24 - RPI4
## 15/10/2024


echo """ 

 _____    _                 _____           
|_   _|  | |               /  ___|          
  | | ___| | ___ ___ ______\ `--.  ___  ___ 
  | |/ _ \ |/ __/ _ \______|`--. \/ _ \/ __|
  | |  __/ | (_| (_) |     /\__/ /  __/ (__ 
  \_/\___|_|\___\___/      \____/ \___|\___|
                                            
www.telco-sec.com                                            
www.learn-telecom.com
by RFS
"""



sudo hostnamectl set-hostname 2g-b0x.telecom.rfs


add_osmocom_repo() {
 sudo apt update -y
 echo "Adding Osmocom repo....\n"
 sudo apt install extrepo
 sudo extrepo enable osmocom-latest
}

install_osmocom() {
 sudo apt install -y osmo-hlr osmo-msc osmo-mgw osmo-stp osmo-bsc
 sudo apt install -y osmo-ggsn osmo-sgsn osmo-bts-trx osmo-trx-lms osmo-pcu osmo-cbc osmo-cbc-utils
}

install_basic_tools() {
 sudo apt install -y telnet \
 iptables git python3-pip python3-flask \
 rpi-imager wireshark tcpdump \
 cardpeek cmake build-essential gawk gcc g++ gfortran \
 git texinfo bison  wget bzip2 libncurses-dev \
 libssl-dev openssl zlib1g-dev libsqlite3-dev


}


install_asterisk() {
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
cd ..
sudo systemctl enable asterisk
sudo systemctl restart asterisk
}

sudo apt install libhackrf-dev hackrf gr-gsm -y

sudo apt install -y libdbi-dev libdbd-sqlite3 libortp-dev build-essential libtool autoconf autoconf-archive automake git-core pkg-config libtalloc-dev libpcsclite-dev libpcap-dev
sudo apt install -y libuhd-dev uhd-host gqrx-sdr  limesuite bladerf
sudo apt install -y libsctp-dev libconfig++-dev libconfig-dev libmbedtls-dev
sudo apt install -y libtalloc-dev libgnutls28-dev libmnl-dev
sudo apt install -y libsoapysdr-dev libi2c-dev libusb-1.0-0-dev
sudo apt install -y libwxgtk3.0-dev freeglut3-dev
sudo apt install -y libi2c-dev libusb-1.0-0-dev libwxgtk* freeglut3-dev sqlite3 




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








sudo apt-get update && sudo apt-get -y install \
pkg-config autoconf automake libtool libfftw3-dev libusb-1.0-0-dev libusb-dev libhidapi-dev libopengl-dev \
qtbase5-dev qtchooser libqt5multimedia5-plugins qtmultimedia5-dev libqt5websockets5-dev \
qttools5-dev qttools5-dev-tools libqt5opengl5-dev libqt5quick5 libqt5charts5-dev \
qml-module-qtlocation  qml-module-qtpositioning qml-module-qtquick-window2 \
qml-module-qtquick-dialogs qml-module-qtquick-controls qml-module-qtquick-controls2 qml-module-qtquick-layouts \
libqt5serialport5-dev qtdeclarative5-dev qtpositioning5-dev qtlocation5-dev libqt5texttospeech5-dev \
qtwebengine5-dev qtbase5-private-dev libqt5gamepad5-dev libqt5svg5-dev \
libfaad-dev libflac-dev zlib1g-dev libboost-all-dev libasound2-dev pulseaudio libopencv-dev libxml2-dev bison flex \
ffmpeg libavcodec-dev libavformat-dev libopus-dev doxygen graphviz



cd /etc/osmocom
sudo chown osmocom:osmocom *
sudo osmo-msc -c osmo-msc.cfg.new
sudo osmo-bsc
sudo osmo-trx-lms -C /etc/osmocom/osmo-trx-lms.cfg.new
sudo osmo-bts-trx -c osmo-bts-trx.cfg



sudo osmo-bts-trx -c /etc/osmocom/osmo-bts-trx.cfg
