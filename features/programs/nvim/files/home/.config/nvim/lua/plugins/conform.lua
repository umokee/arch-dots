local u = require("config.utils")

return u.plugin("conform", {
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				nix = { "nixpkgs-fmt" },
				python = { "ruff_format", "ruff_organize_imports" },
				javascript = { "prettier" },
				javascriptreact = { "prettier" },
				typescript = { "prettier" },
				typescriptreact = { "prettier" },
				html = { "prettier" },
				css = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				sh = { "shfmt" },
				bash = { "shfmt" },
				dockerfile = { "hadolint" },
				qml = { "qmlformat" },
			},
			format_after_save = {
				timeout_ms = 500,
				lsp_format = "fallback",
			},
		},
	},
})
