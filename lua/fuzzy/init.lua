local fuzzy = require('fuzzy.lib')
local helpers = require('fuzzy.lib.helpers')
local source = require('fuzzy.lib.source')
local sorter = require('fuzzy.lib.sorter')
local drawer = require('fuzzy.lib.drawer')
local file_finder = require'fuzzy.lib.file_finder'
local grep = require'fuzzy.lib.grep'
local projects = require'fuzzy.lib.projects'

-- Register execute commands
vim.cmd [[ command! IFiles lua require('fuzzy').interactive_finder{} ]]
vim.cmd [[ command! Files lua require('fuzzy').file_finder{} ]]
vim.cmd [[ command! Grep lua require('fuzzy').grep{} ]]
vim.cmd [[ command! Commands lua require('fuzzy').commands{} ]]
vim.cmd [[ command! MRU lua require('fuzzy').mru{} ]]
vim.cmd [[ command! BLines lua require('fuzzy').buffer_lines{} ]]
vim.cmd [[ command! Cd lua require('fuzzy').cd{} ]]
vim.cmd [[ command! Help lua require('fuzzy').help{} ]]
vim.cmd [[ command! Maps lua require('fuzzy').mappings{} ]]
vim.cmd [[ command! GitFiles lua require('fuzzy.git').git_files{} ]]
vim.cmd [[ command! GitGrep lua require('fuzzy.git').git_grep{} ]]
vim.cmd [[ command! GitCommits lua require('fuzzy.git').git_commits{} ]]
vim.cmd [[ command! GitBCommits lua require('fuzzy.git').git_bcommits{} ]]
vim.cmd [[ command! GitCheckout lua require('fuzzy.git').git_checkout{} ]]
vim.cmd [[ command! Buffers lua require('fuzzy').buffers{} ]]
vim.cmd [[ command! Rg lua require('fuzzy').rg{} ]]
vim.cmd [[ command! Colors lua require('fuzzy').colors{} ]]

local options = vim.g.fuzzy_options or {}
-- Defaults
local FUZZY_DEFAULT_SORTER = options.sorter or sorter.string_distance
local FUZZY_DEFAULT_DRAWER = options.drawer or drawer.new

M = {}

function M.grep(opts)
  if vim.fn.executable('git') and vim.fn.isdirectory('.git') then
    return require'fuzzy.git'.git_grep(opts)
  elseif vim.fn.executable('rg') ~= 0 then
    return require'fuzzy'.rg(opts)
  else
    return require'fuzzy'.luv_grep(opts)
  end
end

function M.file_finder(opts)
  if vim.fn.executable('fdfind') ~= 0 or vim.fn.executable('fd') ~= 0 then
    return require'fuzzy'.fd(opts)
  elseif not vim.g.fuzzy_options.no_luv_finder then
    return require'fuzzy'.luv_finder(opts)
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
  fuzzy.new {
    source = source_and_sorter,
    sorter = source_and_sorter,
    drawer = drawer.new(),
    handler = function(line)
      local filename = vim.split(line, ':')[1]
      local linum = vim.split(line, ':')[2]
      CURRENT_FUZZY.__grep_cache= {}
      helpers.open_file_at(filename, linum)
    end
  }
end

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
  opts.hidden = opts.hidden or false
  opts.depth = opts.depth or FILE_FINDER_DEFAULT_DEPTH
  opts.include_dirs = opts.include_dirs or false
  opts.include_previous_link = opts.include_previous_link or false
  opts.blacklist = opts.blacklist or FUZZY_OPTS.blacklist or {}
  opts.handler = opts.handler or function(line)
    helpers.open_file(line)
  end
  fuzzy.new {
    source = function()
      return file_finder.find({
      path = opts.path,
      depth = opts.depth,
      hidden = opts.hidden,
      include_dirs = opts.include_dirs,
      include_previous_link = opts.include_previous_link,
      blacklist = opts.blacklist,
    })
    end,
    sorter = FUZZY_DEFAULT_SORTER,
    drawer = drawer.new({
    }),
    handler = opts.handler
  }
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
  fuzzy.new {
    source = source.bin_source(cmd),
    sorter = FUZZY_DEFAULT_SORTER,
    drawer = drawer.new(),
    handler = function(line)
      helpers.open_file(line)
    end,
  }
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
  local function handler(line)
    helpers.open_file(line)
  end
  fuzzy.new {
    source = source.bin_source(cmd),
    sorter = FUZZY_DEFAULT_SORTER,
    drawer = FUZZY_DEFAULT_DRAWER,
  }
