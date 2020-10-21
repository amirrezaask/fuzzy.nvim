local api = vim.api
local location = require'fuzzy.location'

-- Create a floating buffer with given win_width and win_height in given row and col.
local function floating_buffer(win_width, win_height, loc)
  local row, col = loc(win_height, win_width)
  local opts = {
    style = "minimal",
    relative = "editor",
    width = win_width,
    height = win_height,
    row = row,
    col = col
  }
  local buf = api.nvim_create_buf(true, true)
  api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  api.nvim_buf_set_option(buf, 'buftype','prompt')

  -- Set keymaps
  vim.api.nvim_buf_set_keymap(buf, 'n', '<esc>', ':q<CR>', {})
  vim.api.nvim_buf_set_keymap(buf, 'n', '<C-c>', ':q<CR>', {})

  local win = api.nvim_open_win(buf, true, opts)
  return buf, win, function()
    vim.api.nvim_win_close(win, true)
  end
end

-- Create a simple floating terminal.
local function floating_terminal(cmd, win_width, win_height, loc)
  local current_window = vim.api.nvim_get_current_win()

  local row, col = loc(win_height, win_width)

  local buf, win, closer = floating_buffer(win_width, win_height, row, col)
  if cmd == "" or cmd == nil then
    cmd = vim.api.nvim_get_option('shell')
  end
  vim.cmd [[ autocmd TermOpen * startinsert ]]
  vim.fn.termopen(cmd, {
    on_exit = function(_, _, _)
      vim.api.nvim_set_current_win(current_window)
      closer()
    end
  })
  return buf, win, closer
end

return {
  floating_terminal = floating_terminal,
  floating_buffer = floating_buffer
} 
