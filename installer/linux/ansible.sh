#!/bin/bash

# Install pip from Python 3
apt install python3-pip

# DON'T UPDATE PIP IF IT HAS BEEN INSTALLED VIA THE DISTRO
# 
# Update pip since the linux repos don't always have the latest version
# This is also not the recommended method since there are issues
# when a binary tries to update itself
# https://pip.pypa.io/en/stable/installing/#upgrading-pip
# python3 -m pip install -U pip

# Install ansible via pip
pip3 install ansible
