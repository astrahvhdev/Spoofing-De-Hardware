@echo off
title Spoofing de Hardware por CMD
chcp 1252 >nul  REM Define a página de código correta (ANSI Windows)
mode con cols=100 lines=30
cls

:: Exibir mensagem inicial corrigida
echo ===================================================
echo         SPOOFING DE HARDWARE POR CMD
echo ===================================================
echo.
echo  Este script modifica temporariamente as configuracoes do hardware.
echo  As mudancas duram ate o proximo reinicio do computador.
echo.
echo  O que sera alterado:
echo  - Endereco MAC da Placa de Rede
echo  - Nome do Computador
echo  - Numero de Serie do Disco
echo  - UUID do Sistema
echo  - ID do Processador
echo  - Machine GUID (Registro do Windows)
echo  - Nome de Usuario do Windows
echo  - Endereco IP Local
echo  - Configuracao de DNS
echo.
echo  Desenvolvido por: astrahvhdev (Telegram)
echo.
echo  Pressione qualquer tecla para iniciar...
pause >nul

:: Elevar para Administrador automaticamente
>nul 2>&1 "%SystemRoot%\system32\cacls.exe" "%SystemRoot%\system32\config\system"
if %errorLevel% neq 0 (
    echo [!] Solicitando privilegios de Administrador...
    powershell -Command "Start-Process cmd -ArgumentList '/c %~s0' -Verb RunAs"
    exit
)

cls

:: 1. Alterar Endereco MAC
echo [*] Alterando Endereco MAC...
setlocal enabledelayedexpansion
for /F "tokens=3" %%A in ('getmac /fo table /nh') do (
    set "mac=%%A"
    set "new_mac=00-1A-2B-!random!!random!"
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}\0001" /v NetworkAddress /t REG_SZ /d !new_mac! /f >nul
    echo [OK] Novo MAC Address: !new_mac!
)

:: 2. Alterar Nome do Computador
set "new_pc=PC-%random%%random%"
wmic computersystem where name="%computername%" call rename name="%new_pc%" >nul
echo [OK] Nome do Computador alterado para: %new_pc%

:: 3. Alterar Numero de Serie do Disco (Temporario)
set "new_disk_serial=DISK-%random%%random%"
wmic diskdrive get serialnumber | find /v "SerialNumber" >nul
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\IDConfigDB\Hardware Profiles\0001" /v HwProfileGuid /t REG_SZ /d %new_disk_serial% /f >nul
echo [OK] Numero de Serie do Disco alterado para: %new_disk_serial%

:: 4. Alterar UUID da Maquina
set "new_uuid={%random%%random%-%random%-4%random%-A%random%-%random%%random%%random%}"
wmic path win32_computersystemproduct where name="%computername%" call SetUUID "%new_uuid%" >nul
echo [OK] UUID do Sistema alterado para: %new_uuid%

:: 5. Alterar ID do Processador
set "new_cpu_id=CPU-%random%%random%"
reg add "HKEY_LOCAL_MACHINE\HARDWARE\DESCRIPTION\System\CentralProcessor\0" /v ProcessorNameString /t REG_SZ /d %new_cpu_id% /f >nul
echo [OK] ID do Processador alterado para: %new_cpu_id%

:: 6. Alterar Machine GUID (Registro do Windows)
set "new_machine_guid={%random%-%random%-4%random%-A%random%-%random%%random%%random%}"
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Cryptography" /v MachineGuid /t REG_SZ /d %new_machine_guid% /f >nul
echo [OK] Machine GUID alterado para: %new_machine_guid%

:: 7. Alterar Nome de Usuario Temporariamente
set "new_user=User-%random%%random%"
wmic useraccount where name="%username%" rename "%new_user%" >nul
echo [OK] Nome de Usuario alterado para: %new_user%

:: 8. Alterar Endereco IP Local (DHCP Temporario)
set /a "ip1=192"
set /a "ip2=168"
set /a "ip3=%random% %% 255"
set /a "ip4=%random% %% 255"
set "new_ip=%ip1%.%ip2%.%ip3%.%ip4%"
netsh interface ip set address name="Ethernet" static %new_ip% 255.255.255.0 192.168.1.1 >nul
echo [OK] Endereco IP Local alterado para: %new_ip%

:: 9. Alterar DNS Temporario
netsh interface ip set dns name="Ethernet" static 8.8.8.8 primary >nul
netsh interface ip add dns name="Ethernet" 8.8.4.4 index=2 >nul
echo [OK] Servidores DNS alterados para Google DNS (8.8.8.8 e 8.8.4.4)

:: Mensagem Final
echo.
echo ====================================================
echo  Spoofing concluido com sucesso!
echo  As mudancas sao temporarias e serao revertidas ao reiniciar.
echo  Caso precise de ajuda, contate: astrahvhdev (Telegram)
echo ====================================================
echo.
pause
exit
