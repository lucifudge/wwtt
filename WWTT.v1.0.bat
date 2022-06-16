    
@echo off
Title Windows Weefee Transfer Tool (WWTT) v1.0

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: Windows Weefee Transfer Tool (WWTT) by lucifudge
::   v1.0
::
:: This tool provides a command-line interface for bulk backup and restore
::  of wireless profiles by automating netsh import & export commands.
::
:: Usage:
::  - Performing a Backup:
::     - Save WWTT.bat file to a (preferably freshly formatted) flash drive
::     - Insert flash drive into source computer and run WWTT.bat file
::     - Choose Option 1, when instructed type "Service Order" and press Enter
::     - Follow instructions to close script, then safely remove flash drive
::          WARNING: Any existing backups are deleted when performing a new one
::
::  - Performing a Restore:
::     - Insert flash drive into destination computer and run WWTT.bat file
::     - Choose Option 2, when instructed type "Service Order" from Backup and press Enter
::     - Verify information is correct and press Y to proceed with import
::          WARNING: Any existing backups are deleted if "Service Order" entered does not match
::
:: Requirements: 
::   - User must provide any 14 or 15 numerical identifier (aka "Service Order") for backup ID
::   - Will not run from OS drive (advise running from a removable disk)
::   - Tested working on Windows 7, 8, 8.1, 10, 11
::   - Keyboard with ISO basic Latin alphabet for navigation with letters Y, N, M
::   - WLAN AutoConfig / WLANSVC enabled
::
:: Features:
::   - Bulk import and export of all networks via single menu selection
::   - Backups saved in same directory as script in folder /WifiExports/Service Order/
::   - Backups include nested folder with timestamp, computer name and Windows user name
::   - List view of known network SSID
::   - Verifies write-access to disk and compatible OS version on startup
::
::   - Protection against accidental imports
::     - Only one computer can be backed up at a time
::     - Attempting more than one backup erases all prior backups
::     - User is required to verify "Service Order" when Restoring
::     - Entering incorrect service order during restore erases all prior backups
::     - Automatic deletion of backups after successful import
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Elegantly end script if XP through Vista
VER | FINDSTR /L "5.0" > NUL
IF %ERRORLEVEL% EQU 0 goto olderos
VER | FINDSTR /L "5.1." > NUL
IF %ERRORLEVEL% EQU 0 goto olderos
VER | FINDSTR /L "5.2." > NUL
IF %ERRORLEVEL% EQU 0 goto olderos
VER | FINDSTR /L "6.0." > NUL
IF %ERRORLEVEL% EQU 0 goto olderos

set top=----------------------------------------------

if "%windir:~0,2%"=="%~d0" (goto osdrive) else (goto removeabledrive)
:osdrive
echo Windows Weefee Transfer Tool has detected it is not
echo running from a removable disk (flash drive).
echo.
echo Please save this tool to a freshly formatted 
echo removable disk containing no data and retry. 
echo.
echo.
echo Press any key to exit.
pause>nul
exit
:removeabledrive

copy /Y NUL "%~dp0\.writable" > NUL 2>&1 && set WRITEOK=1
IF DEFINED WRITEOK ( 
  goto TOC
 ) else (
  echo Windows Weefee Transfer Tool doesn't seem to have write-access to this folder.
  echo If running from external media, please ensure physical write-access switches are not engaged.
  echo.
  echo.
  echo Press any key to exit.
  pause>nul
  exit
)

:TOC
:: Wifi Menu
:profilecheck
:: Check if Windows has saved profiles
netsh wlan show profiles >nul 2>&1
IF %ERRORLEVEL% NEQ 0 goto wehaventssid

