# Dotfiles — WSL 2 + Windows

Setup automatizado para ambiente de desenvolvimento em WSL 2 (Ubuntu) com integração Windows.

---

## O que é instalado

### Windows (via Winget)

| App | Descrição |
|-----|-----------|
| **Bitwarden** | Gerenciador de senhas |
| **VS Code** | Editor de código |
| **Android Studio** | Desenvolvimento Android |
| **USBIPD** | Ponte USB → WSL (para ADB físico) |

### WSL 2 (Ubuntu)

| Ferramenta | Descrição |
|------------|-----------|
| **Zsh + Oh My Zsh** | Shell moderno com plugins |
| **asdf v0.16+** | Gerenciador de versões unificado (Go binary) |
| **Node.js** (latest) | Runtime JS + npm, yarn, pnpm |
| **Ruby** (latest) | Linguagem Ruby |
| **Python** (latest) | Linguagem Python |
| **Kotlin** (latest) | Linguagem Kotlin |
| **Docker Engine** | Containers com suporte a systemd |
| **Docker Compose** | Orquestração de containers |
| **Android ADB bridge** | Ponte TCP via USBIPD (método Akita) |
| **scrcpy** | Espelhamento de tela Android |
| **Antigravity CLI** (`agy`) | Assistente IA agentico do Google |
| **OpenCode CLI** | Agente IA open-source |
| **Codex CLI** | Assistente de código IA |
| **fzf** | Busca fuzzy no terminal |
| **ripgrep** | Grep turbinado |
| **zoxide** | Navegação inteligente entre pastas |
| **gh** | GitHub CLI |
| **jq** | Manipulação de JSON |

---

## Requisitos

- Windows 10 (build 19041+) ou Windows 11
- PowerShell rodando como **Administrador**
- Conexão com a internet

---

## Setup em máquina nova

### Parte 1 — Windows

#### 1. Abra o PowerShell como Administrador e rode

```powershell
irm https://raw.githubusercontent.com/stephanviana/dotfiles/main/windows/setup.ps1 | iex
```

