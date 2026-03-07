#!/usr/bin/env bash
set -e

# ─── Colors ──────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC}  $1"; }
success() { echo -e "${GREEN}[OK]${NC}    $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

NVIM_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
REPO_URL="https://github.com/nicolasfalesy/nvim-config.git"

# ─── Dependency Checks ───────────────────────────────────────────────

check_nvim() {
  if ! command -v nvim &>/dev/null; then
    error "Neovim is not installed. Install it from https://neovim.io (v0.11+ required)."
  fi

  local ver_string
  ver_string=$(nvim --version | head -1)

  local major minor
  major=$(echo "$ver_string" | grep -oP '(?<=v)\d+' | head -1)
  minor=$(echo "$ver_string" | grep -oP '(?<=v\d\.)\d+' | head -1)

  if [ -z "$major" ] || [ -z "$minor" ]; then
    warn "Could not parse Neovim version — proceeding anyway."
  elif [ "$major" -eq 0 ] && [ "$minor" -lt 11 ]; then
    error "Neovim v0.11+ is required (found $ver_string). Please upgrade."
  fi

  success "Neovim — $ver_string"
}

check_git() {
  command -v git &>/dev/null || error "git is not installed. Install it with your package manager."
  success "git — $(git --version | awk '{print $3}')"
}

check_build_tools() {
  local missing=()
  command -v make &>/dev/null || missing+=("make")
  command -v gcc &>/dev/null  || missing+=("gcc")

  if [ ${#missing[@]} -gt 0 ]; then
    warn "Missing build tools: ${missing[*]}"
    warn "Treesitter parsers won't compile without them."
    warn "Install with:  sudo apt install build-essential   (Debian/Ubuntu)"
    warn "               sudo dnf install gcc make           (Fedora)"
    warn "               brew install gcc make               (macOS)"
  else
    success "Build tools — gcc $(gcc --version | grep -oP '\d+\.\d+\.\d+' | head -1), make $(make --version | grep -oP '\d+\.\d+' | head -1)"
  fi
}

install_node_via_nvm() {
  info "Installing nvm (Node Version Manager)..."
  export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"    # respect existing value, default to ~/.nvm
  mkdir -p "$NVM_DIR"                         # ensure the directory actually exists
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

  # shellcheck source=/dev/null
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

  info "Installing Node.js LTS..."
  nvm install --lts

  # Symlink into ~/.local/bin so Mason and other tools can find node/npm
  mkdir -p "$HOME/.local/bin"
  ln -sf "$(which node)" "$HOME/.local/bin/node"
  ln -sf "$(which npm)"  "$HOME/.local/bin/npm"

  success "Node $(node --version), npm $(npm --version) — symlinked to ~/.local/bin"
}

check_node() {
  if command -v node &>/dev/null && command -v npm &>/dev/null; then
    success "Node — $(node --version), npm $(npm --version)"
    return
  fi

  warn "node/npm not found — Mason requires them to install LSP servers (pyright, etc.)"
  echo ""
  read -rp "  Install Node.js LTS via nvm? [Y/n] " answer
  answer="${answer:-Y}"

  if [[ "$answer" =~ ^[Yy]$ ]]; then
    install_node_via_nvm
  else
    warn "Skipping Node install. Mason LSP installs may fail without it."
  fi
}

check_python() {
  if command -v python3 &>/dev/null; then
    success "Python — $(python3 --version | awk '{print $2}')"
  else
    warn "python3 not found (optional, used by pyright and some tools)"
  fi
}

check_ripgrep() {
  if command -v rg &>/dev/null; then
    success "ripgrep — $(rg --version | head -1 | awk '{print $2}')"
  else
    warn "ripgrep not found (optional, but Telescope live_grep won't work without it)"
    warn "Install with:  sudo apt install ripgrep   or   cargo install ripgrep"
  fi
}

# ─── Config Install ───────────────────────────────────────────────────

backup_existing() {
  if [ ! -d "$NVIM_CONFIG_DIR" ]; then
    return
  fi

  if [ -d "$NVIM_CONFIG_DIR/.git" ]; then
    info "nvim-config repo already exists at $NVIM_CONFIG_DIR — pulling latest..."
    git -C "$NVIM_CONFIG_DIR" pull
    echo ""
    success "Config updated. Open nvim and run :Lazy sync to update plugins."
    exit 0
  fi

  local backup="${NVIM_CONFIG_DIR}.bak.$(date +%Y%m%d_%H%M%S)"
  warn "Existing config found — backing up to: $backup"
  mv "$NVIM_CONFIG_DIR" "$backup"
}

clone_config() {
  info "Cloning config to $NVIM_CONFIG_DIR..."
  git clone "$REPO_URL" "$NVIM_CONFIG_DIR"
  success "Config cloned!"
}

# ─── Main ─────────────────────────────────────────────────────────────

echo ""
echo -e "${BOLD}  nvim-config installer${NC}"
echo "  ─────────────────────────────────"
echo ""

info "Checking dependencies..."
echo ""
check_nvim
check_git
check_build_tools
check_node
check_python
check_ripgrep

echo ""
echo -e "  ${YELLOW}Note:${NC} Make sure your terminal uses a Nerd Font for icons in lualine."
echo "        Get one at: https://www.nerdfonts.com/"
echo ""
echo "  ─────────────────────────────────"
info "Installing config..."
echo ""
backup_existing
clone_config

echo ""
echo "  ─────────────────────────────────"
echo -e "${GREEN}${BOLD}  Done!${NC}"
echo ""
echo "  Next steps:"
echo "  1. Open nvim — lazy.nvim will auto-install all plugins on first launch"
echo "  2. Wait for the install to finish, then quit and re-open nvim"
echo "  3. LSP servers (pyright, lua_ls) will be auto-installed via Mason"
echo "  4. Treesitter parsers will be installed automatically"
echo ""
echo "  Useful commands inside nvim:"
echo "    :Lazy          — manage plugins"
echo "    :Mason         — manage LSP servers"
echo "    :TSUpdate      — update Treesitter parsers"
echo "    :checkhealth   — diagnose any issues"
echo ""
