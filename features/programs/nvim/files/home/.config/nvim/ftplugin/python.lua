vim.opt_local.shiftwidth = 4
vim.opt_local.tabstop = 4
vim.opt_local.softtabstop = 4

vim.keymap.set("n", "<Leader>cr", "<cmd>terminal python3 %<CR>", {
   buffer = true,
   desc = "Run Python",
})
