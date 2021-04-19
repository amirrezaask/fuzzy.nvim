-- Sorter.lua
-- Sorter interface for Fuzzy
local lev = require('fuzzy.lib.alg.levenshtein')
local fzy = require('fuzzy.lib.alg.fzy')
local tbl_reverse = require('fuzzy.lib.helpers').tbl_reverse
local Sorter = {}
local spawn = require('spawn')

function Sorter.string_distance(query, collection)
  return lev.match(query, collection)
end

function Sorter.fzy(query, collection)
  return fzy.sort(query, collection)
end

function Sorter.fzf_native(query, collection)
  collection = spawn({
    command = 'fzf',
    args = { '-f', query },
    stdin = collection,
    sync = { timeout = 1000, interval = 200 },
  })
  collection = tbl_reverse(collection)
  return collection
end

function Sorter.fzy_native(query, collection)
  collection = spawn({
    command = 'fzy',
    args = { '--show-matches', query },
    stdin = collection,
    sync = { timeout = 1000, interval = 200 },
  })
  collection = tbl_reverse(collection)
  return collection
end

return Sorter
