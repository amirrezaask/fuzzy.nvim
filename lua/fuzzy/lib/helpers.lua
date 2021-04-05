local function tprint (tbl, indent)
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
    local formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      print(formatting)
      tprint(v, indent+1)
    elseif type(v) == 'boolean' then
      print(formatting .. tostring(v))      
    else
      print(formatting .. v)
    end
  end
end

return {
  open_file = function(filename)
    vim.api.nvim_command(string.format('e %s', filename))
  end,
  open_file_at = function(filename, line)
    vim.api.nvim_command(string.format('e +%s %s', line, filename))
  end,
  split_string_by_char = split,
  tprint = tprint,
}


