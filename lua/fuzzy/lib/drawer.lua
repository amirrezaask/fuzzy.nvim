-- Drawer
local floating = require('fuzzy.lib.floating')
local options = require('fuzzy.lib.options')
local set_mappings = require('fuzzy.lib.mappings')

local M = {}

function table.slice(tbl, first, last, step)
  local sliced = {}
  for i = first or 1, last or #tbl, step or 1 do
    sliced[#sliced + 1] = tbl[i]
  end
  return sliced
end
local function extract_filename(line)
  local splits = vim.split(line, ':')
  if #splits < 2 then
    return line
  end
  return splits[1]
end

function table.clone(original)
  return {unpack(original)}
end

local _mt = {}
function _mt:draw(collection)
  vim.api.nvim_buf_set_lines(self.buf, 0, -2, false, {})
  if not vim.api.nvim_buf_is_valid(self.buf) then
    return
  end
  if #collection == 0 then
    return
  end
  if #collection > self.win_height then
    collection = table.slice(collection, #collection - self.win_height + 2, #collection)
  end
  vim.schedule(function()
    vim.api.nvim_buf_set_lines(self.buf, 0, -2, false, collection)
  end)
  self._start_of_data = self.win_height - #collection
  if self._start_of_data < 1 then
    self._start_of_data = 1
  end
  self.sorted_collection = table.clone(collection) 
  if options.get_value(CurrentFuzzy(), 'icons') == 'yes' then
    collection = self:with_icons(self.sorted_collection)
  end 
  collection = self:fill(self.sorted_collection, self.win_height - 1)
  self.selected_line = self.win_height - 1
  self:update_selection()
end

function _mt:fill(collection, _height)
  for i = 1, #collection do
    if not collection[i] or collection[i] == '' then
      table.remove(collection, i)
    end
  end
  local to_add = _height - (#collection - 1)
  local new_collection = {}
  if to_add > 0 then
    for _ = 1, to_add do
      table.insert(new_collection, '')
    end
    for i = 1, #collection do
      table.insert(new_collection, collection[i])
    end
    return new_collection
  else
    return collection
  end
end
function _mt:selection_down()
  if self.selected_line < self.win_height - 1 then
    self.selected_line = self.selected_line + 1
  end
  self:update_selection()
end

function _mt:selection_up()
  if self.selected_line > self._start_of_data then
    self.selected_line = self.selected_line - 1
  end
  self:update_selection()
end
function _mt:update_selection()
  vim.schedule(function()
    vim.api.nvim_buf_clear_namespace(self.buf, self.FuzzyDrawerHighlight, 0, -1)
    if #vim.api.nvim_buf_get_lines(self.buf, 0, -1, false) < 2 then
      return
    end
    vim.api.nvim_buf_add_highlight(self.buf, self.FuzzyDrawerHighlight, 'Statusline', self.selected_line, 0, -1)
  end)
end

function _mt:get_output()
  local line = vim.api.nvim_buf_get_lines(self.buf, self.selected_line, self.selected_line + 1, false)[1]
  if self.has_icons then
    if string.byte(line, 4) == string.byte(' ', 1) then
      return string.sub(line, 5, #line)
    end
  end
  return line
end
function _mt:with_icons(collection)
  local has_icons, _ = pcall(require, 'nvim-web-devicons')
  if not has_icons then
    -- print('for having icon in drawer install `nvim-web-devicons`')
    return collection
  end
  local i = 1
  while i < #collection + 1 do
    if collection[i] ~= '' then
      local filename = extract_filename(collection[i])
      local icon, _ =
        require('nvim-web-devicons').get_icon(filename, string.match(filename, '%a+$'), { default = true })
      if icon ~= '' then
        collection[i] = icon .. ' ' .. collection[i]
      end
    end
    i = i + 1
  end
  self.has_icons = true
  return collection
end
function M.new(opts)
  opts = opts or {}
  opts.current_win = vim.api.nvim_get_current_win()
  CurrentFuzzy().current_win = vim.api.nvim_get_current_win()

  -- create windows and buffers
  local buf, win, closer = floating.floating_buffer(opts)
  local height = options.get_value(opts, 'height')
  local win_height = math.ceil(vim.api.nvim_get_option('lines') * height / 100)
  local FuzzyDrawerHighlight = vim.api.nvim_create_namespace('FuzzyDrawerHighlight')

  vim.cmd([[ startinsert! ]])

  -- set mappings
  set_mappings(buf)

  -- setup the prompt
  opts.prompt = opts.prompt or FUZZY_OPTS.prompt or '> '
  vim.fn.prompt_setprompt(buf, opts.prompt)

  vim.cmd([[ autocmd TextChangedI,TextChanged <buffer> lua CurrentFuzzy():updater() ]])
  _mt.__index = _mt
  return setmetatable({
    buf = buf,
    win = win,
    prompt = opts.prompt,
    win_height = win_height,
    closer = closer,
    _start_of_data = 1,
    selected_line = 1,
    FuzzyDrawerHighlight = FuzzyDrawerHighlight,
  }, _mt)
end

return M
