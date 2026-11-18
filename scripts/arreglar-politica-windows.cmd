@echo off
REM Diagnostico y arreglo de politicas que bloquean ejecutables (auto-eleva)
powershell -NoProfile -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File','D:\www\wallhaven\scripts\arreglar-politica-windows.ps1'"
