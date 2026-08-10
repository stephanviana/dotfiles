#!/bin/bash
# =============================================================================
# Network & DNS Fix — WSL 2
# Configura DNS estável (OpenDNS FamilyShield + Fallback Cloudflare/Google)
# e evita falhas de resolução no apt e ferramentas do WSL.
# =============================================================================
set -euo pipefail

echo "🌐 Verificando rede e DNS..."

# ── 1. Configurar /etc/wsl.conf ──────────────────────────────────────────────
echo "   → Atualizando /etc/wsl.conf..."

# Desabilitar geração automática do resolv.conf pelo WSL
if ! grep -q "generateResolvConf" /etc/wsl.conf 2>/dev/null; then
    sudo bash -c 'cat <<EOF >> /etc/wsl.conf

[network]
generateResolvConf = false
EOF'
    echo "   ✅ generateResolvConf = false adicionado a /etc/wsl.conf"
fi

# Habilitar systemd no boot caso ainda não esteja
if ! grep -q "systemd=true" /etc/wsl.conf 2>/dev/null; then
    sudo bash -c 'cat <<EOF >> /etc/wsl.conf

[boot]
systemd=true
EOF'
    echo "   ✅ systemd=true adicionado a /etc/wsl.conf"
fi

# ── 2. Testar resolução de nomes atual ──────────────────────────────────────
dns_ok=false
if getent hosts archive.ubuntu.com &>/dev/null; then
    dns_ok=true
    echo "   ✅ Resolução DNS atual está funcionando!"
else
    echo "   ⚠️  Falha na resolução DNS padrão do WSL (relay 10.255.255.254 não responde)."
fi

# ── 3. Aplicar /etc/resolv.conf personalizado se falhou ou for o padrão WSL ──
if [ "$dns_ok" = false ] || grep -q "10.255.255.254" /etc/resolv.conf 2>/dev/null || [ ! -s /etc/resolv.conf ]; then
    echo "   → Aplicando DNS confiável (OpenDNS FamilyShield + Fallback Cloudflare)..."

    # Desbloquear o arquivo se já estiver com atributo imutável (+i)
    sudo chattr -i /etc/resolv.conf 2>/dev/null || true
    sudo rm -f /etc/resolv.conf

    # Escrever OpenDNS FamilyShield (1º e 2º) + Cloudflare (3º) com timeout baixo para failover rápido
    sudo bash -c 'cat <<EOF > /etc/resolv.conf
options timeout:2 attempts:2
nameserver 208.67.222.123
nameserver 208.67.220.123
nameserver 1.1.1.1
EOF'

    # Travar o arquivo contra sobrescritas automáticas do WSL
    sudo chattr +i /etc/resolv.conf 2>/dev/null || true
    echo "   ✅ /etc/resolv.conf configurado e protegido (+i)!"
fi

# ── 4. Validação final ───────────────────────────────────────────────────────
if getent hosts archive.ubuntu.com &>/dev/null; then
    echo "   ✅ Conexão DNS com os repositórios do Ubuntu confirmada!"
else
    echo "   ⚠️  OpenDNS não respondeu nesta rede. Aplicando fallback (Cloudflare + Google)..."
    sudo chattr -i /etc/resolv.conf 2>/dev/null || true
    sudo bash -c 'cat <<EOF > /etc/resolv.conf
options timeout:2 attempts:2
nameserver 1.1.1.1
nameserver 8.8.8.8
EOF'
    sudo chattr +i /etc/resolv.conf 2>/dev/null || true
    echo "   ✅ Fallback aplicado com sucesso!"
fi
