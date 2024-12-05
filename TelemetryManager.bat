@echo off
title Telemetry Manager by Useful Stuffs (http://github.com/usefulstuffs)
color 02
:init
 setlocal DisableDelayedExpansion
 set cmdInvoke=1
 set winSysFolder=System32
 set "batchPath=%~0"
 for %%k in (%0) do set batchName=%%~nk
 set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"
 setlocal EnableDelayedExpansion

:checkPrivileges
  NET FILE 1>NUL 2>NUL
  if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
  if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)
  ECHO.
  ECHO **************************************
  ECHO Requesting admin...
  ECHO **************************************

  ECHO Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
  ECHO args = "ELEV " >> "%vbsGetPrivileges%"
  ECHO For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
  ECHO args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
  ECHO Next >> "%vbsGetPrivileges%"

  if '%cmdInvoke%'=='1' goto InvokeCmd 

  ECHO UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
  goto ExecElevation

:InvokeCmd
  ECHO args = "/c """ + "!batchPath!" + """ " + args >> "%vbsGetPrivileges%"
  ECHO UAC.ShellExecute "%SystemRoot%\%winSysFolder%\cmd.exe", args, "", "runas", 1 >> "%vbsGetPrivileges%"

:ExecElevation
 "%SystemRoot%\%winSysFolder%\WScript.exe" "%vbsGetPrivileges%" %*
 exit /B

:gotPrivileges
 setlocal & cd /d %~dp0
 if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)

 ::::::::::::::::::::::::::::
 ::START
 ::::::::::::::::::::::::::::

:begin
cls
echo Created by Useful Stuffs
echo This script is reversible with manual tweaks to the system.
timeout 5 > NUL
echo Checking Windows version...
ver | find "10.0" >nul 2>&1
if "%errorlevel%" neq "0" (
	color 0c
	echo ERROR. The script requires Windows 10 or 11
	echo Please update your system and try again.
	echo Closing in 5 seconds...
	timeout 5 > nul
	exit
)
echo Supported Windows Version found.
echo Checking for incompatible packages...
dism /online /get-packages | find "Z-Atlas-NoTelemetry" >nul 2>&1
if "%errorlevel%" equ "0" (
	color 0c
	echo ERROR. Atlas NoTelemetry Package was found in this system.
	echo Please uninstall the Atlas Package before using this script.
	echo Closing in 5 seconds...
	timeout 5 > nul
	exit
)
echo No Incompatible packages were found, continuing...
timeout 5 > nul
cls
echo Created by Useful Stuffs
echo This script is reversible with manual tweaks to the system.
timeout 5 > NUL
echo.
echo Please choose an action below:
echo.
echo [1] Disable Telemetry (default)
echo.
echo [2] Enable Telemetry
echo.
echo Any actions done with this tool requires a reboot.
echo.
set /p action=Action: 
if "%action%" == "" set action=1
if %action% == 1 goto teldisable
if %action% == 2 goto telenable
echo.
echo Please select an action!!
pause > NUL
goto begin

:teldisable
cls
echo OK, disabling telemetry...
echo.
echo ------------------------------------------------------------
echo Telemetry Manager logs
echo ------------------------------------------------------------
taskkill /f /im CompatTelRunner.exe
takeown /f C:\Windows\System32\CompatTelRunner.exe
icacls C:\Windows\System32\CompatTelRunner.exe /grant %username%:F
rename C:\Windows\System32\CompatTelRunner.exe CompatTelRunner.bak
sc stop DiagTrack
sc config DiagTrack start=disabled
reg add "HKLM\Software\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "MaxTelemetryAllowed" /t REG_DWORD /d 0 /f
echo ------------------------------------------------------------
echo End logs
echo ------------------------------------------------------------
echo Done. Do you want to restart?
set /p var=['Y'es,'N'o] 
if "%var%" == "y" (
shutdown -r -t 00 -f
exit
) else (
exit
)

:telenable
cls
echo OK, enabling telemetry...
echo.
echo ------------------------------------------------------------
echo Telemetry Manager logs
echo ------------------------------------------------------------
takeown /f C:\Windows\System32\CompatTelRunner.bak
icacls C:\Windows\System32\CompatTelRunner.bak /grant %username%:F
rename C:\Windows\System32\CompatTelRunner.bak CompatTelRunner.exe
sc config DiagTrack start=auto
sc start DiagTrack
reg add "HKLM\Software\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 1 /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 1 /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "MaxTelemetryAllowed" /t REG_DWORD /d 1 /f
echo ------------------------------------------------------------
echo End logs
echo ------------------------------------------------------------
echo Done. Do you want to restart?
set /p var=['Y'es,'N'o] 
if "%var%" == "y" (
shutdown -r -t 00 -f
exit
) else (
exit
)