O script vai:
- Verificar se WSL 2 + Ubuntu já estão instalados (pula se já existirem)
- Copiar o `.wslconfig` para `C:\Users\<user>\`
- Instalar apps via Winget (pula os que já estiverem instalados)
- Registrar uma tarefa para abrir o Ubuntu automaticamente após reboot

#### 2. Reboot (apenas se WSL foi instalado do zero)

Se o WSL 2 **não estava instalado**, o script reinicia o PC em 10 segundos.
Se **já estava instalado**, nenhum reboot é necessário — o `.wslconfig` é aplicado via `wsl --shutdown`.

> Pressione `Ctrl+C` antes dos 10 segundos para cancelar o reboot e reiniciar manualmente.

#### 3. (Apenas na primeira instalação do WSL) Definir usuário e senha do Ubuntu

Na primeira abertura do Ubuntu, será solicitado criar um usuário UNIX e senha.

---

### Parte 2 — WSL (Ubuntu)

#### 4. Clonar o repositório

```bash
git clone https://github.com/stephanviana/dotfiles ~/.dotfiles
```

#### 5. Rodar o instalador

```bash
cd ~/.dotfiles
chmod +x wsl/install.sh wsl/tools/*.sh
./wsl/install.sh
```

O instalador executa em 9 etapas:

```
[1/9] 🌐 Rede e DNS (Mirrored + DNS Tunneling)
[2/9] 📦 Atualiza sistema e instala dependências base
[3/9] 🔀 asdf (Go binary) + Node.js, Ruby, Python, Kotlin
[4/9] 🐳 Docker Engine + Compose
[5/9] 📱 Android ADB bridge + scrcpy
[6/9] 🔧 CLI tools (fzf, ripgrep, zoxide, gh, jq, Oh My Zsh)
[7/9] 🔗 Symlinks (.zshrc → ~/.zshrc, .gitconfig → ~/.gitconfig)
[8/9] 🐚 Zsh como shell padrão
[9/9] ✅ Resumo final
```

> ⏱ **Tempo estimado:** 15–25 minutos (Ruby e Python compilam do fonte)

#### 6. Ativar o systemd (necessário para Docker automático)

Após a instalação, reinicie o WSL no PowerShell para ativar o systemd:

```powershell
wsl --shutdown
```

Reabra o Ubuntu. A partir daí o Docker inicia automaticamente via systemd.

#### 7. Reiniciar o shell

```bash
exec zsh
```

---

## 🛠️ Guia de Configuração Pós-Instalação

### 1. Docker Engine (Sem Sudo e Systemd)

#### Docker sem `sudo`
O script adiciona seu usuário ao grupo `docker`. No entanto, para que o Ubuntu aplique essa permissão sem precisar deslogar do Windows, rode o comando abaixo na sua sessão de terminal ativa:
```bash
newgrp docker
```
Agora teste rodando um container de teste sem usar `sudo`:
```bash
docker run hello-world
```

#### Confirmar status do Systemd
Se você já reiniciou o WSL (`wsl --shutdown` no PowerShell), o Docker deve iniciar sozinho. Verifique o status com:
```bash
sudo systemctl status docker
```

---

### 2. Android ADB Bridge: Escolha seu Método

Para debugar apps Android (React Native, Flutter, Native Kotlin) a partir do WSL 2, existem dois métodos suportados:

#### Método A: TCP Bridge (Método Akita) — Configuração Padrão e Recomendada
Esse método vem pré-configurado no seu `.zshrc`. Ele redireciona os comandos `adb` do WSL para o servidor ADB rodando no próprio Windows. **Não necessita de USBIPD nem de passar o cabo USB físico para dentro do WSL.**

1. Abra o **Android Studio** ou execute no terminal do **Windows**:
   ```cmd
   adb devices
   ```
   *(Isso inicia o ADB Server no host Windows)*
2. No terminal do **WSL**, basta rodar:
   ```bash
   adb devices
   ```
   O WSL vai se comunicar com o Windows via rede mirrored e enxergará o mesmo dispositivo.
3. ⚠️ **Atenção:** A versão do `adb` no Windows e no WSL deve ser exatamente a mesma. Se houver incompatibilidade, o ADB reiniciará em loop.

#### Método B: USBIPD (Passagem Física do USB para o WSL)
Use este método se você precisar que o WSL enxergue o dispositivo USB como se estivesse conectado diretamente à placa-mãe Linux (ex: ferramentas de flash de ROM, ou se o método TCP falhar).

1. No **WSL**, instale as ferramentas necessárias de USBIP:
   ```bash
   sudo apt install -y linux-tools-generic hwdata
   sudo update-alternatives --install /usr/local/bin/usbip usbip $(dirname $(find /usr/lib/linux-tools/ -name usbip -print -quit 2>/dev/null) 2>/dev/null)/usbip 20
   ```
2. Conecte o celular via USB no PC.
3. No **PowerShell do Windows** (como Admin):
   ```powershell
   # Listar dispositivos para achar o BUSID do celular
   usbipd list

   # Compartilhar o dispositivo USB no Windows (apenas na primeira vez)
   usbipd bind --busid <BUSID>

   # Conectar/Montar o dispositivo dentro do WSL
   usbipd attach --wsl --busid <BUSID>
   ```
4. No **WSL (Ubuntu)**, verifique que o dispositivo USB aparece:
   ```bash
   lsusb
   adb devices
   ```
5. Para desconectar do WSL de volta para o Windows:
   ```powershell
   usbipd detach --busid <BUSID>
   ```

---

### 3. asdf (Gerenciando Versões)

O `asdf` gerencia múltiplos runtimes em uma única ferramenta. Os plugins `nodejs`, `ruby`, `python` e `kotlin` já vêm instalados na versão mais recente (`latest`).

#### Como instalar outra versão específica:
```bash
# Listar versões disponíveis
asdf list all nodejs

# Instalar a versão desejada
asdf install nodejs 20.11.0
```

#### Definir a versão ativa:
Você pode configurar de forma global ou local por projeto (criando um arquivo `.tool-versions` na pasta):
```bash
# Global (sistema todo)
asdf global nodejs 20.11.0

# Local (apenas no repositório atual)
asdf local nodejs 20.11.0
```

---

### 4. Git e Chaves SSH

#### Ajustar nome e e-mail
Como o arquivo `~/.gitconfig` é um symlink para o seu repositório de dotfiles, edite diretamente o arquivo do repositório para persistir suas alterações:
```bash
nano ~/.dotfiles/wsl/.gitconfig
```

#### Criar chave SSH para o GitHub
Rode o comando a seguir no terminal do WSL e siga as instruções (pressione enter nas confirmações):
```bash
ssh-keygen -t ed25519 -C "seu-email@gmail.com"
```
Inicie o ssh-agent e adicione a chave:
```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```
Exiba e copie a chave pública para colar nas configurações do seu GitHub:
```bash
cat ~/.ssh/id_ed25519.pub
```

---

### 5. Dicas de Produtividade (CLI Tools)

- **zoxide (`z`)**: Substitui o comando `cd`. Ele aprende as pastas que você mais acessa.
  ```bash
  z dotfiles   # vai direto para ~/.dotfiles independente de onde você estiver
  zi           # abre um menu interativo com o histórico de pastas
  ```
- **fzf**: Busca interativa no terminal.
  ```bash
  Ctrl + R     # Histórico de comandos interativo e pesquisável
  Ctrl + T     # Pesquisa rápida de arquivos no diretório atual
  Alt + C      # Pesquisa interativa de subdiretórios para navegar
  ```

---


## Estrutura do repositório

```
dotfiles/
├── README.md
├── windows/
│   ├── setup.ps1          # Setup Windows: WSL + Winget + .wslconfig
│   └── .wslconfig         # Configuração do WSL 2 (RAM, CPU, systemd)
└── wsl/
    ├── install.sh         # Orquestrador principal (8 etapas)
    ├── .zshrc             # Config do Zsh: asdf, aliases, Docker, ADB
    ├── .gitconfig         # Config do Git: usuário, editor, aliases
    └── tools/
        ├── network.sh     # Rede + DNS (mirrored, systemd-resolved stub)
        ├── asdf.sh        # asdf v0.16+ + Node, Ruby, Python, Kotlin
        ├── docker.sh      # Docker Engine + Compose (systemd-aware)
        ├── android.sh     # ADB bridge + scrcpy + instruções USBIPD
        └── cli-tools.sh   # Oh My Zsh, fzf, ripgrep, zoxide, gh, jq
```

---

## Personalização

| Arquivo | O que editar |
|---------|-------------|
| `wsl/.gitconfig` | Nome, email, editor padrão |
| `wsl/.zshrc` | Aliases, exports, plugins do Oh My Zsh |
| `windows/.wslconfig` | RAM, núcleos, modo de rede do WSL |

Para atualizar após edições:

```bash
cd ~/.dotfiles
git pull
exec zsh   # recarrega o .zshrc via symlink
```
