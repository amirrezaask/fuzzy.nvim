local api = vim.api
local options = require'fuzzy.lib.options'

-- Create a floating buffer with given win_width and win_height in given row and col.
return {
  floating_buffer = function(opts)
    opts = opts or {}
    local width = options.get_value(opts, 'width') 
    local height = options.get_value(opts, 'height') 
    local loc = options.get_value(opts, 'location') 
    
    
    local win_width = math.ceil(vim.api.nvim_get_option('columns')*width/100)
    local win_height = math.ceil(vim.api.nvim_get_option('lines')*height/100)
    opts.win_height = win_width 
    opts.win_width = win_height 
    local row, col = loc(opts.win_height, opts.win_width)
    local main_win_opts = {
      style = "minimal",
      relative = "editor",
      width = opts.win_width,
      height = opts.win_height,
      row = row,
      col = col
    }
    local buf = api.nvim_create_buf(true, true)
    api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    api.nvim_buf_set_option(buf, 'buftype','prompt')
    local border_win
    if opts.border then
      local border_opts = {
        style = "minimal",
        relative = "editor",
        width = opts.win_width + 2,
        height = opts.win_height + 2,
        row = row - 1,
        col = col - 1
      }
      local border_buf = api.nvim_create_buf(false, true)

      local top_line ='╭' .. string.rep('─', opts.win_width) .. '╮'
      local middle_line = '│' .. string.rep(' ', opts.win_width) .. '│'
      local bottom_line =  '╰' .. string.rep('─', opts.win_width) .. '╯'

      local border_lines = {top_line}

      for i=1, opts.win_height do
        table.insert(border_lines, middle_line)
      end

      table.insert(border_lines, bottom_line)
      for i=0, opts.win_height-1 do
        api.nvim_buf_add_highlight(border_buf, 0, 'PopupWindowBorder', i, 0, -1)
      end

      api.nvim_buf_set_lines(border_buf, 0, -1, false, border_lines)
      border_win = api.nvim_open_win(border_buf, true, border_opts)
      api.nvim_win_set_option(border_win, 'wrap', false)
      api.nvim_win_set_option(border_win, 'number', false)
      api.nvim_win_set_option(border_win, 'relativenumber', false)
      api.nvim_win_set_option(border_win, 'cursorline', false)
      api.nvim_win_set_option(border_win, 'signcolumn', 'no')
      api.nvim_win_set_option(border_win, 'winhl', 'Normal:FuzzyBorderNormal')
    end
    local win = api.nvim_open_win(buf, true, main_win_opts)
    api.nvim_win_set_option(win,'winhl', 'Normal:FuzzyNormal')
    return buf, win, function()
      if opts.border then
        vim.api.nvim_win_close(border_win, true)
      end
      vim.api.nvim_win_close(win, true)
    end
  end
}
 
