-- Drawer
local location = require'fuzzy.lib.location'
local floating = require'fuzzy.lib.floating'
local helpers = require'fuzzy.lib.helpers'

local M = {}

function table.slice(tbl, first, last, step)
  local sliced = {}
  for i = first or 1, last or #tbl, step or 1 do
    sliced[#sliced+1] = tbl[i]
  end
  return sliced
end

function __Fuzzy_highlight(buf, hl_group, line)
  if #vim.api.nvim_buf_get_lines(buf, 0, -1, false) < 2 then
    return
  end
  vim.api.nvim_buf_add_highlight(buf, hl_group , FUZZY_DRAWER_HIGHLIGHT_GROUP, line, 0, -1)
end

local function fill(collection)
  local height = vim.api.nvim_win_get_height(CURRENT_FUZZY.drawer.win)
  local to_add = height - (#collection-1)
  local new_collection = {}
  if to_add > 0 then
    for _ = 1, to_add do
      table.insert(new_collection, '')
    end
    for i = 1, #collection do
      table.insert(new_collection, collection[i])
    end
    return new_collection
  else
    return collection
  end
end

local FuzzyDrawerHighlight = vim.api.nvim_create_namespace('FuzzyDrawerHighlight')

function M.new(opts)
  opts = opts or {}
  opts.current_win = vim.api.nvim_get_current_win()

  vim.cmd [[ startinsert! ]]
  local width = FUZZY_OPTS.width or 40
  local height = FUZZY_OPTS.height or 60
  
  local win_width = math.ceil(vim.api.nvim_get_option('columns')*width/100)
  local win_height = math.ceil(vim.api.nvim_get_option('lines')*height/100)
  local loc = FUZZY_OPTS.location or location.bottom_center

  local buf, win, closer = floating.floating_buffer(win_width, win_height, loc)

  vim.api.nvim_buf_set_keymap(buf, 'i', '<C-p>', '<cmd> lua CURRENT_FUZZY.drawer:selection_up()<CR>', {})
  vim.api.nvim_buf_set_keymap(buf, 'i', '<C-k>', '<cmd> lua CURRENT_FUZZY.drawer:selection_up()<CR>', {})
  vim.api.nvim_buf_set_keymap(buf, 'i', '<C-n>', '<cmd> lua CURRENT_FUZZY.drawer:selection_down()<CR>', {})
  vim.api.nvim_buf_set_keymap(buf, 'i', '<C-j>', '<cmd> lua CURRENT_FUZZY.drawer:selection_down()<CR>', {})
  vim.api.nvim_buf_set_keymap(buf, 'i', '<CR>',  '<cmd> lua __Fuzzy_handler()<CR>', {})
  vim.api.nvim_buf_set_keymap(buf, 'i', '<esc>',  '<cmd> lua __Fuzzy_close()<CR>', {})
  vim.api.nvim_buf_set_keymap(buf, 'i', '<C-c>',  '<cmd> lua __Fuzzy_close()<CR>', {})

  opts.prompt = opts.prompt or '> '
  vim.fn.prompt_setprompt(buf, opts.prompt)
  
  vim.cmd([[ autocmd TextChangedI <buffer> lua __Fuzzy_updater() ]])
  
  return {
    buf = buf,
    win = win,
    prompt = opts.prompt,
    closer = closer,
    _start_of_data = 1,
    selected_line = 1,
    selection_down = function(self)
      if self.selected_line >= vim.api.nvim_win_get_height(self.win) then
        self.selected_line = self._start_of_data
      else
        self.selected_line = self.selected_line + 1
      end
      self:update_selection()
    end,
    selection_up = function(self)
      if self.selected_line <= self._start_of_data then
        self.selected_line = vim.api.nvim_win_get_height(self.win)
      else
        self.selected_line = self.selected_line - 1
      end
      self:update_selection()
    end,
    update_selection = function(self)
      vim.schedule(function ()
        vim.api.nvim_buf_clear_namespace(self.buf, FuzzyDrawerHighlight, 0, -1)
        __Fuzzy_highlight(self.buf,FuzzyDrawerHighlight, self.selected_line)
      end)
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
      if #collection > height - 1 then
        collection = table.slice(collection, #collection - height, #collection)
      end
      self._start_of_data = (height - #collection) + 1
      collection = fill(collection)
      vim.api.nvim_buf_set_lines(buf, 0, -2, false, collection)

      self.selected_line = height
      self:update_selection()
    end
  }

end

return M
