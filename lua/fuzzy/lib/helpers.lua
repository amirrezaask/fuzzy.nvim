return {
  open_file = function(filename)
    vim.api.nvim_command(string.format('e %s', filename))
  end,
  open_file_at = function(filename, line)
    vim.api.nvim_command(string.format('e +%s %s', line, filename))
  end,
}


