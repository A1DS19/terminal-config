#!/bin/bash
# Modern Terminal Setup Script
# Auto-starts zellij and sets up atuin with default zsh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${PURPLE}
╔══════════════════════════════════════════════════════════════╗
║                   🚀 Modern Terminal Setup                  ║
║          Zsh + Zellij + Atuin + Modern CLI Tools           ║
╚══════════════════════════════════════════════════════════════╝${NC}"
}

# Detect OS and package manager
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt &> /dev/null; then
            OS="ubuntu"
            PKG_MANAGER="apt"
            INSTALL_CMD="sudo apt update && sudo apt install -y"
        elif command -v pacman &> /dev/null; then
            OS="arch"
            PKG_MANAGER="pacman"
            INSTALL_CMD="sudo pacman -S --noconfirm"
        elif command -v dnf &> /dev/null; then
            OS="fedora"
            PKG_MANAGER="dnf"
            INSTALL_CMD="sudo dnf install -y"
        else
            print_error "Unsupported Linux distribution"
            exit 1
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        PKG_MANAGER="brew"
        if ! command -v brew &> /dev/null; then
            print_status "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        INSTALL_CMD="brew install"
    else
        print_error "Unsupported operating system: $OSTYPE"
        exit 1
    fi
    
    print_success "Detected OS: $OS with package manager: $PKG_MANAGER"
}

# Install packages based on OS
install_packages() {
    print_status "Installing modern CLI tools..."
    
    if [[ "$OS" == "ubuntu" ]]; then
        # Update package list
        sudo apt update
        
        # Install core packages
        sudo apt install -y \
            zsh curl wget git build-essential \
            unzip software-properties-common \
            python3-pip nodejs npm
        
        # Install Rust (needed for some tools)
        if ! command -v cargo &> /dev/null; then
            print_status "Installing Rust..."
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
            source ~/.cargo/env
        fi
        
        # Install modern tools via cargo
        cargo install eza fd-find bat ripgrep zoxide starship atuin zellij
        cargo install procs dust bandwhich choose sd
        
        # Install additional tools
        sudo apt install -y htop jq httpie
        
        # Install lazygit
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf lazygit.tar.gz lazygit
        sudo install lazygit /usr/local/bin
        rm lazygit.tar.gz lazygit
        
        # Install fzf
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install --all
        
    elif [[ "$OS" == "arch" ]]; then
        sudo pacman -Sy
        sudo pacman -S --noconfirm \
            zsh curl wget git base-devel \
            unzip python nodejs npm \
            eza fd bat ripgrep zoxide starship \
            fzf htop jq httpie lazygit \
            procs dust bandwhich
        
        # Install from AUR (if yay is available)
        if command -v yay &> /dev/null; then
            yay -S --noconfirm atuin zellij choose sd
        else
            cargo install atuin zellij choose sd
        fi
        
    elif [[ "$OS" == "fedora" ]]; then
        sudo dnf install -y \
            zsh curl wget git gcc make \
            unzip python3 nodejs npm \
            fd-find bat ripgrep fzf htop jq httpie
        
        # Install Rust tools
        cargo install eza zoxide starship atuin zellij
        cargo install procs dust bandwhich choose sd
        
        # Install lazygit
        sudo dnf copr enable atim/lazygit -y
        sudo dnf install lazygit -y
        
    elif [[ "$OS" == "macos" ]]; then
        brew install \
            zsh curl wget git \
            eza fd bat ripgrep zoxide starship \
            fzf htop jq httpie lazygit \
            procs dust bandwhich choose sd \
            atuin zellij
    fi
    
    print_success "All packages installed successfully!"
}

