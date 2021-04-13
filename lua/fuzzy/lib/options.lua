local M = {}
local loc = require'fuzzy.lib.location'

local defaults = {
  location = loc.bottom_center,
  width = 60,
  height = 100,
  title = 'Fuzzy',
  blacklist = {

  },
  prompt = '> ',
  sorter = require'fuzzy.lib.sorter'.string_distance,
  no_luv_finder = false,
}

function M.get_value(opts, key)
  return opts[key] or FUZZY_OPTS[key] or defaults[key]
end

function M.setup(opts)
  FUZZY_OPTS = opts 
end

return M
