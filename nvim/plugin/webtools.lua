if vim.g.did_load_webtools_plugin then
  return
end
vim.g.did_load_webtools_plugin = true

vim.lsp.enable('eslint')
vim.lsp.enable('html')
vim.lsp.enable('jsonls')
vim.lsp.enable('cssls')
