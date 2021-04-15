-- Sorter.lua
-- Sorter interface for Fuzzy
local lev = require'fuzzy.lib.alg.levenshtein'
local fzy = require'fuzzy.lib.alg.fzy'
local tbl_reverse = require'fuzzy.lib.helpers'.tbl_reverse
FUZZY_INPUT_FILE=string.format('%s/.fuzzy.input', os.getenv("HOME"))
local Sorter = {}

function Sorter.string_distance(query, collection)
  return lev.match(query, collection) 
end

function Sorter.fzy(query, collection)
  return fzy.sort(query, collection)
end

function Sorter.fzy_native(query, collection)
  local input = assert(io.open(FUZZY_INPUT_FILE, 'w'), 'cannot open input file')
  input:write(table.concat(collection, '\n'))

  local cmd = string.format('cat %s | fzy --show-matches="%s"', FUZZY_INPUT_FILE, query)
  local file = assert(io.popen(cmd, 'r'), 'cannot open process')
  local output = file:read('*all') 
  file:close()
  output = vim.split(output, '\n')
  output[#output] = nil
  output = tbl_reverse(output)
  return output
end

function Sorter.fzf(query, collection)
  local input = io.open(FUZZY_INPUT_FILE, 'w') 
  input:write(table.concat(collection, '\n'))
  local cmd = string.format('cat %s | fzf -f "%s"', FUZZY_INPUT_FILE, query)
  local file = assert(io.popen(cmd, 'r'), 'cannot open process')
  local output = file:read('*all') 
  file:close()
  output = vim.split(output, '\n')
  output[#output] = nil
  output = tbl_reverse(output)
  return output
end

return Sorter
