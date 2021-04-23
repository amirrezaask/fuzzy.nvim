-- Drawer
local floating = require('fuzzy.lib.floating')
local options = require('fuzzy.lib.options')
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

function M.new(opts)
  opts = opts or {}
  opts.current_win = vim.api.nvim_get_current_win()
  CURRENT_FUZZY.current_win = vim.api.nvim_get_current_win()
  vim.cmd([[ startinsert! ]])
  if options.get_value(opts, 'title') then
    opts.title = options.get_value(opts, 'title')
  end
  local buf, win, closer = floating.floating_buffer(opts)
  local height = options.get_value(opts, 'height')
  local win_height = math.ceil(vim.api.nvim_get_option('lines') * height / 100)

  local FuzzyDrawerHighlight = vim.api.nvim_create_namespace('FuzzyDrawerHighlight')
  vim.api.nvim_win_set_option(win, 'concealcursor', 'nc')
  vim.api.nvim_buf_set_keymap(buf, 'i', '<C-p>', '<cmd> lua CURRENT_FUZZY.drawer:selection_up()<CR>', {})
  vim.api.nvim_buf_set_keymap(buf, 'i', '<C-k>', '<cmd> lua CURRENT_FUZZY.drawer:selection_up()<CR>', {})
  vim.api.nvim_buf_set_keymap(buf, 'i', '<C-n>', '<cmd> lua CURRENT_FUZZY.drawer:selection_down()<CR>', {})
  vim.api.nvim_buf_set_keymap(buf, 'i', '<C-j>', '<cmd> lua CURRENT_FUZZY.drawer:selection_down()<CR>', {})
  vim.api.nvim_buf_set_keymap(buf, 'i', '<CR>', '<cmd> lua CURRENT_FUZZY:__handler()<CR>', {})
  vim.api.nvim_buf_set_keymap(buf, 'i', '<esc>', '<cmd> lua CURRENT_FUZZY:__close()<CR>', {})
  vim.api.nvim_buf_set_keymap(buf, 'i', '<C-c>', '<cmd> lua CURRENT_FUZZY:__close()<CR>', {})
  vim.api.nvim_buf_set_keymap(buf, 'i', '<C-q>', '<cmd> lua CURRENT_FUZZY:__set_qflist()<CR>', {})

  opts.prompt = opts.prompt or FUZZY_OPTS.prompt or '> '
  vim.fn.prompt_setprompt(buf, opts.prompt)

  vim.cmd([[ highlight default link FuzzyNormal Normal ]])
  vim.cmd([[ highlight default link FuzzyBorderNormal Normal ]])
  vim.cmd([[ highlight default link FuzzySelection Visual ]])
  vim.cmd([[ highlight default link FuzzyMatching Special ]])

  vim.cmd([[ autocmd TextChangedI <buffer> lua CURRENT_FUZZY:__updater() ]])

  local function fill(collection, _height)
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
  return {
    buf = buf,
    win = win,
    prompt = opts.prompt,
    closer = closer,
    _start_of_data = 1,
    selected_line = 1,
    selection_down = function(self)
      if self.selected_line < win_height - 1 then
        self.selected_line = self.selected_line + 1
      end
      self:update_selection()
    end,
    selection_up = function(self)
      if self.selected_line > self._start_of_data then
        self.selected_line = self.selected_line - 1
      end
      self:update_selection()
    end,
    update_selection = function(self)
      vim.schedule(function()
        vim.api.nvim_buf_clear_namespace(self.buf, FuzzyDrawerHighlight, 0, -1)
        if #vim.api.nvim_buf_get_lines(buf, 0, -1, false) < 2 then
          return
        end
        vim.api.nvim_buf_add_highlight(buf, FuzzyDrawerHighlight, 'Statusline', self.selected_line, 0, -1)
      end)
    end,
    get_output = function(self)
      local line = vim.api.nvim_buf_get_lines(
        CURRENT_FUZZY.buf,
        CURRENT_FUZZY.drawer.selected_line,
        CURRENT_FUZZY.drawer.selected_line + 1,
        false
      )[1]
      if string.byte(line, 4) == string.byte(' ', 1) then
        return string.sub(line, 5, #line)
      end
      return line
    end,
    with_icons = function(collection)
      local has_icons, _ = pcall(require, 'nvim-web-devicons')
      if not has_icons then
        print('for having icon in drawer install `nvim-web-devicons`')
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
      return collection
    end,
    draw = function(self, collection)
      vim.api.nvim_buf_set_lines(buf, 0, -2, false, {})
      if not vim.api.nvim_buf_is_valid(buf) then
        return
      end
      if #collection == 0 then
        return
      end
      if #collection > win_height then
        collection = table.slice(collection, #collection - win_height + 2, #collection)
      end
      vim.schedule(function()
        vim.api.nvim_buf_set_lines(buf, 0, -2, false, collection)
      end)
      self._start_of_data = win_height - #collection
      if self._start_of_data < 1 then
        self._start_of_data = 1
      end
      self.sorted_collection = collection
      collection = self.with_icons(collection)
      collection = fill(collection, win_height - 1)
      self.selected_line = win_height - 1
      self:update_selection()
    end,
  }
end

return M
