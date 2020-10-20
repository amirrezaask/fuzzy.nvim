-- Sorter.lua
-- Sorter interface for Luzzy
local lev = require'luzzy.alg.levenshtein'
local uv = vim.loop
local helpers = require'luzzy.helpers'
local Sorter = {}


function Sorter.FZF(query, collection)
  local input = table.concat(collection, '\n')
  local cmd = string.format([[! printf '%s' | fzf --filter='%s' ]], input, query)
  local file = io.popen(cmd)
  local output = file:read('*all')
  file:close()
  output = vim.split(output, '\n')
  for i, o in ipairs(output) do
    if o == '' then
      table.remove(output, i)
    end
  end
  return output
end

function Sorter.Fzy(query, collection)
  local input = table.concat(collection, '\n')
  local cmd = string.format([[! printf '%s' | fzy --show-matches='%s' ]], input, query)
  local file = io.popen(cmd)
  local output = file:read('*all')
  file:close()
  output = vim.split(output, '\n')
  for i, o in ipairs(output) do
    if o == '' then
      table.remove(output, i)
    end
  end
  return output

end

function Sorter.Levenshtein(query, collection)
  return lev.match(query, collection) 
end

return Sorter
