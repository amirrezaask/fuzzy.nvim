-- Sorter.lua
-- Sorter interface for Fuzzy
local lev = require'fuzzy.lib.alg.levenshtein'
local fzy = require'fuzzy.lib.alg.fzy'
local Sorter = {}

function Sorter.string_distance(query, collection)
  return lev.match(query, collection) 
end

function Sorter.fzy(query, collection)
  return fzy.sort(query, collection)
end

return Sorter
