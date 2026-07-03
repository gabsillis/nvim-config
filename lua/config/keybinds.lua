-- Generic Keybinds

-- Better [esc]
vim.keymap.set({ "t", "v", "i", "n" }, "<esc>", [[<c-\><c-n>]], { desc = "[esc] to normal mode" })

-- Window movement
vim.keymap.set({ 't', 'v', 'i', 'n' }, "<M-h>", [[<Cmd>wincmd h<CR>]], { desc = "Go to left window", remap = true })
vim.keymap.set({ 't', 'v', 'i', 'n' }, "<M-j>", [[<Cmd>wincmd j<CR>]], { desc = "Go to lower window", remap = true })
vim.keymap.set({ 't', 'v', 'i', 'n' }, "<M-k>", [[<Cmd>wincmd k<CR>]], { desc = "Go to upper window", remap = true })
vim.keymap.set({ 't', 'v', 'i', 'n' }, "<M-l>", [[<Cmd>wincmd l<CR>]], { desc = "Go to right window", remap = true })

-- visual block indent
vim.cmd("vnoremap < <gv")
vim.cmd("vnoremap > >gv")

-- lsp keymaps
vim.keymap.set({ 'n', 'v' }, "gd",
    vim.lsp.buf.definition, { desc = "[g]oto [d]efinition" })
vim.keymap.set({ 'n', 'v' }, "gr",
    vim.lsp.buf.references, { desc = "[g]oto [r]eferences", nowait = true })
vim.keymap.set({ 'n', 'v' }, "gI",
    vim.lsp.buf.implementation, { desc = "[g]oto [I]mplementation" })
vim.keymap.set({ 'n', 'v' }, "gy",
    vim.lsp.buf.type_definition, { desc = "[g]oto t[y]pe definition" })
vim.keymap.set({ 'n', 'v' }, "gD",
    vim.lsp.buf.declaration, { desc = "[g]oto [d]eclaration" })
vim.keymap.set({ 'n', 'v' }, "K",
    vim.lsp.buf.hover, { desc = "hover" })
vim.keymap.set({ 'n', 'v' }, "gK",
    vim.lsp.buf.signature_help, { desc = "signature help" })

-- fix terminal backspace
vim.keymap.set("t", "<C-h>", "<backspace>")

-- code keymaps
vim.keymap.set({ 'n', 'v' }, "<leader>cf", function()
        require("conform").format({ lsp_fallback = true })
    end,
    { desc = "format the code with formatter" }
)
vim.keymap.set({ 'n', 'v' }, "<leader>ca",
    vim.lsp.buf.code_action, { desc = "[c]ode [a]ction" })

-- diagnostic
local diagnostic_goto = function(next, severity)
    severity = severity and vim.diagnostic.severity[severity] or nil
    return function()
        vim.diagnostic.jump({
            count = next and 1 or -1,
            severity = severity,
            float = true,
        })
    end
end
vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
vim.keymap.set("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
vim.keymap.set("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
vim.keymap.set("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
vim.keymap.set("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
vim.keymap.set("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
vim.keymap.set("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })
