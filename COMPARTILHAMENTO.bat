@echo off
:: Script BAT para executar correções SMB via PowerShell como administrador

:: Verifica se está em modo administrador
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo ==================================================
    echo Este script precisa ser executado como administrador.
    echo Clique com o botao direito e escolha "Executar como administrador".
    echo ==================================================
    pause
    exit /b
)

:: Caminho temporário para o script PowerShell
set "scriptPath=%temp%\fix-smb.ps1"

:: Cria o script PowerShell
echo Write-Host "Desativando exigência de assinatura SMB..." -ForegroundColor Cyan> "%scriptPath%"
echo Set-SmbClientConfiguration -RequireSecuritySignature ^$false -Force>> "%scriptPath%"
echo.>> "%scriptPath%"
echo Write-Host "Habilitando logon de convidado em servidores SMB..." -ForegroundColor Cyan>> "%scriptPath%"
echo Set-SmbClientConfiguration -EnableInsecureGuestLogons ^$true -Force>> "%scriptPath%"
echo.>> "%scriptPath%"
echo Write-Host "Corrigindo chave de registro para compartilhamento de impressora..." -ForegroundColor Cyan>> "%scriptPath%"
echo ^$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Print">> "%scriptPath%"
echo ^$regName = "RpcAuthnLevelPrivacyEnabled">> "%scriptPath%"
echo If (-Not (Test-Path ^$regPath)) {>> "%scriptPath%"
echo     Write-Host "Criando chave de registro Print..." -ForegroundColor Yellow>> "%scriptPath%"
echo     New-Item -Path ^$regPath -Force ^| Out-Null>> "%scriptPath%"
echo }>> "%scriptPath%"
echo New-ItemProperty -Path ^$regPath -Name ^$regName -PropertyType DWord -Value 0 -Force ^| Out-Null>> "%scriptPath%"
echo Write-Host "Chave de registro aplicada com sucesso." -ForegroundColor Green>> "%scriptPath%"
echo.>> "%scriptPath%"
echo Write-Host "`nHEADTECH" -ForegroundColor White>> "%scriptPath%"
echo Write-Host "Todas as correções foram aplicadas. Reinicie o computador para concluir." -ForegroundColor Green>> "%scriptPath%"
echo Pause>> "%scriptPath%"

:: Executa o script PowerShell
echo.
echo =====================================
echo Executando script PowerShell...
echo =====================================
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%scriptPath%"

:: Aguarda usuário visualizar saída
echo.
echo Script finalizado. Pressione qualquer tecla para sair.
pause >nul

:: Limpa o script temporário
del "%scriptPath%" >nul 2>&1
