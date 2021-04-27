local function default_mappings(mappings)
  mappings = mappings or {}
  if not mappings['<CR>'] then
    mappings['<CR>'] = function()
      local line = CurrentFuzzy():get_output()
      CurrentFuzzy():close()
      CurrentFuzzy().handler(line)
    end
  end
  if not mappings['<C-p>'] then
    mappings['<C-p>'] = function()
      CurrentFuzzy().drawer:selection_up()
    end
  end

  if not mappings['<C-k>'] then
    mappings['<C-k>'] = function()
      CurrentFuzzy().drawer:selection_up()
    end
  end

  if not mappings['<C-n>'] then
    mappings['<C-n>'] = function()
      CurrentFuzzy().drawer:selection_down()
    end
  end

  if not mappings['<C-j>'] then
    mappings['<C-j>'] = function()
      CurrentFuzzy().drawer:selection_down()
    end
  end

  if not mappings['<C-c>'] then
    mappings['<C-c>'] = function()
      CurrentFuzzy():close()
    end
  end

  if not mappings['<esc>'] then
    mappings['<esc>'] = function()
      CurrentFuzzy():close()
    end
  end
  if not mappings['<C-q>'] then
    mappings['<C-q>'] = function()
      CurrentFuzzy():set_qflist()
    end
  end
  return mappings
end

__FUZZY_FUNCTION_REGISTRY = {}
return function(buf, mappings)
  mappings = default_mappings(mappings)
  local counter = 0
  for key, handler in pairs(mappings) do
    key = vim.api.nvim_replace_termcodes(key, true, true, true)
    __FUZZY_FUNCTION_REGISTRY[string.format('%s', counter)] = function()
      handler()
    end
    local map_cmd = string.format('<cmd>lua __FUZZY_FUNCTION_REGISTRY["%s"]()<CR>', counter)
    vim.api.nvim_buf_set_keymap(buf, 'i', key, map_cmd, { noremap = true })
    counter = counter + 1
  end
end
