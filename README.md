# fuzzy.nvim
Fast, Simple, Powerfull fuzzy finder all in lua.

## Why another fuzzy finder ?
When I started this project the only alternative was fzf.vim which was in vimscript but I needed my fuzzy finder to be completely in Lua, this projects started as fzf.nvim
and then when I started implementing sorting algorithm in lua changed it to fuzzy.nvim.
[Demo](https://www.youtube.com/watch?v=YCUSN59FBSY)

# Installation
## Packer.nvim
```lua
use { 'amirrezaask/fuzzy.nvim', requires={'nvim-lua/plenary.nvim', 'kyazdani42/nvim-web-devicons'}}
```
# Terminology:
## Source:
source is either a function that returns a list of data that we are going to search or is simply just a lua table or a string which is a command that it's output will be used as a source.
- table
- function
- string ( system command )

## Sorter
Sorter is a function that gets our query and sorts the source data based on that.
- string_distance: ( levenshtein string distance ), needs no dependency
- fzy: uses fzy sorting algorith
- fzy_native: uses fzy binary
- fzf_native: uses fzf binary
## Handler
handlers gets selected item and handles it, varies for each functionality.

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
  sorter = require'fuzzy.lib.sorter'.fzf -- Also fzy, fzy_native, string_distance are supported
  prompt = '> '
}
```

# Credits
- @tjdevries for awesome streams, plenary and telescope.nvim which I took multiple ideas from.
- @neovim for awesome editor we have.
