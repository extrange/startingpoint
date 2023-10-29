#!/usr/bin/env bash

set -oue pipefail

rm /etc/profile.d/nano-default-editor.*

# shellcheck disable=2016
printf 'if [ -z "$EDITOR" ]; then export EDITOR="/usr/bin/vim"; fi' > /etc/profile.d/vim-default-editor.sh