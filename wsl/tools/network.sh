#!/bin/bash
# =============================================================================
# Network & DNS Fix — WSL 2 (OpenDNS FamilyShield Exclusivo)
# Desabilita a geração automática do resolv.conf do WSL e fixa o DNS no
# OpenDNS FamilyShield.
# =============================================================================
set -euo pipefail

echo "🌐 Configurando OpenDNS FamilyShield..."

# ── 1. Configurar /etc/wsl.conf ──────────────────────────────────────────────
echo "   → Atualizando /etc/wsl.conf..."

# Desabilitar geração automática do resolv.conf pelo WSL
if ! grep -q "generateResolvConf" /etc/wsl.conf 2>/dev/null; then
    sudo bash -c 'cat <<EOF >> /etc/wsl.conf

[network]
generateResolvConf = false
EOF'
    echo "   ✅ generateResolvConf = false configurado no /etc/wsl.conf"
fi

# Habilitar systemd no boot caso ainda não esteja
if ! grep -q "systemd=true" /etc/wsl.conf 2>/dev/null; then
    sudo bash -c 'cat <<EOF >> /etc/wsl.conf

[boot]
systemd=true
EOF'
    echo "   ✅ systemd=true configurado no /etc/wsl.conf"
fi

# ── 2. Aplicar OpenDNS FamilyShield no /etc/resolv.conf ──────────────────────
echo "   → Aplicando IPs do OpenDNS FamilyShield..."

# Desbloquear o arquivo se já estiver imutável (+i)
sudo chattr -i /etc/resolv.conf 2>/dev/null || true
sudo rm -f /etc/resolv.conf

# Escrever exclusivamente os IPs do OpenDNS FamilyShield
sudo bash -c 'cat <<EOF > /etc/resolv.conf
nameserver 208.67.222.123
nameserver 208.67.220.123
EOF'

# Travar o arquivo contra alterações automáticas do WSL
sudo chattr +i /etc/resolv.conf 2>/dev/null || true
echo "   ✅ /etc/resolv.conf travado com OpenDNS FamilyShield (+i)!"

# ── 3. Teste de validação ───────────────────────────────────────────────────
if getent hosts archive.ubuntu.com &>/dev/null; then
    echo "   ✅ Conexão com OpenDNS FamilyShield confirmada!"
else
    echo "   ⚠️  Aviso: Não foi possível resolver domínios no momento via OpenDNS."
fi
