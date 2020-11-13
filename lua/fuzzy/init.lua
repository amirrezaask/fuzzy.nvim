local Fuzzy = require('fuzzy.lib')
local helpers = require('fuzzy.lib.helpers')
local source = require('fuzzy.lib.source')
local sorter = require('fuzzy.lib.sorter')
local drawer = require('fuzzy.lib.drawer')
local file_finder = require'fuzzy.lib.file_finder'
local grep = require'fuzzy.lib.grep'

-- Register execute commands
vim.cmd [[ command! IFiles lua require('fuzzy').interactive_finder{} ]]
vim.cmd [[ command! Files lua require('fuzzy').file_finder{} ]]
vim.cmd [[ command! Grep lua require('fuzzy').grep{} ]]
vim.cmd [[ command! Commands lua require('fuzzy').commands{} ]]
vim.cmd [[ command! MRU lua require('fuzzy').mru{} ]]
vim.cmd [[ command! BLines lua require('fuzzy').buffer_lines{} ]]
vim.cmd [[ command! Cd lua require('fuzzy').cd{} ]]
vim.cmd [[ command! GitFiles lua require('fuzzy').git_files{} ]]
vim.cmd [[ command! GitGrep lua require('fuzzy').git_grep{} ]]
vim.cmd [[ command! Buffers lua require('fuzzy').buffers{} ]]
vim.cmd [[ command! Rg lua require('fuzzy').rg{} ]]
vim.cmd [[ command! Colors lua require('fuzzy').colors{} ]]
vim.cmd [[ command! LspReferences lua require('fuzzy').lsp_references{} ]]
vim.cmd [[ command! LspDocumentSymbols lua require('fuzzy').lsp_document_symbols{} ]]
vim.cmd [[ command! LspWorkspaceSymbols lua require('fuzzy').lsp_workspace_symbols{} ]]

local options = vim.g.fuzzy_options or {}
-- Defaults
local FUZZY_DEFAULT_SORTER = options.sorter or sorter.string_distance
local FUZZY_DEFAULT_DRAWER = options.drawer or drawer.new

local M = {}

function M.grep(opts)
  if vim.fn.executable('rg') ~= 0 then
    return require'fuzzy'.rg(opts)
  elseif vim.fn.executable('git') and vim.fn.isdirectory('.git') then
    return require'fuzzy'.git_grep(opts)
  else
    return require'fuzzy'.luv_grep(opts)
  end
end

