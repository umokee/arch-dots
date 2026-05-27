local u = require("config.utils")

return u.plugin("treesitter", {
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").setup({
				install_dir = vim.fn.stdpath("data") .. "/site",

				textobjects = {
					select = {
						enable = true,
						lookhead = true,
						keymaps = {
							["af"] = "@function.outer",
							["if"] = "@function.inner",
							["ac"] = "@class.outer",
							["ic"] = "@class.inner",
							["ai"] = "@conditional.outer",
							["ii"] = "@conditional.inner",
							["al"] = "@loop.outer",
							["il"] = "@loop.inner",
						},
					},
					move = {
						enable = true,
						set_jumps = true,
						goto_next_start = {
							["]m"] = "@function.outer",
							["]]"] = "@class.outer",
						},
						goto_previous_start = {
							["[m"] = "@function.outer",
							["[["] = "@class.outer",
						},
					},
				},
			})

			require("nvim-treesitter").install({
				"python",
				"lua",
				"vim",
				"html",
				"css",
				"comment",
				"vimdoc",
				"javascript",
				"typescript",
				"tsx",
				"dockerfile",
				"nix",
				"sql",
			})

			vim.api.nvim_create_autocmd("FileType", {
				pattern = {
					"lua",
					"python",
					"javascript",
					"typescript",
					"tsx",
					"html",
					"css",
					"nix",
					"sql",
					"dockerfile",
				},
				callback = function()
					vim.treesitter.start()
				end,
			})

			vim.api.nvim_create_autocmd("FileType", {
				pattern = {
					"lua",
					"python",
					"javascript",
					"typescript",
					"nix",
				},
				callback = function()
					vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		opts = {
			max_lines = 3,
			min_window_height = 0,
			line_numbers = true,
			multiline_threshold = 1,
			trim_scope = "outer",
		},
	},
})
