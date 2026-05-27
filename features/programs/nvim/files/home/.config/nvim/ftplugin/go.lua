vim.opt_local.expandtab = false
vim.opt_local.shiftwidth = 4
vim.opt_local.tabstop = 4

vim.keymap.set("n", "<Leader>cr", "<cmd>terminal go run %<CR>", {
   buffer = true,
   desc = "Run Go",
})
