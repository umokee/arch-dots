local autocmd = vim.api.nvim_create_autocmd

vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "*",
	callback = function()
		vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#b4befe" })
		vim.api.nvim_set_hl(0, "TelescopeBorder", { fg = "#b4befe" })
		vim.api.nvim_set_hl(0, "IblScope", { fg = "#b4befe" })
	end,
})

-- only highlight when searching
vim.api.nvim_create_autocmd("CmdlineEnter", {
	callback = function()
		local cmd = vim.v.event.cmdtype
		if cmd == "/" or cmd == "?" then
			vim.opt.hlsearch = true
		end
	end,
})
vim.api.nvim_create_autocmd("CmdlineLeave", {
	callback = function()
		local cmd = vim.v.event.cmdtype
		if cmd == "/" or cmd == "?" then
			vim.opt.hlsearch = false
		end
	end,
})

-- Highlight when yanking
vim.api.nvim_set_hl(0, "YankHighlight", { bg = "#f9e2af", fg = "#000000" })
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.hl.on_yank({
			higroup = "YankHighlight",
			timeout = 200,
		})
	end,
})

-- Disable auto comment
vim.api.nvim_create_autocmd("BufEnter", {
	callback = function()
		vim.opt.formatoptions = { c = false, r = false, o = false }
	end,
})

-- turn on spell check for markdown and text file
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = { "*.md" },
	callback = function()
		vim.opt_local.spell = true
	end,
})

-- keymap for .cpp file
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = { "*.cpp", "*.cc" },
	callback = function()
		vim.keymap.set("n", "<Leader>e", ":terminal ./a.out<CR>", { silent = true })
		-- vim.keymap.set("n", "<Leader>e", ":!./sfml-app<CR>",
		--    { silent = true })
	end,
})

-- tab format for .lua file
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = { "*.lua" },
	callback = function()
		vim.opt.shiftwidth = 3
		vim.opt.tabstop = 3
		vim.opt.softtabstop = 3
		-- vim.opt_local.colorcolumn = {70, 80}
	end,
})

-- keymap for .go file
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = { "*.go" },
	callback = function()
		vim.keymap.set("n", "<Leader>e", ":terminal go run %<CR>", { silent = true })
	end,
})

-- keymap for .py file
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = { "*.py" },
	callback = function()
		vim.keymap.set("n", "<Leader>e", ":terminal python3 %<CR>", { silent = true })
	end,
})

-- В самом начале autocmds.lua
local root_markers = { ".git", "Makefile", "package.json", "Cargo.toml", "flake.nix", "go.mod", "pyproject.toml" }

-- Сохраняем начальную директорию И аргумент ДО загрузки oil
local initial_dir = vim.fn.getcwd()
local initial_arg = vim.fn.argv(0)

-- Расширяем путь сразу, до oil
local target_dir = initial_dir
if initial_arg ~= "" and not initial_arg:match("^oil://") then
	-- Расширяем относительно текущей директории
	local expanded = vim.fn.fnamemodify(initial_arg, ":p")
	if vim.fn.isdirectory(expanded) == 1 then
		target_dir = expanded
	else
		target_dir = vim.fn.fnamemodify(expanded, ":h")
	end
end

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		vim.notify("Target dir: " .. target_dir, vim.log.levels.INFO)

		-- Ищем root от целевой директории
		local root_files = vim.fs.find(root_markers, {
			path = target_dir,
			upward = true,
		})

		if root_files[1] then
			local root = vim.fs.dirname(root_files[1])
			vim.cmd.cd(root)
			vim.notify("Set pwd to root: " .. root, vim.log.levels.WARN)
		else
			vim.cmd.cd(target_dir)
			vim.notify("Set pwd to: " .. target_dir, vim.log.levels.WARN)
		end
	end,
})

vim.keymap.set("n", "<leader>r", function()
	local old_word = vim.fn.expand("<cword>")
	local new_word = vim.fn.input("Заменить " .. old_word .. " на: ", old_word)
	if new_word ~= old_word and new_word ~= "" then
		vim.cmd(":%s/\\<" .. old_word .. "\\>/" .. new_word .. "/g")
	end
end)
