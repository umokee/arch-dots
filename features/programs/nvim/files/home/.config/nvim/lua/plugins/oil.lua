local u = require("config.utils")

return u.plugin("oil", {
	"stevearc/oil.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	lazy = false,
	opts = {
		default_file_explorer = true,
		delete_to_trash = true,
		columns = { "icon" },
		keymaps = {
			["<C-v>"] = "actions.select_vsplit",
			["<C-s>"] = "actions.select_split",
			["<Esc>"] = "actions.close",
		},
		view_options = {
			show_hidden = true,
		},
		float = {
			padding = 3,
			max_width = 90,
			max_height = 0,
			border = "rounded",
			preview_split = "auto",
			win_options = {
				winblend = 0,
			},
		},
		preview = {
			update_on_cursor_move = true,
			border = "rounded",
		},
	},
	keys = {
		{ "<Leader>o", ":lua require('oil').open_float()<CR>" },
	},
})
