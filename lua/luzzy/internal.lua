local Luzzy = require('luzzy').Luzzy
local lev = require('luzzy.alg.levenshtein')
local helpers = require('luzzy.helpers')


-- Register execute commands
vim.cmd [[ command! Files lua require('luzzy.internal').find_files{} ]]
vim.cmd [[ command! Fd lua require('luzzy.internal').fd_files{} ]]
vim.cmd [[ command! GFiles lua require('luzzy.internal').git_files{} ]]
vim.cmd [[ command! GGrep lua require('luzzy.internal').git_grep{} ]]
vim.cmd [[ command! BLines lua require('luzzy.internal').buffer_lines{} ]]
vim.cmd [[ command! Buffers lua require('luzzy.internal').buffers{} ]]
vim.cmd [[ command! Rg lua require('luzzy.internal').rg{} ]]
vim.cmd [[ command! Colors lua require('luzzy.internal').colors{} ]]
vim.cmd [[ command! Cd lua require('luzzy.internal').cd{} ]]

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
      table.insert(opts.args, [[*/\.*]])
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
  end,
  cd = function(opts)
    opts = opts or {}
    opts.cwd = opts.cwd or '.'
    opts.hidden = opts.hidden or false
    opts.args = opts.args or {}
    table.insert(opts.args, opts.cwd)
    if not opts.hidden then
      table.insert(opts.args, '-not')
      table.insert(opts.args, '-path')
      table.insert(opts.args, [[*/\.*]])
    end
    table.insert(opts.args, '-type')
    table.insert(opts.args, 's,d')
    Luzzy.new{
      bin = 'find',
      args = opts.args,
      callback = function(line)
        print(line)
        vim.cmd (string.format('! cd %s', line))
      end
    }
  end,
  colors = function(opts)
    Luzzy.new {
      collection = vim.fn.getcompletion('', 'color'),
      callback = function(color)
        vim.cmd(string.format('colorscheme %s', color))
      end
    } 
  end,
  lsp_document_symbols = function(opts)
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
    Luzzy.new {
      collection = lines,
      callback = function(line)
        local segments = split(line, ":")
        helpers.open_file_at(segments[1], segments[2])
      end
    }
  end,
  lsp_workspace_symbols = function(opts)
    opts = opts or {}
    local params = vim.lsp.util.make_position_params()
    params.context = { includeDeclaration = true }
    params.query = vim.fn.input('Symbol: ')
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
    Luzzy.new {
      collection = lines,
      callback = function(line)
        local segments = split(line, ":")
        helpers.open_file_at(segments[1], segments[2])
      end
    }
  end
}
