local grep = require'fuzzy.lib.grep'
local M = {}
local projects_file_path = '/home/amirreza/.config/nvim/.projects'

vim.cmd(string.format([[ command! AddProject lua require'fuzzy.lib.projects'.add(vim.fn.execute('pwd'))]]))
vim.cmd(string.format([[ command! Projects lua require'fuzzy.lib.projects'.]]))
function M.add(path)
  local file = io.open(projects_file_path, "a")
  if file == nil then
    print('error no file')
    return
  end
  file:write(path, "\n")
  file:close()
  return
end

function M.list()
  if vim.fn.exists(projects_file_path) == 0 then
    vim.cmd(string.format([[! touch %s ]], projects_file_path))
  end
  local content = grep.read_file(projects_file_path)
  if content == '' or content == nil then
    print('try adding project first!')
    return
  end
  return vim.split(content, '\n')
end

return M
