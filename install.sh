# 1. Install basic tools (Ubuntu/WSL)
sudo apt update && sudo apt install -y zsh curl git build-essential

# 2. Install Rust (for modern tools)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source ~/.cargo/env

# 3. Install modern CLI tools
cargo install zellij atuin starship eza bat ripgrep fd-find zoxide

# 4. Install fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install --all

# 5. Install LazyGit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf /tmp/lazygit.tar.gz -C /tmp && sudo install /tmp/lazygit /usr/local/bin

# 6. Setup Zsh plugins
mkdir -p ~/.config/zsh/plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.config/zsh/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.config/zsh/plugins/zsh-syntax-highlighting

# 7. Create .zshrc (copy this entire block)
cat > ~/.zshrc << 'EOF'
# Load plugins
[ -f ~/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ] && source ~/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f ~/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && source ~/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# History
HISTSIZE=50000; SAVEHIST=50000; HISTFILE=~/.zsh_history
setopt appendhistory sharehistory incappendhistory hist_ignore_all_dups
autoload -U compinit && compinit

# Modern tools
command -v starship >/dev/null && eval "$(starship init zsh)"
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
command -v atuin >/dev/null && eval "$(atuin init zsh)"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Aliases
command -v eza >/dev/null && alias ls='eza --icons --git' && alias ll='eza -l --icons --git'
command -v bat >/dev/null && alias cat='bat'
command -v rg >/dev/null && alias grep='rg'
command -v fd >/dev/null && alias find='fd'
command -v zoxide >/dev/null && alias cd='z'
alias g='git'; alias gs='git status'; alias ga='git add'; alias gc='git commit'
command -v lazygit >/dev/null && alias lg='lazygit'
alias ..='cd ..'; alias ...='cd ../..'
mkcd() { mkdir -p "$1" && cd "$1"; }

# AUTO-START ZELLIJ
if command -v zellij >/dev/null; then
    if [[ -z "$ZELLIJ" && -z "$TMUX" && $- == *i* && -z "$VSCODE_PID" ]]; then
        exec zellij
    fi
fi
EOF

# 8. Setup Zellij config
mkdir -p ~/.config/zellij
cat > ~/.config/zellij/config.kdl << 'EOF'
default_shell "zsh"

keybinds {
    normal {
        bind "Alt h" { MoveFocus "Left"; }
        bind "Alt l" { MoveFocus "Right"; }
        bind "Alt j" { MoveFocus "Down"; }
        bind "Alt k" { MoveFocus "Up"; }
        bind "Alt n" { NewPane; }
        bind "Alt t" { NewTab; }
        bind "Alt q" { Quit; }
        bind "Alt f" { ToggleFocusFullscreen; }
        bind "Alt =" { Resize "Increase"; }
        bind "Alt -" { Resize "Decrease"; }
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
EOF

# 9. Setup Starship prompt
mkdir -p ~/.config
cat > ~/.config/starship.toml << 'EOF'
format = """$directory$git_branch$git_status$cmd_duration$line_break$character"""
[character]
success_symbol = "[➜](bold green)"
error_symbol = "[➜](bold red)"
[git_branch]
symbol = "🌱 "
EOF

# 10. Initialize Atuin and set Zsh as default
atuin import auto || true
chsh -s $(which zsh)

# 11. Restart terminal
echo "✅ Done! Restart your terminal to enjoy Zellij + Atuin auto-start!"
