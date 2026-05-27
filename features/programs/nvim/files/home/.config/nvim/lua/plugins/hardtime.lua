local u = require("config.utils")

return u.plugin("hardtime", {
	{
		"m4xshen/hardtime.nvim",
		dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
		lazy = false,
		opts = {
			show_hints = true,
			hint_type = "statusline",
			disabled_keys = {
				["<Up>"] = {},
				["<Down>"] = {},
				["<Left>"] = {},
				["<Right>"] = {},
			},
			max_time = 1000,
			max_count = 2,
			disabled_filetypes = {
				"qf",
				"netrw",
				"NvimTree",
				"lazy",
				"mason",
				"oil",
				"undotree",
			},
			disable_mouse = true,
			hints = {
				["[dcyvV][ia][%(%)]"] = {
					message = function(keys)
						return "Use " .. keys:sub(1, 2) .. "b instead of " .. keys
					end,
					length = 3,
				},
			},
			ui = {
				size = {
					width = "80%",
					height = "80%",
				},
			},
		},
	},
})
