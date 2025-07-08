#!/bin/bash

set -e
BRANCH="${1:-php-dev}"  # Default branch if none provided
REPO_URL="https://github.com/JohannesGrobelski/nvim-bootstrap"

echo "🚀 Bootstrapping Neovim with branch: '$BRANCH'"

# 1. Install Neovim if not present (Debian/Ubuntu)

#!/bin/bash
set -e

NVIM_MIN_VERSION="0.8.0"

# Prüfen, ob nvim vorhanden ist
if command -v nvim >/dev/null 2>&1; then
  # Version auslesen, z.B. "NVIM v0.6.1"
  NVIM_VERSION=$(nvim --version | head -n1 | awk '{print $2}' | tr -d 'v')
  # Vergleich der Versionen
  if printf '%s\n%s\n' "$NVIM_MIN_VERSION" "$NVIM_VERSION" | sort -V -C; then
    echo "✅ Neovim ist installiert und Version >= $NVIM_MIN_VERSION ($NVIM_VERSION)"
  else
    echo "⚠️ Neovim Version ($NVIM_VERSION) ist < $NVIM_MIN_VERSION, neu installieren..."
    INSTALL_NVIM=1
  fi
else
  echo "❌ Neovim nicht installiert, Installation startet..."
  INSTALL_NVIM=1
fi

if [ "$INSTALL_NVIM" == "1" ]; then
  NVIM_VERSION_TO_INSTALL="v0.11.2"
  ARCH="linux64" # ggf. anpassen
  echo "⬇️ Lade Neovim $NVIM_VERSION_TO_INSTALL herunter..."
  curl -L -o nvim.tar.gz "https://github.com/neovim/neovim/releases/download/$NVIM_VERSION_TO_INSTALL/nvim-$ARCH.tar.gz"
  tar xzf nvim.tar.gz
  sudo mv nvim-$ARCH /opt/nvim
  sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
  rm nvim.tar.gz
fi

# Weiter mit restlicher Installation, z.B. Config klonen etc.
# 2. Backup existing Neovim config (optional but recommended)
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
