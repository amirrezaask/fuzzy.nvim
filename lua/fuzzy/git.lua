local fuzzy = require('fuzzy.lib')
local helpers = require('fuzzy.lib.helpers')
local bin = require('fuzzy.lib.source.binary')
local M = {}

function M.git_files(opts)
  opts = opts or {}
  opts.source = bin('bash', { '-c', 'git ls-files $(git rev-parse --show-toplevel)' })
  opts.handler = function(line)
    helpers.open_file(line)
  end
  fuzzy.new(opts)
end

function M.git_grep(opts)
  opts = opts or {}
  opts.source = bin('git', { 'grep', '-n', '""' })
  opts.sorter = function(query, _)
    return bin('git', { 'grep', '-n', query })()
  end
  opts.handler = function(line)
    local filename = vim.split(line, ':')[1]
    local linum = vim.split(line, ':')[2]
    helpers.open_file_at(filename, linum)
  end
  fuzzy.new(opts)
end

function M.git_commits(opts)
  opts = opts or {}
  local commits = bin('git', { 'log', '--pretty=oneline', '--abbrev-commit' })()
  opts.source = commits
  fuzzy.new(opts)
end

function M.git_bcommits(opts)
  opts = opts or {}
  local filename = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
  local commits = bin('git', { 'log', '--pretty=oneline', '--abbrev-commit', filename })()
  opts.source = commits
  opts.handler = function(line)
    local commit_hash = vim.split(line, ' ')[1]
    local diff_command = 'git --no-pager diff ' .. commit_hash
    if vim.fn.executable('bat') then
      diff_command = diff_command .. ' | bat --style plain'
    end
  end
  fuzzy.new(opts)
end

function M.git_checkout(opts)
  opts = opts or {}
  local branches = bin('git', { '--no-pager', 'branch' })()
  opts.source = branches
  opts.handler = function(line)
    vim.cmd(string.format('! git checkout %s', vim.split(line, ' ')[2]))
  end

  fuzzy.new(opts)
end
return M
