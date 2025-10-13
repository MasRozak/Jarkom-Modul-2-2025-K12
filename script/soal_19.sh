#!/bin/bash

#Di Tirion, Valmar, Sirion, Lindon, Vingilot
sudo systemctl enable bind9

# On web/proxy servers
sudo systemctl enable nginx
sudo systemctl enable php*-fpm # versi apapun
