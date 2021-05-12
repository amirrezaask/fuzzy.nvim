local M = {}
local loc = require('fuzzy.lib.location')

M.defaults = {
  location = loc.bottom_center,
  width = 90,
  height = 25,
  blacklist = {
    '.git',
  },
  prompt = '> ',
  sorter = require('fuzzy.lib.sorter').fzy,
  no_luv_finder = false,
  border = 'yes',
  mappings = {
    n = {
      ['k'] = function()
        CurrentFuzzy().drawer:selection_up()
      end,
      ['j'] = function()
        CurrentFuzzy().drawer:selection_down()
      end,
     ['<C-c>'] = function()
        CurrentFuzzy():close()
      end,
      ['<esc>'] = function()
        CurrentFuzzy():close()
      end,
      ['<CR>'] = function()
        local line = CurrentFuzzy():get_output()
        CurrentFuzzy():close()
        CurrentFuzzy().handler(line)
      end,
    },

    i = {
      ['<CR>'] = function()
        local line = CurrentFuzzy():get_output()
        CurrentFuzzy():close()
        CurrentFuzzy().handler(line)
      end,
      ['<C-p>'] = function()
        CurrentFuzzy().drawer:selection_up()
      end,
      ['<C-k>'] = function()
        CurrentFuzzy().drawer:selection_up()
      end,
      ['<C-j>'] = function()
        CurrentFuzzy().drawer:selection_down()
      end,
      ['<C-c>'] = function()
        CurrentFuzzy():close()
      end,
      ['<C-q>'] = function()
        CurrentFuzzy():set_qflist()
      end
    }
  }
}

function M.get_value(opts, key)
  return opts[key] or FUZZY_OPTS[key] or M.defaults[key]
end

function M.setup(opts)
  FUZZY_OPTS = opts
end

return M
