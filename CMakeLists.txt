# Copyright (C) 2013 CoDyCo
# Author: Gabriele Nava
# CopyPolicy: Released under the terms of the GNU GPL v2.0.

cmake_minimum_required(VERSION 2.8.11)
project(TEMP_INSTALLATION)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

set(TEMPORARY_SHARE_DIR "${CMAKE_INSTALL_PREFIX}/share/TEMP")
# Fake installation. Just installs the README.md file
#install(FILE ${CMAKE_CURRENT_SOURCE_DIR}/README.md DESTINATION ${TEMPORARY_SHARE_DIR})
install(CODE "MESSAGE(\"This repository simply acts as a container\")")
