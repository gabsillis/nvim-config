-- Options that are loaded before startup

-- faster update time
vim.o.updatetime = 50

local opt = vim.opt

-- default indentation settings
opt.shiftwidth = 4
opt.tabstop = 4
opt.expandtab = true
opt.smartindent = true

opt.confirm = true -- Confirm to save changes before exiting modified buffer
vim.wo.number = true
vim.wo.relativenumber = true
opt.list = true       -- Show some invisible characters (tabs...
opt.mouse = "a"       -- enable mouse mode
opt.smartcase = true  -- Don't ignore case with capitals
opt.winminwidth = 5   -- Minimum window width
opt.sidescrolloff = 8 -- Columns of context
vim.o.foldcolumn = "0"
--vim.o.foldenable = false
vim.opt.foldlevel = 99
vim.opt.foldmethod = "indent"


-- status column setup (uses the function in ui.lua)
vim.o.statuscolumn = [[%!v:lua.require'config.ui'.statuscolumn()]];
