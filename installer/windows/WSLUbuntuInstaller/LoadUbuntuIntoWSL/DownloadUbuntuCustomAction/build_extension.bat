@echo off
title Building downloader executable

go build -o downloadUbuntu.exe main.go

echo Downloader compiled successfully
pause