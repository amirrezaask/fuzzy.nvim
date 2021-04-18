local fuzzy = require('fuzzy.lib')
local helpers = require('fuzzy.lib.helpers')
local bin = require('fuzzy.lib.source.binary')
local file_finder = require('fuzzy.lib.source.file_finder')

M = {}

function M.find_files(opts)
  opts = opts or {}
  if opts.path then
    opts.path = vim.fn.expand(opts.path)
  end
  if not FUZZY_OPTS.no_luv_finder then
    return require('fuzzy.files').luv_finder(opts)
  elseif vim.fn.executable('fdfind') ~= 0 or vim.fn.executable('fd') ~= 0 then
    return require('fuzzy.files').fd(opts)
  elseif vim.fn.executable('git') and vim.fn.isdirectory('.git') then
    return require('fuzzy.git').git_files(opts)
  elseif vim.fn.executable('find') ~= 0 then
    return require('fuzzy.files').find(opts)
  end
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
      vim.schedule(function()
        require('fuzzy').interactive_finder({ path = '.' })
      end)
    else
      helpers.open_file(line)
    end
  end
  require('fuzzy').luv_finder(opts)
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
    opts.hidden = nil
  end
  opts.path = opts.path or '.'
  local command = 'fd'
  if vim.fn.executable('fdfind') ~= 0 then
    command = 'fdfind'
  end
  local args = {}
  if opts.hidden then
    table.insert(args, opts.hidden)
  end
  table.insert(args, '--type')
  table.insert(args, 'f')
  table.insert(args, '--type')
  table.insert(args, 's')
  table.insert(args, '')
  table.insert(args, opts.path)
  opts.source = bin(command, args)
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
  table.insert(opts.args, opts.cwd)
  if not opts.hidden then
    table.insert(opts.args, '-not')
    table.insert(opts.args, '-path')
    table.insert(opts.args, '*/.*')
  end
  table.insert(opts.args, '-type')
  table.insert(opts.args, 's,f')
  opts.handler = function(line)
    helpers.open_file(line)
  end
  opts.source = bin('find', opts.args)
  fuzzy.new(opts)
end

function M.cd(opts)
  opts = opts or {}
  opts.cwd = opts.cwd or '.'
  opts.hidden = opts.hidden or false
  opts.args = opts.args or {}
  table.insert(opts.args, opts.cwd)
  if not opts.hidden then
    table.insert(opts.args, '-not')
    table.insert(opts.args, '-path')
    table.insert(opts.args, '*/.*')
  end
  table.insert(opts.args, '-type')
  table.insert(opts.args, 's,d')
  opts.source = bin('find', opts.args)
  opts.handler = function(line)
    vim.cmd(string.format('cd %s', line))
  end
  fuzzy.new(opts)
end

function M.find_repo(opts)
  opts = opts or {}
  local project_list = require('fuzzy.lib.source.repos').list_projects(opts.locations)
  opts.source = project_list
  opts.handler = function(path)
    vim.cmd(string.format([[ cd %s ]], path))
  end
  fuzzy.new(opts)
end

return M
