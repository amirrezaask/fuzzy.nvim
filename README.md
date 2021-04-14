# fuzzy.nvim
Fast, Simple, Powerfull fuzzy finder all in lua.

## Why another fuzzy finder ?
When I started this project the only alternative was fzf.vim which was in vimscript but I needed my fuzzy finder to be completely in Lua, this projects started as fzf.nvim
and then when I started implementing sorting algorithm in lua changed it to fuzzy.nvim.

# Demo
<iframe width="560" height="315" src="https://www.youtube.com/embed/YCUSN59FBSY" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
# Terminology:
- Source: source is either a function that returns a list of data that we are going to search or is simply just a lua table or a string which is a command that it's output will be used as a source.
- Sorter: Sorter is a function that gets our input and sorts the source data based on that.
- Handler: handler varies for each function and handles final user choice.

# Commands
- IFiles 
- Files 
- Grep 
- Commands 
- MRU 
- BLines 
- Cd 
- Help 
- GitFiles 
- GitGrep 
- GitCommits 
- GitBCommits 
- GitCheckout 
- Buffers 
- Rg 
- Colors 
- LspReferences 
- LspDocumentSymbols 
- LspWorkspaceSymbols
- LspCodeActions
- LspDefinitions


# Customization 

```lua
require'fuzzy.lib.options'.setup {
  width = 30,
  height = 100,
  blacklist = {
    "vendor"
  },
  location = loc.bottom_center, 
  sorter = require'fuzzy.lib.sorter'.fzy_native
  prompt = '> '
}
```
