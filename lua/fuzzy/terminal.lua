-- Terminal module for fuzzy.nvim => direct interface to terminal fuzzy finder
local floating = require'fuzzy.floating'
local location = require'fuzzy.location'

local TerminalFuzzy = {}

CURRENT_TERMINAL_FUZZY = nil

local FUZZY_FZF_CMD = 'fzf'

function __FUZZY_TERMINAL_CLOSER()
  CURRENT_TERMINAL_FUZZY.closer()
end


-- Handler should be table  containing lines.
function TerminalFuzzy.new(stdin, fuzzy_finder, handler)
  if type(stdin) == 'table' then
    stdin = string.format('printf "%s"', table.concat(stdin, '\n'))
  end
  local cmd = string.format('%s | %s', stdin, fuzzy_finder)
  local buf, win, closer = floating.floating_terminal(cmd, handler, math.ceil(vim.api.nvim_get_option('columns')/2), math.ceil(vim.api.nvim_get_option('lines')), location.bottom_center) 

  vim.api.nvim_buf_set_keymap(buf, 'i', '<esc>',  '<cmd> lua __FUZZY_TERMINAL_CLOSER()<CR>', {})
  vim.api.nvim_buf_set_keymap(buf, 'i', '<C-c>',  '<cmd> lua __FUZZY_TERMINAL_CLOSER()<CR>', {})

  CURRENT_TERMINAL_FUZZY = {
    buf = buf,
    win = win,
    closer = closer,
  } 
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
