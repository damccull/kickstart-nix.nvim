vim.bo.comments = "//,///"

local rust_ls_cmd = 'rust-analyzer'

-- Check if rust-analyzer is available
if vim.fn.executable(rust_ls_cmd) ~= 1 then
  return
end

local root_files = {
  'Cargo.toml',
  '.git',
}

vim.lsp.start {

  name = 'rust-analyzer',
  cmd = {rust_ls_cmd};
  root_dir = vim.fs.dirname(vim.fs.find(root_files, {upward = true})[1]),
  capabilities = require('user.lsp').make_client_capabilities(),
  settings = {
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
}
