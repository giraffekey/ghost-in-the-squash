#!/usr/bin/sh

rm GhostInTheSquash-*.zip
cd exports/linux && zip ../../GhostInTheSquash-Linux.zip * && cd ../..
cd exports/windows && zip ../../GhostInTheSquash-Windows.zip * && cd ../..
cp exports/macos/GhostInTheSquash.zip GhostInTheSquash-macOS.zip
cd exports/web && zip ../../GhostInTheSquash-Web.zip * && cd ../..
