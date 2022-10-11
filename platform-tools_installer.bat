@echo off
title Platform Tools Installer
setlocal EnableDelayedExpansion
if not "%~1"=="" set archive_path=%~1 && goto :unpack 
:download
echo. && echo.Скачивание Platform Tools...
if exist !userprofile!\platform-tools rmdir /s /q !userprofile!\platform-tools
powershell -Command "& {Invoke-WebRequest https://dl.google.com/android/repository/platform-tools-latest-windows.zip -outfile !userprofile!\platform-tools.zip}"
archive_path=!userprofile!\platform-tools.zip
CLS
:unpack
echo. && echo.Распаковка Platform Tools...
powershell -Command "& {Expand-Archive -Path !archive_path!  -DestinationPath !userprofile! -Force}"
CLS
:add_to_path
echo. && echo. Добавление в PATH...
echo.%PATH% | find "platform-tools" >nul
if %errorlevel% NEQ 0 (powershell -Command "& {[Environment]::SetEnvironmentVariable('Path', $env:Path + ';$env:userprofile\platform-tools', 'User')}") >nul
del /f /q !userprofile!\platform-tools.zip
CLS && echo. && echo.Успешно
echo. && pause && exit
exit
