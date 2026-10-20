-- [[ Basic Settings ]]
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
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
-- vim.opt.foldmethod = 'expr'
-- vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
-- vim.opt.foldlevel = 99 -- Start with all folds open

-- Exit terminal mode with double escape
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- [[ Keymaps ]]
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.keymap.set('n', '<leader>e', ':Oil<CR>', { desc = '[E]xplore (Oil)' })

-- buffer delete
vim.keymap.set('n', '<leader>bd', '<CMD>bp|bd #<CR>', { desc = '[X] Close Buffer' })

-- Window Navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move focus to the upper window' })

-- Indent guides (replaces indent-blankline): a guide every 'shiftwidth' columns
vim.opt.list = true
vim.opt.listchars = { tab = '│ ', trail = '·', nbsp = '␣' }
local function set_indent_guides()
  vim.opt_local.listchars:append { leadmultispace = '│' .. string.rep(' ', vim.fn.shiftwidth() - 1) }
end
vim.api.nvim_create_autocmd('BufWinEnter', { callback = set_indent_guides })
vim.api.nvim_create_autocmd('OptionSet', { pattern = 'shiftwidth', callback = set_indent_guides })

-- File marks as a harpoon replacement: slots 1-4 map to global marks A-D (persisted in shada)
local slots = { 'A', 'B', 'C', 'D' }
vim.keymap.set('n', '<leader>a', function()
  local file = vim.api.nvim_buf_get_name(0)
  for i, mark in ipairs(slots) do
    local m = vim.api.nvim_get_mark(mark, {})
    if m[4] ~= '' and vim.fn.fnamemodify(m[4], ':p') == file then
      return vim.notify('Already in slot ' .. i)
    end
  end
  for i, mark in ipairs(slots) do
    if vim.api.nvim_get_mark(mark, {})[4] == '' then
      vim.cmd('normal! m' .. mark)
      return vim.notify('Added to slot ' .. i)
    end
  end
  vim.notify('All slots full, clear one with :delmarks A-D', vim.log.levels.WARN)
end, { desc = 'Mark [A]dd file to slot' })
vim.keymap.set('n', '<leader>q', '<cmd>marks ABCD<CR>', { desc = 'List file mark slots' })
for i, mark in ipairs(slots) do
  vim.keymap.set('n', '<leader>' .. i, function()
    local m = vim.api.nvim_get_mark(mark, {})
    if m[4] == '' then return vim.notify('Slot ' .. i .. ' is empty') end
    -- Prefer the buffer's last cursor position over where the mark was set
    if m[3] ~= 0 and vim.api.nvim_buf_is_loaded(m[3]) then
      vim.cmd.buffer(m[3])
    else
      vim.cmd('normal! `' .. mark)
    end
  end, { desc = 'Go to slot ' .. i })
end

-- [[ Plugins ]]
-- Managed by the built-in vim.pack; update with :lua vim.pack.update()
-- Build hooks must be registered before vim.pack.add() so they also run on install
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == 'nvim-treesitter' and kind == 'update' then
      if not ev.data.active then vim.cmd.packadd 'nvim-treesitter' end
      vim.cmd 'TSUpdate'
    end
  end,
})

local gh = function(repo) return 'https://github.com/' .. repo end
vim.pack.add {
  gh 'folke/tokyonight.nvim',
  gh 'folke/which-key.nvim',
  gh 'nvim-lua/plenary.nvim',
  gh 'nvim-telescope/telescope.nvim',
  { src = gh 'nvim-treesitter/nvim-treesitter', version = 'main' },
  gh 'windwp/nvim-autopairs',
  gh 'lewis6991/gitsigns.nvim',
  gh 'nvim-mini/mini.icons',
  gh 'stevearc/oil.nvim',
}

-- Theme
vim.cmd.colorscheme 'tokyonight-night'

-- Which-Key
require('which-key').setup()

