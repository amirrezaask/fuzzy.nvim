local uv = vim.loop
local floating = require'luzzy.floating'
local lev = require'luzzy.alg.levenshtein'
local location = require'luzzy.location'
local helpers = require('luzzy.helpers')
local Luzzy = {}

--[[
  Source function() collection
  Drawer function(collection) Draw on display
  Sorter function(query, collection) sorts the collection
  Handler function(line) handles user choice
--]]


function __Luzzy_highlight(buf, hl_group, line)
  if #vim.api.nvim_buf_get_lines(buf, 0, -1, false) < 2 then
    return
  end
  vim.api.nvim_buf_add_highlight(buf, hl_group , 'Error', line, 0, -1)
end


function __Luzzy_handler()
  local line = vim.api.nvim_buf_get_lines(CURRENT_LUZZY.buf, CURRENT_LUZZY.drawer.selected_line, CURRENT_LUZZY.drawer.selected_line+1, false)[1]
  print(line)
  __Luzzy_close()
  CURRENT_LUZZY.handler(line)
end

function __Luzzy_close()
  vim.cmd [[ call feedkeys("\<C-c>") ]]
  -- CURRENT_LUZZY.on_exit()
  vim.api.nvim_set_current_win(CURRENT_LUZZY.current_win)
  CURRENT_LUZZY.drawer:closer()
end


CURRENT_LUZZY = nil

function __Luzzy_updater()
  local new_input = vim.api.nvim_buf_get_lines(CURRENT_LUZZY.buf, -2, -1, false)[1]
  new_input = string.sub(new_input, 3, #new_input)
  if new_input == CURRENT_LUZZY.input then
    return
  end
  if not vim.api.nvim_buf_is_valid(CURRENT_LUZZY.buf) then
    return
  end
  CURRENT_LUZZY.input = new_input
  CURRENT_LUZZY.collection = CURRENT_LUZZY.sorter(CURRENT_LUZZY.input, CURRENT_LUZZY.base_collection)
  CURRENT_LUZZY.drawer:draw(CURRENT_LUZZY.collection)
  -- Always select last item after updating the buffer
  local lines = vim.api.nvim_buf_get_lines(CURRENT_LUZZY.buf, 0, -1, false)
  CURRENT_LUZZY.drawer.selected_line = #lines-2 
  CURRENT_LUZZY.drawer:update_selection()
  end

function Luzzy.new(opts)
  CURRENT_LUZZY = opts
  CURRENT_LUZZY.base_collection = opts.collection
  if opts.source then
    opts.source()
  end
  opts.drawer:draw(opts.collection)
end

return {
  Luzzy = Luzzy,
}
