local u = require("config.utils")

return u.plugin("fidget", {
	"j-hui/fidget.nvim",
	veriosn = "*",
	opts = {
		notification = {
			override_vim_notify = true,

			view = {
				reflow = true,
			},
			window = {
				winblend = 100,
				-- max_width = 0.4,
				-- border = "rounded",
				x_padding = 1,
				align = "bottom",
			},
		},
		progress = {
			display = {
				done_ttl = 3,
				progress_icon = { pattern = "dots", period = 1 },
			},
		},
	},
})
