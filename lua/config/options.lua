-- Options that are loaded before startup

-- faster update time
vim.o.updatetime = 50

local opt = vim.opt

-- default indentation settings
opt.shiftwidth = 4
opt.tabstop = 4
opt.expandtab = true
opt.cindent = true
opt.cinoptions = [[0,g0,j1]]

opt.confirm = true -- Confirm to save changes before exiting modified buffer
vim.wo.number = true
vim.wo.relativenumber = true
opt.list = true       -- Show some invisible characters (tabs...
opt.mouse = "a"       -- enable mouse mode
opt.smartcase = true  -- Don't ignore case with capitals
opt.winminwidth = 5   -- Minimum window width
opt.sidescrolloff = 8 -- Columns of context

-- if 0 don't use vims foldcolumn, use statuscolumn instead
-- if 1 we use the foldcolumn but only one column (statuscol plugin would handle this internally)
vim.o.foldcolumn = "1"
vim.o.foldenable = true
vim.opt.foldlevel = 99
vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]] -- nice icons for folding
-- vim.opt.foldmethod = "indent"


-- status column setup (uses the function in ui.lua)
vim.o.statuscolumn = [[%!v:lua.require'config.ui'.statuscolumn()]];