:: Wifi Menu
:wehavessid
:WifiTOC
cls
echo %top%
echo          Windows Weefee Transfer Tool
echo           Enter number for selection
echo %top%
echo.
echo 1. Backup Wifi Profiles
echo.
echo 2. Restore Wifi Profiles from Backup
echo.
echo 3. Display This Computer's Known Wifi Profiles
echo.
echo 4. Exit
del /s "%~dp0\.writable" >nul 2>&1
:: Choices are y and n, default choice is n, timeout = 30 seconds
choice /c 1234 >nul
goto WifiMenu%errorlevel%
:WifiMenu1
goto backupwifi
:WifiMenu2
if exist "%~dp0\WifiExports\" (
  goto restorewifi
) else (
  echo.
  echo No backups found. 
  echo. 
  echo Press any key to continue.
  pause>nul
  goto toc
)
:WifiMenu3
goto showwifi
:WifiMenu4
exit

:showwifi
cls
echo %top%
echo          Windows Weefee Transfer Tool
echo                 Known Networks
echo %top%
netsh wlan show profiles
echo Press M to return to Main Menu.
choice /c m >nul
goto TOC

:wehaventssid
cls
echo %top%
echo          Windows Weefee Transfer Tool
echo           Enter number for selection
echo %top%
echo.
echo 1. Backup Wifi Profiles (disabled - no profiles found)
echo.
echo 2. Restore Wifi Profiles from Backup
echo.
echo 3. Display This Computer's Known Wifi Profiles
echo.
echo 4. Back to Main Menu
:: Choices are y and n, default choice is n, timeout = 30 seconds
del /s "%~dp0\.writable" >nul 2>&1
choice /c 1234 >nul
goto WifiMenu%errorlevel%
:WifiMenu1
goto wehaventssid
:WifiMenu2
goto restorewifi
:WifiMenu3
goto showwifi
:WifiMenu4
exit

:backupwificharerror
echo.
echo ERROR: Service order should contain only numbers and hyphen.
timeout /t 1 /nobreak >nul
echo.
goto wifibackupstart

:backupwifiblankerror
echo ERROR: Service order cannot be blank.
timeout /t 1 /nobreak >nul
echo.
goto wifibackupstart

:backupwifilengtherror
echo ERROR: Service order must be fifteen characters with hyphen.
timeout /t 1 /nobreak >nul
echo.
goto wifibackupstart

:backupwifi
cls
echo %top%
echo             Backup Wifi Profiles
echo Enter 14-digit service order (with hyphen),
echo please type exactly as on service order form.
echo %top%
echo.
if exist "%~dp0\WifiExports\" (
  goto deletionwarning
) else (
  goto wehavessid
)
:deletionwarning
echo WARNING: Proceeding will delete all previously created backups.
echo Press Y to proceed or N to cancel and go back.
choice /c yn >nul
goto backupwifistart%errorlevel%
:backupwifistart1
echo.
goto wehavessid
:backupwifistart2
echo.
goto toc
:wifibackupstart

:wehavessid
:: Remove any existing WifiExports folder to avoid importing wrong profiles
:: but first kill notepad in case user has info.txt opened
taskkill /f /im notepad.exe >nul 2>&1
rmdir "%~dp0\WifiExports" /s /q >nul 2>&1
:: Clear variable
echo Service order:
set "currentserviceorder="
:: Ask user for service order
set /P currentserviceorder=
:: Loop back to an error label if user presses enter without input, service order used for folder name and cannot be blank
if not defined currentserviceorder goto backupwifiblankerror
:: Truncate service order to only 15 characters including hyphen
set truncatedserviceorder=%currentserviceorder:~0,15%
:: Ensure string does not have illegal folder name characters and bounce to an error label if so
echo %currentserviceorder% | >nul findstr /i "Q W E R T Y U I O P A S D F G H J K L Z X C V B N M a b c d e f g h i j k l m n o p q r s t u v w x y z ^^! _ \[ \] \\ ^; ^' ^, \. / { } : \? ^= + \* ^| ^< ^> ^` ~ @ # $ %% ^^ ^& ^( ^) @" && goto backupwificharerror
:: Ensure string is 15 characters long or do not proceed (so end user does not just type 1234)
IF "%currentserviceorder:~14,1%"=="" (
	goto backupwifilengtherror
) else (
    echo.
)
:: Create WifiExports folder and subfolder using truncated service order name
mkdir "%~dp0\WifiExports\%truncatedserviceorder%\Info"
:: Export current wifi profiles to this folder
echo ---
netsh wlan export profile folder="%~dp0\WifiExports\%truncatedserviceorder%" key=clear
IF %ERRORLEVEL% NEQ 0 goto cantbackup
:: Create a text file in that folder with some basic info about this export job
echo This backup was created on %DATE%%TIME%, from computer name ( %COMPUTERNAME% ) while logged into a Windows user account named ( %USERNAME% ). > "%~dp0\WifiExports\%truncatedserviceorder%\Info\Info.txt"
echo ---
echo.
echo Backup complete.
echo.
echo If running this tool from external media, you may eject external media now 
echo and place into destination PC, then run "Restore Wifi Profiles" from Main Menu.
echo.
echo Press M to Exit.
choice /c m >nul
exit
:cantbackup
echo No wireless profiles found to backup.
echo Press M to exit.
choice /c m >nul
exit

