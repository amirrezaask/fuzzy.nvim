-- Sorter.lua
-- Sorter interface for Luzzy
local lev = require'luzzy.alg.levenshtein'
local Sorter = {}

function Sorter.FZF(query, collection)
  local input = table.concat(collection, '\n')
  local cmd = string.format([[ fzf --filter='%s' ]], query)
  local file = io.popen(cmd)
  file:write(input)
  local output = file:read('*all')
  file:close()
  output = vim.split(output, '\n')
  table.remove(output, #output)
  return output
end

function Sorter.Fzy(query, collection)
  local input = table.concat(collection, '\n')
  local cmd = string.format([[ fzy --show-matches='%s' ]], query)
  local file = io.popen(cmd)
  file:write(input)
  local output = file:read('*all')
  file:close()
  output = vim.split(output, '\n')
  return output
end

function Sorter.Levenshtein(query, collection)
  return lev.match(query, collection) 
end

return Sorter
