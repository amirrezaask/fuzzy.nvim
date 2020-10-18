local uv = vim.loop
local floating = require'luzzy.floating'
local lev = require'luzzy.alg.levenshtein'
local location = require'luzzy.location'
local helpers = require('luzzy.helpers')
local Luzzy = {}

local current_luzzy = nil

local LuzzyHighlight = vim.api.nvim_create_namespace('LuzzyHighlight')

function __Luzzy_updater()
  current_luzzy:updater()
end

function __Luzzy_callback()
  local line = vim.api.nvim_buf_get_lines(current_luzzy.buf, current_luzzy.selected_line, current_luzzy.selected_line+1, false)[1]
  vim.api.nvim_set_current_win(current_luzzy.current_win)
  vim.cmd [[ call feedkeys("\<C-c>") ]]
  current_luzzy.closer()
  current_luzzy.callback(line)
end

function __Luzzy_highlight(buf, line)
  vim.api.nvim_buf_add_highlight(buf, LuzzyHighlight, 'Error', line, 0, -1)
end

function __Luzzy_updater()
  vim.schedule(function()
    if not vim.api.nvim_buf_is_valid(current_luzzy.buf) then
      return
    end
    local new_input = vim.api.nvim_buf_get_lines(current_luzzy.buf, -2, -1, false)[1]
    if new_input == current_luzzy.input then
      return
    end
    current_luzzy.input = new_input
    current_luzzy.collection = current_luzzy.alg(current_luzzy.input, current_luzzy.collection)
  end)  
  __Luzzy_drawer()
end

function __Luzzy_drawer()
  vim.schedule(function()
    if not vim.api.nvim_buf_is_valid(current_luzzy.buf) then
      return
    end
    vim.api.nvim_buf_set_lines(current_luzzy.buf, 0, -2, false, current_luzzy.collection)
    if current_luzzy.selected_line == -1 then
      current_luzzy.selected_line = #current_luzzy.collection -1
    end
    __Luzzy_highlight(current_luzzy.buf, current_luzzy.selected_line)
    if current_luzzy.drawer ~= nil then
      current_luzzy:drawer()
    end
  end)
end

function __Luzzy_prev_line()
  local lines = vim.api.nvim_buf_get_lines(current_luzzy.buf, 0, -1, false)
  current_luzzy.selected_line = current_luzzy.selected_line - 1
  if current_luzzy.selected_line < 0 then
   current_luzzy.selected_line = #lines-2 
  end
  vim.api.nvim_buf_clear_namespace(current_luzzy.buf, LuzzyHighlight, 0, -1)
  __Luzzy_highlight(current_luzzy.buf, current_luzzy.selected_line) 
end

function __Luzzy_next_line()
  local lines = vim.api.nvim_buf_get_lines(current_luzzy.buf, 0, -1, false)
  current_luzzy.selected_line = current_luzzy.selected_line + 1
  if current_luzzy.selected_line >= #lines-1 then
   current_luzzy.selected_line = 0
  end
  vim.api.nvim_buf_clear_namespace(current_luzzy.buf, LuzzyHighlight, 0, -1)
  __Luzzy_highlight(current_luzzy.buf, current_luzzy.selected_line) 
end
function __Luzzy_close()
  vim.cmd [[ call feedkeys("\<C-c>") ]]
  vim.api.nvim_set_current_win(current_luzzy.current_win)
  current_luzzy.closer()
end


function Luzzy.new(opts)
  local stdout = uv.new_pipe(false)
  local stderr = uv.new_pipe(false)
  opts.input = ''
  opts.alg = opts.alg or lev
  opts.selected_line = -1
  vim.schedule(function()
    opts.current_win = vim.api.nvim_get_current_win()
    vim.cmd [[ startinsert! ]]
    local buf, win, _, _, closer = floating.floating_buffer(0.6, location.center)
    opts.buf = buf
    opts.win = win
    opts.closer = closer
    vim.cmd([[ autocmd TextChangedI <buffer> lua __Luzzy_updater() ]])
    vim.api.nvim_buf_set_keymap(buf, 'i', '<C-p>', '<cmd> lua __Luzzy_prev_line()<CR>', {})
    vim.api.nvim_buf_set_keymap(buf, 'i', '<C-n>', '<cmd> lua __Luzzy_next_line()<CR>', {})
    vim.api.nvim_buf_set_keymap(buf, 'i', '<C-j>', '<cmd> lua __Luzzy_next_line()<CR>', {})
    vim.api.nvim_buf_set_keymap(buf, 'i', '<C-k>', '<cmd> lua __Luzzy_prev_line()<CR>', {})
    vim.api.nvim_buf_set_keymap(buf, 'i', '<CR>', '<cmd> lua __Luzzy_callback()<CR>', {})
    vim.api.nvim_buf_set_keymap(buf, 'i', '<C-c>', '<cmd> lua __Luzzy_close()<CR>', {})
    vim.api.nvim_buf_set_keymap(buf, 'i', '<esc>', '<cmd> lua __Luzzy_close()<CR>', {})
  end)
  opts.collection = opts.collection or {}
  if #opts.collection == 0 then
    if not opts.bin then
      return 
    end
    uv.spawn(opts.bin, {args=opts.args, stdio={_, stdout, stderr}}, function(code, signal)
      if code ~= 0 then
        print(string.format('process exited with %s and %s', code, signal))
        stdout:read_stop()
        stderr:read_stop()
        stdout:close()
        stderr:close()
      end
    end)
    uv.read_start(stdout, function(err, data)
      if err then
        print(err)
        return
      end
      if data then
        for _, d in ipairs(vim.split(data, '\n')) do
          if d == "" then goto continue end
          table.insert(opts.collection, d)
          ::continue::
        end
        __Luzzy_updater()
      end
    end)
    uv.read_start(stderr, function(err, data)
      if err then
        print(err)
      end
      if data then
        print(data)
      end
    end)
  else
    __Luzzy_updater()
  end
  current_luzzy = opts
end

return {
  current = current_luzzy,
  Luzzy = Luzzy,
}
