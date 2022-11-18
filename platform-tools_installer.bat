@echo off
title Platform Tools Installer
setlocal EnableDelayedExpansion
if exist !PROGRAMFILES(X86)! set bitness=64 || set bitness=32
if not exist !Temp!\arg.txt echo.%~1>!Temp!\arg.txt
:Admin_permissions
>nul 2>&1 %SYSTEMROOT%\system32\icacls.exe %SYSTEMROOT%\system32\WDI
if %errorlevel% EQU 0 cd /d %~dp0 && goto :Download_dialog_app
echo.Запрос прав администратора...
echo.Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo.UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %bitness:"=""%", "", "runas", 1 >> %temp%\getadmin.vbs
%temp%\getadmin.vbs
del /f /q %temp%\getadmin.vbs
exit
:Download_dialog_app
echo. && echo.Скачивание необходимых файлов...
if exist !Temp!\dlgOpenFolder.exe del /f /q !Temp!\dlgOpenFolder.exe
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12}; &"{Invoke-WebRequest https://github.com/SunsetTechuila/Platform-tools-Installer/raw/main/dlgOpenFolder.exe -outfile '%Temp%\dlgOpenFolder.exe'}""
CLS
:Check_start_argument
for /f "delims=" %%a in (!Temp!\arg.txt) do set "arg=%%a"
del /f /q !Temp!\arg.txt
if not "%arg%"=="" set "ArchivePath=%arg%" && goto :Ask_install_path
:Download_PT
echo. && echo.Скачивание Platform tools...
if exist !Temp!\platform-tools.zip del /f /q !Temp!\platform-tools.zip
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12}; &"{Invoke-WebRequest https://dl.google.com/android/repository/platform-tools-latest-windows.zip -outfile '%Temp%\platform-tools.zip'}""
set "ArchivePath=%Temp%\platform-tools.zip"
CLS
:Ask_install_path
echo. && echo.Выберите путь, куда вы хотели бы распаковать Platform tools
echo. && echo.Выбирайте такой путь, где они вам не будут мешать, чтобы вы их не удалили
ping -n 2 127.0.0.1 >nul
for /f "delims=" %%a in ('!Temp!\dlgOpenFolder.exe') do set "TargetPath=%%a"
if "%TargetPath%"=="C:\\" set "TargetPath=%TargetPath:~0,-1%"
if not defined TargetPath pause && exit
CLS
:Unpack
echo. && echo.Распаковка Platform tools...
if exist !TargetPath!\platform-tools rmdir /s /q !TargetPath!\platform-tools
powershell -Command "& {Expand-Archive -Path '%ArchivePath%' -DestinationPath '%TargetPath%' -Force}"
CLS
:Add_to_path
echo. && echo.Добавление в PATH...
echo.%PATH% | find "%TargetPath%\platform-tools" >nul
if %errorlevel% NEQ 0 (powershell -Command "& {[Environment]::SetEnvironmentVariable('Path', $env:Path + ';%TargetPath%\platform-tools', 'User')}") >nul
del /f /q !Temp!\platform-tools.zip
del /f /q !Temp!\arg.txt
del /f /q !Temp!\dlgOpenFolder.exe
CLS && echo. && echo.Успешно^^!
echo. && pause && exit
