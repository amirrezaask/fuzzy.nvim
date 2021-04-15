return {
  quicksort = function (arr, l, h) 
    local function partition(t, low, high)
      local i = (low-1)
      local pivot = t[high]

      for j=low,high-1 do
        if t[j].score >= pivot.score then
          i = i+1
          t[i], t[j] = t[j], t[i]
        end
      end 
      t[i+1], t[high] = t[high], t[i+1]
      return (i+1)
    end

    local function table_with_size(size, default_value)
      local t = {}
      for i=1,size do
        table.insert(t, default_value)
      end
      return t
    end

    local size = h - l + 1
    local stack = table_with_size(size, 0) 

    local top = -1
    top = top + 1
    stack[top] = l 
    top = top + 1
    stack[top] = h 

    while top >= 0 do 
      h = stack[top] 
      top = top - 1
      l = stack[top] 
      top = top - 1
      local p = partition(arr, l, h ) 
      if p-1 > l then 
        top = top + 1
        stack[top] = l 
        top = top + 1
        stack[top] = p - 1
      end
      if p + 1 < h then 
        top = top + 1
        stack[top] = p + 1
        top = top + 1
        stack[top] = h 
      end
    end
    return arr
  end,
  open_file = function(filename)
    require'fuzzy.lib.helpers'.open_file_at(filename, 0)
  end,
  open_file_at = function(filename, line)
    vim.api.nvim_command(string.format('e +%s %s', line, filename))
  end,
  tbl_reverse = function(t)
    local new_t = {}
    local i = #t
    while i > 0 do
      table.insert(new_t, t[i])
      i = i-1
    end
    return new_t
end
}


