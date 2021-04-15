-- Sorter.lua
-- Sorter interface for Fuzzy
local lev = require'fuzzy.lib.alg.levenshtein'
local fzy = require'fuzzy.lib.alg.fzy'
local bin_source = require'fuzzy.lib.source.binary'
local Sorter = {}

function Sorter.string_distance(query, collection)
  return lev.match(query, collection) 
end

function Sorter.fzy(query, collection)
  return fzy.sort(query, collection)
end

function Sorter.fzy_native(query, collection)
  local cmd = string.format('echo "%s" | fzy --show-matches="%s"', table.concat(collection, '\n'), query)
  local file = assert(io.popen(cmd, 'r'), 'cannot open process')
  local output = file:read('*all') 
  file:close()
  output = vim.split(output, '\n')
  output[#output] = nil
  output = table.reverse(output)
  return output
end

function table.reverse(t)
  local new_t = {}
  local i = #t
  while i > 0 do
    table.insert(new_t, t[i])
    i = i-1
  end
  return new_t
end
function Sorter.fzf(query, collection)
  local cmd = string.format('echo "%s" | fzf -f "%s"', table.concat(collection, '\n'), query)
  local file = assert(io.popen(cmd, 'r'), 'cannot open process')
  local output = file:read('*all') 
  file:close()
  output = vim.split(output, '\n')
  output[#output] = nil
  output = table.reverse(output)
  return output
end

return Sorter
