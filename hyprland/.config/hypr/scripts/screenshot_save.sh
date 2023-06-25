#!/bin/bash
grim -g "$(slurp)" ~/Pictures/$(date +'%s_grim.png')
dunstify "Screenshot saved"
