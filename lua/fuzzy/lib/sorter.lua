-- Sorter.lua
-- Sorter interface for Fuzzy
local lev = require('fuzzy.lib.alg.levenshtein')
local fzy = require('fuzzy.lib.alg.fzy')
local tbl_reverse = require('fuzzy.lib.helpers').tbl_reverse
local Sorter = {}
local job = require('plenary.job')

function Sorter.string_distance(query, collection)
  return lev.match(query, collection)
end

function Sorter.fzy(query, collection)
  return fzy.sort(query, collection)
end

function Sorter.fzf_native(query, collection)
  collection = job:new({
    command = 'fzf',
    args = { '-f', query },
    writer = collection,
  }):sync(1000)
  collection = tbl_reverse(collection)
  return collection
end

function Sorter.fzy_native(query, collection)
  collection = job:new({
    command = 'fzy',
    args = { '--show-matches', query },
    writer = collection,
  }):sync(1000)
  collection = tbl_reverse(collection)
  return collection
end

return Sorter
