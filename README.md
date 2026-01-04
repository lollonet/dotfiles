# Dotfiles

Configurazioni shell sincronizzate tra Jupiter (macOS) e Zeus (Linux).

## Struttura

```
bash/
├── bashrc              # File principale, identico su entrambi gli host
├── bashrc_common       # Configurazione Oh My Bash condivisa
├── bashrc_macos        # Specifiche per macOS (Homebrew)
└── bashrc_linux        # Specifiche per Linux (temperatura CPU, neofetch)
```

## Installazione

### 1. Crea il file secrets (locale, non versionato)

```bash
cat > ~/.bashrc_secrets << 'EOF'
# ~/.bashrc_secrets
# API Keys and secrets - DO NOT VERSION THIS FILE

export CONTEXT7_API_KEY="your-key-here"
export BRAVE_API_KEY="your-key-here"
export GITHUB_PERSONAL_ACCESS_TOKEN="your-token-here"
EOF

chmod 600 ~/.bashrc_secrets
```

### 2. Installa i dotfiles

```bash
cd ~/Code/dotfiles

# Backup dei file esistenti
cp ~/.bashrc ~/.bashrc.backup
cp ~/.bashrc_common ~/.bashrc_common.backup 2>/dev/null

# Link o copia i file
cp bash/bashrc ~/.bashrc
cp bash/bashrc_common ~/.bashrc_common

# macOS
cp bash/bashrc_macos ~/.bashrc_macos

# Linux
cp bash/bashrc_linux ~/.bashrc_linux
```

### 3. Ricarica la shell

```bash
source ~/.bashrc
```

## Architettura

Il sistema usa un approccio modulare:

1. **`~/.bashrc`** (main entry point)
   - Carica `~/.bashrc_common` (configurazione Oh My Bash)
   - Carica `~/.bashrc_[os]` (specifiche per OS)
   - Carica `~/.bashrc_secrets` (API keys, mai versionato)

2. **`~/.bashrc_common`**
   - Tema Oh My Bash (brainy)
   - Plugin e completions condivisi
   - PATH comune
   - NVM setup

3. **`~/.bashrc_macos`**
   - Homebrew setup
   - Bash completion

4. **`~/.bashrc_linux`**
   - Git Credential Manager
   - Funzione temperatura CPU
   - neofetch

## Sicurezza

- ✅ File secrets **mai versionato** (in `.gitignore`)
- ✅ Permessi `600` su `~/.bashrc_secrets`
- ✅ Pattern protetti in `~/.claude/protected-paths.json`

## Note

- Su macOS, assicurati di avere Homebrew installato
- Su Linux, installa `lm-sensors` per la funzione temperatura CPU
- Il file `.bashrc_secrets` è **locale** per ogni macchina
