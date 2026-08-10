#!/bin/bash
# =============================================================================
# Android ADB Bridge — Ponte TCP (método Akita) + scrcpy
# =============================================================================
set -euo pipefail

echo "📱 Configurando Android ADB bridge..."

# ── Instalar scrcpy ──────────────────────────────────────────────────────────
echo "   → Instalando scrcpy..."
sudo apt-get update -qq
sudo apt-get install -y -qq scrcpy adb

# ── Criar diretório Android SDK ──────────────────────────────────────────────
echo "   → Criando diretório Android SDK..."
mkdir -p "$HOME/Android/Sdk/platform-tools"

echo "✅ Android ADB bridge configurado!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 INSTRUÇÕES — USBIPD (rodar no PowerShell do Windows como admin):"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  1. Listar dispositivos USB:"
echo "     usbipd list"
echo ""
echo "  2. Vincular o dispositivo Android (primeira vez):"
echo "     usbipd bind --busid <BUSID>"
echo ""
echo "  3. Anexar ao WSL:"
echo "     usbipd attach --wsl --busid <BUSID>"
echo ""
echo "  4. No WSL, verificar conexão:"
echo "     adb devices"
echo ""
echo "  A variável ADB_SERVER_SOCKET já está configurada no .zshrc."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
