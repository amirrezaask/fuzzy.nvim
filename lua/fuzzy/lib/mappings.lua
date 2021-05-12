local get_mapping = require('fuzzy.lib.options').get_mapping

local function all_mappings()
  local mappings = {}
  -- TODO(amirrreza): use default table in options instead of hardcoded
  mappings.i = {
    ['<CR>']  = get_mapping(CurrentFuzzy(), 'i', '<CR>'),
    ['<C-p>'] = get_mapping(CurrentFuzzy(), 'i', '<C-p>'),
    ['<C-k>'] = get_mapping(CurrentFuzzy(), 'i', '<C-k>'),
    ['<C-n>'] = get_mapping(CurrentFuzzy(), 'i', '<C-n>'),
    ['<C-j>'] = get_mapping(CurrentFuzzy(), 'i', '<C-j>'),
    ['<C-c>'] = get_mapping(CurrentFuzzy(), 'i', '<C-c>'),
    ['<C-q>'] = get_mapping(CurrentFuzzy(), 'i', '<C-q>'),
  }
  mappings.n = {
    ['j'] = get_mapping(CurrentFuzzy(), 'n', 'j'),
    ['k'] = get_mapping(CurrentFuzzy(), 'n', 'k'),
  }
  -- mappings['<esc>'] = get_mapping(CurrentFuzzy(), '<esc>')
  if FUZZY_OPTS.mappings and FUZZY_OPTS.mappings.i then
    for lhs, fn in pairs(FUZZY_OPTS.mappings.i) do
      mappings.i[lhs] = fn
    end
  end
  if CurrentFuzzy().mappings and CurrentFuzzy().mappings.i then
    for lhs, fn in pairs(CurrentFuzzy().mappings.i) do
      mappings.i[lhs] = fn
    end
  end
  return mappings
end

__FUZZY_FUNCTION_REGISTRY = {}

return function(buf)
  local mappings = all_mappings()
  local counter = 0
  for mode, _ in pairs(mappings) do
    for key, handler in pairs(mappings[mode]) do
      key = vim.api.nvim_replace_termcodes(key, true, true, true)
      __FUZZY_FUNCTION_REGISTRY[string.format('%s', counter)] = function()
        handler()
      end
      local map_cmd = string.format('<cmd>lua __FUZZY_FUNCTION_REGISTRY["%s"]()<CR>', counter)
      vim.api.nvim_buf_set_keymap(buf, mode, key, map_cmd, { noremap = true })
      counter = counter + 1
    end
  end
end
