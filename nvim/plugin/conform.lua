if vim.g.did_load_conform_plugin then
  return
end
vim.g.did_load_conform_plugin = true

-- Highlights unique characters for f/F and t/T motions
require('conform').setup({
  formatters_by_ft = {
    lua = { "stylua" },
    -- Conform can also run multiple formatters sequentially
    -- python = { "isort", "black" },
    --
    -- You can use a sub-list to tell conform to run *until* a formatter
    -- is found.
    -- javascript = { { "prettierd", "prettier" } },,
    -- format_on_save = {
    --   timeout_ms = 500,
    --   lsp_format = "fallback",
    -- },
  },
  format_on_save = function(bufnr)
    -- Disable "format_on_save lsp_fallback" for languages that don't
    -- have a well standardized coding style. You can add additional
    -- languages here or re-enable it for the disabled ones.
    local disable_filetypes = { c = true, cpp = true }
    return {
      timeout_ms = 500,
      lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
    }
  end
})

vim.keymap.set(
  'n',
  '<leader>f',
  function()
    require('conform').format { async = true, lsp_fallback = true }
  end,
  { desc = '[f]ormat buffer' }
)
