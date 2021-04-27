# Goals
Simpler API, multiple mappings support [x], richer way to display items

```lua
source should return a list of result objects => 
{
    value = 'what to show in drawer and searched on', -- only this key is important and mandaatory
    icon = 'icon to show',
}

```
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
use { 'amirrezaask/fuzzy.nvim', requires={'amirrezaask/spawn.nvim'}}
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
Handler is a function that gets called with the selected_line when you hit <CR> in the fuzzy window.

## mappings
You can attach any mappings you want with `mappings` key in fuzzy.new like below
```lua
fuzzy.new {
    source = ...,
    sorter = ...,
    mappings = {
        ['<CR>'] = function()
            local selected_line = CURRENT_FUZZY:get_output()
            -- do anything you want
        end
    }
}

```
# Customization
## Settings
```lua
require'fuzzy'.setup {
  width = 60,
  height = 40,
  blacklist = {
    "vendor"
  },
  border = 'yes' -- can be 'no' as well
  location = loc.bottom_center,
  sorter = require'fuzzy.lib.sorter'.fzy -- Also fzf_native, fzy_native, string_distance are supported
  prompt = '> ',
  register = {
    some_custom_function = function() -- This function appears in complete menu when using :Fuzzy command.
    end
  }
}
```
## Custom Fuzzy usage
let's say you want to define a simple fuzzy search on a simple lua table.
```lua
  require'fuzzy.lib'.new {
    source = {
      'data1', ...
    },
    handler = function(data)
      print(data)
    end,
    -- Almost all the keys that are supported in setup function are valid here and will override the default one set by user.
  }

```
# Builtin functions
- find_files: find files in recursively
- interactive_file_finder: A simple file browser.
- cd: Change directory of neovim.
- grep: grep a string.
- buffer_lines: search in current buffer lines
- buffers: neovim buffers.
- colors: change neovim colorscheme.
- commands: Run neovim command.
- recent_files: Search through neovim recent files.
- history: Search through neovim commands.
- help: Search through neovim help tags.
- mappings: Search through registered keymappings.
- git_files: List of files in current git repo.
- git_commits: List commits in repo.
- git_bcommits: List of commits happend on current file.
- git_checkout: List of branches to checkout to.
- lsp_document_symbols: List of document symbols from LSP server.
- lsp_workspace_symbols: List of workspace symbols from LSP server.
- lsp_references: List of references to current at point symbol from LSP server.
- lsp_implementations: List of implementations of current at point interface from LSP server.
- lsp_definitions: List or jump to defintions of current symbol.

# Credits
- @tjdevries for awesome streams, plenary and telescope.nvim which I took multiple ideas from.
- @neovim for awesome editor we have.
