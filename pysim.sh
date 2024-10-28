#!/bin/bash

sudo apt install -y --no-install-recommends pcscd libpcsclite-dev python3 python3-dev python3-pip
git clone https://github.com/osmocom/pysim.git
cd ./pysim
if [[ -z "$VIRTUAL_ENV" ]]; then
    echo "No Python virtual environment is active."
    python3 -m venv /home/briskspirit/.pyvenv
    echo "source ~/.pyvenv/bin/activate" >> ~/.bashrc
    source ~/.pyvenv/bin/activate
else
    echo "Python virtual environment is active: $VIRTUAL_ENV"
fi
pip3 uninstall -y pycrypto
pip3 install pycryptodome pyscard setuptools
pip3 install -r requirements.txt
#echo "pySim has been installed successfully."
#echo "Here is an example usage of pySim (can be used to program your first SIM):"
#echo "./pySim-prog.py -p 0 -n YateBTS -c 1 -x 310 -y 260 -i 310260000000551 -s 8912600000000005512 -o 659BDA03311ACBBE767CB56D565A58D6 -k BA351F5C4690491D86377319E5A6DBCC"