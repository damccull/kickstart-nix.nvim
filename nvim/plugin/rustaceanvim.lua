if vim.g.did_load_rustaceanvim_plugin then
  return
end
vim.g.did_load_rustaceanvim_plugin = true

vim.g.rustaceanvim = {
  -- Plugin configuration
  tools = {
  },
  -- LSP configuration
  server = {
    -- on_attach = function(client, bufnr)
    --   -- you can also put keymaps in here
    -- end,
    default_settings = {
      -- rust-analyzer language server configuration
      ['rust-analyzer'] = {
        check = {
          command = 'clippy',
          features = 'all',
        },
        cargo = {
          targetDir = true,
        },
      },
    },
  },
  -- DAP configuration
  dap = {
  },
}
