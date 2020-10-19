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
  vim.schedule(function()
    if not vim.api.nvim_buf_is_valid(CURRENT_LUZZY.buf) then
      return
    end
    local new_input = vim.api.nvim_buf_get_lines(CURRENT_LUZZY.buf, -2, -1, false)[1]
    new_input = string.sub(new_input, 3, #new_input)
    if new_input == CURRENT_LUZZY.input then
      return
    end
    CURRENT_LUZZY.input = new_input
    CURRENT_LUZZY.collection = CURRENT_LUZZY.sorter(CURRENT_LUZZY.input, CURRENT_LUZZY.collection)
  end)  
  CURRENT_LUZZY.drawer:draw(CURRENT_LUZZY.collection)
end

function Luzzy.new(opts)
  CURRENT_LUZZY = opts
  opts.source()
  opts.drawer:draw(opts.collection)
end

-- local source = require'luzzy.source'
-- local drawers = require'luzzy.drawer'
-- local sorter = require'luzzy.sorter'
-- local helpers = require'luzzy.helpers'
-- local collection = {}
-- Luzzy.new {
--   on_exit = function()
--     sorter.Levenshtein.clean()
--   end,
--   collection = collection,
--   source = source.NewBinSource('find', {}, function(data)
--     table.insert(collection, data)
--   end, function(err)
--     print(err)
--   end),
--   drawer = drawers.new(),
--   sorter = sorter.Levenshtein,
--   handler = function(line)
--     print('inja')
--     helpers.open_file(line)
--   end
-- }

return {
  current = CURRENT_LUZZY,
  Luzzy = Luzzy,
}
