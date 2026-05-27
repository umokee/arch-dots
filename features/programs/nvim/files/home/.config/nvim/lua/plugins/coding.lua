local u = require("config.utils")

return u.plugin("coding", {
	{
		"themaxmarchuk/tailwindcss-colors.nvim",
		lazy = true,
		config = function()
			require("tailwindcss-colors").setup()
		end,
	},
	{
		"MaximilianLloyd/tw-values.nvim",
		keys = {
			{
				"gK",
				"<cmd>TWValues<cr>",
				desc = "Show tailwind CSS values",
			},
		},
		opts = {
			border = "rounded",
			show_unknown_classes = true,
			focus_preview = true,
		},
	},
	{
		"nacro90/numb.nvim",
		opts = {},
	},
	{
		"numToStr/Comment.nvim",
		dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
		opts = {
			pre_hook = function()
				return vim.bo.commentstring
			end,
		},
	},
	{
		"norcalli/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup()
		end,
	},
	{
		"roobert/tailwindcss-colorizer-cmp.nvim",
	},
	{
		"coder/claudecode.nvim",
		config = true,
		keys = {
			{ "<leader>a", nil, desc = "AI/Claude" },
			{ "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
			{ "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
			{ "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume сессию" },
			{ "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Добавить текущий файл" },
			{
				"<leader>as",
				"<cmd>ClaudeCodeSend<cr>",
				mode = "v",
				desc = "Отправить выделенное",
			},
			{ "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Принять diff" },
			{ "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Отклонить diff" },
			{
				"<leader>as",
				"<cmd>ClaudeCodeTreeAdd<cr>",
				desc = "Добавить файл из дерева",
				ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
			},
		},
	},
	-- {
	--    "shortcuts/no-neck-pain.nvim",
	--    version = "*",
	--    keys = {
	--       { "<Leader>np", ":NoNeckPain<CR>" },
	--    },
	-- },
	-- {
	--    "chipsenkbeil/distant.nvim",
	--    branch = "v0.3",
	--    config = function()
	--       require("distant"):setup()
	--    end,
	-- },
	{
		"mcauley-penney/visual-whitespace.nvim",
		opts = {
			highlight = { link = "LineNr" },
		},
	},
})
