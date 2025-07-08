#!/bin/bash

set -e
BRANCH="${1:-php-dev}"  # Default branch if none provided
REPO_URL="https://github.com/JohannesGrobelski/nvim-bootstrap"

echo "🚀 Bootstrapping Neovim with branch: '$BRANCH'"

# 1. Install Neovim if not present (Debian/Ubuntu)
# 1.2. Check Neovim version
required_version="0.8.1"
installed_version=$(nvim --version 2>/dev/null | head -n1 | awk '{print $2}' || echo "0.0.0")

version_ge() {
    [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" = "$2" ]
}

if ! command -v nvim &>/dev/null || ! version_ge "$installed_version" "$required_version"; then
    echo "⚙️ Installing latest Neovim (current: $installed_version)..."

    # Download and extract latest nvim
    curl -LO https://github.com/neovim/neovim/releases/download/v0.11.2/nvim-linux-arm64.tar.gz
    tar xzf tar xzf nvim-linux-arm64.tar.gz
    sudo mv nvim-linux-arm64/ /opt/nvim
    sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
    rm nvim-linux64.tar.gz

    echo "✅ Neovim installed: $(nvim --version | head -n1)"
else
    echo "✅ Neovim $installed_version is sufficient"
fi

# 1.2. Backup existing Neovim config (optional but recommended)
echo "📁 Backing up existing Neovim config..."
timestamp=$(date +%s)
[ -d ~/.config/nvim ] && mv ~/.config/nvim ~/.config/nvim.bak.$timestamp
[ -d ~/.local/share/nvim ] && mv ~/.local/share/nvim ~/.local/share/nvim.bak.$timestamp
[ -d ~/.local/state/nvim ] && mv ~/.local/state/nvim ~/.local/state/nvim.bak.$timestamp
[ -d ~/.cache/nvim ] && mv ~/.cache/nvim ~/.cache/nvim.bak.$timestamp

# 3. Clone the selected branch of your repo into ~/.config/nvim
echo "⬇️ Cloning branch '$BRANCH' from $REPO_URL"
git clone --depth 1 --branch "$BRANCH" "$REPO_URL" ~/.config/nvim

# 4. Remove .git to make it a clean local config (optional)
rm -rf ~/.config/nvim/.git

# 5. Install plugins via LazyVim (headless)
echo "🔌 Installing plugins..."
nvim --headless "+Lazy! sync" +qa

# 6. Run LazyHealth (optional, but useful for debugging)
echo "🩺 Checking setup health..."
nvim --headless "+LazyHealth" +qa || true

echo "✅ Neovim setup complete!"
echo "👉 You can now run: nvim"
