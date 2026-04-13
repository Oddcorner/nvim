-- [[ Basic Settings ]]
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.showmode = false
vim.opt.clipboard = 'unnamedplus'
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes'
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 8
vim.opt.termguicolors = true
vim.opt.updatetime = 250

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- Context Aware Folds
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldlevel = 99 -- Start with all folds open

-- Exit terminal mode with double escape
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- [[ Keymaps ]]
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Custom netrw keymap
local function toggle_netrw()
  if vim.bo.filetype == 'netrw' then
    vim.cmd('Rexplore')
  else
    vim.cmd('Explore')
  end
end
vim.keymap.set('n', '<leader>e', toggle_netrw, { desc = '[E]xplore (Toggle Netrw)' })

-- buffer delete
vim.keymap.set('n', '<leader>bd', '<CMD>bp|bd #<CR>', { desc = '[X] Close Buffer' })

-- Window Navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move focus to the upper window' })

-- [[ Install lazy.nvim ]]
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', 'https://github.com/folke/lazy.nvim.git', lazypath }
end
vim.opt.rtp:prepend(lazypath)

-- [[ Configure Plugins ]]
require('lazy').setup {
  -- Theme
  { 'folke/tokyonight.nvim', priority = 1000, config = function() vim.cmd.colorscheme 'tokyonight-night' end },

  -- Which-Key
  { 'folke/which-key.nvim', event = 'VimEnter', config = true },

  -- Telescope (Fuzzy Finder)
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local builtin = require('telescope.builtin')
      local themes = require('telescope.themes')

      -- --- SEARCH MAPPINGS ---
      -- 1. Find Files
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      
      -- 2. Search INSIDE current buffer (Dropdown)
      vim.keymap.set('n', '<leader>sb', function()
        builtin.current_buffer_fuzzy_find(themes.get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[S]earch [B]uffer (Fuzzy)' })

      -- 3. Global Grep (Massive repo search)
      vim.keymap.set('n', '<leader>/', builtin.live_grep, { desc = 'Search [/] (Global)' })
      
      -- 4. Recent Files
      vim.keymap.set('n', '<leader>sr', builtin.oldfiles, { desc = '[S]earch [R]ecent Files' })

      -- 5. Open Buffers
      vim.keymap.set('n', '<leader><space>', builtin.buffers, { desc = '[ ] Find existing buffers' })


      -- --- CODE ANALYSIS MAPPINGS (LSP Integration) ---
      -- These replace the standard LSP jumps with Telescope windows
      
      -- 6. Document Symbols (Functions/Variables in current file)
      vim.keymap.set('n', '<leader>ss', builtin.lsp_document_symbols, { desc = '[S]earch [S]ymbols' })

      -- 7. Workspace Symbols (Find any Struct/Function in the whole Go project)
      vim.keymap.set('n', '<leader>sw', builtin.lsp_dynamic_workspace_symbols, { desc = '[S]earch [W]orkspace Symbols' })

      -- 8. References (Where is this used?)
      vim.keymap.set('n', 'gr', builtin.lsp_references, { desc = '[G]oto [R]eferences' })

      -- 9. Incoming Calls (Who calls this function?)
      vim.keymap.set('n', 'gR', builtin.lsp_incoming_calls, { desc = '[G]oto Incoming [C]alls' })

      -- 10. Implementations (Which struct implements this interface?)
      vim.keymap.set('n', 'gi', builtin.lsp_implementations, { desc = '[G]oto [I]mplementation' })
    end,
  },

  -- Treesitter (Highlighting)
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      -- 1. List the languages you want installed
      local languages = { 'lua', 'vim', 'vimdoc', 'javascript', 'typescript', 'python', 'bash', 'markdown', 'go'}
      -- 2. Ensure they are installed
      require('nvim-treesitter').install(languages)

      -- 3. Create a function to attach Treesitter to a buffer
      local function treesitter_attach(buf, lang)
        -- Start syntax highlighting
        vim.treesitter.start(buf, lang)
        -- Enable smart indentation if the language supports it
        local has_indent = vim.treesitter.query.get(lang, 'indent') ~= nil
        if has_indent then
          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end

      -- 4. Automatically trigger Treesitter when you open a file
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          local lang = vim.treesitter.language.get_lang(args.match)
          if not lang then return end
          -- Try to attach. If the parser isn't installed, this will 
          -- fail silently or you can use require('nvim-treesitter').install()
          pcall(treesitter_attach, args.buf, lang)
        end,
      })
    end,
  },

  -- LSP and Mason
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'mason-org/mason.nvim',
      'mason-org/mason-lspconfig.nvim',
      -- Optional: Useful status updates for LSP
      { 'j-hui/fidget.nvim', opts = {} },
    },
    config = function()
      require('mason').setup()
      local mason_lspconfig = require 'mason-lspconfig'

      -- 1. Setup your on_attach keybinds
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc) vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc }) end

          map('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
          map('K', vim.lsp.buf.hover, 'Hover Documentation')
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

          -- Helpful: highlight references of the word under cursor
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

      -- 2. Define your servers and their settings
      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              completion = { callSnippet = 'Replace' },
              diagnostics = { globals = { 'vim' } },
            },
          },
        },
        -- Add pyright = {}, tsserver = {}, etc. here
        gopls = {
          settings = {
            gopls = {
              codelenses = {
                generate = true,
                gc_details = true, -- Shows "optimization" details like escape analysis
                test = true,
                tidy = true,
              },
            },
          },
        },

      }

      -- 3. Use mason-lspconfig to bridge the gap
      mason_lspconfig.setup {
        ensure_installed = vim.tbl_keys(servers),
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This is the modern replacement for require('lspconfig')[name].setup
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },

  -- Autocompletion
  {
    'hrsh7th/nvim-cmp',
    dependencies = { 'hrsh7th/cmp-nvim-lsp', 'L3MON4D3/LuaSnip', 'saadparwaiz1/cmp_luasnip' },
    config = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      cmp.setup {
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert {
          ['<Down>'] = cmp.mapping.select_next_item(),
          ['<Up>'] = cmp.mapping.select_prev_item(),
          ['<CR>'] = cmp.mapping.confirm { select = true },
          ['<Tab>'] = cmp.mapping(function(fallback)
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        },
        sources = { { name = 'nvim_lsp' }, { name = 'luasnip' } },
      }
    end,
  },

  -- Auto Brackets
  { 'windwp/nvim-autopairs', event = 'InsertEnter', config = true },

  -- File Explorer Sidebar
  -- {
  --   'nvim-tree/nvim-tree.lua',
  --   dependencies = { 'nvim-tree/nvim-web-devicons' },
  --   config = function()
  --     require('nvim-tree').setup()
  --     vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = 'Toggle File [E]xplorer' })
  --   end,
  -- },

  -- GitSigns for git changes
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
      },
    },
  },

  -- Indentation lines
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {},
  },

  -- Status line
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        theme = 'tokyonight',
        component_separators = '|',
        section_separators = '',
      },
    },
  },


  -- Harpoon
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()

      -- Add current file to harpoon
      vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end, { desc = "Harpoon [A]dd" })
      
      -- Toggle the visual menu
      vim.keymap.set("n", "<leader>q", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon Menu" })

      -- Jump to specific files
      vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end, { desc = "Harpoon to 1" })
      vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end, { desc = "Harpoon to 2" })
      vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end, { desc = "Harpoon to 3" })
      vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end, { desc = "Harpoon to 4" })
    end,
  },
}

-- vim: ts=2 sts=2 sw=2 et
