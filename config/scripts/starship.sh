#!/usr/bin/env bash

set -oue pipefail

curl -Lo /tmp/starship.tar.gz "https://github.com/starship/starship/releases/latest/download/starship-x86_64-unknown-linux-gnu.tar.gz"

tar -xzf /tmp/starship.tar.gz -C /tmp

install -c -m 0755 /tmp/starship /usr/bin

# Cannot put in /etc/profiles.d due to vte.sh overwriting $PROMPT_COMMAND
# https://gitlab.gnome.org/GNOME/vte/-/issues/37
echo 'eval "$(starship init bash)"' >> /etc/bashrc