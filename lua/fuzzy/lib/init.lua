local uv = vim.loop
local floating = require'fuzzy.lib.floating'
local lev = require'fuzzy.lib.alg.levenshtein'
local location = require'fuzzy.lib.location'
local helpers = require('fuzzy.lib.helpers')
local Fuzzy = {}
FUZZY_OPTS = vim.g.fuzzy_options or {}

FUZZY_DRAWER_HIGHLIGHT_GROUP = FUZZY_OPTS.hl_group or 'StatusLine'

--[[
  Source function() collection
  Drawer function(collection) Draw on display
  Sorter function(query, collection) sorts the collection
  Handler function(line) handles user choice
--]]
function __Fuzzy_highlight(buf, hl_group, line)
  if #vim.api.nvim_buf_get_lines(buf, 0, -1, false) < 2 then
    return
  end
  vim.api.nvim_buf_add_highlight(buf, hl_group , FUZZY_DRAWER_HIGHLIGHT_GROUP, line, 0, -1)
end


function __Fuzzy_handler()
  local line = vim.api.nvim_buf_get_lines(CURRENT_FUZZY.buf, CURRENT_FUZZY.drawer.selected_line, CURRENT_FUZZY.drawer.selected_line+1, false)[1]
  __Fuzzy_close()
  CURRENT_FUZZY.handler(line)
end

function __Fuzzy_close()
  vim.cmd [[ call feedkeys("\<C-c>") ]]
  -- CURRENT_FUZZY.on_exit()
  vim.api.nvim_set_current_win(CURRENT_FUZZY.current_win)
  CURRENT_FUZZY.drawer:closer()
end


CURRENT_FUZZY = nil

function __Fuzzy_updater()
  local new_input = vim.api.nvim_buf_get_lines(CURRENT_FUZZY.buf, -2, -1, false)[1]
  new_input = string.sub(new_input, 3, #new_input)
  if new_input == CURRENT_FUZZY.input then
    return
  end
  if not vim.api.nvim_buf_is_valid(CURRENT_FUZZY.buf) then
    return
  end
  CURRENT_FUZZY.input = new_input
  CURRENT_FUZZY.collection = CURRENT_FUZZY.sorter(CURRENT_FUZZY.input, CURRENT_FUZZY.collection)
  CURRENT_FUZZY.drawer:draw(CURRENT_FUZZY.collection)
  end

function Fuzzy.new(opts)
  CURRENT_FUZZY = opts
  if opts.source then
    CURRENT_FUZZY.collection = opts.source()
  end
  __Fuzzy_updater()
end

return Fuzzy
