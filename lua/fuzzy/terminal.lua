-- Terminal module for fuzzy.nvim => direct interface to terminal fuzzy finder
local floating = require'fuzzy.floating'
local location = require'fuzzy.location'

local TerminalFuzzy = {}

local FUZZY_FZF_CMD = 'fzf'

-- Handler should be table  containing lines.
function TerminalFuzzy.new(stdin, fuzzy_finder, handler)
  if type(stdin) == 'table' then
    stdin = string.format('printf "%s"', table.concat(stdin, '\n'))
  end
  local cmd = string.format('%s | %s', stdin, fuzzy_finder)
  floating.floating_terminal(cmd, handler, math.ceil(vim.api.nvim_get_option('columns')/2), math.ceil(vim.api.nvim_get_option('lines')), location.bottom_center) 
  
end

function TerminalFuzzy.fzf(stdin, handler)
  TerminalFuzzy.new(stdin, FUZZY_FZF_CMD, function(lines)
    handler(lines[1])
  end)
end
function TerminalFuzzy.fzy(stdin, handler)
  TerminalFuzzy.new(stdin, 'fzy', function(lines)
    handler(lines[1])
  end)
end


return TerminalFuzzy
