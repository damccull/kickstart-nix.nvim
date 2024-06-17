local cmd = vim.cmd
local fn = vim.fn
local opt = vim.o
local g = vim.g

-- <leader> key. Defaults to `\`. Some people prefer space.
g.mapleader = ' '
g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
g.have_nerd_font = true


-- Enable true colour support
if fn.has('termguicolors') then
  opt.termguicolors = true
end

-- See :h <option> to see what the options do
-- For more options, you can see `:help option-list`

opt.breakindent = true
opt.clipboard = 'unnamedplus' -- Use system clipboard by default
opt.cmdheight = 0
opt.cursorline = true
opt.expandtab = true -- Set tab expansion
opt.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
opt.foldenable = true
opt.history = 2000
opt.hlsearch = true -- Highlight on search
opt.ignorecase = true -- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
opt.inccommand = 'split' -- Preview substitutions live, as you type!
opt.incsearch = true
opt.lazyredraw = true
opt.list = true -- Display of white-space characters -- Display of certain whitespace characters in the editor.
opt.listchars = 'tab:» ,trail:·,nbsp:␣' -- Display of certain whitespace characters in the editor.
opt.mouse = 'a' -- Enable mouse mode, can be useful for resizing splits for example!
opt.nrformats = 'bin,hex' -- Set the number types nvim will be able to increment/decrement
opt.number = true
opt.path = vim.o.path .. '**' -- Search down into subfolders
opt.relativenumber = true
opt.scrolloff = 10 -- Minimal number of screen lines to keep above and below the cursor.
opt.signcolumn = 'yes' -- Keep signcolumn on by default
opt.shiftwidth = 2
opt.showmatch = true -- Highlight matching parentheses, etc
-- opt.showmode = false -- Don't show the mode, since it's already in the status line
opt.smartcase = true -- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
opt.softtabstop = 2
opt.spell = true
opt.spelllang = 'en'
opt.splitbelow = true -- Configure how new splits should be opened
opt.splitright = true -- Configure how new splits should be opened
opt.tabstop = 2
opt.timeoutlen = 300 -- Decrease mapped sequence wait time. Displays which-key popup sooner.
opt.undofile = true
opt.updatetime = 250 -- Decrease update time for swap file (crash recovery)
opt.wrap = false -- Turn off word wrap by default.

-- Clear search highlight when pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')



-- Configure Neovim diagnostic messages

local function prefix_diagnostic(prefix, diagnostic)
  return string.format(prefix .. ' %s', diagnostic.message)
end

vim.diagnostic.config {
  virtual_text = {
    prefix = '',
    format = function(diagnostic)
      local severity = diagnostic.severity
      if severity == vim.diagnostic.severity.ERROR then
        return prefix_diagnostic('󰅚', diagnostic)
      end
      if severity == vim.diagnostic.severity.WARN then
        return prefix_diagnostic('⚠', diagnostic)
      end
      if severity == vim.diagnostic.severity.INFO then
        return prefix_diagnostic('ⓘ', diagnostic)
      end
      if severity == vim.diagnostic.severity.HINT then
        return prefix_diagnostic('󰌶', diagnostic)
      end
      return prefix_diagnostic('■', diagnostic)
    end,
  },
  signs = {
    text = {
      -- Requires Nerd fonts
      [vim.diagnostic.severity.ERROR] = '󰅚',
      [vim.diagnostic.severity.WARN] = '⚠',
      [vim.diagnostic.severity.INFO] = 'ⓘ',
      [vim.diagnostic.severity.HINT] = '󰌶',
    },
  },
  update_in_insert = false,
  underline = true,
  severity_sort = true,
  float = {
    focusable = false,
    style = 'minimal',
    border = 'rounded',
    source = 'if_many',
    header = '',
    prefix = '',
  },
}

g.editorconfig = true

vim.opt.colorcolumn = '100'

-- Native plugins
cmd.filetype('plugin', 'indent', 'on')
cmd.packadd('cfilter') -- Allows filtering the quickfix list with :cfdo

-- let sqlite.lua (which some plugins depend on) know where to find sqlite
vim.g.sqlite_clib_path = require('luv').os_getenv('LIBSQLITE')
