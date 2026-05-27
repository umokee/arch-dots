local u = require("config.utils")
-- TODO Подумать можно ли объединить с bufferline
return u.plugin("bufremove", {
	"echasnovski/mini.bufremove",
	version = "*",
	keys = {
		{
			"<leader>bb",
			function()
				require("mini.bufremove").delete(0, false)
			end,
			desc = "Delete buffer",
		},
		{
			"<leader>bD",
			function()
				require("mini.bufremove").delete(0, true)
			end,
			desc = "Delete buffer (force)",
		},
	},
})
