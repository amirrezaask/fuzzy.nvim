local uv = vim.loop
local M = {}

local function list_projects(output, path)
	path = vim.fn.expand(path)
	output = output or {}
	local fs_t = uv.fs_scandir(path)
	if fs_t == nil then
		print("Error scanning " .. path)
	end
	while true do
		local name, type = uv.fs_scandir_next(fs_t)
		if name == nil and type == nil then
			break
		end
		if type == "directory" then
			if vim.fn.isdirectory(path .. "/.git") ~= 0 then
				if not vim.tbl_contains(output, path) then
					table.insert(output, path)
				end
			else
				list_projects(output, path .. "/" .. name)
			end
		end
	end
	return output
end

function M.list_projects(locations)
	local list = {}
	for _, location in ipairs(locations) do
		list_projects(list, location)
	end
	return list
end
return M
