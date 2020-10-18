return {
  center = function(win_height, win_width)
    local width = vim.api.nvim_get_option("columns")
    local height = vim.api.nvim_get_option("lines")
    local row = math.ceil((height - win_height) / 2 - 1)
    local col = math.ceil((width - win_width) / 2)
    return row, col
  end,
  bottom_center = function(win_height, win_width)
    local width = vim.api.nvim_get_option("columns")
    local height = vim.api.nvim_get_option("lines")
    local row = math.ceil(win_height) 
    local col = math.ceil((width - win_width) / 2 )  
    return row, col
  end
}


