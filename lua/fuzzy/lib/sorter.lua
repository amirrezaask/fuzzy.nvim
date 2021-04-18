-- Sorter.lua
-- Sorter interface for Fuzzy
local lev = require('fuzzy.lib.alg.levenshtein')
local fzy = require('fuzzy.lib.alg.fzy')
local tbl_reverse = require('fuzzy.lib.helpers').tbl_reverse
local Job = require('plenary.job')
local Sorter = {}

function Sorter.string_distance(query, collection)
  return lev.match(query, collection)
end

function Sorter.fzy(query, collection)
  return fzy.sort(query, collection)
end

function Sorter.fzy_native(query, collection)
  Job
    :new({
      command = 'fzy',
      args = { '--show-matches', query },
      on_exit = function(j, _)
        collection = j:result()
      end,
      writer = collection,
    })
    :sync(1000)
  collection = tbl_reverse(collection)
  return collection
end

function Sorter.fzf_native(query, collection)
  Job
    :new({
      command = 'fzf',
      args = { '-f', query },
      on_exit = function(j, _)
        collection = j:result()
      end,
      writer = collection,
    })
    :sync(1000)
  collection = tbl_reverse(collection)
  return collection
end

function Sorter.fzf_spawn_native(query, collection)
  local spawn = require('spawn')
  collection = spawn({
    command = 'fzf',
    args = { '-f', query },
    stdin = collection,
    sync = { timeout = 1000, interval = 200 },
  })
  collection = tbl_reverse(collection)
  return collection
end
function Sorter.fzy_spawn_native(query, collection)
  local spawn = require('spawn')
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
