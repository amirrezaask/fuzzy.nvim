# fuzzy.nvim
fuzzy.nvim provides a simple mechanism and pipeline to create fuzzy matching in neovim.

# Terminology:
- Source: source is either a function that returns a list of data that we are going to search or is simply just a lua table.
- Drawer: Drawer handles the floating window and displaying of the data.
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
- You can set window location and geometry using the `g:fuzzy_options` variable :
  - location can be `center`, `bottom` or a function with `win_width`(width of the floating window) and`win_height`(height of the floating window) as arguments returning the location of the NE corner of the floating window
  - Width and height are in percent of the main window

```lua
require'fuzzy.lib.options'.setup {
  width = 30,
  height = 100,
  blacklist = {
    "vendor"
  },
  location = loc.bottom_center, 
  prompt = '> '
}
```
