local uv = vim.loop
local helpers = require'fuzzy.helpers'

FILE_FINDER_DEFAULT_DEPTH = 5 
-- list of files and directories recursively with optional depth.
local function _scandir(output, path, depth, hidden)
  output = output or {}
  depth = depth or 5
  hidden = hidden or false
  if depth == 0 then return output end
  local fs_t = uv.fs_scandir(path)
  while true do
    local name, type = uv.fs_scandir_next(fs_t)
    if name == nil and type == nil then
      break
    end
    if name:sub(0, 1) == '.' and not hidden then
      goto continue
    end
    if type == 'directory' then
      _scandir(output, path .. '/' .. name, depth-1)
    end
    if type == 'file' then
      table.insert(output, path .. '/' .. name)
    end
    ::continue::
  end
  return output
end

local file_finder = {}

function file_finder.find(opts)
  opts = opts or {}
  opts.path = opts.path or '.'
  opts.depth = opts.depth or FILE_FINDER_DEFAULT_DEPTH
  return _scandir({}, opts.path, opts.depth)
end

return file_finder
