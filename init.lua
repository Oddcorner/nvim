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
    map('<leader>ss', vim.lsp.buf.document_symbol, '[S]earch [S]ymbols')
    map('<leader>sw', vim.lsp.buf.workspace_symbol, '[S]earch [W]orkspace Symbols')
    map('grc', vim.lsp.buf.incoming_calls, '[G]oto Incoming [C]alls')

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

-- [[ Finder ]]
-- Replaces Telescope with fuzzy command-line completion (:find, :b, :Recent) and :grep
vim.o.wildmode = 'noselect:lastused,full'
vim.o.wildoptions = 'pum,fuzzy'
vim.api.nvim_create_autocmd('CmdlineChanged', { pattern = ':', callback = function() vim.fn.wildtrigger() end })
-- Keep history navigation on <Up>/<Down> unless the popup is open
vim.keymap.set('c', '<Up>', function() return vim.fn.wildmenumode() == 1 and '<C-e><Up>' or '<Up>' end, { expr = true })
vim.keymap.set('c', '<Down>', function() return vim.fn.wildmenumode() == 1 and '<C-e><Down>' or '<Down>' end, { expr = true })

-- :find uses fd (respects .gitignore), cached for the duration of one command line
local files_cache
function _G.FindFiles(arg, _)
  if not files_cache then files_cache = vim.fn.systemlist { 'fd', '--type', 'f', '--hidden', '--exclude', '.git' } end
  return arg == '' and files_cache or vim.fn.matchfuzzy(files_cache, arg)
end
vim.o.findfunc = 'v:lua.FindFiles'
vim.api.nvim_create_autocmd('CmdlineEnter', { pattern = ':', callback = function() files_cache = nil end })

-- :Recent picks from v:oldfiles; falls back to the best fuzzy match if the name isn't exact
local function recent_files(arg)
  local files = vim.tbl_filter(function(f) return vim.fn.filereadable(f) == 1 end, vim.v.oldfiles)
  return arg == '' and files or vim.fn.matchfuzzy(files, arg)
end
vim.api.nvim_create_user_command('Recent', function(opts)
  local file = vim.fn.filereadable(opts.args) == 1 and opts.args or recent_files(opts.args)[1]
  if file then vim.cmd.edit(vim.fn.fnameescape(file)) end
end, { nargs = 1, complete = recent_files, desc = 'Open a recent file' })

-- :grep uses ripgrep and opens the quickfix list with the results
vim.o.grepprg = 'rg --vimgrep --smart-case --hidden -g !.git'
vim.api.nvim_create_autocmd('QuickFixCmdPost', { pattern = '[^l]*', command = 'cwindow' })
vim.api.nvim_create_autocmd('QuickFixCmdPost', { pattern = 'l*', command = 'lwindow' })

-- :Grep takes the whole argument as one pattern, with no shell quoting or %/#/| expansion.
-- It is a regex, falling back to a literal string if the regex doesn't parse (e.g. "foo(")
local rg = { 'rg', '--vimgrep', '--smart-case', '--hidden', '-g', '!.git' }
local function grep(pattern, fixed)
  local cmd = vim.list_extend(vim.list_slice(rg), fixed and { '--fixed-strings', '--', pattern } or { '--', pattern })
  vim.system(cmd, { text = true }, vim.schedule_wrap(function(res)
    -- rg exits 1 for no matches and 2 for errors such as an invalid regex
    if res.code == 2 and not fixed then return grep(pattern, true) end
    if res.code == 2 then return vim.notify(res.stderr, vim.log.levels.ERROR) end
    if res.code == 1 then return vim.notify('No matches for: ' .. pattern) end
    vim.fn.setqflist({}, ' ', { title = 'Grep: ' .. pattern, lines = vim.split(res.stdout, '\n', { trimempty = true }), efm = vim.o.grepformat })
    vim.cmd 'botright copen'
  end))
end
vim.api.nvim_create_user_command('Grep', function(opts) grep(opts.args) end, { nargs = '+', desc = 'Search the project with ripgrep' })

-- Fuzzy-match lines in the current buffer into the location list
local function buffer_fuzzy_find()
  vim.ui.input({ prompt = 'Fuzzy find in buffer: ' }, function(query)
    if not query or query == '' then return end
    local buf = vim.api.nvim_get_current_buf()
    local items = {}
    for lnum, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
      items[#items + 1] = { bufnr = buf, lnum = lnum, text = line }
    end
    vim.fn.setloclist(0, {}, ' ', { title = 'Fuzzy: ' .. query, items = vim.fn.matchfuzzy(items, query, { key = 'text' }) })
    vim.cmd.lwindow()
  end)
end

vim.keymap.set('n', '<leader>sf', ':find ', { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sb', buffer_fuzzy_find, { desc = '[S]earch [B]uffer (Fuzzy)' })
vim.keymap.set('n', '<leader>/', ':Grep ', { desc = 'Search [/] (Global)' })
vim.keymap.set('n', '<leader>sr', ':Recent ', { desc = '[S]earch [R]ecent Files' })
vim.keymap.set('n', '<leader><space>', ':b ', { desc = '[ ] Find existing buffers' })

-- <CR> in a quickfix/location list jumps to the entry and closes the list
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'qf',
  callback = function(args)
    vim.keymap.set('n', '<CR>', function()
      local is_loclist = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1].loclist == 1
      local idx = vim.fn.line '.'
      vim.cmd((is_loclist and 'll ' or 'cc ') .. idx)
      vim.cmd(is_loclist and 'lclose' or 'cclose')
    end, { buffer = args.buf, desc = 'Open entry and close list' })
  end,
})

-- vim: ts=2 sts=2 sw=2 et
