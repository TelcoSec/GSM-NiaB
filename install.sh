
# Debian 12 - RPI4
## 15/10/2024




sudo hostnamectl set-hostname 2g-b0x.telecom.rfs

sudo apt install extrepo
sudo extrepo enable osmocom-latest
sudo apt update -y
sudo apt install -y telnet iptables git limesuite bladerf 
sudo apt install -y osmo-hlr osmo-msc osmo-mgw osmo-stp osmo-bsc osmo-ggsn osmo-sgsn osmo-bts-trx osmo-trx-lms osmo-pcu osmo-cbc osmo-cbc-utils




# Asterix
git clone https://github.com/asterisk/asterisk.git
cd asterisk
sudo apt install uuid-dev libedit* libxml2 libxml2-dev libsqlite3-dev
./configure --with-jansson-bundled
make
sudo make install
make samples
