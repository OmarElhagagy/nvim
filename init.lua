-- Disable undefined global diagnostics (useful for Neovim-specific globals)
---@diagnostic disable: undefined-global

-- Set leader keys for custom mappings
vim.g.mapleader = ' '        -- Global leader key set to space
vim.g.maplocalleader = ' '   -- Local leader key set to space

-- Indicate if Nerd Font is available for icons (false by default)
vim.g.have_nerd_font = false

-- [[ Setting Options ]]
vim.opt.number = true        -- Show line numbers
vim.opt.mouse = 'a'          -- Enable mouse support in all modes
vim.opt.showmode = false     -- Hide mode display (e.g., -- INSERT --) since statusline often shows it

-- Set clipboard to sync with system clipboard (unnamedplus register)
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

vim.opt.breakindent = true   -- Indent wrapped lines to match the start of the line
vim.opt.undofile = true      -- Enable persistent undo across sessions
vim.opt.ignorecase = true    -- Case-insensitive searching
vim.opt.smartcase = true     -- Case-sensitive search if query contains uppercase
vim.opt.signcolumn = 'yes'   -- Always show the sign column (for diagnostics, git signs, etc.)
vim.opt.updatetime = 250     -- Faster updates (e.g., for CursorHold events) in milliseconds
vim.opt.timeoutlen = 300     -- Timeout for mapped sequences in milliseconds
vim.opt.splitright = true    -- New vertical splits open to the right
vim.opt.splitbelow = true    -- New horizontal splits open below
vim.opt.list = true          -- Show special characters (defined in listchars)
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' } -- Customize how tabs, trailing spaces, and non-breaking spaces appear
vim.opt.inccommand = 'split' -- Show live preview of substitutions in a split
vim.opt.cursorline = true    -- Highlight the current line
vim.opt.scrolloff = 10       -- Keep 10 lines visible above/below the cursor when scrolling

-- [[ Basic Keymaps ]]
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')                  -- Clear search highlights with Escape
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' }) -- Show diagnostics in quickfix list
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' }) -- Double Esc to exit terminal mode

-- Window navigation keymaps
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- [[ Highlight on Yank ]]
-- Highlight yanked text briefly
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }), -- Create or clear the autocommand group
  callback = function()
    vim.highlight.on_yank() -- Trigger Neovim's built-in yank highlight
  end,
})

-- [[ Install `lazy.nvim` Plugin Manager ]]
-- Automatically install lazy.nvim if not present
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
end
vim.opt.rtp = vim.opt.rtp + lazypath -- Add lazy.nvim to runtime path

