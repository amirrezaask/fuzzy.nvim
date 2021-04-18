local Fuzzy = {}

local options = require('fuzzy.lib.options')

FUZZY_OPTS = FUZZY_OPTS or {}

CURRENT_FUZZY = nil
function Fuzzy.new(opts)
  CURRENT_FUZZY = opts
  CURRENT_FUZZY.__updater = function(self)
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
    -- if #self.collection == 0 then
    --   error('data collection is empty')
    --   self.__close()
    -- end
    self.drawer:draw(self.collection)
  end

  CURRENT_FUZZY.__close = function(self)
    vim.cmd([[ call feedkeys("\<C-c>") ]])
    vim.api.nvim_set_current_win(self.current_win)
    self.drawer:closer()
  end

  CURRENT_FUZZY.__handler = function(self)
    local line = self.drawer:get_output()
    self:__close()
    self.handler(line)
  end

  CURRENT_FUZZY.sorter = options.get_value(opts, 'sorter')
  CURRENT_FUZZY.current_win = vim.api.nvim_get_current_win()
  CURRENT_FUZZY.current_buf = vim.api.nvim_get_current_buf()
  CURRENT_FUZZY.drawer = require('fuzzy.lib.drawer').new(opts)

  if type(opts.source) == 'function' then
    CURRENT_FUZZY.collection = opts.source()
  elseif type(opts.source) == 'table' then
    CURRENT_FUZZY.collection = opts.source
    -- elseif type(opts.source) == "string" then
    -- 	CURRENT_FUZZY.collection = require("fuzzy.lib.source").bin_source(opts.source)
  end
  CURRENT_FUZZY.original_collection = CURRENT_FUZZY.collection
  CURRENT_FUZZY:__updater()
end

return Fuzzy
