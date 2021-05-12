local fuzzy = require('fuzzy.lib')
local helpers = require('fuzzy.lib.helpers')

local M = {}

function M.document_symbols(opts)
  opts = opts or {}
  local params = vim.lsp.util.make_position_params()
  params.context = { includeDeclaration = true }
  params.query = ''
  local results_lsp = vim.lsp.buf_request_sync(0, 'textDocument/documentSymbol', params, opts.timeout or 10000)
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
  opts.source = lines
  opts.handler = function(line)
    local segments = vim.split(line, ':')
    helpers.open_file_at(segments[1], segments[2])
  end
  fuzzy.new(opts)
end

function M.workspace_symbols(opts)
  opts = opts or {}
  local params = vim.lsp.util.make_position_params()
  params.context = { includeDeclaration = true }
  params.query = vim.fn.input('Query: ')
  local results_lsp = vim.lsp.buf_request_sync(0, 'workspace/symbol', params, opts.timeout or 10000)
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
  opts.source = lines
  opts.handler = function(line)
    local segments = vim.split(line, ':')
    helpers.open_file_at(segments[1], segments[2])
  end
  fuzzy.new(opts)
end

function M.references(opts)
  opts = opts or {}
  local params = vim.lsp.util.make_position_params()
  params.context = { includeDeclaration = true }
  local results_lsp = vim.lsp.buf_request_sync(0, 'textDocument/references', params, opts.timeout or 10000)
  local locations = {}
  for _, server_results in pairs(results_lsp) do
    if server_results.result then
      vim.list_extend(locations, vim.lsp.util.locations_to_items(server_results.result) or {})
    end
  end
  local callback = function(line)
    local segments = vim.split(line, ':')
    helpers.open_file_at(segments[1], segments[2])
  end
  opts.callback = callback
  local lines = {}
  for _, loc in ipairs(locations) do
    table.insert(lines, string.format('%s:%s:%s', loc.filename, loc.lnum, loc.text))
  end
  if #lines == 1 then
    opts.callback(lines[1])
    return
  end
  opts.source = lines
  opts.handler = function(line)
    local segments = vim.split(line, ':')
    helpers.open_file_at(segments[1], segments[2])
  end
  fuzzy.new(opts)
end

function M.implementation(opts)
  opts = opts or {}
  local params = vim.lsp.util.make_position_params()
  params.context = { includeDeclaration = true }
  local results_lsp = vim.lsp.buf_request_sync(0, 'textDocument/implementations', params, opts.timeout or 10000)
  local locations = {}
  for _, server_results in pairs(results_lsp) do
    if server_results.result then
      vim.list_extend(locations, vim.lsp.util.locations_to_items(server_results.result) or {})
    end
  end
  local callback = function(line)
    local segments = vim.split(line, ':')
    helpers.open_file_at(segments[1], segments[2])
  end
  opts.callback = callback
  local lines = {}
  for _, loc in ipairs(locations) do
    table.insert(lines, string.format('%s:%s:%s', loc.filename, loc.lnum, loc.text))
  end
  if #lines == 1 then
    opts.callback(lines[1])
    return
  end

  opts.source = lines
  opts.handler = function(line)
    local segments = vim.split(line, ':')
    helpers.open_file_at(segments[1], segments[2])
  end
  fuzzy.new(opts)
end

local function do_lsp_code_action(code_action)
  if code_action.edit or type(code_action.command) == 'table' then
    if code_action.edit then
      vim.lsp.util.apply_workspace_edit(code_action.edit)
    end
    if type(code_action.command) == 'table' then
      vim.lsp.buf.execute_command(code_action.command)
    end
  else
    vim.lsp.buf.execute_command(code_action)
  end
end
function M.code_actions(opts)
  opts = opts or {}
  local params = opts.params or vim.lsp.util.make_range_params()

  params.context = {
    diagnostics = vim.lsp.diagnostic.get_line_diagnostics(),
  }

  local results_lsp, err = vim.lsp.buf_request_sync(0, 'textDocument/codeAction', params, opts.timeout or 10000)

  if err then
    print('ERROR: ' .. err)
    return
  end

  if not results_lsp or vim.tbl_isempty(results_lsp) then
    print('No results from textDocument/codeAction')
    return
  end

  local _, response = next(results_lsp)
  if not response then
    print('No code actions available')
    return
  end

  local results = response.result
  if not results or #results == 0 then
    print('No code actions available')
    return
  end
  if #results == 1 then
    do_lsp_code_action(results[1])
    return
  end
  local results_titles = {}

  for i, a in ipairs(results) do
    table.insert(results_titles, string.format('%d.%s', i, a.title))
  end
  opts.source = results_titles
  opts.handler = function(code_action)
    code_action = results[tonumber(vim.split(code_action, '%.')[1])]
    do_lsp_code_action(code_action)
  end
  fuzzy.new(opts)
end

function M.definitions(opts)
  opts = opts or {}
  local params = vim.lsp.util.make_position_params()
  params.context = { includeDeclaration = true }
  local results_lsp = vim.lsp.buf_request_sync(0, 'textDocument/definition', params, opts.timeout or 10000)
  local locations = {}
  for _, server_results in pairs(results_lsp) do
    if server_results.result then
      vim.list_extend(locations, vim.lsp.util.locations_to_items(server_results.result) or {})
    end
  end
  local callback = function(line)
    local segments = vim.split(line, ':')
    helpers.open_file_at(segments[1], segments[2])
  end
  opts.callback = callback
  local lines = {}
  for _, loc in ipairs(locations) do
    table.insert(lines, string.format('%s:%s:%s', loc.filename, loc.lnum, loc.text))
  end
  if #lines == 1 then
    opts.callback(lines[1])
    return
  end

  opts.source = lines
  opts.handler = function(line)
    local segments = vim.split(line, ':')
    helpers.open_file_at(segments[1], segments[2])
  end
  fuzzy.new(opts)
end

return M