# Setup zsh with modern plugins (without oh-my-zsh)
setup_zsh() {
    print_status "Setting up Zsh with modern plugins..."
    
    # Install zsh if not already installed
    if ! command -v zsh &> /dev/null; then
        print_error "Zsh installation failed"
        exit 1
    fi
    
    # Create zsh config directory
    mkdir -p ~/.config/zsh
    
    # Install zsh plugins manually (lightweight approach)
    ZSH_PLUGINS_DIR="$HOME/.config/zsh/plugins"
    mkdir -p "$ZSH_PLUGINS_DIR"
    
    # Install zsh-autosuggestions
    if [ ! -d "$ZSH_PLUGINS_DIR/zsh-autosuggestions" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_PLUGINS_DIR/zsh-autosuggestions"
    fi
    
    # Install zsh-syntax-highlighting
    if [ ! -d "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting" ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting"
    fi
    
    # Install zsh-completions
    if [ ! -d "$ZSH_PLUGINS_DIR/zsh-completions" ]; then
        git clone https://github.com/zsh-users/zsh-completions "$ZSH_PLUGINS_DIR/zsh-completions"
    fi
    
    print_success "Zsh plugins installed!"
}

# Create zsh configuration
create_zsh_config() {
    print_status "Creating Zsh configuration..."
    
    cat > ~/.zshrc << 'EOF'
# Modern Zsh Configuration
# Auto-starts Zellij and sets up Atuin

# Set up the prompt
autoload -U colors && colors

# History settings
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt appendhistory
setopt sharehistory
setopt incappendhistory
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_verify

# Enable completion
autoload -U compinit
compinit

# Load plugins
ZSH_PLUGINS_DIR="$HOME/.config/zsh/plugins"

# zsh-completions
if [ -d "$ZSH_PLUGINS_DIR/zsh-completions" ]; then
    fpath=($ZSH_PLUGINS_DIR/zsh-completions/src $fpath)
fi

# zsh-autosuggestions
if [ -f "$ZSH_PLUGINS_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
    source "$ZSH_PLUGINS_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
    ZSH_AUTOSUGGEST_STRATEGY=(history completion)
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=241'
fi

# zsh-syntax-highlighting (must be last)
if [ -f "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
    source "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# Modern tool integrations
# Starship prompt
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi

# Zoxide (smart cd)
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
fi

# Atuin (better history)
if command -v atuin &> /dev/null; then
    eval "$(atuin init zsh)"
fi

# FZF integration
if [ -f ~/.fzf.zsh ]; then
    source ~/.fzf.zsh
elif command -v fzf &> /dev/null; then
    # Set up fzf key bindings and fuzzy completion
    eval "$(fzf --zsh)"
fi

# Modern aliases
alias ls='eza --icons --git'
alias ll='eza -l --icons --git'
alias la='eza -la --icons --git'
alias lt='eza --tree --level=2 --icons'
alias cat='bat'
alias grep='rg'
alias find='fd'
alias ps='procs'
alias du='dust'
alias cd='z'

# Git aliases
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph'
alias gd='git diff'
alias lg='lazygit'

# Docker aliases (if docker is available)
if command -v docker &> /dev/null; then
    alias d='docker'
    alias dc='docker-compose'
fi

# Kubernetes aliases (if kubectl is available)
if command -v kubectl &> /dev/null; then
    alias k='kubectl'
fi

# Development aliases
if command -v nvim &> /dev/null; then
    alias v='nvim'
    alias vim='nvim'
elif command -v vim &> /dev/null; then
    alias v='vim'
fi

alias py='python3'
alias pip='pip3'
alias serve='python3 -m http.server'

# Navigation aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'

# Utility functions
function mkcd() { mkdir -p "$1" && cd "$1"; }
function weather() { curl "wttr.in/$1"; }
function cheat() { curl "cheat.sh/$1"; }
function qr() { curl "qrenco.de/$1"; }
function extract() {
    if [ -f $1 ]; then
        case $1 in
            *.tar.bz2) tar xjf $1 ;;
            *.tar.gz) tar xzf $1 ;;
            *.bz2) bunzip2 $1 ;;
            *.rar) unrar e $1 ;;
            *.gz) gunzip $1 ;;
            *.tar) tar xf $1 ;;
            *.tbz2) tar xjf $1 ;;
            *.tgz) tar xzf $1 ;;
            *.zip) unzip $1 ;;
            *.Z) uncompress $1 ;;
            *.7z) 7z x $1 ;;
            *) echo "'$1' cannot be extracted" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Auto-start Zellij if not already in a session and terminal supports it
if command -v zellij &> /dev/null; then
    if [[ -z "$ZELLIJ" && -z "$TMUX" && $- == *i* ]]; then
        # Only start zellij in interactive shells and not in VS Code terminal
        if [[ -z "$VSCODE_PID" && -z "$TERM_PROGRAM" ]]; then
            exec zellij
        fi
    fi
fi

EOF
    
    print_success "Zsh configuration created!"
}

# Setup Starship prompt
setup_starship() {
    print_status "Setting up Starship prompt..."
    
    mkdir -p ~/.config
    cat > ~/.config/starship.toml << 'EOF'
# Starship Configuration
format = """
$username\
$hostname\
$directory\
$git_branch\
$git_state\
$git_status\
$cmd_duration\
$line_break\
$python\
$character"""

[directory]
style = "blue"

[character]
success_symbol = "[➜](bold green)"
error_symbol = "[➜](bold red)"

[git_branch]
symbol = "🌱 "
format = "[$symbol$branch]($style) "
style = "bright-black"

[git_status]
format = '([\[$all_status$ahead_behind\]]($style) )'
style = "cyan"

[git_state]
format = '\([$state( $progress_current/$progress_total)]($style)\) '
style = "bright-black"

[cmd_duration]
format = "[$duration]($style) "
style = "yellow"

[python]
symbol = "🐍 "
format = "[$symbol$pyenv_prefix$version( \\($virtualenv\\))]($style) "
style = "bright-black"

[nodejs]
symbol = "⚡ "
format = "[$symbol$version]($style) "
style = "bright-black"

[rust]
symbol = "🦀 "
format = "[$symbol$version]($style) "
style = "bright-black"

[package]
format = "[$symbol$version]($style) "
style = "bright-black"
EOF
    
    print_success "Starship prompt configured!"
}

