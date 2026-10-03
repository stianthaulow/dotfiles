#!/usr/bin/env bash
set -eu

# Kanata reads /dev/input/event* (input group) and writes /dev/uinput (uinput group).
rule=/etc/udev/rules.d/99-kanata-uinput.rules
if [[ ! -f $rule ]] || ! getent group uinput | grep -qw "$USER"; then
  getent group uinput >/dev/null || sudo groupadd --system uinput
  sudo usermod -aG input,uinput "$USER"
  echo 'KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"' | sudo tee "$rule" >/dev/null
  echo uinput | sudo tee /etc/modules-load.d/uinput.conf >/dev/null
  sudo udevadm control --reload-rules
  sudo udevadm trigger
  echo "kanata: log out and back in for the input/uinput groups, then: systemctl --user restart kanata"
fi

systemctl --user daemon-reload
systemctl --user enable kanata.service
