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

  local win = api.nvim_open_win(buf, true, opts)
  return buf, win, function()
    vim.api.nvim_win_close(win, true)
  end
end

-- Create a simple floating terminal.
local function floating_terminal(cmd, callback, win_width, win_height, loc)
  local current_window = vim.api.nvim_get_current_win()

  local buf, win, closer = floating_buffer(win_width, win_height, loc)
  if cmd == "" or cmd == nil then
    cmd = vim.api.nvim_get_option('shell')
  end
  vim.cmd [[ autocmd TermOpen * startinsert ]]
  vim.fn.termopen(cmd, {
    on_exit = function(_, _, _)
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      vim.api.nvim_set_current_win(current_window)
      closer()
      if callback then
        callback(lines)
      end
    end
  })
  return buf, win, closer
end

return {
  floating_terminal = floating_terminal,
  floating_buffer = floating_buffer
} 