-- Telescope (Fuzzy Finder)
do
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
  -- 6. Document Symbols (Functions/Variables in current file)
  vim.keymap.set('n', '<leader>ss', builtin.lsp_document_symbols, { desc = '[S]earch [S]ymbols' })

  -- 7. Workspace Symbols (Find any Struct/Function in the whole Go project)
  vim.keymap.set('n', '<leader>sw', builtin.lsp_dynamic_workspace_symbols, { desc = '[S]earch [W]orkspace Symbols' })

  -- These override the built-in gr* LSP defaults (grr, gri) with Telescope pickers
  -- 8. References (Where is this used?)
  vim.keymap.set('n', 'grr', builtin.lsp_references, { desc = '[G]oto [R]eferences' })

  -- 9. Incoming Calls (Who calls this function?)
  vim.keymap.set('n', 'grc', builtin.lsp_incoming_calls, { desc = '[G]oto Incoming [C]alls' })

  -- 10. Implementations (Which struct implements this interface?)
  vim.keymap.set('n', 'gri', builtin.lsp_implementations, { desc = '[G]oto [I]mplementation' })
end

-- Treesitter (Highlighting)
do
  -- 1. List the languages you want installed
  local languages = { 'lua', 'vim', 'vimdoc', 'javascript', 'typescript', 'python', 'bash', 'markdown', 'go' }
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
end

-- Auto Brackets
-- map_cr is handled by the completion <CR> mapping below
require('nvim-autopairs').setup { map_cr = false }

-- GitSigns for git changes
require('gitsigns').setup {
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
  },
}

-- oil
require('mini.icons').setup()
require('oil').setup()

-- [[ LSP ]]
-- Servers are installed by Mason previously; reuse its bin dir
vim.env.PATH = vim.fn.stdpath 'data' .. '/mason/bin:' .. vim.env.PATH

vim.lsp.config('lua_ls', {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { '.luarc.json', '.luarc.jsonc', '.stylua.toml', '.git' },
  settings = {
    Lua = {
      completion = { callSnippet = 'Replace' },
      diagnostics = { globals = { 'vim' } },
    },
  },
})

vim.lsp.config('gopls', {
  cmd = { 'gopls' },
  filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
  root_markers = { 'go.work', 'go.mod', '.git' },
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
})

vim.lsp.enable { 'lua_ls', 'gopls' }

-- Built-in defaults: K hover, grn rename, gra code action, grr references,
-- gri implementation, grt type definition, gO document symbols, <C-s> signature help
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('user-lsp-attach', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc) vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc }) end

    map('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client then return end

    -- Lets <C-y> apply snippets, auto-imports, etc. for items from omnifunc
    if client:supports_method 'textDocument/completion' then vim.lsp.completion.enable(true, client.id, event.buf) end

    -- Highlight references of the word under cursor
    if client:supports_method 'textDocument/documentHighlight' then
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

-- [[ Completion ]]
-- Native autocompletion: LSP (omnifunc) first, then buffer words
vim.o.autocomplete = true
vim.o.complete = 'o,.,w,b,u'
vim.opt.completeopt = { 'menuone', 'noselect', 'popup', 'fuzzy' }

-- <Up>/<Down> navigate the menu natively; <Tab>/<S-Tab> jump snippet placeholders by default
-- <CR> accepts the selected (or first) item, otherwise falls through to autopairs
vim.keymap.set('i', '<CR>', function()
  local keys = function(s) return vim.api.nvim_replace_termcodes(s, true, false, true) end
  if vim.fn.pumvisible() == 1 then
    return vim.fn.complete_info({ 'selected' }).selected == -1 and keys '<C-n><C-y>' or keys '<C-y>'
  end
  local ok, npairs = pcall(require, 'nvim-autopairs')
  return ok and npairs.autopairs_cr() or keys '<CR>'
end, { expr = true, replace_keycodes = false, desc = 'Accept completion' })

-- vim: ts=2 sts=2 sw=2 et
