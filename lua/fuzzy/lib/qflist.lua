local M = {}
local remove_icon = require('fuzzy.lib.helpers').remove_icon

function M.set_qflist(results)
  local qflist = {}
  for _, v in pairs(results) do
    if v ~= '' then
      local parts = vim.split(v, ':')
      if #parts > 1 then
        table.insert(qflist, { filename = remove_icon(parts[1]), lnum = parts[2], col = parts[3], text= parts[4] })
      else
        table.insert(qflist, { filename = remove_icon(v), lnum = 0, col = 0 })
      end
    end
  end
  vim.fn.setqflist(qflist)
end

return M