function M.file_finder(opts)
  if not vim.g.fuzzy_options.no_luv_finder then
    return require'fuzzy'.luv_finder(opts)
  elseif vim.fn.executable('fdfind') ~= 0 or vim.fn.executable('fd') ~= 0 then
    return require'fuzzy'.fd(opts)
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
  Fuzzy.new {
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
  opts.hidden = opts.hidden or false
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
  opts.handler = opts.handler or function(line)
    helpers.open_file(line)
  end
  Fuzzy.new {
    source = function()
      return file_finder.find({
      path = opts.path,
      depth = opts.depth,
      hidden = opts.hidden,
      include_dirs = opts.include_dirs,
      include_previous_link = opts.include_previous_link
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
  local cmd = string.format('fdfind %s --type f --type s', opts.hidden)
  Fuzzy.new {
    source = source.NewBinSource(cmd),
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
  Fuzzy.new {
    source = source.NewBinSource(cmd),
    sorter = FUZZY_DEFAULT_SORTER,
    drawer = FUZZY_DEFAULT_DRAWER,
  }
end
function M.git_files(opts) 
  Fuzzy.new {
    source = source.NewBinSource('git ls-files'),
    sorter = FUZZY_DEFAULT_SORTER,
    drawer = drawer.new(),
    handler = function(line)
      helpers.open_file(line)
    end,
  }
end

function M.git_grep(opts)
  local cmd = 'git grep -n ""'
  Fuzzy.new {
    source = source.NewBinSource(cmd),
    sorter = function(query, coll)
      return source.NewBinSource(string.format(cmd .. '"%s"', query))()
    end,
    drawer = drawer.new(),
    handler = function(line)
      local filename = vim.split(line, ':')[1]
      local linum = vim.split(line, ':')[2]
      helpers.open_file_at(filename, linum)
    end,
  }
end

function M.rg(opts)
  local cmd = 'rg --column --line-number --no-heading --ignore-case '
  Fuzzy.new {
    source = source.NewBinSource(string.format(cmd .. '""')),
    sorter = function(query, coll)
      return source.NewBinSource(string.format(cmd .. '"%s"', query))()
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
  Fuzzy.new {
    sorter = FUZZY_DEFAULT_SORTER,
    drawer = drawer.new(),
    handler = function(line)
      local buffer_name = vim.split(line, ':')[2]
      vim.cmd(string.format('buffer %s', buffer_name))
    end,
    collection = _buffers,
  }
end

function M.buffer_lines(opts)
  local filename = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
  local source = vim.split(grep.read_file(filename), '\n')
  for i=1,#source do
    source[i] = string.format('%s:%s', i, source[i])
  end
  Fuzzy.new {
    collection = source,
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
  Fuzzy.new {
    source = source.NewBinSource(cmd),
    sorter = sorter.FZF,
    drawer = drawer.new(),
    handler = function(line)
      vim.cmd(string.format('cd %s', line))
    end,
  }
end

function M.colors(opts)
  Fuzzy.new {
    sorter = FUZZY_DEFAULT_SORTER,
    drawer = drawer.new(),
    handler = function(color)
      vim.cmd(string.format('colorscheme %s', color))
    end,
    collection = vim.fn.getcompletion('', 'color'),
  }
end

function M.lsp_document_symbols(opts)
  opts = opts or {}
  local params = vim.lsp.util.make_position_params()
  params.context = { includeDeclaration = true }
  params.query = '' 
  local results_lsp = vim.lsp.buf_request_sync(0, "textDocument/documentSymbol", params, opts.timeout or 10000)
  local locations = {}
  for _, server_results in pairs(results_lsp) do
    if server_results.result then
      vim.list_extend(locations, vim.lsp.util.symbols_to_items(server_results.result) or {})
    end
  end
  local lines = {}
  for _, loc in ipairs(locations) do
    table.insert(lines, string.format('%s:%s:%s', loc.filename, loc.lnum, loc.text))
  end
  local cmd = table.concat(lines, '\n')
  Fuzzy.new {
    collection = lines,
    sorter = sorter.FZF,
    drawer = drawer.new(),
    handler = function(line)
      local segments = split(line, ":")
      helpers.open_file_at(segments[1], segments[2])
    end
  }
end

function M.lsp_workspace_symbols(opts)
  opts = opts or {}
  local params = vim.lsp.util.make_position_params()
  params.context = { includeDeclaration = true }
  params.query = ''
  local results_lsp = vim.lsp.buf_request_sync(0, "workspace/symbol", params, opts.timeout or 10000)
  local locations = {}
  for _, server_results in pairs(results_lsp) do
    if server_results.result then
      vim.list_extend(locations, vim.lsp.util.symbols_to_items(server_results.result) or {})
    end
  end
  local lines = {}
  for _, loc in ipairs(locations) do
    table.insert(lines, string.format('%s:%s:%s', loc.filename, loc.lnum, loc.text))
  end
  Fuzzy.new {
    collection = lines,
    handler = function(line)
      local segments = split(line, ":")
      helpers.open_file_at(segments[1], segments[2])
    end,
    sorter = sorter.FZF,
    drawer = drawer.new(),
  }
end

function M.lsp_references(opts)
  opts = opts or {}
  local params = vim.lsp.util.make_position_params()
  params.context = { includeDeclaration = true }
  local results_lsp = vim.lsp.buf_request_sync(0, "textDocument/references", params, opts.timeout or 10000)
  local locations = {}
  for _, server_results in pairs(results_lsp) do
    if server_results.result then
      vim.list_extend(locations, vim.lsp.util.locations_to_items(server_results.result) or {})
    end
  end
  local callback = function(line)
    local segments = split(line, ":")
    helpers.open_file_at(segments[1], segments[2])
  end
  opts.callback = callback
  local lines = {}
  for _, loc in ipairs(locations) do
    table.insert(lines, string.format('%s:%s:%s', loc.filename, loc.lnum, loc.text))
  end
  Fuzzy.new {
    collection = lines,
    handler = function(line)
      local segments = split(line, ":")
      helpers.open_file_at(segments[1], segments[2])
    end,
    sorter = FUZZY_DEFAULT_SORTER,
    drawer = drawer.new(),
  }
end

function M.commands(opts)
  Fuzzy.new {
    collection = vim.fn.getcompletion('', 'command'),
    handler = function(command)
      vim.cmd(command)
    end,
    sorter = FUZZY_DEFAULT_SORTER,
    drawer = drawer.new()
  }
end

function M.mru()
  Fuzzy.new {
    collection = vim.split(vim.fn.execute('oldfiles'), '\n'),
    handler = function(file)
      vim.cmd (string.format('e %s', vim.split(file, ':')[2]))
    end,
    sorter = FUZZY_DEFAULT_SORTER,
    drawer = drawer.new(),
  }
end

function M.history()
  Fuzzy.new {
    collection = vim.split(vim.fn.execute('history cmd'), '\n'),
    handler = function(command)
      print(vim.split(command, ' ')[2])
      vim.cmd(vim.split(command, ' ')[2])
    end,
    sorter = FUZZY_DEFAULT_SORTER,
    drawer = drawer.new()
  }
end
return M
 
