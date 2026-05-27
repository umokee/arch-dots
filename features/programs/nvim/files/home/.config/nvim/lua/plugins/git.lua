local u = require("config.utils")

return u.plugin("git", {
	{
		"lewis6991/gitsigns.nvim",
		opts = {},
	},
	{
		"tpope/vim-fugitive",
	},
})
