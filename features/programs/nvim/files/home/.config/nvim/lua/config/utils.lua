local conf = require("config.conf")
local M = {}

function M.enabled(name)
	return vim.tbl_contains(conf, name)
end

function M.plugin(name, spec)
	if M.enabled(name) then
		return spec
	end
	return {}
end

function M.merge(...)
	return vim.tbl_deep_extend("force", ...)
end

function M.map(mode, lhs, rhs, opts)
	opts = opts or {}
	opts.silent = opts.silent ~= false
	vim.keymap.set(mode, lhs, rhs, opts)
end

return M
