---@diagnostic disable: undefined-global

-- Set the leader keys (used for custom shortcuts)
vim.g.mapleader = ' '        -- Spacebar as the main leader key
vim.g.maplocalleader = ' '   -- Spacebar as the local leader key (for buffer-specific mappings)

-- Enable this if you use a Nerd Font for fancy icons (set to false if not)
vim.g.have_nerd_font = false

-- [[ Setting options ]]
-- Basic editor settings to make Neovim comfy
vim.opt.number = true        -- Show line numbers
vim.opt.mouse = 'a'          -- Enable mouse for all modes (clicking, scrolling)
vim.opt.showmode = false     -- Hide mode display (e.g., "-- INSERT --") since we use a statusline

-- Sync clipboard with system (copy/paste works outside Neovim)
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus' -- Use system clipboard
end)

vim.opt.breakindent = true   -- Indent wrapped lines nicely
vim.opt.undofile = true      -- Save undo history between sessions
vim.opt.ignorecase = true    -- Ignore case when searching...
vim.opt.smartcase = true     -- ...unless query has uppercase letters
vim.opt.signcolumn = 'yes'   -- Always show the sign column (for git signs, errors)
vim.opt.updatetime = 250     -- Faster updates (in milliseconds) for responsiveness
vim.opt.timeoutlen = 300     -- Time (ms) to wait for key combos
vim.opt.splitright = true    -- New vertical splits go right
vim.opt.splitbelow = true    -- New horizontal splits go below
vim.opt.list = true          -- Show hidden characters (like tabs, spaces)
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' } -- How to show tabs, trailing spaces, etc.
vim.opt.inccommand = 'split' -- Preview substitutions in a split window
vim.opt.cursorline = true    -- Highlight the current line
vim.opt.scrolloff = 10       -- Keep 10 lines above/below cursor when scrolling

-- [[ Basic Keymaps ]]
-- Handy shortcuts for common tasks
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>') -- Clear search highlights with Esc
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' }) -- Show errors/warnings in a list
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' }) -- Double Esc to exit terminal

-- Move between windows with Ctrl + h/j/k/l
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- [[ Highlight on yank ]]
-- Flash the text you just copied
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }), -- Group for this command
  callback = function()
    vim.highlight.on_yank() -- Briefly highlight yanked text
  end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
-- Automatically install the plugin manager if it’s missing
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim' -- Where plugins live
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath } -- Download it
end
vim.opt.rtp = vim.opt.rtp + lazypath -- Add lazy.nvim to Neovim’s runtime path

