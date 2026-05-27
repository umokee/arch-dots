local u = require("config.utils")

return u.plugin("flash", {
	"folke/flash.nvim",
	event = "VeryLazy",
	opts = {
		-- Настройки по умолчанию
		labels = "asdfghjklqwertyuiopzxcvbnm",
		search = {
			multi_window = true,
			forward = true,
			wrap = true,
			mode = "exact",
		},
		jump = {
			jumplist = true,
			pos = "start",
			history = false,
			register = false,
			nohlsearch = false,
			autojump = false,
		},
		label = {
			uppercase = true,
			exclude = "",
			current = true,
			after = true,
			before = false,
			style = "overlay",
		},
		highlight = {
			backdrop = true,
			matches = true,
			priority = 5000,
			groups = {
				match = "FlashMatch",
				current = "FlashCurrent",
				backdrop = "FlashBackdrop",
				label = "FlashLabel",
			},
		},
		modes = {
			search = {
				enabled = true,
			},
			char = {
				enabled = true,
				keys = { "f", "F", "t", "T", ";" },
				jump_labels = true,
			},
		},
	},
	keys = {
		-- Основной режим - s + 2 буквы
		{
			"s",
			mode = { "n", "x", "o" },
			function()
				require("flash").jump()
			end,
			desc = "Flash",
		},

		-- Treesitter режим - S
		{
			"S",
			mode = { "n", "o", "x" },
			function()
				require("flash").treesitter()
			end,
			desc = "Flash Treesitter",
		},

		-- Remote Flash (для работы с operators)
		{
			"r",
			mode = "o",
			function()
				require("flash").remote()
			end,
			desc = "Remote Flash",
		},

		-- Treesitter Search
		{
			"R",
			mode = { "o", "x" },
			function()
				require("flash").treesitter_search()
			end,
			desc = "Treesitter Search",
		},

		-- Toggle Flash Search при /
		{
			"<c-s>",
			mode = { "c" },
			function()
				require("flash").toggle()
			end,
			desc = "Toggle Flash Search",
		},
	},
})
