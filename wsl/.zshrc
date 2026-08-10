# =============================================================================
# Dotfiles — .zshrc
# =============================================================================

# ---------------------------------------------------------------------------
# PATH essencial (deve vir antes dos plugins do Oh My Zsh)
# ---------------------------------------------------------------------------
export PATH="$HOME/.local/bin:$PATH"

# ---------------------------------------------------------------------------
# Oh My Zsh
# ---------------------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

plugins=(
    git
    zoxide
    docker
    docker-compose
    command-not-found
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

# ---------------------------------------------------------------------------
# asdf v0.16+ (binário Go)
# ---------------------------------------------------------------------------
export ASDF_DATA_DIR="$HOME/.asdf"
# completions
fpath=("${ASDF_DATA_DIR}/completions" $fpath)
autoload -Uz compinit && compinit

# ---------------------------------------------------------------------------
# Android ADB Bridge (ponte TCP — método Akita)
# ---------------------------------------------------------------------------
export ADB_SERVER_SOCKET=tcp:127.0.0.1:5037
export ANDROID_HOME="$HOME/Android/Sdk"
export PATH="$PATH:$ANDROID_HOME/platform-tools"

# ---------------------------------------------------------------------------
# Docker — iniciar se não estiver rodando
# ---------------------------------------------------------------------------
if ! pgrep -x "dockerd" > /dev/null 2>&1; then
    sudo service docker start > /dev/null 2>&1
fi

# ---------------------------------------------------------------------------
# Aliases — Navegação
# ---------------------------------------------------------------------------
alias cls="clear"
alias ll="ls -lah --color=auto"
alias la="ls -A --color=auto"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias mkd="mkdir -pv"

# ---------------------------------------------------------------------------
# Aliases — Git
# ---------------------------------------------------------------------------
alias gs="git status -sb"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git pull"
alias gd="git diff"
alias gco="git checkout"
alias gb="git branch"
alias glog="git log --oneline --graph --decorate --all"

# ---------------------------------------------------------------------------
# Aliases — Docker
# ---------------------------------------------------------------------------
alias dps="docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
alias dcp="docker compose"
alias dcu="docker compose up -d"
alias dcd="docker compose down"
alias dcl="docker compose logs -f"

# ---------------------------------------------------------------------------
# Aliases — Utilitários
# ---------------------------------------------------------------------------
alias ports="ss -tulnp"
alias myip="curl -s ifconfig.me"
alias reload="exec zsh"
alias dotfiles="cd ~/.dotfiles"

# ---------------------------------------------------------------------------
# FZF
# ---------------------------------------------------------------------------
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# ---------------------------------------------------------------------------
# Zoxide (substituição do cd)
# ---------------------------------------------------------------------------
eval "$(zoxide init zsh)"

# ---------------------------------------------------------------------------
# PATH extras
# ---------------------------------------------------------------------------
export PATH="$HOME/.local/bin:$PATH"
