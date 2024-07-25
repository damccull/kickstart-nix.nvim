if vim.g.did_load_autocommands_plugin then
  return
end
vim.g.did_load_autocommands_plugin = true

local api = vim.api

local tempdirgroup = api.nvim_create_augroup('tempdir', { clear = true })
-- Do not set undofile for files in /tmp
api.nvim_create_autocmd('BufWritePre', {
  pattern = '/tmp/*',
  group = tempdirgroup,
  callback = function()
    vim.cmd.setlocal('noundofile')
  end,
})

-- Disable spell checking in terminal buffers
local nospell_group = api.nvim_create_augroup('nospell', { clear = true })
api.nvim_create_autocmd('TermOpen', {
  group = nospell_group,
  callback = function()
    vim.wo[0].spell = false
  end,
})

-- LSP
local keymap = vim.keymap

local function preview_location_callback(_, result)
  if result == nil or vim.tbl_isempty(result) then
    return nil
  end
  local buf, _ = vim.lsp.util.preview_location(result[1])
  if buf then
    local cur_buf = vim.api.nvim_get_current_buf()
    vim.bo[buf].filetype = vim.bo[cur_buf].filetype
  end
end

local function peek_definition()
  local params = vim.lsp.util.make_position_params()
  return vim.lsp.buf_request(0, 'textDocument/definition', params, preview_location_callback)
end

local function peek_type_definition()
  local params = vim.lsp.util.make_position_params()
  return vim.lsp.buf_request(0, 'textDocument/typeDefinition', params, preview_location_callback)
end

