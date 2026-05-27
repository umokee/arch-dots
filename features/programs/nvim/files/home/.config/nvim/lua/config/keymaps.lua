local function map(mode, lhs, rhs, opts)
   opts = opts or {}
   opts.noremap = opts.noremap ~= false
   opts.silent = opts.silent ~= false
   vim.keymap.set(mode, lhs, rhs, opts)
end

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- better up/down
map({ "n", "x" }, "j", function()
   return vim.v.count > 0 and "j" or "gj"
end, { expr = true })

map({ "n", "x" }, "k", function()
   return vim.v.count > 0 and "k" or "gk"
end, { expr = true })

-- Центрирование при скролле
map("n", "<C-u>", "<C-u>zz", {})
map("n", "<C-d>", "<C-d>zz", {})
map("n", "<C-b>", "<C-b>zz", {})
map("n", "<C-f>", "<C-f>zz", {})

-- Base commands
map("n", "<Leader>w", "<cmd>write<CR>", { desc = "Save file" })
map("n", "<Leader>q", "<cmd>quit<CR>", { desc = "Quit" })
map("n", "<Leader>m", "<cmd>make<CR>", { desc = "Make" })

map("n", "<Leader>s", function()
   if vim.bo.filetype == "lua" then
      vim.cmd("source %")
      vim.notify("Sourced " .. vim.fn.expand("%", vim.log.levels.INFO))
   end
end, { desc = "Source current lua file" })

-- system clipboard
map({ "n", "v" }, "<Leader>y", '"+y', {})
map({ "n" }, "<Leader>Y", '"+y$', {})

map({ "n", "v" }, "<Leader>p", '"+p', {})
map({ "n", "v" }, "<Leader>P", '"+P', {})

-- Splits
map("n", "<Leader>-", "<cmd>split<CR>", { desc = "Horizontal split" })
map("n", "<Leader>|", "<cmd>vsplit<CR>", { desc = "Vertical split" })
