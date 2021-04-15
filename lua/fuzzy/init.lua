local fuzzy = require('fuzzy.lib')
local helpers = require('fuzzy.lib.helpers')
local bin = require('fuzzy.lib.source.binary')
local file_finder = require'fuzzy.lib.source.file_finder'
local grep = require'fuzzy.lib.source.grep'

M = {}

function M.grep(opts)
  opts = opts or {}
  if vim.fn.executable('rg') ~= 0 then
    return require'fuzzy'.rg(opts)
  elseif vim.fn.executable('git') and vim.fn.isdirectory('.git') then
    return require'fuzzy.git'.git_grep(opts)
  else
    return require'fuzzy'.luv_grep(opts)
  end
end

function M.find_files(opts)
  opts = opts or {}
  if opts.path then
    opts.path = vim.fn.expand(opts.path)
  end
  if not FUZZY_OPTS.no_luv_finder then
    return require'fuzzy'.luv_finder(opts)
  elseif vim.fn.executable('fdfind') ~= 0 or vim.fn.executable('fd') ~= 0 then
    return require'fuzzy'.fd(opts)
  elseif vim.fn.executable('git') and vim.fn.isdirectory('.git') then
    return require'fuzzy.git'.git_files(opts)
  elseif vim.fn.executable('find') ~= 0 then
    return require'fuzzy'.find(opts)
  end
end

function M.luv_grep(opts)
  opts = opts or {}
  opts.cwd = '.'
  opts.hidden = opts.hidden or false
  local source_and_sorter = function()
    local files = file_finder.find({
      path = opts.cwd,
      depth = opts.depth,
      hidden = opts.hidden
    })
    local lines = grep.grep(files, CURRENT_FUZZY.input or '')
    return lines
  end
  opts.source = source_and_sorter
  opts.sorter = source_and_sorter
  opts.handler = function(line)
      local filename = vim.split(line, ':')[1]
      local linum = vim.split(line, ':')[2]
      CURRENT_FUZZY.__grep_cache= {}
      helpers.open_file_at(filename, linum)
    end
  fuzzy.new(opts)
end

--TODO: improve
function M.interactive_finder(opts)
  opts = opts or {}
  opts.path = opts.path or '.'
  opts.hidden = opts.hidden or true
  opts.depth = 1
  opts.include_dirs = true
  opts.include_previous_link = true
  opts.handler = function(line)
    if file_finder.file_type(line) == 'directory' then
      vim.cmd(string.format('cd %s', line))
      vim.schedule(function() require'fuzzy'.interactive_finder({path = '.'}) end)
    else
      helpers.open_file(line)
    end
  end
  require'fuzzy'.luv_finder(opts)
end

function M.luv_finder(opts)
  opts = opts or {}
  opts.path = opts.path or '.'
  opts.hidden = opts.hidden or true
  opts.depth = opts.depth or FILE_FINDER_DEFAULT_DEPTH
  opts.include_dirs = opts.include_dirs or false
  opts.include_previous_link = opts.include_previous_link or false
  opts.blacklist = opts.blacklist or FUZZY_OPTS.blacklist or {}
  opts.handler = opts.handler or function(line)
    helpers.open_file(line)
  end
  opts.source = function()
      return file_finder.find({
      path = opts.path,
      depth = opts.depth,
      hidden = opts.hidden,
      include_dirs = opts.include_dirs,
      include_previous_link = opts.include_previous_link,
      blacklist = opts.blacklist,
    })
    end
  fuzzy.new(opts)
end

function M.fd(opts)
  opts = opts or {}
  opts.hidden = opts.hidden or false
  if opts.hidden then
    opts.hidden = '--hidden'
  else
    opts.hidden = ''
  end
  opts.path = opts.path or '.'
  local program_name = 'fd'
  if vim.fn.executable('fdfind') ~= 0 then
    program_name = 'fdfind'
  end
  local cmd = string.format('%s %s --type f --type s "" %s', program_name, opts.hidden, opts.path)
  opts.source = bin.bin_source(cmd)
  opts.handler = function(line)
    helpers.open_file(line)
  end
  fuzzy.new(opts) 
end

function M.find(opts)
  opts = opts or {}
  opts.cwd = opts.cwd or '.'
  opts.hidden = opts.hidden or false
  opts.args = opts.args or {}
  local hidden = [[-not -path '*/\.*']]
  if opts.hidden then
    hidden = ''
  end
  local cmd = string.format('find %s %s -type s,f', opts.cwd, hidden)
  opts.handler= function(line)
    helpers.open_file(line)
  end
  opts.source = bin.bin_source(cmd)
  fuzzy.new (opts)
end


function M.rg(opts)
  opts = opts or {}
  local cmd = 'rg --column --line-number --no-heading --ignore-case '
  opts.source = {}
  opts.sorter = function(query, _)
      return bin.bin_source(string.format(cmd .. '"%s"', query))()
    end
  opts.handler = function(line)
    local filename = vim.split(line, ':')[1]
    local linum = vim.split(line, ':')[2]
    helpers.open_file_at(filename, linum)
  end
  fuzzy.new(opts)
end


function M.buffer_lines(opts)
  opts = opts or {}
  local filename = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
  local source = vim.split(grep.read_file(filename), '\n')
  for i=1,#source do
    source[i] = string.format('%s:%s', i, source[i])
  end
  opts.source = source
  opts.handler = function(line)
    helpers.open_file_at(filename, vim.split(line, ':')[1])
  end
  fuzzy.new(opts)
end

function M.cd(opts)
  opts = opts or {}
  opts.cwd = opts.cwd or '.'
  opts.hidden = opts.hidden or false
  opts.args = opts.args or {}
  table.insert(opts.args, opts.cwd)
  if not opts.hidden then
    table.insert(opts.args, [[-not -path '*/\.*']])
  end
  table.insert(opts.args, '-type s,d')
  local cmd = string.format('find %s', table.concat(opts.args, ' '))
  opts.source = bin.bin_source(cmd)
  opts.handler = function(line)
    vim.cmd(string.format('cd %s', line))
  end
  fuzzy.new(opts)
end

return M
