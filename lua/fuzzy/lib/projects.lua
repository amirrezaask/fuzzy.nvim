local grep = require'fuzzy.lib.grep'
local uv = vim.loop
local M = {}

local function is_repo(path)
  return vim.fn.isdirectory(path .. '/.git')
end

local function list_projects(output, path)
  output = output or {}
  local fs_t = uv.fs_scandir(path)
  while true do
    local name, type = uv.fs_scandir_next(fs_t)
    if name == nil and type == nil then
      break
    end
    if type ~= 'directory' then
      goto continue
    end
    if vim.fn.isdirectory(path .. '/.git') then
      table.insert(output, path)
    else
      list_projects(output, path .. '/' .. name)
    end
    ::continue::
  end
  return output
end

function M.list_projects(locations)
  local list = {}
  for location in pairs(locations) do
    list_projects(list, location)
  end
  return list
end

return M

