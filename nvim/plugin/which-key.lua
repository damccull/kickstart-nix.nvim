if vim.g.did_load_whichkey_plugin then
  return
end
vim.g.did_load_whichkey_plugin = true

require('which-key').setup()
require('which-key').add({
  { "<leader>c", group = "[C]ode" },
  { "<leader>d", group = "[D]ocument" },
  { "<leader>g", group = "[G]it" },
  { "<leader>p", group = "[P]eek" },
  { "<leader>r", group = "[R]ename" },
  { "<leader>s", group = "[S]earch" },
  { "<leader>t", group = "[T]oggle" },
  { "<leader>w", group = "[W]orkspace" },
})
