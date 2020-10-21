local M = {}
function M.NewBinSource(cmd)
  return function()
    local file =io.popen(cmd)
    local output = file:read('*all')
    file:close()
    output = vim.split(output, '\n')
    return output
  end
end

return M
