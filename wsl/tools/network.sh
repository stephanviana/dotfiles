#!/bin/bash
# =============================================================================
# Network & System Config — WSL 2 (Mirrored + DNS Tunneling)
#
# Estratégia:
#   .wslconfig  → networkingMode=mirrored, dnsTunneling=true
#   wsl.conf    → systemd=true, generateResolvConf=false
#   resolv.conf → symlink para stub do systemd-resolved (127.0.0.53)
#
# Fluxo DNS:
#   App → 127.0.0.53 (systemd-resolved stub)
#       → 10.255.255.254 (DNS Tunnel via hypervisor)
#           → Windows DNS (dinâmico via DHCP)
# =============================================================================
set -euo pipefail

echo "🌐 Configurando rede e DNS..."

# ── 1. Configurar /etc/wsl.conf ──────────────────────────────────────────────
echo "   → Escrevendo /etc/wsl.conf..."
sudo tee /etc/wsl.conf > /dev/null << 'WSLCONF'
[boot]
systemd=true

[network]
generateResolvConf = false
WSLCONF
echo "   ✅ /etc/wsl.conf configurado."

# ── 2. Apontar resolv.conf para o stub do systemd-resolved ───────────────────
echo "   → Configurando /etc/resolv.conf → stub do systemd-resolved..."

# Remover imutabilidade se existir
sudo chattr -i /etc/resolv.conf 2>/dev/null || true

# Remover arquivo/symlink antigo e criar symlink para o stub
sudo rm -f /etc/resolv.conf
sudo ln -s /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

echo "   ✅ /etc/resolv.conf → /run/systemd/resolve/stub-resolv.conf"

# ── 3. Reiniciar systemd-resolved para aplicar ───────────────────────────────
echo "   → Reiniciando systemd-resolved..."
sudo systemctl restart systemd-resolved

# ── 4. Validar resolução DNS ─────────────────────────────────────────────────
echo "   → Testando resolução DNS..."
sleep 1
if getent hosts archive.ubuntu.com &>/dev/null; then
    echo "   ✅ Resolução DNS (Mirrored + DNS Tunneling) funcionando!"
else
    echo "   ⚠️  DNS ainda não resolve. Tente reiniciar o WSL:"
    echo "      1. No PowerShell: wsl --shutdown"
    echo "      2. Reabra o terminal WSL"
    echo "      3. Verifique que ~/.wslconfig tem networkingMode=mirrored e dnsTunneling=true"
fi