-- Setup plugins with lazy.nvim
require('lazy').setup({
  'tpope/vim-sleuth', -- Auto-detect indentation settings

  -- Git integration with signs for added/changed/deleted lines
  {
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

  -- Show keybinding hints with a delay of 0ms
  {
    'folke/which-key.nvim',
    event = 'VimEnter', -- Load when entering Neovim
    opts = {
      delay = 0, -- Immediate display of keybinding hints
      icons = {
        mappings = vim.g.have_nerd_font, -- Use icons if Nerd Font is available
        keys = vim.g.have_nerd_font and {} or { -- Fallback key representations if no Nerd Font
          up = '<Up> ', down = '<Down> ', left = '<Left> ', right = '<Right> ',
          c = '<C-…> ', m = '<M-…> ', d = '<D-…> ', s = '<S-…> ',
          cr = '<CR> ', esc = '<Esc> ', scrollwheeldown = '<ScrollWheelDown> ',
          scrollwheelup = '<ScrollWheelUp> ', nl = '<NL> ', bs = '<BS> ',
          space = '<Space> ', tab = '<Tab> ',
        },
      },
      spec = { -- Define keybinding groups for which-key
        { '<leader>c', group = '[C]ode', mode = { 'n', 'x' } },
        { '<leader>d', group = '[D]ocument' },
        { '<leader>r', group = '[R]ename' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>w', group = '[W]orkspace' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      },
    },
  },

  -- Rust-specific tools integration
  {
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

  -- Telescope fuzzy finder with various search utilities
  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make', cond = function() return vim.fn.executable 'make' == 1 end },
      'nvim-telescope/telescope-ui-select.nvim',
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      require('telescope').setup {
        extensions = {
          ['ui-select'] = { require('telescope.themes').get_dropdown() }, -- Dropdown style for UI select
        },
      }
      pcall(require('telescope').load_extension, 'fzf')       -- Load fzf extension if available
      pcall(require('telescope').load_extension, 'ui-select') -- Load ui-select extension

      local builtin = require 'telescope.builtin'
      -- Define Telescope keybindings
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

      -- Fuzzy search in current buffer
      vim.keymap.set('n', '<leader>/', function()
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown { winblend = 10, previewer = false })
      end, { desc = '[/] Fuzzily search in current buffer' })

      -- Grep in open files
      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep { grep_open_files = true, prompt_title = 'Live Grep in Open Files' }
      end, { desc = '[S]earch [/] in open files' })

      -- Search Neovim config files
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
    end,
  },

  -- Add nvim-jdtls for enhanced Java support
  {
    'mfussenegger/nvim-jdtls',
    ft = 'java', -- Load only for Java files
  },

  -- LSP (Language Server Protocol) configuration
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',           -- LSP installer
      'williamboman/mason-lspconfig.nvim', -- Bridge between mason and lspconfig
      'WhoIsSethDaniel/mason-tool-installer.nvim', -- Additional tool installer
      { 'j-hui/fidget.nvim', opts = {} },  -- LSP status UI
      { 'hrsh7th/nvim-cmp', dependencies = { 'hrsh7th/cmp-nvim-lsp' } }, -- Autocompletion
    },
    config = function()
      -- Setup LSP attach behavior
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- LSP keybindings
          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
          map('K', vim.lsp.buf.hover, 'Hover Documentation')

          -- Highlight references under cursor if supported
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

      -- Enhance LSP capabilities with autocompletion
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

      -- Define LSP servers and their settings (excluding jdtls)
      local servers = {
        gopls = {},
        rust_analyzer = {
          settings = {
            ['rust-analyzer'] = {
              checkOnSave = { command = 'clippy' },
            },
          },
        },
        lua_ls = {
          settings = {
            Lua = { completion = { callSnippet = 'Replace' } },
          },
          root_dir = require('lspconfig.util').root_pattern('.git', 'lua'),
        },
      }

      -- Setup Mason and LSP servers
      require('mason').setup()
      require('mason-lspconfig').setup({
        ensure_installed = vim.tbl_keys(servers), -- Install all defined servers
        handlers = {
          function(server_name)
            require('lspconfig')[server_name].setup {
              capabilities = capabilities,
              settings = servers[server_name].settings,
              root_dir = servers[server_name].root_dir,
            }
          end,
        },
      })
    end,
  },

  -- Autocompletion plugin
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter', -- Load when entering insert mode
    dependencies = {
      'L3MON4D3/LuaSnip',         -- Snippet engine
      'saadparwaiz1/cmp_luasnip', -- Snippet source for nvim-cmp
      'hrsh7th/cmp-nvim-lsp',     -- LSP source for nvim-cmp
      'hrsh7th/cmp-path',         -- File path source for nvim-cmp
    },
    config = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      luasnip.config.setup {}

      cmp.setup {
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end, -- Expand snippets with LuaSnip
        },
        completion = { completeopt = 'menu,menuone,noinsert' }, -- Autocompletion behavior
        mapping = cmp.mapping.preset.insert { -- Keybindings for completion
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-y>'] = cmp.mapping.confirm { select = true },
          ['<C-Space>'] = cmp.mapping.complete {},
        },
        sources = { -- Completion sources prioritized
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
        },
      }
    end,
  },

  -- Tokyo Night theme with high priority
  {
    'folke/tokyonight.nvim',
    priority = 1000, -- Load early to ensure theme applies
    config = function()
      vim.cmd.colorscheme 'tokyonight-night' -- Apply the night variant
      vim.cmd.hi 'Comment gui=none'          -- Remove italic/bold from comments
    end,
  },

  -- Highlight TODO comments
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false }, -- Disable signs for TODOs
  },

  -- REST client for HTTP requests
  {
    'rest-nvim/rest.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('rest-nvim').setup()
      vim.keymap.set('n', '<leader>rr', '<Cmd>Rest run<CR>', { desc = 'Run REST request' })
    end,
  },

  -- Mini plugins for various utilities
  {
    'echasnovski/mini.nvim',
    config = function()
      require('mini.ai').setup { n_lines = 500 }      -- Enhanced text objects
      require('mini.surround').setup()                -- Surround operations
      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = vim.g.have_nerd_font } -- Minimal statusline
    end,
  },

  -- Syntax highlighting with Tree-sitter
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate', -- Update parsers on install
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = { 'lua', 'vim', 'vimdoc', 'javascript', 'typescript', 'rust', 'go', 'java' }, -- Languages to install
        auto_install = true, -- Auto-install missing parsers
        highlight = { enable = true, additional_vim_regex_highlighting = false }, -- Enable highlighting
        indent = { enable = true }, -- Enable indentation
      }
    end,
  },
})

-- Custom diagnostic signs (using ● for errors, warnings, etc.)
vim.fn.sign_define("DiagnosticSignError", {text = "●", texthl = "DiagnosticSignError"})
vim.fn.sign_define("DiagnosticSignWarn", {text = "●", texthl = "DiagnosticSignWarn"})
vim.fn.sign_define("DiagnosticSignInfo", {text = "●", texthl = "DiagnosticSignInfo"})
vim.fn.sign_define("DiagnosticSignHint", {text = "●", texthl = "DiagnosticSignHint"})

-- Configure how diagnostics are displayed
vim.diagnostic.config({
  virtual_text = true,    -- Show diagnostic messages inline
  signs = true,           -- Show signs in the sign column
  underline = true,       -- Underline affected code
  update_in_insert = false, -- Don't update diagnostics while typing
  severity_sort = true,   -- Sort diagnostics by severity
})

-- Function to set up jdtls for Java files
local function setup_jdtls()
  local jdtls = require('jdtls')
  local jdtls_bin = vim.fn.stdpath('data') .. '/mason/bin/jdtls'
  local root_dir = require('jdtls.setup').find_root({ '.git', 'pom.xml', 'build.gradle' })
  local project_name = vim.fn.fnamemodify(root_dir, ':p:h:t')
  local workspace_dir = vim.fn.stdpath('cache') .. '/jdtls/workspace/' .. project_name

  local config = {
    cmd = { jdtls_bin, '-data', workspace_dir },
    root_dir = root_dir,
    settings = {
      java = {
        configuration = {
          runtimes = {
            { name = "JavaSE-21", path = "/home/omaradel/.sdkman/candidates/java/21.0.5-tem" },
          },
        },
        autobuild = { enabled = true },
        signatureHelp = { enabled = true },
        contentProvider = { preferred = "fernflower" },
        completion = {
          favoriteStaticMembers = {
            "jakarta.servlet.http.HttpServletRequest.*",
            "jakarta.servlet.http.HttpServletResponse.*",
          },
        },
      },
    },
  }

  jdtls.start_or_attach(config)
end

-- Autocommand to trigger jdtls setup for each Java file
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'java',
  callback = setup_jdtls,
})
