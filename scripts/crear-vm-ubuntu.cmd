@echo off
REM Crea y arranca la VM Ubuntu en Hyper-V (auto-eleva)
powershell -NoProfile -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File','D:\www\wallhaven\scripts\crear-vm-ubuntu.ps1'"
