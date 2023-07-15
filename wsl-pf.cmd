@ECHO OFF
SETLOCAL

:: Check admin
NET FILE 1>NUL 2>NUL & IF ERRORLEVEL 1 (ECHO This script must be run as administrator. & ECHO: & GOTO usage)

SET CMD=%~1
IF "%CMD%" == "" (
  GOTO usage
)

SET PORT=%~2
IF "%PORT%" == "" (
  GOTO usage
)

SET ADDR=

SET PARAM=%~3
SET ARG=%~4
IF "%PARAM%" == "-i" (
  IF NOT "%ARG%" == "" (
    SET ADDR=%ARG%
    SHIFT
  ) ELSE (
    ECHO Missing IP address value. 1>&2
    ECHO:
    GOTO usage
  )
) ELSE IF "%PARAM%" == "-d" (
  IF NOT "%ARG%" == "" (
    FOR /f %%i IN ('wsl -d %ARG% hostname -I') DO SET ADDR=%%i
    SHIFT
  ) ELSE (
    ECHO Missing WSL distro name. 1>&2
    ECHO:
    GOTO usage
  )
) ELSE (
  ECHO Missing IP address or WSL distro name. 1>&2
  ECHO:
  GOTO usage
)

IF "%CMD%" == "add" (
  ECHO Add port forwarding to %ADDR%:%PORT%
  netsh interface portproxy add v4tov4 listenport="%PORT%" listenaddress=0.0.0.0 connectport="%PORT%" connectaddress="%ADDR%"
  netsh advfirewall firewall add rule name="WSLPF_%ADDR%_%PORT%" dir=in action=allow protocol=TCP localport="%PORT%"
) ELSE IF "%CMD%" == "remove" (
  ECHO Remove port forwarding to %ADDR%:%PORT%
  netsh advfirewall firewall delete rule name="WSLPF_%ADDR%_%PORT%" protocol=TCP localport="%PORT%"
  netsh interface portproxy delete v4tov4 listenport="%PORT%" listenaddress=0.0.0.0
) ELSE (
  ECHO Unrecognized option %1. 1>&2
  ECHO:
  GOTO usage
)

GOTO :eof

:usage
ECHO WSL Port Forwarding
ECHO Usage: wsl-pf ^<add^|remove^> ^<port^> ^[-i ^<ip_address^> ^| -d ^<wsl_distro_name^>^]
EXIT /D