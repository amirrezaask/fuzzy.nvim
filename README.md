# Luzzy.nvim
Luzzy.nvim provides a simple mechanism and pipeline to create fuzzy matching in neovim.

# Terminology:
- Source: source is a function that returns a list of data that we are going to search.
- Drawer: Drawer handles the floating window and displaying of the data.
- Sorter: Sorter is a function that gets our input and sorts the source data based on that.
- Handler: handler varies for each function and handles final user choice.

# Source:
- Table: Fuzzy searching on a Lua table.
- Binary: Fuzzy can help you run system commands and capture the result and fuzzy search on it.

# Sorter:
- Levenshtein: Levenshtein sorter uses Levenshtein string distance algorithm with some help from NGram technique it would sort the list.
- FZF: Ultra fast, powered by black magic terminal fuzzy finder.
- Fzy: another terminal fuzzy finder.

# Commands
- Files
- Fd
- GFiles
- GGrep
- BLines
- Buffers
- Rg
- LspReferences
- LspWorkspaceSymbols
- LspDocumentSymbols
