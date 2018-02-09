#!/bin/sh

# update apt
sudo apt-get update
sudo apt-get upgrade

# essentials
sudo apt-get install tmux vim

# python
sudo apt-get install python-setuptools python-dev build-essential
sudo easy_install pip
sudo pip install --upgrade virtualenv

#samba
sudo apt-get install samba samba-common-bin

# add user
sudo adduser noise
sudo usermod -aG sudo noise

sudo cp ./smb.conf /etc/samba/smb.conf
sudo smbpasswd -a noise
