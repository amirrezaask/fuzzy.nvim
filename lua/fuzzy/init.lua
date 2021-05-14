local files = require('fuzzy.files')
local search = require('fuzzy.search')
local lsp = require('fuzzy.lsp')
local vim = require('fuzzy.vim')
local git = require('fuzzy.git')

local fuzzy = {}
FUZZY_USER_DEFAULTS = nil
FUZZY_DEFAULTS = {
  -- location = loc.bottom_center,
  window = {
    width = 40,
    height = 100,
  },
  blacklist = {
    '.git',
  },
  icons = 'yes',
  prompt = '> ',
  sorter = require('fuzzy.lib.sorter').fzy,
  no_luv_finder = false,
  border = 'yes',
  highlight_matches = 'yes',
  selection_highlight = 'StatusLine'
}

function fuzzy.setup(opts)
  FUZZY_USER_DEFAULTS = opts
  fuzzy.find_files = files.find_files
  fuzzy.interactive_file_finder = files.interactive_finder
  fuzzy.cd = files.cd
  fuzzy.find_repo = files.find_repo
  fuzzy.grep = search.grep
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
  if opts.register then
    for n, f in pairs(opts.register) do
      fuzzy[n] = f
    end
  end
end

return setmetatable(fuzzy, {
  __call = function(...)
    return require('fuzzy.lib')(...)
  end
})
