if vim.g.did_load_remote_nvim_plugin then
  return
end
vim.g.did_load_remote_nvim_plugin = true

-- Highlights unique characters for f/F and t/T motions
require('remote-nvim').setup {

}
