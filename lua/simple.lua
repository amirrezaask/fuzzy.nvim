local levenshtein_distance = require('fuzzy.lib.alg.levenshtein').match
local FuzzyHi = vim.api.nvim_create_namespace('FuzzyHi')

__FUZZY_MAP_REGISTRY = {}
local function map(buf, mappings)
  local counter = 0
    for key, handler in pairs(mappings) do
      local mode = vim.split(key, ' ')[1]
      local actual_key = vim.split(key, ' ')[2]
      actual_key = vim.api.nvim_replace_termcodes(actual_key, true, true, true)
      __FUZZY_MAP_REGISTRY[string.format('%s', counter)] = function()
        handler()
      end
      local map_cmd = string.format('<cmd>lua __FUZZY_MAP_REGISTRY["%s"]()<CR>', counter)
      vim.api.nvim_buf_set_keymap(buf, mode, actual_key, map_cmd, { noremap = true })
      counter = counter + 1
    end
end

__FUZZY_AU_REGISTRY = {}
local function autocmd(event, filter, callback)
  __FUZZY_AU_REGISTRY[event.. ' ' ..filter] = callback
  vim.cmd(string.format([[ autocmd %s %s lua __FUZZY_AU_REGISTRY['%s']() ]], event, filter, event .. ' ' .. filter))
end
--@returns table to be searched on, collection is a list of item tables { value, metadata(icon, score, ...) }
local function resolve_source(source)
  if type(source) == 'string' then

  elseif type(source) == 'table' then
    return source
  elseif type(source) == 'function' then
  end

end

local function default_sorter(opts)
  return levenshtein_distance
end

--@param height is a number that is the height of floating window, it is absolute cause it is the lenght of our original results 
--@param width_scale is a number that is the percentage of neovim width
--@returns bufnr, winid
local function floating_win(height, width_scale)
  local win_width = math.ceil(vim.api.nvim_get_option('columns') * width_scale / 100)
  local nvim_width = vim.api.nvim_get_option('columns')
  local nvim_height = vim.api.nvim_get_option('lines')
  local row = math.ceil((nvim_height - height))
  local col = math.ceil((nvim_width - win_width) / 2)
  local results_win_opts = {
      relative = 'editor',
      width = win_width,
      height = height,
      anchor = 'NW',
      style = 'minimal',
      row = row,
      col = col
    }
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, results_win_opts)
  return buf, win
end

local function highlight_item(buf, lnum, hi)
  vim.api.nvim_buf_add_highlight(buf, FuzzyHi, hi, lnum, 0, -1)
end


--@param opts is a table with other optional configs
local function fuzzy(opts)
  assert(opts, 'you need to pass opts')
  assert(opts.handler, 'you need a handler after all')
  assert(opts.source, 'you need a source for fuzzy search')
  opts.sorter = opts.sorter or default_sorter(opts)
  -- TODO(amirreza): Add previewer function
  opts.prompt = opts.prompt or '> '
  opts.selection_highlight = opts.selection_highlight or 'StatusLine'
  opts.window = opts.window or {
    height = 100,
    width = 60
  }
  local results = resolve_source(opts.source)
  local selection = #results - 1
  local buf, _ = floating_win(#results+1, opts.window.width)
  vim.api.nvim_buf_set_option(buf, 'buftype', 'prompt')

  local function shift_selection(amount)
    local last_idx = #results -1
    selection = selection + amount
    if selection < 0 then
      selection = last_idx 
    end
    if selection > last_idx then
      selection = 0
    end
    vim.schedule(function()
      vim.api.nvim_buf_clear_namespace(buf, FuzzyHi, 0, -1)
      vim.api.nvim_buf_add_highlight(buf, FuzzyHi, opts.selection_highlight, selection, 0, -1)
    end)
  end

  local function exit()
    vim.api.nvim_buf_delete(buf, {force = true})
  end

  local function get_selection()
    return vim.api.nvim_buf_get_lines(buf, selection, selection+1, true)[1]
  end
  vim.fn.prompt_setprompt(buf, opts.prompt)

  autocmd('TextChangedI,TextChanged', '<buffer>', function()
    local query = vim.api.nvim_buf_get_lines(buf, -2, -1, false)[1]
    query = string.sub(query, #opts.prompt + 1, #query)
    results = opts.sorter(query, results)
    vim.api.nvim_buf_set_lines(buf, 0, -2, false, results)
    selection = #results -1
    highlight_item(buf, selection, opts.selection_highlight)
  end)
  map(buf, {
    ['n k'] = function()
      shift_selection(-1)
    end,
    ['n j'] = function()
      shift_selection(1)
    end,
    ['n q'] = function()
      exit()
    end,
    ['i <C-k>'] = function()
      shift_selection(-1)
    end,
    ['i <C-j>'] = function()
      shift_selection(1)
    end,
    ['i <C-p>'] = function()
      shift_selection(-1)
    end,
    ['i <C-n>'] = function()
      shift_selection(1)
    end,
    ['i <C-c>'] = function()
      exit()
    end,
    ['n <C-c>'] = function()
      exit()
    end,
    ['n <CR>'] = function()
      opts.handler(get_selection())
    end,
    ['i <CR>'] = function()
      opts.handler(get_selection())
    end
  })
end

fuzzy {
  source = vim.fn.getcompletion('', 'color'),
  handler = function(selection) 
    print(selection)
  end
}

return fuzzy
