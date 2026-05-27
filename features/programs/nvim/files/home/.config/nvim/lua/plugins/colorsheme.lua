local u = require("config.utils")

return u.plugin("colorscheme", {
	-- {
	--    "craftzdog/solarized-osaka.nvim",
	--    lazy = false,
	--    priority = 1000,
	--    opts = {},
	--    config = function(opts)
	--       require("solarized-osaka").setup(opts)
	--       vim.cmd.colorscheme("solarized-osaka")
	--    end,
	-- },

	-- {
	-- 	"EdenEast/nightfox.nvim",
	-- 	lazy = false,
	-- 	priority = 1000,
	-- 	opts = {},
	-- 	config = function()
	-- 		vim.cmd.colorscheme("carbonfox")
	-- 	end,
	-- },

	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {},
		config = function()
			vim.cmd([[colorscheme tokyonight-night]])
			vim.cmd([[hi Normal guibg=#090B17]])
			vim.cmd([[hi NormalNC guibg=#090B17]])
			vim.cmd([[hi VertSplit guibg=#090B17]])
			vim.cmd([[hi StatusLine guibg=#090B17]])
			vim.cmd([[hi StatusLineNC guibg=#090B17]])
			vim.cmd([[hi TabLine guibg=#090B17]])
			vim.cmd([[hi TabLineFill guibg=#090B17]])
			vim.cmd([[hi TabLineSel guibg=#090B17]])
			vim.cmd([[hi SignColumn guibg=#090B17]])
		end,
	},

	{
		"mvllow/modes.nvim",
		event = "VeryLazy",
		opts = {
			colors = {
				bg = "",
				copy = "#f9e2af",
				delete = "#f38ba8",
				insert = "#a6e3a1",
				visual = "#cba6f7",
			},
		},
	},
})
