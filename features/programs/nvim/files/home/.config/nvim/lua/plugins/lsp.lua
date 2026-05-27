local u = require("config.utils")

return u.plugin("lsp", {
	"neovim/nvim-lspconfig",
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		-- Улучшенная поддержка Neovim Lua API
		{
			"folke/lazydev.nvim",
			ft = "lua",
			opts = {
				library = {
					{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
				},
			},
		},
		{
			"kiyoon/python-import.nvim",
			build = "pipx install python-import[with_optional]",
			keys = {
				{
					"<leader>i",
					function()
						require("python-import.api").add_import_current_word()
					end,
					desc = "Add import",
				},
			},
			opts = {},
		},
	},
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		-- Расширенные capabilities
		local capabilities = vim.tbl_deep_extend(
			"force",
			vim.lsp.protocol.make_client_capabilities(),
			require("cmp_nvim_lsp").default_capabilities()
		)

		-- Поддержка folding через LSP
		capabilities.textDocument.foldingRange = {
			dynamicRegistration = false,
			lineFoldingOnly = true,
		}

		vim.diagnostic.config({
			virtual_lines = { current_line = true },
			virtual_text = false,
			signs = true,
			underline = true,
			update_in_insert = false,
			severity_sort = true,
			float = { border = "rounded", source = "always" },
		})

		-- vim.diagnostic.config({
		-- 	virtual_text = { prefix = "●", spacing = 4 },
		-- 	signs = true,
		-- 	underline = true,
		-- 	update_in_insert = false,
		-- 	severity_sort = true,
		-- 	float = { border = "rounded", source = "always" },
		-- })

		local signs = { Error = "󰅚 ", Warn = "󰀪 ", Hint = "󰌶 ", Info = "󰋽 " }
		for name, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. name
			vim.fn.sign_define(hl, { text = icon, numhl = hl, texthl = hl })
		end

		local servers = {
			html = {
				settings = {
					html = {
						suggest = { html5 = true },
						format = { wrapLineLength = 120 },
					},
				},
			},
			cssls = {
				settings = {
					css = { validate = true, lint = { unknownAtRules = "ignore" } },
				},
			},
			jsonls = {
				settings = {
					json = {
						validate = { enable = true },
					},
				},
			},
			ts_ls = {
				settings = {
					typescript = {
						inlayHints = {
							includeInlayParameterNameHints = "all",
							includeInlayParameterNameHintsWhenArgumentMatchesName = false,
							includeInlayFunctionParameterTypeHints = true,
							includeInlayVariableTypeHints = true,
							includeInlayVariableTypeHintsWhenTypeMatchesName = false,
							includeInlayPropertyDeclarationTypeHints = true,
							includeInlayFunctionLikeReturnTypeHints = true,
							includeInlayEnumMemberValueHints = true,
						},
						preferences = {
							includeCompletionsForModuleExports = true,
							includeCompletionsWithInsertText = true,
							includeCompletionsWithSnippetText = true,
							includeAutomaticOptionalChainCompletions = true,
							importModuleSpecifierPreference = "shortest",
							allowIncompleteCompletions = true,
							includeCompletionsForImportStatements = true,
						},
						suggest = {
							completeFunctionCalls = true,
							includeCompletionsForImportStatements = true,
							includeAutomaticOptionalChainCompletions = true,
						},
						updateImportsOnFileMove = { enabled = "always" },
					},
					javascript = {
						inlayHints = {
							includeInlayParameterNameHints = "all",
							includeInlayFunctionParameterTypeHints = true,
							includeInlayVariableTypeHints = true,
							includeInlayFunctionLikeReturnTypeHints = true,
						},
						preferences = {
							includeCompletionsForModuleExports = true,
							includeCompletionsWithInsertText = true,
							importModuleSpecifierPreference = "shortest",
						},
						suggest = {
							completeFunctionCalls = true,
						},
						updateImportsOnFileMove = { enabled = "always" },
					},
					completions = {
						completeFunctionCalls = true,
					},
				},
				-- Автоматический organize imports при сохранении
				on_attach = function(client, bufnr)
					-- Code action для organize imports
					vim.api.nvim_buf_create_user_command(bufnr, "OrganizeImports", function()
						vim.lsp.buf.execute_command({
							command = "_typescript.organizeImports",
							arguments = { vim.api.nvim_buf_get_name(bufnr) },
						})
					end, { desc = "Organize Imports" })
				end,
			},
			emmet_ls = {
				filetypes = {
					"html",
					"css",
					"scss",
					"javascript",
					"javascriptreact",
					"typescript",
					"typescriptreact",
					"astro",
				},
			},
			eslint = {
				settings = {
					workingDirectories = { mode = "auto" },
				},
				on_attach = function(_, bufnr)
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = bufnr,
						command = "EslintFixAll",
					})
				end,
			},
			basedpyright = {
				filetypes = { "python" },
				settings = {
					basedpyright = {
						analysis = {
							typeCheckingMode = "basic",
							autoImportCompletions = true,
							autoSearchPaths = true,
							useLibraryCodeForTypes = true,
							diagnosticMode = "workspace",
							packageIndexDepths = {
								{ name = "", depth = 4, includeAllSymbols = true },
							},
							inlayHints = {
								variableTypes = true,
								functionReturnTypes = true,
							},
						},
					},
				},
			},
			nil_ls = {
				settings = {
					["nil"] = {
						nix = {
							flake = {
								autoArchive = false,
								autoEvalInputs = false,
							},
						},
					},
				},
			},
			qmlls = {
				settings = {
					importPaths = {
						"/run/current-system/sw/lib/qt-6/qml",
					},
				},
			},
			gopls = {
				settings = {
					gopls = {
						analyses = {
							unusedparams = true,
							shadow = true,
							nilness = true,
							unusedwrite = true,
							useany = true,
						},
						staticcheck = true,
						gofumpt = true,
						usePlaceholders = true,
						completeUnimported = true,
						hints = {
							assignVariableTypes = true,
							compositeLiteralFields = true,
							compositeLiteralTypes = true,
							constantValues = true,
							functionTypeParameters = true,
							parameterNames = true,
							rangeVariableTypes = true,
						},
						codelenses = {
							gc_details = true,
							generate = true,
							regenerate_cgo = true,
							run_govulncheck = true,
							tidy = true,
							upgrade_dependency = true,
							vendor = true,
						},
						semanticTokens = true,
					},
				},
			},
			lua_ls = {
				settings = {
					Lua = {
						runtime = { version = "LuaJIT" },
						diagnostics = { globals = { "vim", "describe", "it" } },
						workspace = {
							checkThirdParty = false,
							library = { vim.env.VIMRUNTIME },
						},
						hint = {
							enable = true,
							setType = true,
							paramType = true,
							paramName = "All",
							semicolon = "Disable",
							arrayIndex = "Disable",
						},
						completion = {
							callSnippet = "Replace",
							postfix = ".",
							showWord = "Disable",
							workspaceWord = false,
						},
						telemetry = { enable = false },
						codeLens = { enable = true },
					},
				},
			},
			clangd = {
				cmd = {
					"clangd",
					"--background-index",
					"--clang-tidy",
					"--header-insertion=iwyu",
					"--completion-style=detailed",
					"--function-arg-placeholders",
					"--fallback-style=llvm",
				},
				init_options = {
					usePlaceholders = true,
					completeUnimported = true,
					clangdFileStatus = true,
				},
			},
			tailwindcss = {
				filetypes = {
					"html",
					"css",
					"scss",
					"javascript",
					"javascriptreact",
					"typescript",
					"typescriptreact",
					"astro",
				},
				settings = {
					tailwindCSS = {
						experimental = {
							classRegex = {
								{ "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
								{ "cx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
							},
						},
						suggestions = true,
						classAttributes = { "class", "className", "classList", "ngClass" },
					},
				},
				on_attach = function()
					require("tailwindcss-colors").buf_attach(0)
				end,
			},
		}

		for server, opts in pairs(servers) do
			opts.capabilities = vim.tbl_deep_extend("force", capabilities, opts.capabilities or {})
			vim.lsp.config(server, opts)
			vim.lsp.enable(server)
		end

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
			callback = function(ev)
				local client = vim.lsp.get_client_by_id(ev.data.client_id)
				local bufnr = ev.buf

				local map = function(keys, func, desc)
					vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
				end

				-- Navigation
				map("gd", vim.lsp.buf.definition, "Definition")
				map("gD", vim.lsp.buf.declaration, "Declaration")
				map("gi", vim.lsp.buf.implementation, "Implementation")
				map("gr", vim.lsp.buf.references, "References")
				map("gy", vim.lsp.buf.type_definition, "Type Definition")
				map("K", vim.lsp.buf.hover, "Hover")
				map("<C-k>", vim.lsp.buf.signature_help, "Signature Help")

				-- Signature help в insert mode
				vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, { buffer = bufnr, desc = "Signature Help" })

				-- Workspace
				map("<Leader>lws", vim.lsp.buf.workspace_symbol, "Workspace Symbols")
				map("<Leader>lwa", vim.lsp.buf.add_workspace_folder, "Add Workspace Folder")
				map("<Leader>lwr", vim.lsp.buf.remove_workspace_folder, "Remove Workspace Folder")
				map("<Leader>lwl", function()
					print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
				end, "List Workspace Folders")

				-- Actions
				map("<Leader>lr", vim.lsp.buf.rename, "Rename")
				map("<Leader>la", vim.lsp.buf.code_action, "Code Action")
				vim.keymap.set(
					"v",
					"<Leader>la",
					vim.lsp.buf.code_action,
					{ buffer = bufnr, desc = "LSP: Code Action" }
				)
				map("<Leader>lf", function()
					vim.lsp.buf.format({ async = true })
				end, "Format")

				-- Diagnostics
				map("<Leader>ld", vim.diagnostic.open_float, "Line Diagnostics")
				map("<Leader>lD", vim.diagnostic.setloclist, "Diagnostics to Loclist")
				map("[d", function()
					vim.diagnostic.jump({ count = -1 })
				end, "Prev Diagnostic")
				map("]d", function()
					vim.diagnostic.jump({ count = 1 })
				end, "Next Diagnostic")
				map("[e", function()
					vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR })
				end, "Prev Error")
				map("]e", function()
					vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR })
				end, "Next Error")

				-- Call hierarchy
				map("<Leader>lci", vim.lsp.buf.incoming_calls, "Incoming Calls")
				map("<Leader>lco", vim.lsp.buf.outgoing_calls, "Outgoing Calls")

				-- Inlay hints
				if vim.lsp.inlay_hint then
					vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
					map("<Leader>lh", function()
						vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }))
					end, "Toggle Inlay Hints")
				end

				-- Code lens
				if client and client.supports_method("textDocument/codeLens") then
					map("<Leader>ll", vim.lsp.codelens.run, "Run Code Lens")
					map("<Leader>lL", vim.lsp.codelens.refresh, "Refresh Code Lens")
					vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave" }, {
						buffer = bufnr,
						callback = function()
							vim.lsp.codelens.refresh({ bufnr = bufnr })
						end,
					})
				end

				-- Document highlight (подсветка символа под курсором)
				if client and client.supports_method("textDocument/documentHighlight") then
					local hl_group = vim.api.nvim_create_augroup("LspDocumentHighlight", { clear = false })
					vim.api.nvim_clear_autocmds({ group = hl_group, buffer = bufnr })
					vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
						group = hl_group,
						buffer = bufnr,
						callback = vim.lsp.buf.document_highlight,
					})
					vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
						group = hl_group,
						buffer = bufnr,
						callback = vim.lsp.buf.clear_references,
					})
				end
			end,
		})
	end,
})
