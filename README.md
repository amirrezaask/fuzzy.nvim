# Luzzy.nvim
All in lua fuzzy finder for neovim

# What is the difference with Fzf.vim, Fuzzy.nvim,...
Luzzy is written completely in lua and has no dependency to FZF or any other fuzzy finders.
Yet it's not as fast as FZF but I am working hard to smaller the speed gap.

# Algorithm
Currently we use levenshtein string distance algorithm to compare given query to 
collection we have and sort them, but first we run an NGram function on the collection data
to make computing string distance easier. We have two layers of cache on both NGram generation
and string distance computing to make Luzzy faster.

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
