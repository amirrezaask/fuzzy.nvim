-- Drawer
local location = require'fuzzy.location'
local floating = require'fuzzy.floating'

local M = {}

local FuzzyDrawerHighlight = vim.api.nvim_create_namespace('FuzzyDrawerHighlight')

local function fill_buffer(lines)
  local height = math.ceil(vim.api.nvim_get_option('lines'))
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

function M.new()
  local opts = {}
 
  opts.current_win = vim.api.nvim_get_current_win()
 
  vim.cmd [[ startinsert! ]]
 
  local buf, win, closer = floating.floating_buffer(math.ceil(vim.api.nvim_get_option('columns')/2), math.ceil(vim.api.nvim_get_option('lines')), location.bottom_center)

  vim.api.nvim_buf_set_keymap(buf, 'i', '<C-p>', '<cmd> lua CURRENT_FUZZY.drawer:selection_up()<CR>', {})
  vim.api.nvim_buf_set_keymap(buf, 'i', '<C-k>', '<cmd> lua CURRENT_FUZZY.drawer:selection_up()<CR>', {})
  vim.api.nvim_buf_set_keymap(buf, 'i', '<C-n>', '<cmd> lua CURRENT_FUZZY.drawer:selection_down()<CR>', {})
  vim.api.nvim_buf_set_keymap(buf, 'i', '<C-j>', '<cmd> lua CURRENT_FUZZY.drawer:selection_down()<CR>', {})
  vim.api.nvim_buf_set_keymap(buf, 'i', '<CR>',  '<cmd> lua __Fuzzy_handler()<CR>', {})
  vim.api.nvim_buf_set_keymap(buf, 'i', '<esc>',  '<cmd> lua __Fuzzy_close()<CR>', {})
  vim.api.nvim_buf_set_keymap(buf, 'i', '<C-c>',  '<cmd> lua __Fuzzy_close()<CR>', {})

  vim.fn.prompt_setprompt(buf, '> ')
  
  vim.cmd([[ autocmd TextChangedI <buffer> lua __Fuzzy_updater() ]])
  
  return {
    buf = buf,
    win = win,
    closer = closer,
    selected_line = -1,
    selection_down = function(self)
      self.selected_line = self.selected_line + 1
      self:update_selection()
    end,
    selection_up = function(self)
      self.selected_line = self.selected_line - 1
      self:update_selection()
    end,
    update_selection = function(self)
      local lines = vim.api.nvim_buf_get_lines(self.buf, 0, -1, false)
      if self.selected_line < 0 then
        self.selected_line = #lines-2 
      end
      if self.selected_line >= #lines-1 then
        self.selected_line = 0
      end
      vim.api.nvim_buf_clear_namespace(self.buf, FuzzyDrawerHighlight, 0, -1)
      __Fuzzy_highlight(self.buf,FuzzyDrawerHighlight, self.selected_line) 
    end,
    draw = function(self, collection)
      if not vim.api.nvim_buf_is_valid(buf) then
        return
      end
      if #collection == 0 then
        return
      end
      collection = fill_buffer(collection)
      vim.api.nvim_buf_set_lines(buf, 0, -2, false, collection)
    end
  }
end

return M
