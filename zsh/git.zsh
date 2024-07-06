#!/usr/bin/env bash

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `git.sh` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Step 1: Add git mods
echo "------------------------------"
echo "Augmenting Git with custom templates and variables"

read -r -p "Enter your global Git user name: " answer
git config --global user.name "$answer"

read -r -p "Enter your global Git email address: " answer
git config --global user.email "$answer"
