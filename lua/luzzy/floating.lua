local api = vim.api
local location = require'luzzy.location'

-- Create a floating buffer with given win_width and win_height in given row and col.
local function floating_buffer(win_width, win_height, row, col)
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

  vim.cmd [[ autocmd TermOpen * startinsert ]]
  local win = api.nvim_open_win(buf, true, opts)
  return buf, win, function()
    vim.api.nvim_win_close(win, true)
  end
end

-- Create a floating border
local function floating_border(win_width, win_height, row, col)

  local buf, win, closer = floating_buffer(win_width + 2, win_height + 2, row - 1, col - 1) 

  local border_lines = { '╭' .. string.rep('─', win_width) .. '╮' }
  local middle_line = '│' .. string.rep(' ', win_width) .. '│'
  for _ = 1, win_height do
    table.insert(border_lines, middle_line)
  end
  table.insert(border_lines, '╰' .. string.rep('─', win_width) .. '╯')
  api.nvim_command('au BufWipeout <buffer> exe "silent bwipeout! "'.. buf)

  api.nvim_buf_set_lines(buf, 0, -1, false, border_lines)
  return buf, win, closer
  
end

-- Create a floating buffer with border
local function floating_buffer_with_border(win_width, win_height, row, col)
  
  local border_buf, border_win, border_closer = floating_border(win_width, win_height, row, col) 

  local buf, win, closer = floating_buffer(win_width, win_height, row, col)
  return buf, win, border_buf, border_win, function()
    border_closer()
    closer()
  end
end


-- Calculate window size
local function floating_window_size(scale)
  local width = api.nvim_get_option("columns")
  local height = api.nvim_get_option("lines")

  local win_height = math.ceil(height * scale - 4)
  local win_width = math.ceil(width * scale)

  return win_height, win_width
end

local function execute(backend, cmd, opts)
  opts = opts or {}
  opts.scale = opts.scale or 0.6

  local current_window = vim.api.nvim_get_current_win()
  local win_height, win_width = floating_window_size(opts.scale)

  local row, col = location.center(win_height, win_width)

  local buf, win, border_buf, border_win, closer = floating_buffer_with_border(win_width, win_height, row, col)

  -- Create cmd
  cmd = string.format('%s | %s', cmd, backend.command_name)

  -- Open a terminal and launch the cmd 
  vim.fn.termopen(cmd, {
    on_exit = function(_, exit, _)
      vim.api.nvim_set_current_win(current_window)
      if exit == 0 then
        backend.process(buf, opts.callback)
      end
      closer()
    end
  })
end

-- Create a simple floating terminal.
local function floating_terminal(cmd, opts)
  opts = opts or {}
  opts.scale = opts.scale or 0.6

  local current_window = vim.api.nvim_get_current_win()
  local win_height, win_width = floating_window_size(opts.scale)

  local row, col = location.center(win_height, win_width)

  local buf, win, border_buf, border_win, closer = floating_buffer_with_border(win_width, win_height, row, col)
  if cmd == "" or cmd == nil then
    cmd = vim.api.nvim_get_option('shell')
  end
  vim.fn.termopen(cmd, {
    on_exit = function(_, _, _)
      vim.api.nvim_set_current_win(current_window)
      closer()
    end
  })

end

return {
  execute = execute,
  floating_terminal = floating_terminal,
  floating_buffer_with_prompt = floating_buffer_with_prompt,
  floating_buffer = function(scale, loc)
    local win_height, win_width = floating_window_size(scale)
    local row, col = loc(win_height, win_width)
    return floating_buffer_with_border(win_width, win_height, row, col)
  end,
} 
