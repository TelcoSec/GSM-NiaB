# GSM In A B0x



## Portable GSM Stack

The goal of this lab is to create a GSM network with internet access and execute calls between our mobile phones.

SISO for MIMO use BladeRF
## OS
1. Debian 12 RPI4
2. Linux RPI4-GSM-B0x 6.6.31+rpt-rpi-v8 #1 SMP PREEMPT Debian 1:6.6.31-1+rpt1 (2024-05-29) aarch64 GNU/Linux

## Installation

1. Install in Debian 12 - no GUI
2. Download my Image Ready for RPI4


## Configuration
- 2 SIM cards provisioned to our network
- 1 BTS
- GSM Core - OSMO
- PBX Asterix
- Internet Connection



## Learn GSM
- https://gsm.learn-telecom.com
- https://ss7.learn-telecom.com
- https://diameter.learn-telecom.com
- https://isdn.learn-telecom.com
- https://sim-cards.learn-telecom.com
- https://gtp.learn-telecom.com
- https://sip.learn-telecom.com
- https://ims.learn-telecom.com
- https://mobiles.learn-telecom.com



## Console Access

1. telnet 127.0.0.1 4264 - CBC
2. telnet 127.0.0.1 4258 - HLR
3. telnet 127.0.0.1 4242 - BSC
4. telnet 127.0.0.1 4241 - BTS
5. telnet 127.0.0.1 4237 - OsmoTRX
## Versions used

## Osmocom Versions
- OsmoCBC version 0.5.0
- OsmoHLR version 1.8.0
- OsmoBTS version 1.8.0
- OsmoTRX version 1.7.0
- OsmoBSC version 1.12.1
- OsmoMSC version 1.12.1
- OsmoMGW version 1.13.1
- OsmoSTP version 2.0.1
- OsmoSGSN version 1.12.1
- OsmoGGSN version 1.12.0


## LimeSDR

######################################################
## LimeSuite information summary
######################################################

### Version information:
- Library version:      v23.11.0-23.11.0
- Build timestamp:      2023-11-20
- Interface version:    v2023.11.0
- Binary interface:     23.11-1
