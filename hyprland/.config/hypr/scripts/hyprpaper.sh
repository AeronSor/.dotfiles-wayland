#!/bin/bash
if pgrep -x "hyprpaper" > /dev/null
then
        pkill hyprpaper
	hyprpaper
else
	hyprpaper
fi
