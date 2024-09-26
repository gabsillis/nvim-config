-- Generic Keybinds

-- Better [esc]
vim.keymap.set({ "t", "v", "i", "n" }, "<esc>", [[<c-\><c-n>]], { desc = "[esc] to normal mode" })

-- Window movement
vim.keymap.set({ 't', 'v', 'i', 'n' }, "<M-h>", [[<Cmd>wincmd h<CR>]], { desc = "Go to left window", remap = true })
vim.keymap.set({ 't', 'v', 'i', 'n' }, "<M-j>", [[<Cmd>wincmd j<CR>]], { desc = "Go to lower window", remap = true })
vim.keymap.set({ 't', 'v', 'i', 'n' }, "<M-k>", [[<Cmd>wincmd k<CR>]], { desc = "Go to upper window", remap = true })
vim.keymap.set({ 't', 'v', 'i', 'n' }, "<M-l>", [[<Cmd>wincmd l<CR>]], { desc = "Go to right window", remap = true })

-- fix terminal backspace
vim.keymap.set("t", "<C-h>", "<backspace>")

-- formatting
vim.keymap.set({ 'n', 'v' }, "<leader>cf", function()
        vim.lsp.buf.format()
    end,
    { desc = "format the code with lsp formatter" }
)
