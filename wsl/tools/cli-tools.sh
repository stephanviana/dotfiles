#!/bin/bash
# =============================================================================
# CLI Tools — Ferramentas de qualidade de vida
# =============================================================================
set -euo pipefail

echo "🔧 Instalando CLI tools..."

# ── Zsh ──────────────────────────────────────────────────────────────────────
echo "   → Instalando Zsh..."
sudo apt-get update -qq
sudo apt-get install -y -qq zsh

# ── Oh My Zsh ────────────────────────────────────────────────────────────────
echo "   → Instalando Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no KEEP_ZSHRC=yes \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "     Oh My Zsh já instalado, pulando..."
fi

# ── Plugins do Oh My Zsh ─────────────────────────────────────────────────────
echo "   → Instalando plugins do Oh My Zsh..."

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
        "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting \
        "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# ── fzf — busca fuzzy ───────────────────────────────────────────────────────
echo "   → Instalando fzf..."
if [ ! -d "$HOME/.fzf" ]; then
    git clone --depth=1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
    "$HOME/.fzf/install" --all --no-bash --no-fish
else
    echo "     fzf já instalado, pulando..."
fi

# ── ripgrep — grep turbinado ─────────────────────────────────────────────────
echo "   → Instalando ripgrep..."
sudo apt-get install -y -qq ripgrep

# ── zoxide — navegação inteligente ───────────────────────────────────────────
echo "   → Instalando zoxide..."
if ! command -v zoxide &> /dev/null; then
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
else
    echo "     zoxide já instalado, pulando..."
fi

# ── gh — GitHub CLI ──────────────────────────────────────────────────────────
echo "   → Instalando GitHub CLI..."
if ! command -v gh &> /dev/null; then
    (type -p wget >/dev/null || (sudo apt-get update -qq && sudo apt-get install -y -qq wget)) \
        && sudo mkdir -p -m 755 /etc/apt/keyrings \
        && out=$(mktemp) \
        && wget -nv -O "$out" https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        && cat "$out" | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
        && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
        && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | \
            sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
        && sudo apt-get update -qq \
        && sudo apt-get install -y -qq gh \
        && rm -f "$out"
else
    echo "     gh já instalado, pulando..."
fi

# ── jq — manipulação de JSON ────────────────────────────────────────────────
echo "   → Instalando jq..."
sudo apt-get install -y -qq jq

# ── Antigravity CLI (agy) ───────────────────────────────────────────────────
echo "   → Instalando Antigravity CLI (agy)..."
if ! command -v agy &> /dev/null; then
    curl -fsSL https://antigravity.google/cli/install.sh | bash || true
else
    echo "     Antigravity CLI já instalado, pulando..."
fi

# ── OpenCode CLI ─────────────────────────────────────────────────────────────
echo "   → Instalando OpenCode CLI..."
if ! command -v opencode &> /dev/null; then
    curl -fsSL https://opencode.ai/install | bash || true
else
    echo "     OpenCode CLI já instalado, pulando..."
fi

# ── Codex CLI ────────────────────────────────────────────────────────────────
echo "   → Instalando Codex CLI..."
if ! command -v codex &> /dev/null; then
    curl -fsSL https://chatgpt.com/codex/install.sh | sh || true
else
    echo "     Codex CLI já instalado, pulando..."
fi

echo ""
echo "✅ CLI tools instalados!"
echo "   zsh:         $(zsh --version)"
echo "   fzf:         $(~/.fzf/bin/fzf --version 2>/dev/null || echo 'instalado')"
echo "   ripgrep:     $(rg --version | head -1)"
echo "   zoxide:      $(zoxide --version 2>/dev/null || echo 'instalado')"
echo "   gh:          $(gh --version | head -1)"
echo "   jq:          $(jq --version)"
echo "   antigravity: $(agy --version 2>/dev/null || echo 'instalado')"
echo "   opencode:    $(opencode --version 2>/dev/null || echo 'instalado')"
echo "   codex:       $(codex --version 2>/dev/null || echo 'instalado')"
