# =============================================================================
# Dotfiles — Setup Windows (PowerShell como Admin)
# Instala WSL 2, apps via Winget e configura .wslconfig
# =============================================================================
#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

# ── Helpers ──────────────────────────────────────────────────────────────────
function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host "----------------------------------------------------------------" -ForegroundColor Cyan
    Write-Host "  $Message" -ForegroundColor White
    Write-Host "----------------------------------------------------------------" -ForegroundColor Cyan
    Write-Host ""
}

function Install-WingetApp {
    param(
        [string]$Id,
        [string]$Name
    )
    # Verificar se ja esta instalado antes de tentar instalar
    $installed = winget list --id $Id --accept-source-agreements 2>$null |
                 Where-Object { $_ -match [regex]::Escape($Id) }
    if ($installed) {
        Write-Host "   -> $Name ja instalado, pulando..." -ForegroundColor Yellow
        return
    }

    Write-Host "   -> Instalando $Name..." -ForegroundColor Gray
    try {
        winget install --id $Id --accept-source-agreements --accept-package-agreements --silent
        Write-Host "   OK $Name instalado!" -ForegroundColor Green
    }
    catch {
        Write-Host "   AVISO: Falha ao instalar ${Name}: $_" -ForegroundColor Red
    }
}

# ── Banner ───────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "==================================================================" -ForegroundColor Magenta
Write-Host "  Dotfiles Windows -- Setup Automatizado" -ForegroundColor Magenta
Write-Host "  github.com/stephanviana/dotfiles" -ForegroundColor Magenta
Write-Host "==================================================================" -ForegroundColor Magenta
Write-Host ""

# ── [1] WSL 2 + Ubuntu ──────────────────────────────────────────────────────
Write-Step "[1] Verificando WSL 2 com Ubuntu..."

$needsReboot = $false

# Checar se Ubuntu ja existe no WSL
$wslList = wsl --list --quiet 2>$null
$ubuntuExists = $wslList | Where-Object { $_ -match "Ubuntu" }

if ($ubuntuExists) {
    Write-Host "   -> Ubuntu ja instalado no WSL, pulando instalacao..." -ForegroundColor Yellow
} else {
    Write-Host "   -> Instalando WSL 2 + Ubuntu..." -ForegroundColor Gray
    try {
        wsl --install -d Ubuntu --no-launch
        Write-Host "   OK WSL 2 + Ubuntu instalados! Reboot necessario." -ForegroundColor Green
        $needsReboot = $true
    }
    catch {
        Write-Host "   ERRO: $_" -ForegroundColor Red
        Write-Host "   -> Tente manualmente: wsl --install -d Ubuntu" -ForegroundColor Yellow
    }
}

# ── [2] .wslconfig ──────────────────────────────────────────────────────────
Write-Step "[2] Copiando .wslconfig..."

$ScriptDir = $null

if ($PSScriptRoot) {
    $ScriptDir = $PSScriptRoot
} elseif ($MyInvocation.MyCommand.Path) {
    $ScriptDir = Split-Path $MyInvocation.MyCommand.Path -Parent
}

if ($ScriptDir -and (Test-Path "$ScriptDir\.wslconfig")) {
    Copy-Item "$ScriptDir\.wslconfig" "$env:USERPROFILE\.wslconfig" -Force
    Write-Host "   OK .wslconfig copiado de $ScriptDir" -ForegroundColor Green
} else {
    Write-Host "   -> Criando .wslconfig inline (execucao remota)..." -ForegroundColor Gray
    $wslConfigContent = "[wsl2]`nmemory=4GB`nprocessors=4`nnetworkingMode=mirrored`n"
    Set-Content -Path "$env:USERPROFILE\.wslconfig" -Value $wslConfigContent -Encoding UTF8
    Write-Host "   OK .wslconfig criado em $env:USERPROFILE\" -ForegroundColor Green
}

# Aplicar .wslconfig reiniciando o WSL (sem reboot completo do Windows)
if (-not $needsReboot) {
    Write-Host "   -> Reiniciando WSL para aplicar .wslconfig..." -ForegroundColor Gray
    wsl --shutdown
    Write-Host "   OK WSL reiniciado com novas configuracoes!" -ForegroundColor Green
}

# ── [3] Apps via Winget ──────────────────────────────────────────────────────
Write-Step "[3] Instalando apps via Winget..."

$Apps = @(
    @{ Id = "Anysphere.Cursor";           Name = "Cursor" },
    @{ Id = "Microsoft.VisualStudioCode"; Name = "VS Code" },
    @{ Id = "Git.Git";                    Name = "Git" },
    @{ Id = "Google.AndroidStudio";       Name = "Android Studio" },
    @{ Id = "dorssel.usbipd-win";         Name = "USBIPD" }
)

foreach ($App in $Apps) {
    Install-WingetApp -Id $App.Id -Name $App.Name
}

# ── [4] Tarefa pos-reboot ────────────────────────────────────────────────────
Write-Step "[4] Registrando tarefa pos-reboot..."

$TaskName     = "DotfilesOpenUbuntu"
$ExistingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue

if (-not $ExistingTask) {
    $Action   = New-ScheduledTaskAction -Execute "wsl.exe" -Argument "-d Ubuntu"
    $Trigger  = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
    $Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
    Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger `
        -Settings $Settings -Description "Abre Ubuntu apos reboot do setup dotfiles" | Out-Null
    Write-Host "   OK Tarefa '$TaskName' registrada!" -ForegroundColor Green
} else {
    Write-Host "   -> Tarefa ja existe, pulando..." -ForegroundColor Yellow
}

# ── Resumo ───────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "==================================================================" -ForegroundColor Green
Write-Host "  RESUMO" -ForegroundColor Green
Write-Host "==================================================================" -ForegroundColor Green
Write-Host ""

if ($needsReboot) {
    Write-Host "  OK  WSL 2 + Ubuntu instalados        (reboot necessario)" -ForegroundColor Green
} else {
    Write-Host "  OK  WSL 2 + Ubuntu ja presentes      (sem reboot)" -ForegroundColor Green
}
Write-Host "  OK  .wslconfig aplicado" -ForegroundColor Green
Write-Host "  OK  Apps verificados/instalados via Winget" -ForegroundColor Green
Write-Host "  OK  Tarefa pos-reboot registrada" -ForegroundColor Green
Write-Host ""

if ($needsReboot) {
    Write-Host "  AVISO: Reiniciando em 10s... (Ctrl+C para cancelar)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Apos reiniciar: abra o Ubuntu, defina usuario/senha e rode:" -ForegroundColor White
} else {
    Write-Host "  Abra o Ubuntu e rode:" -ForegroundColor White
}

Write-Host ""
Write-Host "    git clone https://github.com/stephanviana/dotfiles ~/.dotfiles" -ForegroundColor Cyan
Write-Host "    cd ~/.dotfiles && chmod +x wsl/install.sh && ./wsl/install.sh" -ForegroundColor Cyan
Write-Host ""
Write-Host "==================================================================" -ForegroundColor Green
Write-Host ""

# ── Reboot condicional ────────────────────────────────────────────────────────
if ($needsReboot) {
    Write-Host "Pressione Ctrl+C para cancelar o reboot..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    Restart-Computer -Force
} else {
    Write-Host "Setup concluido! Nenhum reboot necessario." -ForegroundColor Green
}
