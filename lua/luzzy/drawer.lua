-- Drawer
local location = require'luzzy.location'
local floating = require'luzzy.floating'

local M = {}

local LuzzyDrawerHighlight = vim.api.nvim_create_namespace('LuzzyDrawerHighlight')

function M.new()
  local opts = {}
 
  opts.current_win = vim.api.nvim_get_current_win()
 
  vim.cmd [[ startinsert! ]]
 
  local buf, win, closer = floating.floating_buffer(math.ceil(vim.api.nvim_get_option('columns')/2), math.ceil(vim.api.nvim_get_option('lines')/2), location.bottom_center)

  vim.api.nvim_buf_set_keymap(buf, 'i', '<C-p>', '<cmd> lua CURRENT_LUZZY.drawer:selection_up()<CR>', {})
  vim.api.nvim_buf_set_keymap(buf, 'i', '<C-k>', '<cmd> lua CURRENT_LUZZY.drawer:selection_up()<CR>', {})
  vim.api.nvim_buf_set_keymap(buf, 'i', '<C-n>', '<cmd> lua CURRENT_LUZZY.drawer:selection_down()<CR>', {})
  vim.api.nvim_buf_set_keymap(buf, 'i', '<C-j>', '<cmd> lua CURRENT_LUZZY.drawer:selection_down()<CR>', {})
  vim.api.nvim_buf_set_keymap(buf, 'i', '<C-c>', '<cmd> lua __Luzzy_close()<CR>', {})
  vim.api.nvim_buf_set_keymap(buf, 'i', '<esc>', '<cmd> lua __Luzzy_close()<CR>', {})
  vim.api.nvim_buf_set_keymap(buf, 'i', '<CR>',  '<cmd> lua __Luzzy_handler()<CR>', {})

  vim.fn.prompt_setprompt(buf, '> ')
  
  vim.cmd([[ autocmd TextChangedI <buffer> lua __Luzzy_updater() ]])
  
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
      vim.api.nvim_buf_clear_namespace(self.buf, LuzzyDrawerHighlight, 0, -1)
      __Luzzy_highlight(self.buf,LuzzyDrawerHighlight, self.selected_line) 
    end,
    draw = function(self, collection)
      if not vim.api.nvim_buf_is_valid(buf) then
        return
      end
      if #collection == 0 then
        return
      end
      local buf_size = vim.api.nvim_win_get_height(win)
      vim.api.nvim_buf_set_lines(buf, 0, -2, false, collection)

      if self.selected_line == -1 then
        self.selected_line = #collection -1
      end
      __Luzzy_highlight(self.buf, LuzzyDrawerHighlight, self.selected_line)
    end
  }
end

return M
