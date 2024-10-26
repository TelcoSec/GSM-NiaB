#!/bin/sh
cmd="${1:-status}"
set -ex
systemctl $cmd osmo-hlr osmo-msc osmo-mgw osmo-ggsn osmo-sgsn osmo-stp osmo-bsc osmo-hnbgw osmo-sip-connector osmo-cbc osmo-pcu
