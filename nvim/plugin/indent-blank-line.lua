if vim.g.did_load_indent_blank_line_plugin then
  return
end
vim.g.did_load_indent_blank_line_plugin = true

require("ibl").setup()
