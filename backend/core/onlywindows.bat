@echo off
if exist C:\ProgramData\chocolatey rd /q /s C:\ProgramData\chocolatey
powershell -command "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser"
powershell -command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"

choco install make
@REM echo Set path for flutter
set "SystemPath="
for /F "skip=2 tokens=1,2*" %%N in ('%SystemRoot%\System32\reg.exe query "HKLM\System\CurrentControlSet\Control\Session Manager\Environment" /v "Path" 2^>nul') do (
    if /I "%%N" == "Path" (
        set "SystemPath=%%P"
       
    )
)

SET "EXTRA_PATH="
SET STRING=%SystemPath%
SET SUBSTRING=%USERPROFILE%\flutter\bin
ECHO %STRING% | FINDSTR /C:"%SUBSTRING%" >nul & IF ERRORLEVEL 1 (
    SET "EXTRA_PATH=%USERPROFILE%\flutter\bin;"
) else (
    echo Path existed
)

SET SUBSTRING=%USERPROFILE%\flutter\\.pub-cache\bin
ECHO %STRING% | FINDSTR /C:"%SUBSTRING%" >nul & IF ERRORLEVEL 1 (
    SET "EXTRA_PATH=%EXTRA_PATH%;%USERPROFILE%\flutter\.pub-cache\bin";
) else (
    echo Path existed
)

SET SUBSTRING=%USERPROFILE%\flutter\bin\cache\dart-sdk\bin
ECHO %STRING% | FINDSTR /C:"%SUBSTRING%" >nul & IF ERRORLEVEL 1 (
    SET "EXTRA_PATH=%EXTRA_PATH%;%USERPROFILE%\flutter\bin\cache\dart-sdk\bin;"
) else (
    echo Path existed
)

SET SUBSTRING=%USERPROFILE%\go\bin
ECHO %STRING% | FINDSTR /C:"%SUBSTRING%" >nul & IF ERRORLEVEL 1 (
    SET "EXTRA_PATH=%EXTRA_PATH%;%USERPROFILE%\go\bin;"
) else (
    echo Path existed
)

reg add "HKLM\System\CurrentControlSet\Control\Session Manager\Environment" /f /v Path /t REG_EXPAND_SZ /d "%SystemPath%;%EXTRA_PATH%;"

echo Successful!
echo Next. cd <project root>\backend\core. Run make wonce-dev
pause