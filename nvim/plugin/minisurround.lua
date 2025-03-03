if vim.g.did_load_minisurround_plugin then
  return
end
vim.g.did_load_minisurround_plugin = true

-- many plugins annoyingly require a call to a 'setup' function to be loaded,
-- even with default configs

require('mini.surround').setup({
  mappings = {
    add = 'ysa',            -- Add surrounding in Normal and Visual modes
    delete = 'ysd',         -- Delete surrounding
    find = 'ysf',           -- Find surrounding (to the right)
    find_left = 'ysF',      -- Find surrounding (to the left)
    highlight = 'ysh',      -- Highlight surrounding
    replace = 'ysr',        -- Replace surrounding
    update_n_lines = 'ysn', -- Update `n_lines`

    suffix_last = 'l',      -- Suffix to search with "prev" method
    suffix_next = 'n',      -- Suffix to search with "next" method
  },
})
