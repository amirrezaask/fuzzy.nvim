local Luzzy = require('luzzy').Luzzy
local lev = require('luzzy.alg.levenshtein')
local helpers = require('luzzy.helpers')

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
      args = {'-t', 'file', '-t', 'symlink', opts.cwd, opts.hidden }

    }

  end,
  find_files = function(opts)
    opts = opts or {}
    opts.cwd = opts.cwd or '.'
    Luzzy.new {
      bin = 'find',
      args = {opts.cwd},
      callback = function(line)
        helpers.open_file(line)
      end,
      updater = function(self)
        vim.schedule(function()
          self.collection = self.alg(self.input, self.collection)
        end)
      end,
    }
  end



}
