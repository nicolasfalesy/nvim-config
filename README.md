# nvim-config

Personal Neovim configuration. Single-file setup using [lazy.nvim](https://github.com/folke/lazy.nvim) for plugin management and [Mason](https://github.com/williamboman/mason.nvim) for LSP servers.

## Requirements

| Dependency | Version | Purpose |
|---|---|---|
| [Neovim](https://neovim.io) | 0.11+ | Required (uses native `vim.lsp.config` API) |
| git | any | Plugin management via lazy.nvim |
| gcc + make | any | Compiling Treesitter parsers |
| node + npm | any | Mason LSP installs (pyright, etc.) |
| python3 | any | Optional, used by pyright |
| ripgrep | any | Optional, Telescope `live_grep` |
| [Nerd Font](https://www.nerdfonts.com/) | any | Icons in lualine |

## Install

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/nicolasfalesy/nvim-config/main/install.sh)
```

The installer will:
- Check all dependencies and warn about anything missing
- Offer to install Node.js via nvm if not found
- Back up any existing `~/.config/nvim/` automatically
- Clone this repo to `~/.config/nvim/`

On first launch, Neovim will:
1. Auto-bootstrap lazy.nvim
2. Install all plugins
3. Install LSP servers via Mason (lua_ls, pyright)
4. Install Treesitter parsers

## Plugins

| Plugin | Purpose |
|---|---|
| [catppuccin](https://github.com/catppuccin/nvim) | Colorscheme (Mocha) |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Syntax highlighting |
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | LSP configuration |
| [mason.nvim](https://github.com/williamboman/mason.nvim) | LSP/linter installer |
| [mason-lspconfig](https://github.com/williamboman/mason-lspconfig.nvim) | Mason + lspconfig bridge |
| [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) | Autocompletion |
| [cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp) | LSP completion source |
| [LuaSnip](https://github.com/L3MON4D3/LuaSnip) | Snippet engine |
| [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | Fuzzy finder |
| [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | Status line |

## LSP Servers

Managed by Mason, auto-installed on first launch:

- `lua_ls` — Lua
- `pyright` — Python

## Keybindings

| Key | Action |
|---|---|
| `Space` | Leader key |
| `gd` | Go to definition |
| `K` | Hover documentation |
| `<leader>rn` | Rename symbol |

## Update

```bash
# Update plugins
:Lazy sync

# Update LSP servers
:Mason  (then press U)

# Update Treesitter parsers
:TSUpdate
```

Or re-run the installer — it will `git pull` if the repo is already installed.
