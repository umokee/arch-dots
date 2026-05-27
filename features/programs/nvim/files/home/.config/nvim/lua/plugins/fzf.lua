local u = require("config.utils")
-- TODO Добавить кнопку поиска туду в fzf
return u.plugin("fzf", {
	{
		"ibhagwan/fzf-lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local fzf = require("fzf-lua")

			fzf.setup({
				winopts = {
					height = 0.85,
					width = 0.80,
					border = "rounded",
				},
			})

			local map = vim.keymap.set
			map("n", "<Leader>ff", fzf.files, { desc = "Files" })
			map("n", "<Leader>fg", fzf.live_grep, { desc = "Grep" })
			map("n", "<Leader>fG", fzf.grep_curbuf, { desc = "Grep buffer" })
			map("n", "<Leader>fb", fzf.buffers, { desc = "Buffers" })
			map("n", "<Leader>fv", function()
				fzf.files({ cwd = "~/.config/nvim" })
			end, { desc = "Nvim config" })
		end,
	},
})
