#!/bin/bash

#Di elrond
apt update 
apt install -y apache2-utils

# Test dynamic app
ab -n 500 -c 10 http://www.k12.com/app/

# Test static files
ab -n 500 -c 10 http://www.k12.com/static/