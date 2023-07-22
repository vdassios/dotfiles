#!/usr/bin/env bash

# display critical alert when battery is under 20%
# and play glass.ogg sound three times
# but only if the battery is not charging 
while :
do
  STATUS=$(acpi -b | sed -n 's/^Battery 0: \([A-Za-z]*\).*/\1/p')
	POWER=$(acpi -b | sed -ne 's/Battery 0.* \([0-9]*\)%.*/\1/p')
  if [[ ($POWER -le 20) && ($STATUS = 'Discharging') ]]; then
		notify-send --urgency=critical "Connect charger" "Battery power is lower than 20%!" && cvlc --play-and-exit --gain=5 /usr/share/sounds/gnome/default/alerts/glass.ogg{,,}
	fi
sleep 60
done
