local Fuzzy = {}

FUZZY_OPTS = vim.g.fuzzy_options or {}

FUZZY_DRAWER_HIGHLIGHT_GROUP = FUZZY_OPTS.hl_group or 'StatusLine'

function __Fuzzy_handler()
  -- gets output, closes drawer, runs the handler
  local line = CURRENT_FUZZY.drawer.get_output()
  __Fuzzy_close()
  CURRENT_FUZZY.handler(line)
end

function __Fuzzy_close()
  vim.cmd [[ call feedkeys("\<C-c>") ]]
  -- CURRENT_FUZZY.on_exit()
  vim.api.nvim_set_current_win(CURRENT_FUZZY.current_win)
  CURRENT_FUZZY.drawer:closer()
end

CURRENT_FUZZY = nil

function __Fuzzy_updater()
  if CURRENT_FUZZY.sorter then
    local new_input = vim.api.nvim_buf_get_lines(CURRENT_FUZZY.buf, -2, -1, false)[1]
    new_input = string.sub(new_input, #CURRENT_FUZZY.drawer.prompt+1, #new_input)
    if new_input == CURRENT_FUZZY.input then
      return
    end
  CURRENT_FUZZY.input = new_input
  end
  if not vim.api.nvim_buf_is_valid(CURRENT_FUZZY.buf) then
    return
  end
  if CURRENT_FUZZY.sorter then
    CURRENT_FUZZY.collection = CURRENT_FUZZY.sorter(CURRENT_FUZZY.input, CURRENT_FUZZY.collection)
  end
  if CURRENT_FUZZY.sorter then
    CURRENT_FUZZY.drawer:draw(CURRENT_FUZZY.collection)
  end
end

function Fuzzy.new(opts)
  CURRENT_FUZZY = opts
  if type(opts.source) == 'function' then
    CURRENT_FUZZY.collection = opts.source()
  elseif type(opts.source) == 'table' then
    CURRENT_FUZZY.collection = opts.source
  end
  __Fuzzy_updater()
end

return Fuzzy
