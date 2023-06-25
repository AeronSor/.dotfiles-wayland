#!/bin/bash
grim -g "$(slurp)" - | wl-copy
dunstify "Screenshot copied"