end


function M.rg(opts)
  local cmd = 'rg --column --line-number --no-heading --ignore-case '
  fuzzy.new {
    source = {},
    sorter = function(query, coll)
      return source.bin_source(string.format(cmd .. '"%s"', query))()
    end,
    drawer = drawer.new(),
    handler = function(line)
      local filename = vim.split(line, ':')[1]
      local linum = vim.split(line, ':')[2]
      helpers.open_file_at(filename, linum)
    end,
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
    sorter = FUZZY_DEFAULT_SORTER,
    drawer = drawer.new(),
    handler = function(line)
      local buffer_name = vim.split(line, ':')[2]
      vim.cmd(string.format('buffer %s', buffer_name))
    end,
    source = _buffers,
  }
end

function M.buffer_lines(opts)
  local filename = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
  local source = vim.split(grep.read_file(filename), '\n')
  for i=1,#source do
    source[i] = string.format('%s:%s', i, source[i])
  end
  fuzzy.new {
    source = source,
    sorter = FUZZY_DEFAULT_SORTER,
    drawer = drawer.new(),
    handler = function(line)
      helpers.open_file_at(filename, vim.split(line, ':')[1])
    end,
  }
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
  fuzzy.new {
    source = source.bin_source(cmd),
    sorter = FUZZY_DEFAULT_SORTER,
    drawer = drawer.new(),
    handler = function(line)
      vim.cmd(string.format('cd %s', line))
    end,
  }
end

function M.colors(opts)
  fuzzy.new {
    sorter = FUZZY_DEFAULT_SORTER,
    drawer = drawer.new(),
    handler = function(color)
      vim.cmd(string.format('colorscheme %s', color))
    end,
    source = vim.fn.getcompletion('', 'color'),
  }
end

function M.commands(opts)
  fuzzy.new {
    source = vim.fn.getcompletion('', 'command'),
    handler = function(command)
      vim.cmd(command)
    end,
    sorter = FUZZY_DEFAULT_SORTER,
    drawer = drawer.new()
  }
end

function M.mru()
  fuzzy.new {
    source = vim.split(vim.fn.execute('oldfiles'), '\n'),
    handler = function(file)
      vim.cmd (string.format('e %s', vim.split(file, ':')[2]))
    end,
    sorter = FUZZY_DEFAULT_SORTER,
    drawer = drawer.new(),
  }
end

function M.history()
  fuzzy.new {
    source = vim.split(vim.fn.execute('history cmd'), '\n'),
    handler = function(command)
      print(vim.split(command, ' ')[2])
      vim.cmd(vim.split(command, ' ')[2])
    end,
    sorter = FUZZY_DEFAULT_SORTER,
    drawer = drawer.new()
  }
end

function M.projects(opts)
  local project_list = projects.list_projects(opts.locations)
  fuzzy.new {
    source = function()
      return project_list 
    end,
    sorter = FUZZY_DEFAULT_SORTER,
    drawer = drawer.new(),
    handler = function (path)
      vim.cmd(string.format([[ cd %s ]], path))
    end
  }
end
function M.help()
  fuzzy.new {
    source = function()
      return vim.fn.getcompletion('', 'help')
    end,
    sorter = function(query, collection)
      return vim.fn.getcompletion(query, 'help')
    end,
    drawer = drawer.new(),
    handler = function(line)
      vim.cmd ([[ h ]] .. line)
    end
  }
end

function M.mappings()
  local mappings = vim.split(vim.fn.execute('map'), '\n')
  fuzzy.new {
    source = mappings,
    sorter = FUZZY_DEFAULT_SORTER,
    drawer = drawer.new(),
    handler = function(line)
      local command = vim.split(line, ' ')[3]
      vim.fn.execute(command)
    end
  }
end

return M
