#!/bin/bash
# Quick Modern Terminal Setup - Auto-start Zellij + Atuin

set -e

echo "🚀 Quick Modern Terminal Setup with Auto-start Zellij + Atuin"

# Detect package manager
if command -v brew >/dev/null 2>&1; then
    PM="brew install"
    OS="macos"
elif command -v apt >/dev/null 2>&1; then
    PM="sudo apt install -y"
    OS="ubuntu"
elif command -v pacman >/dev/null 2>&1; then
    PM="sudo pacman -S --noconfirm"
    OS="arch"
else
    echo "❌ Please install homebrew (macOS) or ensure you're on Ubuntu/Arch Linux"
    exit 1
fi

echo "📦 Detected OS: $OS"

# Install essential tools
echo "📦 Installing tools..."
if [ "$OS" = "macos" ]; then
    # macOS
    brew install zsh zellij atuin starship eza bat ripgrep fd fzf git lazygit zoxide
else
    # Linux - install basics first
    sudo apt update
    sudo apt install -y zsh curl git build-essential
    
    # Install Rust for modern tools
    if ! command -v cargo >/dev/null 2>&1; then
        echo "🦀 Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        export PATH="$HOME/.cargo/bin:$PATH"
        source ~/.cargo/env
    fi
    
    # Install modern tools via cargo
    echo "⚡ Installing modern CLI tools..."
    cargo install zellij atuin starship eza bat ripgrep fd-find zoxide
    
    # Install fzf
    if [ ! -d ~/.fzf ]; then
        echo "🔍 Installing fzf..."
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install --all
    fi
    
    # Install lazygit
    echo "📝 Installing lazygit..."
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit /usr/local/bin
    rm lazygit.tar.gz lazygit
fi

# Setup minimal zsh plugins
echo "🔧 Setting up Zsh plugins..."
mkdir -p ~/.config/zsh/plugins

# Install zsh-autosuggestions
if [ ! -d ~/.config/zsh/plugins/zsh-autosuggestions ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.config/zsh/plugins/zsh-autosuggestions
fi

# Install zsh-syntax-highlighting  
if [ ! -d ~/.config/zsh/plugins/zsh-syntax-highlighting ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.config/zsh/plugins/zsh-syntax-highlighting
fi

# Create .zshrc with auto-start zellij and atuin
echo "⚙️  Creating Zsh configuration..."
cat > ~/.zshrc << 'ZSHRC_EOF'
# Auto-start Zellij + Atuin + Modern Terminal Setup

# Load plugins
if [ -f ~/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source ~/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

if [ -f ~/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source ~/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# History settings
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt appendhistory sharehistory incappendhistory hist_ignore_all_dups

# Enable completion
autoload -U compinit && compinit

# Modern tool integrations
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

if command -v atuin >/dev/null 2>&1; then
    eval "$(atuin init zsh)"
fi

# Load fzf
if [ -f ~/.fzf.zsh ]; then
    source ~/.fzf.zsh
fi

# Modern aliases
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --icons --git'
    alias ll='eza -l --icons --git' 
    alias la='eza -la --icons --git'
fi

if command -v bat >/dev/null 2>&1; then
    alias cat='bat'
fi

if command -v ripgrep >/dev/null 2>&1; then
    alias grep='rg'
fi

if command -v fd >/dev/null 2>&1; then
    alias find='fd'
fi

if command -v zoxide >/dev/null 2>&1; then
    alias cd='z'
fi

# Git aliases
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph'

if command -v lazygit >/dev/null 2>&1; then
    alias lg='lazygit'
fi

# Navigation
alias ..='cd ..'
alias ...='cd ../..'

# Utility functions
mkcd() { mkdir -p "$1" && cd "$1"; }

# AUTO-START ZELLIJ
# Only start if:
# - zellij is available
# - not already in zellij or tmux
# - interactive shell
# - not in VS Code terminal
if command -v zellij >/dev/null 2>&1; then
    if [ -z "$ZELLIJ" ] && [ -z "$TMUX" ] && [[ $- == *i* ]] && [ -z "$VSCODE_PID" ]; then
        exec zellij
    fi
fi
ZSHRC_EOF

# Setup Zellij config
echo "🖥️  Setting up Zellij..."
mkdir -p ~/.config/zellij
cat > ~/.config/zellij/config.kdl << 'ZELLIJ_EOF'
// Simple Zellij Config
default_shell "zsh"

keybinds {
    normal {
        bind "Alt h" { MoveFocus "Left"; }
        bind "Alt l" { MoveFocus "Right"; }
        bind "Alt j" { MoveFocus "Down"; }
        bind "Alt k" { MoveFocus "Up"; }
        bind "Alt n" { NewPane; }
        bind "Alt t" { NewTab; }
        bind "Alt x" { ClosePane; }
        bind "Alt f" { ToggleFocusFullscreen; }
    }
}

ui {
    pane_frames {
        rounded_corners true
    }
}

mouse_mode true
default_layout "compact"
scroll_buffer_size 10000
ZELLIJ_EOF

# Setup Starship prompt
echo "⭐ Setting up Starship..."
mkdir -p ~/.config
cat > ~/.config/starship.toml << 'STARSHIP_EOF'
format = """
$directory\
$git_branch\
$git_status\
$cmd_duration\
$line_break\
$character"""

[character]
success_symbol = "[➜](bold green)"
error_symbol = "[➜](bold red)"

[git_branch]
symbol = "🌱 "

[directory]
style = "blue"
STARSHIP_EOF

# Initialize Atuin
echo "📚 Setting up Atuin..."
if command -v atuin >/dev/null 2>&1; then
    atuin import auto || true
fi

# Set zsh as default shell
echo "🐚 Setting Zsh as default shell..."
ZSH_PATH=$(which zsh)
if [ "$SHELL" != "$ZSH_PATH" ]; then
    if ! grep -q "$ZSH_PATH" /etc/shells; then
        echo "$ZSH_PATH" | sudo tee -a /etc/shells
    fi
    chsh -s "$ZSH_PATH"
    echo "⚠️  Please restart your terminal for shell change to take effect"
fi

echo "✅ Setup complete!"
echo ""
echo "🎉 Your terminal now features:"
echo "   • Auto-starts Zellij (terminal multiplexer)"
echo "   • Atuin (better history with Ctrl+R)"
echo "   • Modern CLI tools (eza, bat, ripgrep, etc.)"
echo "   • Starship prompt"
echo ""
echo "🔥 Zellij shortcuts:"
echo "   Alt+n: New pane    Alt+t: New tab"
echo "   Alt+h/j/k/l: Navigate    Alt+f: Fullscreen"
echo "   Alt+x: Close pane"
echo ""
echo "🚀 Restart your terminal to start using everything!"
