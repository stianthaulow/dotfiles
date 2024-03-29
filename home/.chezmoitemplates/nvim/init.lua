vim.env.LANG = "en_US"

-- Use Powershell on Windows
if vim.loop.os_uname().sysname == "Windows_NT" then
  vim.o.shell = "pwsh"
  vim.o.shellquote = ""
  vim.o.shellxquote = ""
  vim.o.shellcmdflag = "-NoLogo -NoProfile -Command $PSStyle.OutputRendering=[System.Management.Automation.OutputRendering]::PlainText;Remove-Alias -Name tee -Force -ErrorAction SilentlyContinue;"
  vim.o.shellpipe = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
  vim.o.shellredir = '2>&1 | %%{ "$_" } | tee %s; exit $LastExitCode'
end

-- Set <space> as leader
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Install Lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", 
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  'tpope/vim-fugitive', -- Fugitive Git plugin
  'tpope/vim-rhubarb', -- Github extension to Fugitive

  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically

  -- LSP Configuration & Plugins
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
  },

  {
    -- Theme inspired by Atom
    'navarasu/onedark.nvim',
    priority = 1000,
    config = function()
      vim.cmd.colorscheme 'onedark'
    end,
  },

  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    opts = {
      options = {
        theme = 'onedark',
        component_separators = '|',
        section_separators = '',
      },
    },
  },

  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    opts = {},
  },

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        {{ if eq .chezmoi.os "windows" }}
        build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build',
        {{ else }}
        build = 'make',
        {{ end }}
        cond = function()
          {{ if eq .chezmoi.os "windows" }}
          return vim.fn.executable 'cmake' == 1
          {{ else }}
          return vim.fn.executable 'make' == 1
          {{ end }}
        end,
      },
    },
  },

  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },

})

-- Disable highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true

-- Relative line numbers
vim.wo.relativenumber = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
vim.o.clipboard = 'unnamedplus'

-- Indent lines that wrap because they are to long
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Show completion menu even if only one match, dont select anything by default
vim.o.completeopt = 'menuone,noselect'

-- Enable 24-bit colors (not just 256)
vim.o.termguicolors = true

-- Disable <space> in Normal and Visual mode
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Make k and j work with wrapped lines, <k> moves up a file line, <gk> moves up a visual line
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- [[ Norwegian keymappings ]]
-- Swap ¤ with $ in everything but Insert mode
vim.keymap.set({'n', 'v', 's', 'o'}, '¤', '$', { noremap = true })

-- Use ØÆ for brackets
vim.keymap.set({'n', 'v', 's', 'o'}, 'ø', '[', { noremap = true })
vim.keymap.set({'n', 'v', 's', 'o'}, 'æ', ']', { noremap = true })

-- Use , for /
vim.keymap.set({'n', 'v', 's', 'o'}, ',', '/', { noremap = true })


-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
      },
    },
  },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')
