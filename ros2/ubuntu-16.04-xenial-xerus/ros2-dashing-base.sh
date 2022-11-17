#!/usr/bin/env bash
set -eu

# Copyright 2019-2022 Tiryoh
# https://github.com/Tiryoh/ros2_setup_scripts_ubuntu
# Licensed under the Apache License, Version 2.0
#
# REF: https://index.ros.org/doc/ros2/Installation/Linux-Install-Debians/
# by Open Robotics, licensed under CC-BY-4.0
# source: https://github.com/ros2/ros2_documentation

CHOOSE_ROS_DISTRO=dashing
INSTALL_PACKAGE=ros-base

sudo apt-get update
sudo apt-get install -y curl gnupg2 lsb-release build-essential

[[ "$(lsb_release -sc)" == "bionic" ]] || exit 1

printf '\033[33m%s\033[m\n' "=============================================="
printf '\033[33m%s\033[m\n' "ROS Dashing has been reached end-of-life (EOL)"
printf '\033[33m%s\033[m\n' "=============================================="

sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
sudo apt-get update
sudo apt-get install -y ros-$CHOOSE_ROS_DISTRO-$INSTALL_PACKAGE
sudo apt-get install -y python3-argcomplete
sudo apt-get install -y python3-colcon-common-extensions
sudo apt-get install -y python-rosdep python3-vcstool # https://index.ros.org/doc/ros2/Installation/Linux-Development-Setup/
[ -e /etc/ros/rosdep/sources.list.d/20-default.list ] ||
sudo rosdep init
rosdep update --include-eol-distros # https://discourse.ros.org/t/rosdep-and-eol-distros/7640
grep -F "source /opt/ros/$CHOOSE_ROS_DISTRO/setup.bash" ~/.bashrc ||
echo "source /opt/ros/$CHOOSE_ROS_DISTRO/setup.bash" >> ~/.bashrc

set +u

source /opt/ros/$CHOOSE_ROS_DISTRO/setup.bash

echo "success installing ROS2 $CHOOSE_ROS_DISTRO"
echo "Run 'source /opt/ros/$CHOOSE_ROS_DISTRO/setup.bash'"
