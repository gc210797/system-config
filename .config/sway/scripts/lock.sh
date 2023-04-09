#!/bin/bash

# If idle for 15s, power down the output
swayidle -w \
		timeout 10 'swaymsg "output * dpms off"' \
		resume 'swaymsg "output * dpms on"' &


# Lock screen immediately
pgrep swaylock || swaylock-fancy


# Kill the last instance of swayidle so the timer doesn't keep running in background
pkill --newest swayidle
