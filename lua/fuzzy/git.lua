local fuzzy = require('fuzzy.lib')
local helpers = require('fuzzy.lib.helpers')
local bin_source = require('fuzzy.lib.source.binary').bin_source
local sorter = require('fuzzy.lib.sorter')
local drawer = require('fuzzy.lib.drawer')
local options = vim.g.fuzzy_options or {}

local M = {}

function M.git_files(opts) 
  fuzzy.new {
    source = bin_source('git ls-files $(git rev-parse --show-toplevel)'),
    handler = function(line)
      helpers.open_file(line)
    end,
  }
end

function M.git_grep(opts)
  local cmd = 'git grep -n ""'
  fuzzy.new {
    source = bin_source(cmd),
    sorter = function(query, coll)
      return bin_source(string.format(cmd .. '"%s"', query))()
    end,
    handler = function(line)
      local filename = vim.split(line, ':')[1]
      local linum = vim.split(line, ':')[2]
      helpers.open_file_at(filename, linum)
    end,
  }
end

local function preview_win(data)
  local buf = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(buf, 'buftype','nowrite')
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, data)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false) 
  vim.cmd [[ vnew ]]
  vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win, buf)
end
function M.git_commits(opts)
  local commits = bin_source('git log --pretty=oneline --abbrev-commit')()
  vim.inspect(commits)
  fuzzy.new {
    source = commits,
    handler = function(line)
      local commit_hash = vim.split(line, ' ')[1]
      local diff_command = 'git --no-pager diff ' .. commit_hash
      if vim.fn.executable('bat') then
        diff_command = diff_command .. ' | bat --style plain'
      end
      local diff = bin_source(diff_command)()
      preview_win(diff)
      -- vim.cmd(string.format('! git checkout %s', vim.split(line, ' ')[1]))
    end
  }

end


function M.git_bcommits(opts)
  local filename = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
  local commits = bin_source('git log --pretty=oneline --abbrev-commit ' .. filename)()
  fuzzy.new {
    source = commits,
    handler = function(line)
      local commit_hash = vim.split(line, ' ')[1]
      local diff_command = 'git --no-pager diff ' .. commit_hash
      if vim.fn.executable('bat') then
        diff_command = diff_command .. ' | bat --style plain'
      end
      local diff = bin_source(diff_command)()
      preview_win(diff)
    end
  }
end

function M.git_checkout(opts)
  local branches = bin_source('git --no-pager branch')()
  fuzzy.new {
    source = branches,
    handler = function(line)
      vim.cmd(string.format('! git checkout %s', vim.split(line, ' ')[2]))
    end
  }
end
return M

