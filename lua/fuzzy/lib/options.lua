local M = {}
local loc = require('fuzzy.lib.location')

local defaults = {
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
      ['<esc>'] = function()
        CurrentFuzzy():close()
      end,
      ['<C-q>'] = function()
        CurrentFuzzy():set_qflist()
      end
    }
  }
}

function M.get_value(opts, key)
  return opts[key] or FUZZY_OPTS[key] or defaults[key]
end

function M.get_mapping(opts, mode, lhs)
  if opts.mappings and opts.mappings[mode] then
    if opts.mappings[mode][lhs] then
      return opts.mappings[mode][lhs]
    end
  end
  if FUZZY_OPTS.mappings and FUZZY_OPTS.mappings[mode] then
    if FUZZY_OPTS.mappings[mode][lhs] then
      return FUZZY_OPTS.mappings[mode][lhs]
    end
  end
  if defaults.mappings and defaults.mappings[mode] then
    return defaults.mappings[mode][lhs]
  end
  return nil
end


function M.setup(opts)
  FUZZY_OPTS = opts
end

return M
