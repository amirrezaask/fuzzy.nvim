local Luzzy = require('luzzy').Luzzy
local lev = require('luzzy.alg.levenshtein')
local helpers = require('luzzy.helpers')

local not_hidden_find = '-not -path "*/\\.*"'

-- Register execute commands
vim.cmd [[ command! Files lua require('luzzy.internal').find_files{} ]]
vim.cmd [[ command! Fd lua require('luzzy.internal').fd_files{} ]]
vim.cmd [[ command! GFiles lua require('luzzy.internal').git_files{} ]]
vim.cmd [[ command! GGrep lua require('luzzy.internal').git_grep{} ]]
vim.cmd [[ command! BLines lua require('luzzy.internal').buffer_lines{} ]]
vim.cmd [[ command! Buffers lua require('luzzy.internal').buffers{} ]]
vim.cmd [[ command! Rg lua require('luzzy.internal').rg{} ]]
-- Not supported yet
-- vim.cmd [[ command! Colors lua require('luzzy.internal').rg{} ]]
-- vim.cmd [[ command!  lua require('luzzy.internal').rg{} ]]

return {
  fd_files = function(opts)
    opts = opts or {}
    opts.cwd = '.'
    opts.hidden = opts.hidden or false
    local hidden = ''
    if opts.hidden then
      hidden = '--hidden'
    end
    Luzzy.new {
      bin = 'fdfind',
      args = {'-t', 'file', '-t', 'symlink', opts.cwd, opts.hidden },
      callback =  function(line)
        helpers.open_file(line)
      end
    }
  end,
  find_files = function(opts)
    opts = opts or {}
    opts.cwd = opts.cwd or '.'
    opts.hidden = opts.hidden or false
    opts.args = opts.args or {}
    table.insert(opts.args, opts.cwd)
    if not opts.hidden then
      table.insert(opts.args, '-not')
      table.insert(opts.args, '-path')
      table.insert(opts.args, [['*/\.*']])
    end
    table.insert(opts.args, '-type')
    table.insert(opts.args, 's,f')
    Luzzy.new {
      bin = 'find',
      args = opts.args,
      callback = function(line)
        helpers.open_file(line)
    end,
    }
  end,
  git_files = function(opts)
    Luzzy.new {
      bin = 'git',
      args = {'ls-files'},
      callback = function(line)
        helpers.open_file(line)
      end,
    } 
  end,
  git_grep = function(opts)
    Luzzy.new {
      bin = 'git',
      args = {'grep', '-n', [[]]},
      callback = function(line)
        local filename = vim.split(line, ':')[1]
        local linum = vim.split(line, ':')[2]
        helpers.open_file_at(filename, linum)
      end
    }
  end,
  rg = function(opts)
    Luzzy.new {
      bin = 'rg',
      args = {'--column', '--line-number', '--no-heading', '--smart-case', ''},
      callback = function(line)
        helpers.open_file_at(vim.split(line, ':')[1], vim.split(line, ':')[2])
      end
    }
  end,
  buffers = function(opts)
    local _buffers = {}
    for _,b in ipairs(vim.api.nvim_list_bufs()) do
      if 1 == vim.fn.buflisted(b) then
        table.insert(_buffers, string.format("%s: %s", b, vim.api.nvim_buf_get_name(b)))
      end
    end
    Luzzy.new {
      collection = _buffers, 
      callback = function(line)
        local buffer_name = vim.split(line, ':')[2]
        vim.cmd(string.format('buffer %s', buffer_name))
      end
    }
  end,
  buffer_lines = function(opts)
    local filename = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
    Luzzy.new {
      bin = 'cat',
      args = {'--number', filename},
      callback = function(line)
        local number = vim.split(line, '  ')[3]
        helpers.open_file_at(filename, number)
      end
    } 
  end
}
