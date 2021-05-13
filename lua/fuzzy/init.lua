local files = require('fuzzy.files')
local search = require('fuzzy.search')
local lsp = require('fuzzy.lsp')
local vim = require('fuzzy.vim')
local git = require('fuzzy.git')

local fuzzy = {}
fuzzy.find_files = files.find_files
fuzzy.interactive_file_finder = files.interactive_finder
fuzzy.cd = files.cd
fuzzy.find_repo = files.find_repo
fuzzy.grep = search.grep
fuzzy.rg = search.rg
fuzzy.buffer_lines = search.buffer_lines
fuzzy.buffers = vim.buffers
fuzzy.colors = vim.colors
fuzzy.commands = vim.commands
fuzzy.recent_files = vim.mru
fuzzy.history = vim.history
fuzzy.help = vim.help
fuzzy.mappings = vim.mappings
fuzzy.git_commits = git.git_commits
fuzzy.git_files = git.git_files
fuzzy.git_bcommits = git.git_bcommits
fuzzy.git_checkout = git.git_checkout
fuzzy.lsp_document_symbols = lsp.document_symbols
fuzzy.lsp_workspace_symbols = lsp.workspace_symbols
fuzzy.lsp_references = lsp.references
fuzzy.lsp_implementations = lsp.implementation
fuzzy.lsp_definitions = lsp.definitions
return setmetatable(fuzzy, {
  __call = function(...)
    return require('fuzzy.lib')(...)
  end
})
