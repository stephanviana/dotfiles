#!/bin/bash
# =============================================================================
# Network & System Config — WSL 2 (DNS Tunneling)
# =============================================================================
set -euo pipefail

echo "🌐 Verificando rede e configurações de sistema..."

# ── 1. Garantir que /etc/resolv.conf não está travado ───────────────────────
echo "   → Verificando /etc/resolv.conf..."
sudo chattr -i /etc/resolv.conf 2>/dev/null || true

# Se generateResolvConf = false estiver no /etc/wsl.conf, remover para permitir DNS Tunneling
if grep -q "generateResolvConf = false" /etc/wsl.conf 2>/dev/null; then
    echo "   → Habilitando gerador de DNS nativo no /etc/wsl.conf..."
    sudo sed -i '/generateResolvConf/d' /etc/wsl.conf
    sudo sed -i '/\[network\]/d' /etc/wsl.conf
    sudo rm -f /etc/resolv.conf
fi

# ── 2. Habilitar systemd no /etc/wsl.conf ────────────────────────────────────
if ! grep -q "systemd=true" /etc/wsl.conf 2>/dev/null; then
    echo "   → Habilitando systemd=true em /etc/wsl.conf..."
    sudo bash -c 'cat <<EOF >> /etc/wsl.conf

[boot]
systemd=true
EOF'
fi

# ── 3. Validar resolução DNS ────────────────────────────────────────────────
if getent hosts archive.ubuntu.com &>/dev/null; then
    echo "   ✅ Resolução DNS (via Windows DNS Tunneling) funcionando perfeitamente!"
else
    echo "   ⚠️  Aviso: Não foi possível resolver domínios."
    echo "   💡 Garanta que 'dnsTunneling=true' esteja no C:\\Users\\<user>\\.wslconfig e rode 'wsl --shutdown' no PowerShell."
fi
