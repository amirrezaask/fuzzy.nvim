local Fuzzy = {}

local options = require('fuzzy.lib.options')

FUZZY_OPTS = FUZZY_OPTS or {}

local _mt = {}

function _mt:updater()
  if self.sorter then
    local new_input = vim.api.nvim_buf_get_lines(self.buf, -2, -1, false)[1]
    new_input = string.sub(new_input, #self.drawer.prompt + 1, #new_input)
    if new_input == self.input then
      return
    end
    self.input = new_input
  end

  if not vim.api.nvim_buf_is_valid(self.buf) then
    return
  end
  vim.fn.matchadd('FuzzyMatching', self.input)
  self.collection = self.original_collection
  if self.sorter then
    self.collection = self.sorter(self.input, self.collection)
  end
  self.drawer:draw(self.collection)
end

function _mt:close()
  vim.cmd([[ call feedkeys("\<C-c>") ]])
  vim.api.nvim_set_current_win(self.current_win)
  self.drawer:closer()
end

function _mt:get_output()
  return self.drawer:get_output()
end 

function _mt:selection_up()
  return self.drawer:selection_up()
end 

function _mt:selection_down()
  return self.drawer:selection_down()
end 

function _mt:set_qflist()
  local lines = vim.api.nvim_buf_get_lines(self.drawer.buf, 0, -1, false)
  require('fuzzy.lib.qflist').set_qflist(lines)
  self:__close()
end


CURRENT_FUZZY = nil
function Fuzzy.new(opts)
  CURRENT_FUZZY = opts
  setmetatable(CURRENT_FUZZY, _mt)

  _mt.__index = _mt
  CURRENT_FUZZY.sorter = options.get_value(opts, 'sorter')
  CURRENT_FUZZY.current_win = vim.api.nvim_get_current_win()
  CURRENT_FUZZY.current_buf = vim.api.nvim_get_current_buf()
  CURRENT_FUZZY.drawer = require('fuzzy.lib.drawer').new(opts)

  if type(opts.source) == 'function' then
    CURRENT_FUZZY.collection = opts.source()
  elseif type(opts.source) == 'table' then
    CURRENT_FUZZY.collection = opts.source
  elseif type(opts.source) == 'string' then
    local cmd = vim.split(opts.source, ' ')[1]
    local args = vim.split(opts.source, ' ')
    table.remove(args, 1)
    CURRENT_FUZZY.collection = require('fuzzy.lib.source').bin_source(cmd, args)
  end
  CURRENT_FUZZY.original_collection = CURRENT_FUZZY.collection
  CURRENT_FUZZY:updater()
end

return Fuzzy
