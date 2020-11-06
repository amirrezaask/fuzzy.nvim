-- Terminal module for fuzzy.nvim => direct interface to terminal fuzzy finder
local floating = require'fuzzy.lib.floating'
local location = require'fuzzy.lib.location'

local TerminalFuzzy = {}

CURRENT_TERMINAL_FUZZY = nil

local function fzf_command()
  local base = 'fzf'
  if vim.fn.executable('bat') or vim.fn.executable('batcat') then
    base = base .. ' --preview="bat {}"'
  end
  print(base)
  return base
end

local FUZZY_FZY_CMD = 'fzy -p '

function __FUZZY_TERMINAL_CLOSER()
  CURRENT_TERMINAL_FUZZY.closer()
end


-- Handler should be table  containing lines.
function TerminalFuzzy.new(stdin, fuzzy_finder, handler)
  if type(stdin) == 'table' then
    stdin = string.format('printf "%s"', table.concat(stdin, '\n'))
  end
  -- Check for options
  -- should be set as vim.g.fuzzy_options = {location = "center", width = 50, height = 50}
  local options = vim.g.fuzzy_options or {}
  -- if options.location then
  --   -- loc can be "center", "bottom" or a function
  --   if options.location == 'center' then
  --     loc = location.center
  --   elseif options.location == 'bottom' then
  --     loc = location.bottom_center
  --   end
  -- else
  local loc = location.bottom_center
  -- end
  -- Width and height should be proportions (percentages) of the main window
  local win_width = math.ceil(vim.api.nvim_get_option('columns')/2)
  local win_height = math.ceil(vim.api.nvim_get_option('lines'))
  if options.width then
    local width = options.width
    win_width = math.ceil(vim.api.nvim_get_option('columns')*width/100)
  end
  if options.height then
    local height = options.height
    win_height = math.ceil(vim.api.nvim_get_option('lines')*height/100)
  end
  local cmd = string.format('%s | %s', stdin, fuzzy_finder)
  local buf, win, closer = floating.floating_terminal(cmd, handler, win_width, win_height, loc)

  vim.api.nvim_buf_set_keymap(buf, 'i', '<esc>',  '<cmd> lua __FUZZY_TERMINAL_CLOSER()<CR>', {})
  vim.api.nvim_buf_set_keymap(buf, 'i', '<C-c>',  '<cmd> lua __FUZZY_TERMINAL_CLOSER()<CR>', {})

  CURRENT_TERMINAL_FUZZY = {
    buf = buf,
    win = win,
    closer = closer,
  } 
end

function TerminalFuzzy.fzf(stdin, handler)
  TerminalFuzzy.new(stdin, fzf_command(), function(lines)
    handler(lines[1])
  end)
end

function TerminalFuzzy.fzy(stdin, handler)
  if vim.g.fuzzy_options.height then
    local height = vim.g.fuzzy_options.height
    win_height = math.ceil(vim.api.nvim_get_option('lines')*height/100)
    FUZZY_FZY_CMD = FUZZY_FZY_CMD .. ' -l ' .. tostring(win_height - 1) -- fzy takes the last -l field into account
  end
  TerminalFuzzy.new(stdin, FUZZY_FZY_CMD, function(lines)
    require'fuzzy.helpers'.tprint(lines)
    handler(lines[1])
  end)
end


return TerminalFuzzy
