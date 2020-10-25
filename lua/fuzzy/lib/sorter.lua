-- Sorter.lua
-- Sorter interface for Fuzzy
local lev = require'fuzzy.lib.alg.levenshtein'
local Sorter = {}

function Sorter.FZF(query, collection)
  local input = table.concat(collection, '\n')
  local tmp = io.open('/tmp/sorter', 'w')
  tmp:write(input)
  tmp:close()
  local file = io.popen(string.format([[ cat /tmp/sorter | fzf -f '%s' ]], query))
  local output = file:read('*all')
  file:close()
  output = vim.split(output, '\n')
  table.remove(output, #output)
  return output
end

function Sorter.Fzy(query, collection)
  local input = table.concat(collection, '\n')
  local tmp = io.open('/tmp/sorter', 'w')
  tmp:write(input)
  tmp:close()
  local file = io.popen(string.format([[ cat /tmp/sorter | fzy --show-matches='%s' ]], query))
  local output = file:read('*all')
  file:close()
  output = vim.split(output, '\n')
  table.remove(output, #output)
  return output
end

function Sorter.Levenshtein(query, collection)
  return lev.match(query, collection) 
end

return Sorter
