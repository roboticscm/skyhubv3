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
SET PROGRAM_FILES="C:\Program Files"
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

SET SUBSTRING=%USERPROFILE%\AppData\Local\Android\Sdk\platform-tools
ECHO %STRING% | FINDSTR /C:"%SUBSTRING%" >nul & IF ERRORLEVEL 1 (
    SET "EXTRA_PATH=%EXTRA_PATH%;%USERPROFILE%\AppData\Local\Android\Sdk\platform-tools;"
) else (
    echo Path existed
)

SET SUBSTRING=%USERPROFILE%\node\node-v14.16.0-win-x64
ECHO %STRING% | FINDSTR /C:"%SUBSTRING%" >nul & IF ERRORLEVEL 1 (
    SET "EXTRA_PATH=%EXTRA_PATH%;%USERPROFILE%\node\node-v14.16.0-win-x64;"
) else (
    echo Path existed
)

SET SUBSTRING=%USERPROFILE%\git\PortableGit\cmd
ECHO %STRING% | FINDSTR /C:"%SUBSTRING%" >nul & IF ERRORLEVEL 1 (
    SET "EXTRA_PATH=%EXTRA_PATH%;%USERPROFILE%\git\PortableGit\cmd;"
) else (
    echo Path existed
)

SET SUBSTRING=%USERPROFILE%\git\PortableGit\bin
ECHO %STRING% | FINDSTR /C:"%SUBSTRING%" >nul & IF ERRORLEVEL 1 (
    SET "EXTRA_PATH=%EXTRA_PATH%;%USERPROFILE%\git\PortableGit\bin;"
) else (
    echo Path existed
)

@REM ECHO %STRING% | FINDSTR /C:"C:\Program\ Files\go\bin" >nul & IF ERRORLEVEL 1 (
@REM     SET "EXTRA_PATH="%EXTRA_PATH%;%PROGRAM_FILES%\go\bin;""
@REM ) else (
@REM     echo Path existed
@REM )

SET SUBSTRING=%USERPROFILE%\golang\go\bin
ECHO %STRING% | FINDSTR /C:"%SUBSTRING%" >nul & IF ERRORLEVEL 1 (
    SET "EXTRA_PATH=%EXTRA_PATH%;%USERPROFILE%\golang\go\bin;"
) else (
    echo Path existed
)

reg add "HKLM\System\CurrentControlSet\Control\Session Manager\Environment" /f /v Path /t REG_EXPAND_SZ /d "%SystemPath%;%EXTRA_PATH%;"
reg add "HKLM\System\CurrentControlSet\Control\Session Manager\Environment" /f /v FLUTTER_HOME /t REG_EXPAND_SZ /d "%USERPROFILE%\flutter;"
echo Successful!
echo Next. cd <project root>\backend\core. Run make wonce-dev
pause