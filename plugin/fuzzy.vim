command! IFiles lua require('fuzzy').interactive_finder{} 
command! Files lua require('fuzzy').file_finder{} 
command! Grep lua require('fuzzy').grep{} 
command! Commands lua require('fuzzy').commands{} 
command! MRU lua require('fuzzy').mru{} 
command! BLines lua require('fuzzy').buffer_lines{} 
command! Cd lua require('fuzzy').cd{} 
command! Help lua require('fuzzy').help{} 
command! Maps lua require('fuzzy').mappings{} 
command! GitFiles lua require('fuzzy.git').git_files{} 
command! GitGrep lua require('fuzzy.git').git_grep{} 
command! GitCommits lua require('fuzzy.git').git_commits{} 
command! GitBCommits lua require('fuzzy.git').git_bcommits{} 
command! GitCheckout lua require('fuzzy.git').git_checkout{} 
command! Buffers lua require('fuzzy').buffers{} 
command! Rg lua require('fuzzy').rg{} 
command! Colors lua require('fuzzy').colors{} 
command! LspReferences lua require('fuzzy.lsp').lsp_references{} 
command! LspDefinitions lua require('fuzzy.lsp').definitions{} 
command! LspCodeActions lua require('fuzzy.lsp').code_actions{} 
command! LspDocumentSymbols lua require('fuzzy.lsp').lsp_document_symbols{} 
command! LspWorkspaceSymbols lua require('fuzzy.lsp').lsp_workspace_symbols{} 


