local function augroup(name)
    return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

-- Folds based on treesitter or syntax highlighting otherwise
-- vim.api.nvim_create_autocmd({ "FileType" }, {
--     pattern = { "cpp", "hpp", "lua", "rs" },
--     callback = function()
--         vim.opt.foldmethod = "expr"
--         vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
--         vim.opt.foldtext = 'v:lua.vim.treesitter.foldtext()'
--     end,
-- })

-- re-render on cursor movement for the statuscolumn
vim.api.nvim_create_autocmd({'CursorMovedI'}, {
  callback = function() 
    vim.cmd('redraw!')
  end
})

-- Disable autoformat for cpp files
vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = { "cpp", "hpp" },
    callback = function()
        vim.b.autoformat = false
    end,
})

-- smart relative numbering
-- relative numbering
vim.o.relativenumber = true
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave", "WinEnter" }, {
    pattern = { "*" },
    callback = function() vim.opt.relativenumber = true; end
})
vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter", "WinLeave" }, {
    pattern = { "*" },
    callback = function() vim.opt.relativenumber = false; end
})

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
    group = augroup("close_with_q"),
    pattern = {
        "PlenaryTestPopup",
        "grug-far",
        "help",
        "lspinfo",
        "notify",
        "qf",
        "spectre_panel",
        "startuptime",
        "tsplayground",
        "neotest-output",
        "checkhealth",
        "neotest-summary",
        "neotest-output-panel",
        "dbout",
        "gitsigns.blame",
    },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<cr>", {
            buffer = event.buf,
            silent = true,
            desc = "Quit buffer",
        })
    end,
})

-- resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
    group = augroup("resize_splits"),
    callback = function()
        local current_tab = vim.fn.tabpagenr()
        vim.cmd("tabdo wincmd =")
        vim.cmd("tabnext " .. current_tab)
    end,
})
