local get_mapping = require('fuzzy.lib.options').get_mapping

local function default_mappings()
  local mappings = {}
  -- TODO(amirrreza): use default table in options instead of hardcoded
  mappings['<CR>']  = get_mapping(CurrentFuzzy(), '<CR>')
  mappings['<C-p>'] = get_mapping(CurrentFuzzy(), '<C-p>')
  mappings['<C-k>'] = get_mapping(CurrentFuzzy(), '<C-k>')
  mappings['<C-n>'] = get_mapping(CurrentFuzzy(), '<C-n>')
  mappings['<C-j>'] = get_mapping(CurrentFuzzy(), '<C-j>')
  mappings['<C-c>'] = get_mapping(CurrentFuzzy(), '<C-c>')
  mappings['<esc>'] = get_mapping(CurrentFuzzy(), '<esc>')
  mappings['<C-q>'] = get_mapping(CurrentFuzzy(), '<C-q>')
  if FUZZY_OPTS.mappings then
    for lhs, fn in pairs(FUZZY_OPTS.mappings) do
      mappings[lhs] = fn
    end
  end
  if CurrentFuzzy().mappings then
    for lhs, fn in pairs(CurrentFuzzy().mappings) do
      mappings[lhs] = fn
    end
  end
  return mappings
end

__FUZZY_FUNCTION_REGISTRY = {}

return function(buf)
  local mappings = default_mappings()
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
