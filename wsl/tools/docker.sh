#!/bin/bash
# =============================================================================
# Docker Engine — Instalação oficial para Ubuntu no WSL 2
# =============================================================================
set -euo pipefail

echo "🐳 Instalando Docker Engine..."

# ── Remover versões antigas ──────────────────────────────────────────────────
echo "   → Removendo versões anteriores..."
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
    sudo apt-get remove -y "$pkg" 2>/dev/null || true
done

# ── Dependências ─────────────────────────────────────────────────────────────
echo "   → Instalando dependências..."
sudo apt-get update -qq
sudo apt-get install -y -qq ca-certificates curl gnupg

# ── Chave GPG oficial ────────────────────────────────────────────────────────
echo "   → Adicionando chave GPG do Docker..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg --yes
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# ── Repositório oficial ─────────────────────────────────────────────────────
echo "   → Adicionando repositório oficial..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# ── Instalar Docker Engine ──────────────────────────────────────────────────
echo "   → Instalando Docker Engine + Compose..."
sudo apt-get update -qq
sudo apt-get install -y -qq \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

# ── Adicionar usuário ao grupo docker ──────────────────────────────────────
echo "   → Adicionando $USER ao grupo docker..."
sudo usermod -aG docker "$USER"

# ── Habilitar systemd no /etc/wsl.conf ───────────────────────────────────────
echo "   → Configurando systemd=true em /etc/wsl.conf..."
if ! grep -q "systemd=true" /etc/wsl.conf 2>/dev/null; then
    printf '\n[boot]\nsystemd=true\n' | sudo tee -a /etc/wsl.conf > /dev/null
fi

# ── Habilitar serviço (systemd ou fallback) ──────────────────────────────────
if [ "$(ps -p 1 -o comm=)" = "systemd" ]; then
    echo "   → systemd detectado — habilitando via systemctl..."
    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service
    sudo systemctl start docker.service
    echo "   ✅ Docker iniciado via systemd!"
else
    echo "   ⚠️  systemd não está ativo (WSL precisa ser reiniciado)."
    echo "   → Iniciando Docker via service como fallback..."
    sudo service docker start 2>/dev/null || true
    echo ""
    echo "   💡 Para ativar systemd permanentemente, rode no PowerShell:"
    echo "      wsl --shutdown"
    echo "   E reabra o Ubuntu. O Docker iniciará automaticamente."
fi

echo "✅ Docker instalado com sucesso!"
echo "   Versão: $(docker --version 2>/dev/null || echo 'requer novo login')"
echo "   Compose: $(docker compose version 2>/dev/null || echo 'requer novo login')"
