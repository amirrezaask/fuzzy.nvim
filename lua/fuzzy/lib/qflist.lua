local M = {}
local function remove_icon(line)
  if string.byte(line, 4) == string.byte(' ', 1) then
    return string.sub(line, 5, #line)
  end
  return line
end
function M.set_qflist(results)
  local qflist = {}
  for _, v in pairs(results) do
    local parts = vim.split(v, ':')
    table.insert(qflist, { filename = remove_icon(parts[1]), lnum = parts[2], col = parts[3] })
  end
  vim.fn.setqflist(qflist)
end

return M