:restorewifi
cls
echo %top%
echo             Restore Wifi Profiles
echo Enter 14-digit service order (with hyphen),
echo please type exactly as on service order form.
echo %top%
echo.
echo WARNING: Entering incorrect service order will delete all previously created backups.
echo Press Y to proceed or N to cancel and go back.
choice /c yn >nul
goto restorewifistart%errorlevel%
:restorewifistart1
echo.
goto queryforso
:restorewifistart2
goto toc

:queryforso
:: Ask user for service order
echo Service order:
set /P checkserviceorder=
:: Truncate user input to 15 characters including hyphen
set truncatedcheckserviceorder=%checkserviceorder:~0,15%
:: Check if we have a backup for that service order
if exist "%~dp0\WifiExports\%truncatedcheckserviceorder%" (
  echo.
  echo Backup found.
  echo.
:: Echo Info file for that service order
  type "%~dp0\WifiExports\%truncatedcheckserviceorder%\Info\Info.txt"
) else (
:: If service order invalid then delete backups
  rmdir "%~dp0\WifiExports" /s /q >nul 2>&1
  echo.
  echo Service order incorrect or does not exist.
  echo.
  echo All previously created backups have been deleted for safety.
  echo.
  echo Please run "Backup Wifi Profiles" again on source computer to redo backup.
  echo.
  echo Press M to Exit.
  choice /c m >nul
  exit
)

:verifyso
:: Ask user if these are the droids we are looking for
echo.
echo Please verify the above information is correct.
echo Press Y to proceed with import or N if information is incorrect.
choice /c yn >nul
goto restorefinalcheck%errorlevel%
:restorefinalcheck1
goto startrestore
:restorefinalcheck2
  rmdir "%~dp0\WifiExports\" /s /q >nul 2>&1
  echo.
  echo All previously created backups have been deleted for safety.
  echo.
  echo Please run Wifi Backup Tool again on source computer and redo backup.
  echo.
  echo Press M to Exit.
  choice /c m >nul
  exit

:startrestore
:: Import wifi backup and then the delete backup
  echo.
  echo ---
  for %%f in ("%~dp0\WifiExports\%truncatedcheckserviceorder%\*") do ( netsh wlan add profile filename="%~dp0\WifiExports\%truncatedcheckserviceorder%\%%~nf.xml" )
  rmdir "%~dp0\WifiExports\" /s /q >nul 2>&1
  echo ---
  goto importcomplete

:importcomplete
  echo.
  echo Import complete.
  echo Profile backups deleted.
  echo.
  echo.
  echo Press M to return to Main Menu.
  choice /c m >nul
  goto TOC

:olderos
echo This tool only supports Windows 7 or newer. Press any key to exit.
pause > nul
:exitscript
exit