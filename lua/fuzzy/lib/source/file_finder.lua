local uv = vim.loop
local helpers = require("fuzzy.lib.helpers")

local function has_value(tab, val)
	if not tab then
		return false
	end
	for index, value in ipairs(tab) do
		if value == val then
			return true
		end
	end
	return false
end

FILE_FINDER_DEFAULT_DEPTH = 5
FILE_FINDER_THRESHOLD = 2000
-- list of files and directories recursively with optional depth.
local function _scandir(output, path, depth, hidden, show_dirs, include_previous_link, blacklist)
	output = output or {}
	depth = depth or 5
	hidden = hidden or false
	show_dirs = show_dirs or false
	if depth == 0 then
		return output
	end
	local fs_t = uv.fs_scandir(path)
	while true do
		if #output > FILE_FINDER_THRESHOLD then
			return output
		end
		local name, type = uv.fs_scandir_next(fs_t)
		if name == nil and type == nil then
			break
		end
		if not (name:sub(0, 1) == "." and not hidden) then
			if type == "directory" and not has_value(blacklist, name) then
				_scandir(output, path .. "/" .. name, depth - 1)
				if show_dirs then
					table.insert(output, path .. "/" .. name)
				end
			end
			if type == "file" then
				table.insert(output, path .. "/" .. name)
			end
		end
	end
	if include_previous_link then
		table.insert(output, "..")
	end
	return output
end

local file_finder = {}

function file_finder.find(opts)
	opts = opts or {}
	opts.path = opts.path or "."
	opts.depth = opts.depth or FILE_FINDER_DEFAULT_DEPTH
	opts.include_dirs = opts.include_dirs or false
	opts.include_previous_link = opts.include_previous_link or false
	opts.hidden = opts.hidden or false
	opts.blacklist = opts.blacklist or {}
	return _scandir(
		{},
		opts.path,
		opts.depth,
		opts.hidden,
		opts.include_dirs,
		opts.include_previous_link,
		opts.blacklist
	)
end

function file_finder.file_type(filename)
	local fd = assert(uv.fs_open(filename, "r", 438))
	local stat = assert(uv.fs_fstat(fd))
	return stat.type
end

return file_finder