# Setup Zellij
setup_zellij() {
    print_status "Setting up Zellij..."
    
    mkdir -p ~/.config/zellij
    cat > ~/.config/zellij/config.kdl << 'EOF'
// Zellij Configuration
default_shell "zsh"

// Simplified keybindings
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
        bind "Alt =" { Resize "Increase"; }
        bind "Alt -" { Resize "Decrease"; }
        bind "Alt [" { PreviousSwapLayout; }
        bind "Alt ]" { NextSwapLayout; }
    }
}

// UI configuration
ui {
    pane_frames {
        rounded_corners true
        hide_session_name false
    }
}

// Theme
themes {
    dracula {
        fg 248 248 242
        bg 40 42 54
        red 255 85 85
        green 80 250 123
        yellow 241 250 140
        blue 98 114 164
        magenta 255 121 198
        orange 255 184 108
        cyan 139 233 253
        black 0 0 0
        white 255 255 255
    }
}

theme "dracula"

// Default layout
default_layout "compact"

// Session serialization
session_serialization false

// Mouse mode
mouse_mode true

// Copy command (adjust for your OS)
copy_command "wl-copy"        // Linux Wayland
// copy_command "xclip -selection clipboard"  // Linux X11
// copy_command "pbcopy"      // macOS

// Scroll buffer size
scroll_buffer_size 10000
EOF
    
    print_success "Zellij configured!"
}

# Setup Atuin
setup_atuin() {
    print_status "Setting up Atuin..."
    
    # Initialize Atuin
    if command -v atuin &> /dev/null; then
        # Import existing history
        atuin import auto || true
        print_success "Atuin configured and history imported!"
    else
        print_warning "Atuin not found, skipping configuration"
    fi
}

# Set zsh as default shell
set_default_shell() {
    print_status "Setting Zsh as default shell..."
    
    current_shell=$(echo $SHELL)
    zsh_path=$(which zsh)
    
    if [[ "$current_shell" != "$zsh_path" ]]; then
        # Add zsh to valid shells if not already there
        if ! grep -q "$zsh_path" /etc/shells; then
            echo "$zsh_path" | sudo tee -a /etc/shells
        fi
        
        # Change default shell
        chsh -s "$zsh_path"
        print_success "Default shell changed to Zsh"
        print_warning "Please restart your terminal or log out and back in for the change to take effect"
    else
        print_success "Zsh is already the default shell"
    fi
}

# Install Nerd Font
install_nerd_font() {
    print_status "Installing Nerd Font..."
    
    if [[ "$OS" == "macos" ]]; then
        brew tap homebrew/cask-fonts
        brew install --cask font-hack-nerd-font
    else
        # Download and install Hack Nerd Font
        font_dir="$HOME/.local/share/fonts"
        mkdir -p "$font_dir"
        
        cd /tmp
        curl -fLo "Hack.zip" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip
        unzip -o Hack.zip -d "$font_dir"
        rm Hack.zip
        
        # Update font cache
        if command -v fc-cache &> /dev/null; then
            fc-cache -fv
        fi
    fi
    
    print_success "Hack Nerd Font installed!"
}

# Cleanup function
cleanup() {
    print_status "Cleaning up..."
    # Remove any temporary files
    rm -f /tmp/lazygit.tar.gz /tmp/lazygit
}

# Main installation function
main() {
    print_header
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        print_error "Please don't run this script as root"
        exit 1
    fi
    
    # Detect OS and package manager
    detect_os
    
    # Install packages
    install_packages
    
    # Setup shell and configurations
    setup_zsh
    create_zsh_config
    setup_starship
    setup_zellij
    setup_atuin
    install_nerd_font
    
    # Set zsh as default shell
    set_default_shell
    
    # Cleanup
    cleanup
    
    print_success "🎉 Modern terminal setup complete!"
    echo -e "${GREEN}
╔══════════════════════════════════════════════════════════════╗
║                      Setup Complete!                        ║
║                                                              ║
║  🚀 Restart your terminal to start using:                   ║
║     • Zellij (auto-starts)                                  ║
║     • Atuin (better history with Ctrl+R)                    ║
║     • Modern CLI tools (eza, bat, ripgrep, etc.)            ║
║     • Starship prompt                                       ║
║                                                              ║
║  📖 Key bindings in Zellij:                                 ║
║     • Alt+n: New pane                                       ║
║     • Alt+t: New tab                                        ║
║     • Alt+h/j/k/l: Navigate panes                           ║
║     • Alt+f: Toggle fullscreen                              ║
║     • Alt+x: Close pane                                     ║
║                                                              ║
║  🔧 Configuration files created:                            ║
║     • ~/.zshrc                                              ║
║     • ~/.config/starship.toml                               ║
║     • ~/.config/zellij/config.kdl                           ║
╚══════════════════════════════════════════════════════════════╝${NC}"
}

# Run the main function
main "$@"
EOF
