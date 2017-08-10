#!/bin/bash

apt-get update
apt-get -y upgrade
apt-get install -y python2.7
ln -s /usr/bin/python2.7 /usr/bin/python

