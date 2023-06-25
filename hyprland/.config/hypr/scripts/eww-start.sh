#!/bin/bash
if pgrep -x "eww" > /dev/null
then
        pkill eww
	eww open bar
else
	eww open bar
fi
