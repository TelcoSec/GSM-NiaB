#!/bin/bash

# Debian 12  - RPI4
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
RPI4 + LimeSDR + OsmoCom + eSIMs
"""
show_menu() {
  clear
  echo "---------------------------"
  echo "      RFS GSM Menu         "
  echo "---------------------------"
  echo "1. Install Dependencies"
  echo "2. Install LimeSDR Drivers"
  echo "3. Install Asterisk"
  echo "4. All - Full Install"
  echo "5. Configure OsmoCom"
  echo "6. Exit"
  echo "---------------------------"
  echo -n "Enter your choice: "
}
# Main loop
while true; do
  show_menu
  read choice

  case $choice in
    1)
      echo "You selected Option 1"
      # Add your code for Option 1 here
      read -p "Press Enter to continue..."
      ;;
    2)
      echo "2 - Installing LimeSDR Drivers"
      # Add your code for Option 2 here
      install_radio_packages
      read -p "Press Enter to continue..."
      ;;
    3)
      echo "3 - Installing Asterisk"
      # Add your code for Option 3 here
      install_asterisk
      read -p "Press Enter to continue..."
      ;;    
    4)
      echo "You selected Option 3"
      # Add your code for Option 3 here
      read -p "Press Enter to continue..."
      ;;
    5)
      echo "You selected Option 3"
      # Add your code for Option 3 here
      read -p "Press Enter to continue..."
      ;;      
    6)
      echo "Exiting..."
      break
      ;;
    *)
      echo "Invalid choice. Please try again."
      ;;
  esac
done

sudo hostnamectl set-hostname 2g-b0x.telecom.rfs

mkdir $HOME/RFS_OSMOCOM
cd $HOME/RFS_OSMOCOM


add_osmocom_repo() {
 sudo apt update -y
 echo "Adding Osmocom repo....\n"
 sudo apt install extrepo
 sudo extrepo enable osmocom-latest
}

install_osmocom() {
echo "Install Osmocom Packages....\n"
 sudo apt install -y osmo-hlr osmo-msc osmo-mgw osmo-stp osmo-bsc
 sudo apt install -y osmo-ggsn osmo-sgsn osmo-bts-trx osmo-trx-lms osmo-pcu osmo-cbc osmo-cbc-utils
}

install_basic_packages() {
echo "Install Basic Packages....\n"
 sudo apt install -y telnet \
 iptables git python3-pip python3-flask \
 rpi-imager wireshark tcpdump \
 cmake build-essential gawk gcc g++ gfortran \
 git texinfo bison  wget bzip2 libncurses-dev \
 libssl-dev openssl zlib1g-dev libsqlite3-dev \
 libtool autoconf autoconf-archive automake git-core pkg-config cpufrequtils 
}


install_radio_packages() {
echo "Install Radio Packages....\n"
  sudo apt install -y libhackrf-dev hackrf gr-gsm
  sudo apt remove xtrx-dkms
  sudo apt autoremove
  sudo apt install -y libuhd-dev uhd-host gqrx-sdr  limesuite bladerf cardpeek \
  libsctp-dev libconfig++-dev libconfig-dev libmbedtls-dev \
  libtalloc-dev libgnutls28-dev libmnl-dev \
  libsoapysdr-dev libi2c-dev libusb-1.0-0-dev \
  libwxgtk* freeglut3-dev \
  libi2c-dev libusb-1.0-0-dev libwxgtk* freeglut3-dev sqlite3 \
  libdbi-dev libdbd-sqlite3 libortp-dev \
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
}



install_asterisk() {
# Asterix
# Docs https://docs.asterisk.org/
echo "Installing Asterisk Packages....\n"
git clone https://github.com/asterisk/asterisk.git
cd asterisk
sudo apt install uuid-dev libedit* libxml2 libxml2-dev libsqlite3-dev libpcsclite-dev libpcap-dev
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


install_other_deps(){
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

}


sudo apt install libxcb-cursor0
export QT_QPA_PLATFORM=offscreen

LimeUtil --info

sudo systemctl daemon-reload

sudo chown osmocom:osmocom /etc/osmocom

