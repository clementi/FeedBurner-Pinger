#!/usr/bin/env bash

sudo apt-get install htop -y

sudo gem install foreman
sudo gem install bundler

echo "export PORT=9000" >> /home/vagrant/.bashrc
