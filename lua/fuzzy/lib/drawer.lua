-- Drawer
local location = require'fuzzy.lib.location'
local floating = require'fuzzy.lib.floating'

local M = {}


function table.slice(tbl, first, last, step)
  local sliced = {}

  for i = first or 1, last or #tbl, step or 1 do
    sliced[#sliced+1] = tbl[i]
  end

  return sliced
end


local FuzzyDrawerHighlight = vim.api.nvim_create_namespace('FuzzyDrawerHighlight')

local function fill_buffer(lines)
  local height = math.ceil(vim.api.nvim_win_get_height(CURRENT_FUZZY.drawer.win))
  if height - #lines > 2 then
    local new_lines = {}
    for _ = 1, height-#lines do
      table.insert(new_lines, '')
    end
    for i=1,#lines do
      table.insert(new_lines, lines[i])
    end
    lines = new_lines
  end
  return lines
end

function M.new(opts)
  opts = opts or {}

  opts.current_win = vim.api.nvim_get_current_win()
 
  vim.cmd [[ startinsert! ]]
 
  -- Check for options
  -- should be set as vim.g.fuzzy_options = {location = "center", width = 50, height = 50}
  local options = vim.g.fuzzy_options or {}
  if options.location then
    -- loc can be "center", "bottom" or a function
    if options.location == 'center' then
      loc = location.center
    elseif options.location == 'bottom' then
      loc = location.bottom_center
    else
      loc = location.bottom_center
    end
  else 
    loc = location.bottom_center
  end
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
  local buf, win, closer = floating.floating_buffer(win_width, win_height, loc)

  vim.api.nvim_buf_set_keymap(buf, 'i', '<C-p>', '<cmd> lua CURRENT_FUZZY.drawer:selection_up()<CR>', {})
  vim.api.nvim_buf_set_keymap(buf, 'i', '<C-k>', '<cmd> lua CURRENT_FUZZY.drawer:selection_up()<CR>', {})
  vim.api.nvim_buf_set_keymap(buf, 'i', '<C-n>', '<cmd> lua CURRENT_FUZZY.drawer:selection_down()<CR>', {})
  vim.api.nvim_buf_set_keymap(buf, 'i', '<C-j>', '<cmd> lua CURRENT_FUZZY.drawer:selection_down()<CR>', {})
  vim.api.nvim_buf_set_keymap(buf, 'i', '<CR>',  '<cmd> lua __Fuzzy_handler()<CR>', {})
  vim.api.nvim_buf_set_keymap(buf, 'i', '<esc>',  '<cmd> lua __Fuzzy_close()<CR>', {})
  vim.api.nvim_buf_set_keymap(buf, 'i', '<C-c>',  '<cmd> lua __Fuzzy_close()<CR>', {})

  opts.prompt = opts.prompt or 'Query> '
  vim.fn.prompt_setprompt(buf, opts.prompt)
  
  vim.cmd([[ autocmd TextChangedI <buffer> lua __Fuzzy_updater() ]])
  
  return {
    buf = buf,
    win = win,
    closer = closer,
    _start_of_data = 1,
    selected_line = -1,
    selection_down = function(self)
      self.selected_line = self.selected_line + 1
      if self.selected_line >= vim.api.nvim_win_get_height(self.win) -1 then
        self.selected_line = self._start_of_data
      end
      self:update_selection()
    end,
    selection_up = function(self)
      self.selected_line = self.selected_line - 1
      if self.selected_line < self._start_of_data then
        self.selected_line = vim.api.nvim_win_get_height(self.win) - 2
      end
      self:update_selection()
    end,
    update_selection = function(self)
      vim.api.nvim_buf_clear_namespace(self.buf, FuzzyDrawerHighlight, 0, -1)
      __Fuzzy_highlight(self.buf,FuzzyDrawerHighlight, self.selected_line) 
    end,
    get_output = function()
      local line = vim.api.nvim_buf_get_lines(CURRENT_FUZZY.buf, CURRENT_FUZZY.drawer.selected_line, CURRENT_FUZZY.drawer.selected_line+1, false)[1]
      return line
    end,
    draw = function(self, collection)
      if not vim.api.nvim_buf_is_valid(buf) then
        return
      end
      if #collection == 0 then
        return
      end
      local height = vim.api.nvim_win_get_height(self.win)
      local start_point = #collection - (height - 2)
      collection = table.slice(collection, start_point, #collection)
      self._start_of_data = height - #collection - 1
      if collection[#collection] ~= '' then
        table.insert(collection, '')
      end
      collection = fill_buffer(collection)
      vim.api.nvim_buf_set_lines(buf, 0, -2, false, collection)
      self.selected_line = height-2
      self:update_selection()
    end
  }
end

return M
