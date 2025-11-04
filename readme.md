# Modern Terminal Setup with Auto-start Zellij + Atuin

Two installation options: **Quick Setup** (recommended) or **Full Setup** (comprehensive).

## 🚀 Quick Setup (Recommended)

**One command to rule them all:**
```bash
bash <(curl -fsSL https://bit.ly/modern-terminal-setup)
```

**Or download and run manually:**
```bash
# Download the quick setup script
wget -O quick-setup.sh https://github.com/yourusername/modern-terminal/raw/main/quick-setup.sh

# Make it executable and run
chmod +x quick-setup.sh
./quick-setup.sh
```

### What Quick Setup Includes:
- ✅ **Auto-starts Zellij** when terminal opens
- ✅ **Atuin** for better history (Ctrl+R)
- ✅ **Default Zsh** with plugins (no oh-my-zsh)
- ✅ **Modern CLI tools**: eza, bat, ripgrep, fd, fzf
- ✅ **Starship prompt**
- ✅ **LazyGit** for Git management
- ✅ Essential aliases and functions

---

## 🎯 What You Get

After installation, **every time you open a terminal**:

1. **Zellij starts automatically** (terminal multiplexer)
2. **Atuin is ready** for enhanced history search
3. **Modern tools** replace traditional commands
4. **Beautiful Starship prompt**

### Key Features:

#### 🖥️ Zellij (Auto-starts)
- **Alt+n**: New pane
- **Alt+t**: New tab  
- **Alt+h/j/k/l**: Navigate panes
- **Alt+f**: Toggle fullscreen
- **Alt+x**: Close pane

#### 📚 Atuin (Better History)
- **Ctrl+R**: Fuzzy search through history
- **Up/Down**: Navigate history
- Syncs across machines (optional)

#### ⚡ Modern CLI Tools
```bash
ls        # → eza (with icons and git status)
cat       # → bat (syntax highlighting)
grep      # → ripgrep (faster)
find      # → fd (simpler)
cd        # → zoxide (smart jumping)
```

#### 🌟 Git Integration
```bash
lg        # Opens LazyGit TUI
gs        # git status
ga        # git add
gc        # git commit
gl        # git log --oneline --graph
```

---

## 🚨 Troubleshooting

### Zellij doesn't start automatically
Check if the auto-start code is in `~/.zshrc`:
```bash
grep -A5 "AUTO-START ZELLIJ" ~/.zshrc
```

### Commands not found after install
Restart terminal or reload shell:
```bash
exec zsh
```

### Rust tools not in PATH
Add to `~/.zshrc`:
```bash
export PATH="$HOME/.cargo/bin:$PATH"
```

---

## 🎉 You're Done!

Restart your terminal and enjoy your modern terminal setup! 

Every terminal session will now automatically start with Zellij and have Atuin ready for enhanced history search.

**Happy coding! 🚀**
EOF
