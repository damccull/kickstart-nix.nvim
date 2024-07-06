if vim.g.did_load_remote_nvim_plugin then
  return
end
vim.g.did_load_remote_nvim_plugin = true


local utils = require('remote-nvim.utils')
local constants = require('remote-nvim.constants')

require('remote-nvim').setup {
  devpod = {
    ssh_config_path = utils.path_join(utils.is_windows, vim.fn.stdpath("data"), constants.PLUGIN_NAME, "ssh_config"), -- Path where devpod SSH configurations should be stored
    search_style = "current_dir_only"
  }
}
