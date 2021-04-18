local files = require('fuzzy.files')
local search = require('fuzzy.search')
local lsp = require('fuzzy.lsp')
local vim = require('fuzzy.vim')
local git = require('fuzzy.git')

local Fuzzy = {}

Fuzzy.find_files = files.find_files
Fuzzy.interactive_file_finder = files.interactive_finder
Fuzzy.cd = files.cd
Fuzzy.grep = search.grep
Fuzzy.buffer_lines = search.buffer_lines
Fuzzy.buffers = vim.buffers
Fuzzy.colors = vim.colors
Fuzzy.commands = vim.commands
Fuzzy.recent_files = vim.mru
Fuzzy.history = vim.history
Fuzzy.help = vim.help
Fuzzy.mappings = vim.mappings
Fuzzy.projects = vim.projects
Fuzzy.git_files = git.git_files
Fuzzy.git_commits = git.git_files
Fuzzy.git_files = git.git_files
Fuzzy.git_bcommits = git.git_bcommits
Fuzzy.git_checkout = git.git_checkout
Fuzzy.lsp_document_symbols = lsp.document_symbols
Fuzzy.lsp_workspace_symbols = lsp.workspace_symbols
Fuzzy.lsp_references = lsp.references
Fuzzy.lsp_implementations = lsp.implementation
Fuzzy.lsp_definitions = lsp.definitions

return Fuzzy
