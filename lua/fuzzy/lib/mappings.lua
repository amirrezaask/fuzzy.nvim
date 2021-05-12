local defaults = require('fuzzy.lib.options').defaults

__FUZZY_FUNCTION_REGISTRY = {}

local function get_mappings()
  local opts = CurrentFuzzy()
  local mappings = defaults.mappings
  if FUZZY_OPTS.mappings then
    for mode, _ in pairs(FUZZY_OPTS.mappings) do
      if FUZZY_OPTS.mappings[mode] then
        for key, handler in pairs(FUZZY_OPTS.mappings[mode]) do
          mappings[mode][key] = handler
        end
      end
    end
  end
  if opts.mappings then
    for mode, _ in pairs(opts.mappings) do
      if opts.mappings[mode] then
        for key, handler in pairs(opts.mappings[mode]) do
          mappings[mode][key] = handler
        end
      end
    end
  end
  return mappings
end

return function(buf)
  local mappings = get_mappings()
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
