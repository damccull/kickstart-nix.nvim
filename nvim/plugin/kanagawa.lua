if vim.g.did_load_kanagawa_plugin then
  return
end
vim.g.did_load_kanagawa_plugin = true

kanagawa = require('kanagawa');

kanagawa.setup {
  compile = false, -- enable compiling the colorscheme
  undercurl = true, -- enable undercurls
  commentStyle = { italic = true },
  functionStyle = {},
  keywordStyle = { italic = true },
  statementStyle = { bold = true },
  typeStyle = {},
  transparent = false, -- do not set background color
  dimInactive = false, -- dim inactive window `:h hl-NormalNC`
  terminalColors = true, -- define vim.g.terminal_color_{0,17}
  colors = { -- add/modify theme and palette colors
    palette = {},
    theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
  },
  overrides = function(colors) -- add/modify highlights
    return {}
  end,
  theme = 'wave', -- Load "wave" theme when 'background' option is not set
  background = { -- map the value of 'background' option to a theme
    dark = 'dragon', -- try "dragon" !
    light = 'lotus',
  }
}
kanagawa.load()
  -- Load the colorscheme here
vim.cmd.colorscheme 'kanagawa'

    -- You can configure highlights by doing something like:
vim.cmd.hi 'Comment gui=none'