--- Don't create a comment string when hitting <Enter> on a comment line
vim.api.nvim_create_autocmd('BufEnter', {
  group = vim.api.nvim_create_augroup('DisableNewLineAutoCommentString', {}),
  callback = function()
    vim.opt.formatoptions = vim.opt.formatoptions - { 'c', 'r', 'o' }
  end,
})

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local bufnr = ev.buf
    local client = vim.lsp.get_client_by_id(ev.data.client_id)

    -- Attach plugins
    require('nvim-navic').attach(client, bufnr)

    vim.cmd.setlocal('signcolumn=yes')
    vim.bo[bufnr].bufhidden = 'hide'

    -- Enable completion triggered by <c-x><c-o>
    vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
    local function desc(description)
      return { noremap = true, silent = true, buffer = bufnr, desc = 'LSP:' .. description }
    end
    -- WARN: This is not Goto Definition, this is Goto Declaration
    -- For example, in C this would take you to the header.
    keymap.set('n', 'gD', vim.lsp.buf.declaration, desc(' [g]o to [D]eclaration'))

    -- Jump to the definition of the word under your cursor.
    --  This is where a variable was first declared, or where a function is defined, etc.
    --  To jump back, press <C-t>.
    keymap.set('n', 'gd', require('telescope.builtin').lsp_definitions, desc(' [g]o to [d]efinition'))

    -- Jump to the type of the word under your cursor.
    --  Useful when you're not sure what type a variable is and you want to see
    --  the definition of its *type*, not where it was *defined*.
    keymap.set('n', '<leader>gt', require('telescope.builtin').lsp_type_definitions,
      desc(' [g]o to [t]ype definition'))

    -- Opens a popup that displays documentation about the word under your cursor
    --  See `:help K` for why this keymap.
    keymap.set('n', 'K', vim.lsp.buf.hover, desc(' hover'))

    -- Shows the definition in a little peek window instead of jumping to it.
    keymap.set('n', '<leader>pd', peek_definition, desc(' [p]eek [d]efinition'))

    -- Shows the type definition in a little peek window instead of jumping to it.
    keymap.set('n', '<leader>pt', peek_type_definition, desc(' [p]eek [t]ype definition'))

    -- Jump to the implementation of the word under your cursor.
    --  Useful when your language has ways of declaring types without an actual implementation.
    keymap.set('n', 'gi', require('telescope.builtin').lsp_implementations, desc(' [g]o to [i]mplementation'))

    -- Asks the lsp for signature help
    -- keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, desc(' signature help'))
    keymap.set('n', 'gsh', vim.lsp.buf.signature_help, desc(' signature help'))

    -- Adds a folder to the workspace.
    keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, desc(' add [w]orksp[a]ce folder'))

    -- Removes a folder from the workspace.
    keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, desc(' [w]orkspace folder [r]emove'))

    keymap.set('n', '<leader>wl', function()
      vim.print(vim.lsp.buf.list_workspace_folders())
    end, desc(' [w]orkspace folders [l]ist'))

    -- Rename the variable under your cursor.
    --  Most Language Servers support renaming across files, etc.
    keymap.set('n', '<leader>rn', vim.lsp.buf.rename, desc(' [r]e[n]ame'))

    -- Fuzzy find all the symbols in your current workspace.
    --  Similar to document symbols, except searches over your entire project.
    keymap.set('n', '<leader>wq', require('telescope.builtin').lsp_dynamic_workspace_symbols,
      desc(' [w]orkspace symbol [q]'))

    -- Fuzzy find all the symbols in your current document.
    --  Symbols are things like variables, functions, types, etc.
    keymap.set('n', '<leader>ds', require('telescope.builtin').lsp_document_symbols, desc(' [d]ocument [s]ymbol'))

    -- Execute a code action, usually your cursor needs to be on top of an error
    -- or a suggestion from your LSP for this to activate.
    -- keymap.set('n', '<M-CR>', vim.lsp.buf.code_action, desc(' code action'))
    keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, desc(' code action'))

    -- keymap.set('n', '<M-l>', vim.lsp.codelens.run, desc(' run code lens'))
    keymap.set('n', '<leader>cl', vim.lsp.codelens.run, desc(' run code lens'))

    keymap.set('n', '<leader>cr', vim.lsp.codelens.refresh, desc(' [c]ode lenses [r]efresh'))

    -- Find references for the word under your cursor.
    keymap.set('n', 'gr', require('telescope.builtin').lsp_references, desc(' [g]et [r]eferences'))

    -- keymap.set('n', '<leader>f', function()
    --   vim.lsp.buf.format { async = true }
    -- end, desc(' [f]ormat buffer'))

    -- Enable inlay hints by default but then enable a toggle command
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    if client and client.server_capabilities.inlayHintProvider then
      keymap.set('n', '<leader>th', function()
        local current_setting = vim.lsp.inlay_hint.is_enabled { bufnr = bufnr }
        vim.lsp.inlay_hint.enable(not current_setting, { bufnr = bufnr })
      end, desc('[t]oggle [i]nlay hints'))
    end

    -- The following two autocommands are used to highlight references of the
    -- word under your cursor when your cursor rests there for a little while.
    --    See `:help CursorHold` for information about when this is executed
    --
    -- When you move your cursor, the highlights will be cleared (the second autocommand).
    if client and client.server_capabilities.documentHighlightProvider then
      local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = ev.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = ev.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })

      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
        end,
      })
    end

    -- Auto-refresh code lenses
    if not client then
      return
    end
    local function buf_refresh_codeLens(opts)
      vim.schedule(function()
        if client.server_capabilities.codeLensProvider then
          vim.lsp.codelens.refresh({ bufnr = opts.buf })
          return
        end
      end)
    end
    local group = api.nvim_create_augroup(string.format('lsp-%s-%s', bufnr, client.id), {})
    if client.server_capabilities.codeLensProvider then
      vim.api.nvim_create_autocmd({ 'InsertLeave', 'BufWritePost', 'TextChanged' }, {
        group = group,
        callback = buf_refresh_codeLens,
        buffer = bufnr,
      })
      buf_refresh_codeLens({ buf = bufnr })
    end
  end,
})

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})


-- More examples, disabled by default

-- Toggle between relative/absolute line numbers
-- Show relative line numbers in the current buffer,
-- absolute line numbers in inactive buffers
-- local numbertoggle = api.nvim_create_augroup('numbertoggle', { clear = true })
-- api.nvim_create_autocmd({ 'BufEnter', 'FocusGained', 'InsertLeave', 'CmdlineLeave', 'WinEnter' }, {
--   pattern = '*',
--   group = numbertoggle,
--   callback = function()
--     if vim.o.nu and vim.api.nvim_get_mode().mode ~= 'i' then
--       vim.opt.relativenumber = true
--     end
--   end,
-- })
-- api.nvim_create_autocmd({ 'BufLeave', 'FocusLost', 'InsertEnter', 'CmdlineEnter', 'WinLeave' }, {
--   pattern = '*',
--   group = numbertoggle,
--   callback = function()
--     if vim.o.nu then
--       vim.opt.relativenumber = false
--       vim.cmd.redraw()
--     end
--   end,
-- })
