#!/usr/bin/env bash

printf "Installing python and pip"
rpm-ostree install python3-pip

printf "Installing gnome-extensions-cli"
pip install --prefix=/usr gnome-extensions-cli
