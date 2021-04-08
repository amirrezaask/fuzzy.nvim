local M = {}
local loc = require'fuzzy.lib.location'

function M.set_defaults(opts)
  opts.width = opts.width or 40
  opts.height = opts.height or 100
  opts.blacklist = opts.blacklist or {
    "vendor"
  }
  opts.location = opts.location or loc.center
  opts.prompt = opts.prompt or '❯ '
  return opts
end

function M.setup(opts)
  FUZZY_OPTS = opts 
end


return M
