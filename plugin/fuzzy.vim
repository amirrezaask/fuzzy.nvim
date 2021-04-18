function! s:fuzzy_complete(arg,line,pos)
  let l:funtions = luaeval('vim.tbl_keys(require("fuzzy"))')

  let list = [l:funtions]
  let l = split(a:line[:a:pos-1], '\%(\%(\%(^\|[^\\]\)\\\)\@<!\s\)\+', 1)
  let n = len(l) - index(l, 'Fuzzy') - 2

  if n == 0
    return join(list[0],"\n")
  endif

  if n == 1
    return join(list[1],"\n")
  endif

  if n > 1
    return join(list[1],"\n")
  endif
endfunction




command! -nargs=1 -complete=custom,s:fuzzy_complete Fuzzy lua require('fuzzy').<args>()
