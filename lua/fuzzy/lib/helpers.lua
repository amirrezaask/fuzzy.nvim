return {
  open_file = function(filename)
    require'fuzzy.lib.helpers'.open_file_at(filename, 0)
  end,
  open_file_at = function(filename, line)
    vim.api.nvim_command(string.format('e +%s %s', line, filename))
  end,
}


