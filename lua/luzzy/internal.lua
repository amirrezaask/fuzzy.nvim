local Luzzy = require('luzzy').Luzzy
local lev = require('luzzy.alg.levenshtein')
local helpers = require('luzzy.helpers')

local not_hidden_find = '-not -path "*/\\.*"'
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
  rg = function(opts)
    Luzzy.new {
      bin = 'rg',
      args = {'--column', '--line-number', '--no-heading', '--smart-case', ''},
      callback = function(line)
        helpers.open_file_at(vim.split(line, ':')[1], vim.split(line, ':')[2])
      end
    }
  end
}
