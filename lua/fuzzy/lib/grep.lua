-- Grep replacement in Lua
local uv = vim.loop

local G = {}

function G.read_file(file)
  local fd = uv.fs_open(file, 'r', 438)  
  if fd == nil then
    print(string.format('can\'t read the file: %s', file))
    return
  end

  local stat = uv.fs_fstat(fd)
  if stat == nil then
    print(string.format('can\'t stat the file: %s', file))
    return
  end

  local data = uv.fs_read(fd, stat.size, 0)
  if data == nil then
    print(string.format('can\'t get data of the file: %s', file))
    return
  end
  uv.fs_close(fd)
  return data
end
GREP_FILE_THRESHOLD = 500
local function grep_file(file, pattern, output)
  CURRENT_FUZZY.__grep_cache = CURRENT_FUZZY.__grep_cache or {}
  local text = CURRENT_FUZZY.__grep_cache[file]
  if not text then
    text = G.read_file(file)
    CURRENT_FUZZY.__grep_cache[file] = text
  end
  for i, t in ipairs(vim.split(text, '\n')) do
    if #output == GREP_FILE_THRESHOLD then
      return 
    end
    if pattern == '' then
      table.insert(output, string.format('%s:%s:%s',file, i, t))
      goto continue
    end
    local res = t:find(pattern)
    if res ~= nil then
      table.insert(output, string.format('%s:%s:%s',file, i, t)) 
    end
    ::continue::
  end
end

function G.grep(files, pattern)
  local matched = {}
  for _, f in ipairs(files) do
    grep_file(f, pattern, matched)
  end
  return matched
end

return G

