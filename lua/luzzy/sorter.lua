-- Sorter.lua
-- Sorter interface for Luzzy
local lev = require'luzzy.alg.levenshtein'

local Sorter = {}


function Sorter.FZF(query, collection)

end

function Sorter.Fzy(query, collection)

end


function Sorter.Levenshtein(query, collection)
  return lev.match(query, collection) 
end

return Sorter
