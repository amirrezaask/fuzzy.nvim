return function(call_opts, key)
  local layers = {FUZZY_DEFAULTS, FUZZY_USER_DEFAULTS, call_opts}
  local value
  for _, layer in ipairs(layers) do
    if layer[key] then value = layer[key] end
  end
  return value
end
