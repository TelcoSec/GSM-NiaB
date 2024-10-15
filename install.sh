
# Debian 12 - RPI4
## 15/10/2024
sudo apt install extrepo
sudo extrepo enable osmocom-latest
sudo apt update -y
sudo apt install -y  telnet iptables git limesuite 
sudo apt install -y osmo-hlr  osmo-msc  osmo-mgw  osmo-stp  osmo-bsc  osmo-ggsn osmo-sgsn osmo-bts-trx osmo-trx-lms osmo-pcu osmo-cbc osmo-cbc-utils
