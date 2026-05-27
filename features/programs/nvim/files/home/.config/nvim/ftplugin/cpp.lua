vim.opt_local.shiftwidth = 4
vim.opt_local.tabstop = 4
vim.opt_local.softtabstop = 4

vim.keymap.set("n", "<Leader>cr", "<cmd>terminal ./a.out<CR>", {
   buffer = true,
   desc = "Run ./a.out",
})

vim.keymap.set("n", "<Leader>cm", "<cmd>make<CR>", {
   buffer = true,
   desc = "Make",
})
