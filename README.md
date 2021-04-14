# fuzzy.nvim
Fast, Simple, Powerfull fuzzy finder all in lua.

## Why another fuzzy finder ?
When I started this project the only alternative was fzf.vim which was in vimscript but I needed my fuzzy finder to be completely in Lua, this projects started as fzf.nvim
and then when I started implementing sorting algorithm in lua changed it to fuzzy.nvim.

# Demo
<div align="center">
    <a href="https://www.youtube.com/watch?v=YCUSN59FBSY">
    <img 
    src="https://img.youtube.com/vi/YCUSN59FBSY/0.jpg" 
    alt="Fuzzy.nvim demo" 
    style="width:100%;">
    </a>
</div>
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
