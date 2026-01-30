#!/bin/bash

# Disable the "Are you sure you want to open this application?" dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Allow running files downloaded from the internet
sudo spctl --master-disable

killall Dock
