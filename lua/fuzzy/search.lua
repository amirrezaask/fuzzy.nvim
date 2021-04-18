local fuzzy = require("fuzzy.lib")
local helpers = require("fuzzy.lib.helpers")
local bin = require("fuzzy.lib.source.binary")
local file_finder = require("fuzzy.lib.source.file_finder")
local grep = require("fuzzy.lib.source.grep")
M = {}

function M.grep(opts)
	opts = opts or {}
	if vim.fn.executable("rg") ~= 0 then
		return require("fuzzy.search").rg(opts)
	elseif vim.fn.executable("git") and vim.fn.isdirectory(".git") then
		return require("fuzzy.git").git_grep(opts)
	else
		return require("fuzzy.search").luv_grep(opts)
	end
end

function M.luv_grep(opts)
	opts = opts or {}
	opts.cwd = "."
	opts.hidden = opts.hidden or false
	local source_and_sorter = function()
		local files = file_finder.find({
			path = opts.cwd,
			depth = opts.depth,
			hidden = opts.hidden,
		})
		local lines = grep.grep(files, CURRENT_FUZZY.input or "")
		return lines
	end
	opts.source = source_and_sorter
	opts.sorter = source_and_sorter
	opts.handler = function(line)
		local filename = vim.split(line, ":")[1]
		local linum = vim.split(line, ":")[2]
		CURRENT_FUZZY.__grep_cache = {}
		helpers.open_file_at(filename, linum)
	end
	fuzzy.new(opts)
end

function M.rg(opts)
	opts = opts or {}
	local cmd = "rg --column --line-number --no-heading --ignore-case "
	opts.source = {}
	opts.sorter = function(query, _)
		return bin.bin_source(string.format(cmd .. '"%s"', query))()
	end
	opts.handler = function(line)
		local filename = vim.split(line, ":")[1]
		local linum = vim.split(line, ":")[2]
		helpers.open_file_at(filename, linum)
	end
	fuzzy.new(opts)
end

function M.buffer_lines(opts)
	opts = opts or {}
	local filename = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
	local source = vim.split(grep.read_file(filename), "\n")
	for i = 1, #source do
		source[i] = string.format("%s:%s", i, source[i])
	end
	opts.source = source
	opts.handler = function(line)
		helpers.open_file_at(filename, vim.split(line, ":")[1])
	end
	fuzzy.new(opts)
end

return M
