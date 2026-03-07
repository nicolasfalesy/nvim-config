-- Global settings
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- UI & Editor options
local opt = vim.opt
opt.number = true           -- Show line numbers
--opt.relativenumber = true   -- Relative line numbers
opt.splitright = true       -- Vertical splits to the right
opt.splitbelow = true       -- Horizontal splits below
opt.ignorecase = true       -- Ignore case in search
opt.smartcase = true        -- Case sensitive if uppercase present
opt.termguicolors = true    -- True color support
opt.cursorline = true       -- Highlight current line
opt.signcolumn = "yes"      -- Always show sign column
opt.scrolloff = 10

-- Tab/Indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true

opt.clipboard = "unnamedplus"

-- Keybindings
--vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
--vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- Colorscheme
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },

  -- Syntax & LSP
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },

  -- Completion
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "L3MON4D3/LuaSnip" },

  -- Utilities
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
  { "nvim-lualine/lualine.nvim" },
})

-- Initialize Colorscheme
vim.cmd.colorscheme "catppuccin-mocha"

-- Treesitter configuration
require'nvim-treesitter.config'.setup {
  ensure_installed = { "c", "toml", "lua", "python", "javascript", "bash", "dockerfile", "yaml" },
  highlight = { enable = true },
}

-- Mason & LSP Setup
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "lua_ls", "pyright" }
})

-- LSP Setup (Neovim 0.11+)

local capabilities = require('cmp_nvim_lsp').default_capabilities()

local on_attach = function(_, bufnr)
  local opts = { buffer = bufnr }
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
end

vim.lsp.config('lua_ls', {
  capabilities = capabilities,
  on_attach = on_attach,
})

vim.lsp.config('pyright', {
  capabilities = capabilities,
  on_attach = on_attach,
})

vim.lsp.enable('lua_ls')
vim.lsp.enable('pyright')
