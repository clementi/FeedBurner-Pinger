#!/usr/bin/env bash

sudo apt-get install htop -y

sudo gem install sinatra
sudo gem install haml
sudo gem install maruku

echo "export PORT=9000" >> /home/vagrant/.bashrc
