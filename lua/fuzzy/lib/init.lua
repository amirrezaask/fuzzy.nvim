local sorters = require('fuzzy.lib.sorter')
local FuzzyHi = vim.api.nvim_create_namespace('FuzzyHi')
local config = require('fuzzy.lib.config')

function table.clone(original)
  return {unpack(original)}
end

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
    local cmd = vim.split(source, ' ')[1]
    local args = vim.split(source, ' ')
    table.remove(args, 1)
    return require('fuzzy.lib.source.binary')(cmd, args)()
  elseif type(source) == 'table' then
    return source
  elseif type(source) == 'function' then
    return source()
  end
end

local function executable_exists(name)
  return vim.fn.executable(name) ~= 0
end

local function default_sorter()
  if executable_exists('fzf') then
    return sorters.fzf_native
  elseif executable_exists('fzy') then
    return sorters.fzy_native
  else
    return sorters.string_distance 
  end
end

--@param height is a number that is the height of floating window, it is absolute cause it is the lenght of our original results 
--@param width_scale is a number that is the percentage of neovim width
--@returns bufnr, winid
local function floating_win(height, width_scale)
  local MIN_H = 3
  local win_width = math.ceil(vim.api.nvim_get_option('columns') * width_scale / 100)
  local nvim_width = vim.api.nvim_get_option('columns')
  local nvim_height = vim.api.nvim_get_option('lines')
  height = math.min(height, nvim_height)
  if height < MIN_H then height = nvim_height end
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
  -- vim.api.nvim_win_set_option(win, 'winhl', 'Normal:FuzzyNormal')
  return buf, win
end

local function exit_insert()
  vim.cmd [[ silent call feedkeys("\<esc>") ]]
end

local function resize_window(win, new_height)
  local current_config = vim.api.nvim_win_get_config(win)
  local nvim_width = vim.api.nvim_get_option('columns')
  local nvim_height = vim.api.nvim_get_option('lines')
  local row = math.ceil((nvim_height - new_height))
  local col = math.ceil((nvim_width - current_config.width) / 2)
  current_config.height = new_height
  current_config.row = row
  current_config.col = col
  vim.api.nvim_win_set_config(win, current_config)
end

--@param opts is a table 
--@param opts.source look into resolve_source
--@param opts.handler function
local function fuzzy(opts)
  assert(opts, 'you need to pass opts')
  assert(opts.handler, 'you need a handler after all')
  assert(opts.source, 'you need a source for fuzzy search')
  -- TODO(amirreza): maybe use config ?
  opts.sorter = opts.sorter or default_sorter()

  -- TODO(amirreza): Add previewer function
  opts.prompt = config(opts, 'prompt')
  opts.selection_highlight = config(opts, 'selection_highlight')
  opts.window = config(opts, 'window')
  local results = resolve_source(opts.source)
  local selection = #results
  local original_results = table.clone(results)
  local buf, win = floating_win(#results+1, opts.window.width)
  vim.api.nvim_buf_set_option(buf, 'buftype', 'prompt')
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')

  local function get_query()
    local query = vim.api.nvim_buf_get_lines(buf, -2, -1, false)[1]
    query = string.sub(query, #opts.prompt + 1, #query)
    return query
  end

  local function set_selection(line, col, move_cursor)
    if move_cursor == nil then
      move_cursor = true
    end
    if not col then col = #opts.prompt + #(get_query()) end
    if line == -1 then
      line = vim.api.nvim_buf_line_count(buf) - 1
    end
    if line <= 0 then
      line = 1
    end
    local ll = vim.api.nvim_buf_line_count(buf) - 1
    --TODO(amirreza): fix this!!
    if math.abs(line - ll) >= vim.api.nvim_win_get_height(win) then
      exit_insert()
    end
    selection = line - 1 -- fucking idxs everywhere
    vim.schedule(function()
      vim.api.nvim_buf_clear_namespace(buf, FuzzyHi, 0, -1)
      vim.api.nvim_buf_add_highlight(buf, FuzzyHi, opts.selection_highlight, selection, 0, -1)
    end)
    if move_cursor then
      vim.api.nvim_win_set_cursor(win, {line, col})
    end
  end

  local function shift_selection(amount, move_cursor)
    local current = vim.api.nvim_win_get_cursor(win)[1]
    if current ~= selection + 1 then
      current = selection + 1
    end
    current = current + amount
    local last_idx = vim.api.nvim_buf_line_count(buf) - 1
    if current == 0 then
      current = last_idx
    end
    if current > last_idx then
      current = 1
    end
    set_selection(current, move_cursor)
  end

  local function exit()
    vim.api.nvim_buf_delete(buf, {force = true})
  end

  local function get_selected()
    return vim.api.nvim_buf_get_lines(buf, selection, selection+1, false)[1]
  end
  vim.fn.prompt_setprompt(buf, opts.prompt)

  autocmd('TextChangedI,TextChanged', '<buffer>', function()
    local query = get_query()
    results = opts.sorter(query, original_results)
    resize_window(win, #results+1)
    vim.api.nvim_buf_set_lines(buf, 0, -2, false, results)
    set_selection(-1, #query+#opts.prompt+1)
  end)

  autocmd('BufLeave', '<buffer>', function()
    exit_insert()
  end)

  autocmd('BufEnter', '<buffer>', function()
   vim.cmd [[ startinsert! ]] 
  end)

  autocmd('CursorMoved', '<buffer>', function()
    local cursor_line = vim.api.nvim_win_get_cursor(win)[1]
    set_selection(cursor_line, #opts.prompt+#(get_query())+1, false)
  end)

  vim.cmd [[ startinsert! ]]
  -- TODO(amirreza): mappings should come from config
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
    ['n <C-c>'] = function()
      exit()
    end,
    ['n <CR>'] = function()
      local line = get_selected()
      exit()
      exit_insert()
      opts.handler(line)
    end,
    -- ['i <C-n>'] = function()
    --   shift_selection(1, false)
    -- end,
    -- ['i <C-p>'] = function()
    --   shift_selection(-1, false)
    -- end,
    -- ['i <C-j>'] = function()
    --   shift_selection(1, false)
    -- end,
    -- ['i <C-k>'] = function()
    --   shift_selection(-1, false)
    -- end,
    ['i <CR>'] = function()
      local line = get_selected()
      exit()
      exit_insert()
      opts.handler(line)
    end
  })
end

return fuzzy
