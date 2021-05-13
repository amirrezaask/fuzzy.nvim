local M = {}
local fuzzy = require('fuzzy.lib')

function M.colors(opts)
  opts = opts or {}
  opts.handler = function(color)
    vim.cmd(string.format('colorscheme %s', color))
  end
  opts.source = vim.fn.getcompletion('', 'color')
  fuzzy(opts)
end

function M.buffers(opts)
  opts = opts or {}
  local _buffers = {}
  local function buffer_state(buf)
    if vim.api.nvim_buf_is_loaded(buf) then
      return 'L'
    else
      return 'U'
    end
  end
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if 1 == vim.fn.buflisted(b) then
      table.insert(_buffers, string.format('[%s] %s:%s', buffer_state(b), b, vim.api.nvim_buf_get_name(b)))
    end
  end
  opts.handler = function(line)
    local buffer_name = vim.split(line, ':')[2]
    vim.cmd(string.format('buffer %s', buffer_name))
  end
  opts.source = _buffers
  fuzzy(opts)
end

function M.commands(opts)
  opts = opts or {}
  opts.source = vim.fn.getcompletion('', 'command')
  opts.handler = function(command)
    vim.cmd(command)
  end
  fuzzy(opts)
end

function M.mru(opts)
  opts = opts or {}
  opts.source = vim.split(vim.fn.execute('oldfiles'), '\n')
  opts.handler = function(file)
    vim.cmd(string.format('e %s', vim.split(file, ':')[2]))
  end
  fuzzy(opts)
end

function M.history(opts)
  opts = opts or {}
  opts.source = vim.split(vim.fn.execute('history cmd'), '\n')
  opts.handler = function(command)
    vim.cmd(vim.split(command, ' ')[2])
  end
  fuzzy(opts)
end

function M.help(opts)
  opts = opts or {}
  opts.source = function()
    return vim.fn.getcompletion('', 'help')
  end
  opts.sorter = function(query, collection)
    return vim.fn.getcompletion(query, 'help')
  end
  opts.handler = function(line)
    vim.cmd([[ h ]] .. line)
  end
  fuzzy(opts)
end

function M.mappings(opts)
  opts = opts or {}
  local mappings = vim.split(vim.fn.execute('map'), '\n')
  opts.source = mappings
  opts.handler = function(line)
    local command = vim.split(line, ' ')[3]
    vim.fn.execute(command)
  end
  fuzzy(opts)
end

return M
