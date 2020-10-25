# Fuzzy.nvim
Fuzzy.nvim provides a simple mechanism and pipeline to create fuzzy matching in neovim.

# Terminology:
- Source: source is a function that returns a list of data that we are going to search.
- Drawer: Drawer handles the floating window and displaying of the data.
- Sorter: Sorter is a function that gets our input and sorts the source data based on that.
- Handler: handler varies for each function and handles final user choice.
- TerminalFuzzy: If you want pure terminal interface like FZF itself use TerminalFuzzy.

# Source:
- Table: Fuzzy searching on a Lua table.
- Binary: Fuzzy can help you run system commands and capture the result and fuzzy search on it.

# Sorter:
- Levenshtein: Levenshtein sorter uses Levenshtein string distance algorithm with some help from NGram technique it would sort the list.
- FZF: Ultra fast, powered by black magic terminal fuzzy finder.
- Fzy: another terminal fuzzy finder.


# Commands
- Files => Using a luv (libuv bindings for lua) file operations.
- Grep => Using luv for reading files and matching text in them. 
- Find => using find program in Unix environments.
- Fd => using fd program 
- GFiles => Git files.
- GGrep => Git grep.
- BLines => current buffer lines.
- Buffers => all buffers.
- Rg => Rg greping.
- LspReferences
- LspWorkspaceSymbols
- LspDocumentSymbols

# Options
- You can set window location and geometry using the `g:fuzzy_options` variable :
  - location can be `center`, `bottom` or a function with `win_width`(width of the floating window) and`win_height`(height of the floating window) as arguments returning the location of the NE corner of the floating window
  - Width and height are in percent of the main window
```lua
lua << EOF
  vim.g.fuzzy_options = {
    location = "center",
    width = 50,
    height = 50
  }
EOF
```
