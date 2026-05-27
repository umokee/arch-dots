local u = require("config.utils")

return u.plugin("indent-blankline", {
	"lukas-reineke/indent-blankline.nvim",
	main = "ibl",
	opts = {
		indent = {
			char = "┆",
			tab_char = "┆",
		},
		scope = {
			enabled = true,
			show_start = false,
			show_end = false,
			highlight = { "Function", "Label" },
		},
		exclude = {
			filetypes = {
				"help",
				"alpha",
				"dashboard",
				"neo-tree",
				"Trouble",
				"lazy",
				"mason",
				"notify",
				"oil",
			},
		},
	},
})
