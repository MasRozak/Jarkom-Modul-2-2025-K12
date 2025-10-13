#!/bin/bash

apt-get update 
apt-get install -y journalctl

#Di valmar (Slave)
dig @192.217.2.3 k12.com SOA
dig @192.217.2.4 k12.com SOA
