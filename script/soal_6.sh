#!/bin/bash

apt update 
apt install -y journalctl

#Di valmar (Slave)
dig @192.217.2.3 k12.com SOA
dig @192.217.2.4 k12.com SOA
