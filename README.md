# fuzzy.nvim
Fast, Simple, Powerfull fuzzy finder all in lua.

## Why another fuzzy finder ?
When I started this project the alternatives were fzf.vim which was in vimscript but I needed my fuzzy finder to be completely in Lua and also telescope.nvim in the early stages, my problem with telescope was that it was too complicated
 to use and customize and add custom functions, so i started this.
[Demo](https://www.youtube.com/watch?v=YCUSN59FBSY)

# Installation
## Packer.nvim
```lua
use { 'kyazdani42/nvim-web-devicons' } --Optional if you want icons, also you need to have a patched font, look at nvim-web-devicons README for information.
use { 'amirrezaask/fuzzy.nvim', requires={'nvim-lua/plenary.nvim'}}
```

# Terminology:
## Source:
source is either a function that returns a list of data that we are going to search or is simply just a lua table or a string which is a command that it's output will be used as a source.
- table
- function
- string ( system command )

## Sorter
Sorter is a function that gets our query and sorts the source data based on that.
- string_distance: levenshtein string distance, needs no dependency.
- fzy: uses fzy sorting algorithm, needs no dependency.
- fzy_native: uses fzy binary, needs fzy installed.
- fzf_native: uses fzf binary, needs fzf installed.

## Handler
handlers gets selected item and do smth with it, varies for each functionality.

# Customization
```lua
require'fuzzy.lib.options'.setup {
  width = 30,
  height = 100,
  blacklist = {
    "vendor"
  },
  location = loc.bottom_center,
  sorter = require'fuzzy.lib.sorter'.fzy -- Also fzf_native, fzy_native, string_distance are supported
  prompt = '> '
}
```


# Builtin functions

# Credits
- @tjdevries for awesome streams, plenary and telescope.nvim which I took multiple ideas from.
- @neovim for awesome editor we have.
