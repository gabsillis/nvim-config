return {

    {
        'mason-org/mason.nvim',
        lazy = false,
        keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
        opts = {
            ui = { border = 'single' },
            PATH = 'prepend',
        },
    },

    {
        'WhoIsSethDaniel/mason-tool-installer.nvim',
        lazy = false,
        dependencies = { 'mason-org/mason.nvim' },
        opts = {
            ensure_installed = { 'tree-sitter-cli' },
            run_on_start = false,
        },
    },

    -- nvim-treesitter's main branch is the rewritten API for Neovim 0.12.
    {
        'nvim-treesitter/nvim-treesitter',
        lazy = false,
        build = ':TSUpdate',
        dependencies = { 'WhoIsSethDaniel/mason-tool-installer.nvim' },
        config = function()
            local parsers = { 'rust', 'cpp', 'lua' }

            local function has_tree_sitter_cli()
                if vim.fn.executable('tree-sitter') ~= 1 then
                    return false
                end

                local result = vim.system({ 'tree-sitter', '--version' }, { text = true }):wait()
                local version = result.code == 0 and vim.version.parse(result.stdout) or nil
                return version ~= nil and vim.version.ge(version, { 0, 26, 1 })
            end

            local function install_parsers()
                if has_tree_sitter_cli() then
                    require('nvim-treesitter').install(parsers)
                    return true
                end
                return false
            end

            if not install_parsers() then
                vim.api.nvim_create_autocmd('User', {
                    pattern = 'MasonToolsUpdateCompleted',
                    once = true,
                    callback = install_parsers,
                })
                vim.cmd('MasonToolsInstall')
            end
        end,
    },
    -- {
    --     "mason-org/mason-lspconfig.nvim",
    --     opts = {},
    --     dependencies = {
    --         { "mason-org/mason.nvim", opts = {} },
    --         "neovim/nvim-lspconfig",
    --     },
    -- },

    -- auto pair braces and stuff
    {
        "echasnovski/mini.pairs",
        event = "VeryLazy",
        opts = {
            modes = { insert = true, command = true, terminal = false },
            -- skip autopair when next character is one of these
            skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
            -- skip autopair when the cursor is inside these treesitter nodes
            skip_ts = { "string" },
            -- skip autopair when next character is closing pair
            -- and there are more closing pairs than opening pairs
            skip_unbalanced = true,
            -- better deal with markdown code blocks
            markdown = true,
        },
    },

    -- comment strings
    {
        "folke/ts-comments.nvim",
        event = "VeryLazy",
        opts = {},
    },

    -- autocomplete
    {
        "hrsh7th/nvim-cmp",
        version = false, -- last release is way too old
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
        },
        opts = function()
            local cmp = require("cmp");

            return {
                snippet = {
                    -- NOTE: snippet engine is required
                    expand = function(args)
                        vim.snippet.expand(args.body);
                    end,
                },
                auto_brackets = {},
                completion = {
                    complete_opt = "menu, menuone, noinsert",
                },
                -- Specify sources and limit the number for each source to prevent visual clutter
                sources = cmp.config.sources({
                    { name = "nvim_lsp", max_item_count = 8 },
                    { name = "buffer",   max_item_count = 4 },
                }),
                mapping = cmp.mapping.preset.insert({
                    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-e>'] = cmp.mapping.abort(),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
                }),
                -- Set up lspconfig.
                capabilities = require('cmp_nvim_lsp').default_capabilities(),
            }
        end,
    },

    -- autoformatting for special cases
    {
        'stevearc/conform.nvim',
        config = function()
            require("conform").setup({

                formatters_by_ft = {
                    lua = { "stylua", lsp_format = "fallback" },
                    cpp = { "clang_format" },
                    c = { "clang_format" }
                },

                format_on_save = function(bufnr)
                    if vim.bo[bufnr].filetype == "cpp" then
                        return nil
                    end
                    return {
                        timeout_ms = 500,
                        lsp_fallback = true,
                    }
                end,
            });
        end,
    },

    -- repl for debugging lua
    { 'rafcamlet/nvim-luapad', requires = "antoinemadec/FixCursorHold.nvim" },

    -- LEAN integration
    {
        "Julian/lean.nvim",
        event = { "BufReadPre *.lean", "BufNewFile *.lean" },
        dependencies = {
            -- "neovim/nvim-lspconfig",
            "nvim-lua/plenary.nvim",
            -- optional but recommended:
            "hrsh7th/nvim-cmp", -- completion
            "hrsh7th/cmp-nvim-lsp",
        },
        opts = {
            mappings = true, -- enables default keymaps
        },
    },
}
