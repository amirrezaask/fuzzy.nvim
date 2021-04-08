local Fuzzy = {}

local options = require'fuzzy.lib.options'

FUZZY_OPTS = FUZZY_OPTS or {}

FUZZY_DRAWER_HIGHLIGHT_GROUP = FUZZY_OPTS.hl_group or 'StatusLine'

local function __Fuzzy_handler()
  local line = CURRENT_FUZZY.drawer.get_output()
  CURRENT_FUZZY.__Fuzzy_close()
  CURRENT_FUZZY.handler(line)
end

local function __Fuzzy_close()
  vim.cmd [[ call feedkeys("\<C-c>") ]]
  vim.api.nvim_set_current_win(CURRENT_FUZZY.current_win)
  CURRENT_FUZZY.drawer:closer()
end

CURRENT_FUZZY = nil

local function __Fuzzy_updater()
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
  CURRENT_FUZZY.sorter = options.get_value(opts, 'sorter')
  CURRENT_FUZZY.current_win = vim.api.nvim_get_current_win()
  CURRENT_FUZZY.current_buf = vim.api.nvim_get_current_buf()
  CURRENT_FUZZY.drawer = options.get_value(opts, 'drawer')()

  CURRENT_FUZZY.__Fuzzy_handler = __Fuzzy_handler
  CURRENT_FUZZY.__Fuzzy_close = __Fuzzy_close
  CURRENT_FUZZY.__Fuzzy_updater = __Fuzzy_updater

  if type(opts.source) == 'function' then
    CURRENT_FUZZY.collection = opts.source()
  elseif type(opts.source) == 'table' then
    CURRENT_FUZZY.collection = opts.source
  end
  CURRENT_FUZZY.__Fuzzy_updater()
end

return Fuzzy
