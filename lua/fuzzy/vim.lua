local M = {}
local fuzzy = require'fuzzy.lib'

function M.colors(opts)
  fuzzy.new {
    handler = function(color)
      vim.cmd(string.format('colorscheme %s', color))
    end,
    source = vim.fn.getcompletion('', 'color'),
  }
end

function M.buffers(opts)
  local _buffers = {}
  local function buffer_state(buf)
    if vim.api.nvim_buf_is_loaded(buf) then
      return 'L'
    else
      return 'U'
    end
  end
  for _,b in ipairs(vim.api.nvim_list_bufs()) do
    if 1 == vim.fn.buflisted(b) then
      table.insert(_buffers, string.format("[%s] %s:%s", buffer_state(b), b, vim.api.nvim_buf_get_name(b)))
    end
  end
  fuzzy.new {
    handler = function(line)
      local buffer_name = vim.split(line, ':')[2]
      vim.cmd(string.format('buffer %s', buffer_name))
    end,
    source = _buffers,
  }
end


function M.commands(opts)
  fuzzy.new {
    source = vim.fn.getcompletion('', 'command'),
    handler = function(command)
      vim.cmd(command)
    end,
  }
end

function M.mru(opts)
  fuzzy.new {
    source = vim.split(vim.fn.execute('oldfiles'), '\n'),
    handler = function(file)
      vim.cmd (string.format('e %s', vim.split(file, ':')[2]))
    end,
  }
end

function M.history(opts)
  opts = opts or {}
  fuzzy.new {
    source = vim.split(vim.fn.execute('history cmd'), '\n'),
    handler = function(command)
      print(vim.split(command, ' ')[2])
      vim.cmd(vim.split(command, ' ')[2])
    end,
  }
end

function M.projects(opts)
  opts = opts or {}
  local project_list = require'fuzzy.lib.projects'.list_projects(opts.locations)
  fuzzy.new {
    source = function()
      return project_list 
    end,
    handler = function (path)
      vim.cmd(string.format([[ cd %s ]], path))
    end
  }
end
function M.help(opts)
  opts = opts or {}
  fuzzy.new {
    source = function()
      return vim.fn.getcompletion('', 'help')
    end,
    sorter = function(query, collection)
      return vim.fn.getcompletion(query, 'help')
    end,
    handler = function(line)
      vim.cmd ([[ h ]] .. line)
    end
  }
end

function M.mappings(opts)
  opts = opts or {}
  local mappings = vim.split(vim.fn.execute('map'), '\n')
  fuzzy.new {
    source = mappings,
    handler = function(line)
      local command = vim.split(line, ' ')[3]
      vim.fn.execute(command)
    end
  }
end

return M