-- [[ Plugin Setup ]]
-- List of plugins to enhance Neovim
require('lazy').setup({
  'tpope/vim-sleuth', -- Auto-detects indentation settings

  { -- Git signs in the gutter (e.g., + for added lines)
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },

  { -- Shows keybinding hints as you type
    'folke/which-key.nvim',
    event = 'VimEnter', -- Load when Neovim starts
    opts = {
      delay = 0, -- Show hints instantly
      icons = {
        mappings = vim.g.have_nerd_font, -- Use icons if Nerd Font is enabled
        keys = vim.g.have_nerd_font and {} or { -- Plain text if no Nerd Font
          up = '<Up> ', down = '<Down> ', left = '<Left> ', right = '<Right> ',
          c = '<C-…> ', m = '<M-…> ', d = '<D-…> ', s = '<S-…> ',
          cr = '<CR> ', esc = '<Esc> ', scrollwheeldown = '<ScrollWheelDown> ',
          scrollwheelup = '<ScrollWheelUp> ', nl = '<NL> ', bs = '<BS> ',
          space = '<Space> ', tab = '<Tab> ',
        },
      },
      spec = { -- Define leader key groups
        { '<leader>c', group = '[C]ode',     mode = { 'n', 'x' } },
        { '<leader>d', group = '[D]ocument' },
        { '<leader>r', group = '[R]ename' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>w', group = '[W]orkspace' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      },
    },
  },

  { -- Extra tools for Rust development
    'simrat39/rust-tools.nvim',
    dependencies = { 'neovim/nvim-lspconfig' },
    config = function()
      require('rust-tools').setup {
        tools = {
          inlay_hints = { auto = true }, -- Show type hints in Rust code
        },
      }
    end,
  },

  { -- Powerful search and navigation tool
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim', -- Utility library
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make', cond = function() return vim.fn.executable 'make' == 1 end }, -- Faster fuzzy search
      'nvim-telescope/telescope-ui-select.nvim', -- Better UI for selections
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font }, -- File icons
    },
    config = function()
      require('telescope').setup {
        extensions = {
          ['ui-select'] = { require('telescope.themes').get_dropdown() }, -- Dropdown style for selections
        },
      }
      pcall(require('telescope').load_extension, 'fzf') -- Load fzf if available
      pcall(require('telescope').load_extension, 'ui-select') -- Load ui-select

      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

      vim.keymap.set('n', '<leader>/', function()
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown { winblend = 10, previewer = false })
      end, { desc = '[/] Fuzzily search in current buffer' })

      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep { grep_open_files = true, prompt_title = 'Live Grep in Open Files' }
      end, { desc = '[S]earch [/] in open files' })

      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
    end,
  },

  { -- Language server support (autocomplete, go-to-definition, etc.)
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim', -- Package manager for LSPs
      'williamboman/mason-lspconfig.nvim', -- Bridges Mason and LSP
      'WhoIsSethDaniel/mason-tool-installer.nvim', -- Installs LSP tools
      { 'j-hui/fidget.nvim', opts = {} }, -- Shows LSP progress
      { 'hrsh7th/nvim-cmp', dependencies = { 'hrsh7th/cmp-nvim-lsp' } }, -- Autocompletion
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end
          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
          map('K', vim.lsp.buf.hover, 'Hover Documentation')

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

      local servers = {
        gopls = {}, -- Go language server
        rust_analyzer = { -- Rust language server
          settings = {
            ['rust-analyzer'] = {
              checkOnSave = { command = 'clippy' },
            },
          },
        },
        lua_ls = { -- Lua language server
          settings = {
            Lua = { completion = { callSnippet = 'Replace' } },
          },
        },
        jdtls = {}, -- Java language server
      }

      require('mason').setup()
      require('mason-lspconfig').setup({
        ensure_installed = vim.tbl_keys(servers), -- Install these LSPs
        handlers = {
          function(server_name)
            require('lspconfig')[server_name].setup {
              capabilities = capabilities,
              settings = servers[server_name].settings,
            }
          end,
        },
      })
    end,
  },

  { -- Autocompletion plugin
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'L3MON4D3/LuaSnip', -- Snippets engine
      'saadparwaiz1/cmp_luasnip', -- Snippet completion
      'hrsh7th/cmp-nvim-lsp', -- LSP completion
      'hrsh7th/cmp-path', -- File path completion
    },
    config = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      luasnip.config.setup {}

      cmp.setup {
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        completion = { completeopt = 'menu,menuone,noinsert' },
        mapping = cmp.mapping.preset.insert {
          ['<C-n>'] = cmp.mapping.select_next_item(), -- Next suggestion
          ['<C-p>'] = cmp.mapping.select_prev_item(), -- Previous suggestion
          ['<C-b>'] = cmp.mapping.scroll_docs(-4), -- Scroll docs up
          ['<C-f>'] = cmp.mapping.scroll_docs(4), -- Scroll docs down
          ['<C-y>'] = cmp.mapping.confirm { select = true }, -- Accept suggestion
          ['<C-Space>'] = cmp.mapping.complete {}, -- Trigger completion
        },
        sources = {
          { name = 'nvim_lsp' }, -- LSP suggestions
          { name = 'luasnip' }, -- Snippet suggestions
          { name = 'path' }, -- File path suggestions
        },
      }
    end,
  },

  { -- Dark theme
    'folke/tokyonight.nvim',
    priority = 1000, -- Load early
    config = function()
      vim.cmd.colorscheme 'tokyonight-night'
      vim.cmd.hi 'Comment gui=none' -- No italic comments
    end,
  },

  { -- Highlight TODOs and similar keywords
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false }, -- No gutter signs
  },

  { -- HTTP client for REST requests
    'rest-nvim/rest.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('rest-nvim').setup()
      vim.keymap.set('n', '<leader>rr', '<Cmd>Rest run<CR>', { desc = 'Run REST request' })
    end,
  },

  { -- Mini utilities (surround, AI textobjects, statusline)
    'echasnovski/mini.nvim',
    config = function()
      require('mini.ai').setup { n_lines = 500 } -- Better textobjects
      require('mini.surround').setup() -- Surround text easily
      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = vim.g.have_nerd_font } -- Simple statusline
    end,
  },

  { -- Syntax highlighting and more
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate', -- Update parsers
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = { 'lua', 'vim', 'vimdoc', 'javascript', 'typescript', 'rust', 'go', 'java' }, -- Languages to support
        auto_install = true, -- Install missing parsers
        highlight = { enable = true, additional_vim_regex_highlighting = false },
        indent = { enable = true }, -- Better indentation
      }
    end,
  },
})

-- [[ Diagnostics Display ]]
-- Show error/warning signs in the gutter
vim.fn.sign_define("DiagnosticSignError", {text = "●", texthl = "DiagnosticSignError"})
vim.fn.sign_define("DiagnosticSignWarn", {text = "●", texthl = "DiagnosticSignWarn"})
vim.fn.sign_define("DiagnosticSignInfo", {text = "●", texthl = "DiagnosticSignInfo"})
vim.fn.sign_define("DiagnosticSignHint", {text = "●", texthl = "DiagnosticSignHint"})

-- Configure how errors/warnings show up
vim.diagnostic.config({
  virtual_text = true,  -- Show errors inline
  signs = true,         -- Show signs in the gutter
  underline = true,     -- Underline problematic code
  update_in_insert = false, -- Don’t update while typing
  severity_sort = true, -- Sort by severity
})
