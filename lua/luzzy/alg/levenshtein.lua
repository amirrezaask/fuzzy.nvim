local function ngrams_of(s, n)
  n = n or 3
  local ngrams = {}

  for i=1,#s do
    local last = i+n-1
    if last >= #s then
      last = #s
    end
    local this_ngram = string.sub(s, i, last)    
    table.insert(ngrams, this_ngram)
  end
  return ngrams
end


local function levenshtein_distance(str1, str2)
    local len1, len2 = #str1, #str2
    local char1, char2, distance = {}, {}, {}
    str1:gsub('.', function (c) table.insert(char1, c) end)
    str2:gsub('.', function (c) table.insert(char2, c) end)
    for i = 0, len1 do distance[i] = {} end
    for i = 0, len1 do distance[i][0] = i end
    for i = 0, len2 do distance[0][i] = i end
    for i = 1, len1 do
        for j = 1, len2 do
            distance[i][j] = math.min(
                distance[i-1][j  ] + 1,
                distance[i  ][j-1] + 1,
                distance[i-1][j-1] + (char1[i] == char2[j] and 0 or 1)
                )
        end
    end
    return distance[len1][len2]
end

local function sort(list)
  table.sort(list, function(l1, l2) return l1.score > l2.score end) 
  return list
end

local function match(str, collection)
  local list = {}
  for i=1,#collection do
    if str == nil or collection[i] == nil then
      goto continue
    end
    local ngrams = ngrams_of(collection[i], 5)
    local min_distance_of_ngrams = 100000
    for _, n in ipairs(ngrams) do
      local distance = levenshtein_distance(str, n)
      if distance < min_distance_of_ngrams then
        min_distance_of_ngrams = distance
      end
    end
    local word_score = {score=min_distance_of_ngrams, word=collection[i]}
    table.insert(list, word_score)
    ::continue::
  end
  local output = {}
  list = sort(list)
  for _, v in ipairs(list) do
    table.insert(output, v.word) 
  end
  return output 
end

-- local list = match('tmp 123', {'./tmp', './tmp/123', './tmp/456'})
-- for i=1,#list do
--   print(list[i].word)
--   print(list[i].score)
-- end

return match

