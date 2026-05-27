local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.cursorline = true
-- opt.cursorlineopt = "number"

opt.tabstop = 3
opt.shiftwidth = 3
opt.softtabstop = 3
opt.expandtab = true
opt.smartindent = true

opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true

opt.termguicolors = true
opt.scrolloff = 10
opt.sidescrolloff = 8
opt.cmdheight = 0
opt.laststatus = 3
opt.showmode = false
opt.signcolumn = "yes"
opt.guicursor = ""

opt.splitright = true
opt.splitbelow = true
opt.splitkeep = "screen"

opt.swapfile = false
opt.undofile = true
opt.updatetime = 250
opt.timeoutlen = 500
opt.completeopt = "menu,menuone,noselect"
-- opt.mouse = "a"
opt.mousemoveevent = true

opt.clipboard = "unnamedplus"

opt.wrap = false
opt.linebreak = true
opt.breakindent = true

opt.shortmess:append("sIc")
