#!/bin/bash
# =============================================================================
# Dotfiles — Instalador WSL 2 (Ubuntu)
# Orquestra a instalação de todas as ferramentas e configurações
# =============================================================================
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TOOLS_DIR="$DOTFILES_DIR/wsl/tools"
TOTAL_STEPS=9
STEP=0

# ── Helpers ──────────────────────────────────────────────────────────────────
step() {
    STEP=$((STEP + 1))
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "[$STEP/$TOTAL_STEPS] $1"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

run_tool() {
    local script="$TOOLS_DIR/$1"
    if [ -f "$script" ]; then
        chmod +x "$script"
        bash "$script"
    else
        echo "⚠️  Script não encontrado: $script"
        return 1
    fi
}

# ── Banner ───────────────────────────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════════════════════════════╗"
echo "║                                                                    ║"
echo "║           🚀  Dotfiles WSL 2 — Setup Automatizado                  ║"
echo "║                                                                    ║"
echo "║           github.com/stephanviana/dotfiles                         ║"
echo "║                                                                    ║"
echo "╚══════════════════════════════════════════════════════════════════════╝"
echo ""

# ── [1/9] Rede e DNS ────────────────────────────────────────────────────────
step "🌐 Configurando rede e DNS..."
run_tool "network.sh"

# ── [2/9] Atualizar sistema ─────────────────────────────────────────────────
step "📦 Atualizando sistema..."
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y \
    curl \
    wget \
    git \
    unzip \
    build-essential \
    software-properties-common \
    openjdk-17-jdk \
    p7zip-full \
    p7zip-rar \
    ffmpeg

# ── [3/9] Linguagens via asdf ────────────────────────────────────────────────
step "🔀 Instalando linguagens via asdf (Node, Ruby, Python, Kotlin)..."
run_tool "asdf.sh"

# ── [4/9] Docker Engine ─────────────────────────────────────────────────────
step "🐳 Instalando Docker Engine..."
run_tool "docker.sh"

# ── [5/9] Android ADB bridge ────────────────────────────────────────────────
step "📱 Configurando Android ADB bridge..."
run_tool "android.sh"

# ── [6/9] CLI Tools ─────────────────────────────────────────────────────────
step "🔧 Instalando CLI tools..."
run_tool "cli-tools.sh"

# ── [7/9] Symlinks ──────────────────────────────────────────────────────────
step "🔗 Criando symlinks..."

create_symlink() {
    local src="$1"
    local dest="$2"
    if [ -f "$dest" ] || [ -L "$dest" ]; then
        echo "   → Backup: $dest → ${dest}.bak"
        mv "$dest" "${dest}.bak" 2>/dev/null || true
    fi
    ln -sf "$src" "$dest"
    echo "   → $src → $dest"
}

create_symlink "$DOTFILES_DIR/wsl/.zshrc" "$HOME/.zshrc"
create_symlink "$DOTFILES_DIR/wsl/.gitconfig" "$HOME/.gitconfig"

echo "✅ Symlinks criados!"

# ── [8/9] Configurar Zsh como shell padrão ──────────────────────────────────
step "🐚 Configurando Zsh..."
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "   → Definindo Zsh como shell padrão..."
    chsh -s "$(which zsh)"
    echo "✅ Zsh definido como shell padrão!"
else
    echo "   → Zsh já é o shell padrão."
fi

# ── [9/9] Resumo final ──────────────────────────────────────────────────────
step "✅ Ambiente pronto!"

echo "╔══════════════════════════════════════════════════════════════════════╗"
echo "║  📋 RESUMO DA INSTALAÇÃO                                          ║"
echo "╠══════════════════════════════════════════════════════════════════════╣"
echo "║                                                                    ║"
echo "║  ✅ Rede & DNS configurados (Mirrored + DNS Tunneling)              ║"
echo "║  ✅ Sistema atualizado                                             ║"
echo "║  ✅ asdf + Node.js, Ruby, Python, Kotlin                            ║"
echo "║  ✅ Docker Engine + Compose                                        ║"
echo "║  ✅ Android ADB bridge + scrcpy                                    ║"
echo "║  ✅ CLI tools (zsh, fzf, ripgrep, zoxide, gh, jq, agy, opencode, codex) ║"
echo "║  ✅ Symlinks (.zshrc, .gitconfig)                                  ║"
echo "║  ✅ Zsh como shell padrão                                          ║"
echo "║                                                                    ║"
echo "╠══════════════════════════════════════════════════════════════════════╣"
echo "║                                                                    ║"
echo "║  👉 Próximo passo: reinicie o terminal ou rode:                    ║"
echo "║     exec zsh                                                       ║"
echo "║                                                                    ║"
echo "║  👉 Para Docker sem sudo, faça logout/login ou rode:               ║"
echo "║     newgrp docker                                                  ║"
echo "║                                                                    ║"
echo "║  👉 Para autenticar no GitHub CLI:                                 ║"
echo "║     gh auth login                                                  ║"
echo "║                                                                    ║"
echo "╚══════════════════════════════════════════════════════════════════════╝"
