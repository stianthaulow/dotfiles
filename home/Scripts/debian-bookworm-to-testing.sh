#!/bin/bash

sudo sed -i 's/bookworm/testing/g' /etc/apt/sources.list 
sudo apt update
sudo apt -y full-upgrade