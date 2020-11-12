# Fuzzy.nvim
Fuzzy.nvim provides a simple mechanism and pipeline to create fuzzy matching in neovim.

# Example Usage
```lua
-- Find files interactively ( using Libuv )
require('fuzzy').interactive_finder{}

-- Find files recursively ( using Libuv )
require('fuzzy').file_finder{}

-- Search for text ( using Libuv )
require('fuzzy').grep{}

-- Search current buffer
require('fuzzy').buffer_lines{}

-- Search in recent files (file history)
require('fuzzy').recents{}

-- Search in commands
require('fuzzy').commands{}

-- Search in command history
require('fuzzy').history{}

-- Switch to any open buffer
require('fuzzy').buffers{}

-- Search LSP docuemnt symbols
require('fuzzy').lsp_document_symbols{}

-- Search LSP workspace symbols
require('fuzzy').lsp_workspace_symbols{}

```

# Terminology:
- Source: source is a function that returns a list of data that we are going to search.
- Drawer: Drawer handles the floating window and displaying of the data.
- Sorter: Sorter is a function that gets our input and sorts the source data based on that.
- Handler: handler varies for each function and handles final user choice.

# Commands
- Files
- Grep
- Commands
- Recents
- Cd
- GFiles
- GGrep
- BLines
- Buffers
- Rg
- LspReferences
- LspWorkspaceSymbols
- LspDocumentSymbols

# Customization 
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
