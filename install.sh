
# Debian 12 - RPI4

sudo apt install extrepo
sudo extrepo enable osmocom-latest
sudo apt update -y
sudo apt install telnet         \
            iptables       \
            limesuite      \
            osmo-hlr       \
            osmo-msc       \
            osmo-mgw       \
            osmo-stp       \
            osmo-bsc       \
            osmo-ggsn      \
            osmo-sgsn      \
            osmo-bts-trx   \
            osmo-trx-lms   \
            osmo-pcu       \
            osmo-cbc       \
            osmo-cbc-utils -y

