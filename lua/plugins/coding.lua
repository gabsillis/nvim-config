return {

    -- LSP setup
    {
        'neovim/nvim-lspconfig',
        event = { "BufReadPre", "BufWritePost", "BufNewFile" },

        dependencies = {
            'williamboman/mason-lspconfig.nvim',
            dependencies = { 'williamboman/mason.nvim', command = "Mason" },

            config = function()
                require('mason-lspconfig').setup({
                    ensure_installed = {
                        'clangd',
                        'lua_ls',
                        'rust_analyzer'
                    },
                })
                -- automagiacally set up newly installed servers
                require("mason-lspconfig").setup_handlers {

                    -- default handler
                    function(server_name)
                        require("lspconfig")[server_name].setup {}
                    end,

                    -- custom handlers here
                    ["lua_ls"] = function()
                        require("lspconfig")["lua_ls"].setup {
                            on_init = function(client)
                                if client.workspace_folders then
                                    local path = client.workspace_folders[1].name;
                                    if vim.loop.fs_stat(path .. '/.luarc.json') or vim.loop.fs_stat(path .. '/.luarc.jsonc') then
                                        return
                                    end
                                end

                                client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
                                    runtime = { version = 'LuaJIT' },
                                    workspace = {
                                        checkThirdParty = false,
                                        library = { vim.env.VIMRUNTIME }
                                    },
                                })
                            end,
                            settings = {
                                Lua = {}
                            }
                        }
                    end,
                }
            end,
        }
    },
    {
        'williamboman/mason.nvim',
        keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
        opts = {
            ui = { border = 'single' },
            PATH = 'append',
        },
        config = function(_, opts) require('mason').setup(opts) end,
    },

    -- Treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        version = false,
        build = ":TSUpdate",
        event = { "BufReadPre", "BufWritePost", "BufNewFile", "VeryLazy" },
        lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening file from the cmdline
        init = function(plugin)
            -- PERF: add nvim-treesitter queries to the rtp and it's custom query predicates early
            -- This is needed because a bunch of plugins no longer `require("nvim-treesitter")`, which
            -- no longer trigger the **nvim-treesitter** module to be loaded in time.
            -- Luckily, the only things that those plugins need are the custom queries, which we make available
            -- during startup.
            require("lazy.core.loader").add_to_rtp(plugin);
            require("nvim-treesitter.query_predicates");
        end,
        cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
        keys = {
            { "<c-space>", desc = "Increment Selection" },
            { "<bs>",      desc = "Decrement Selection", mode = "x" },
        },

        opts = {
            highlight = { enable = true },
            indent = { enable = false },
            ensure_installed = {
                "bash",
                "c",
                "cpp",
                "diff",
                "html",
                "javascript",
                "jsdoc",
                "json",
                "jsonc",
                "lua",
                "luadoc",
                "luap",
                "markdown",
                "markdown_inline",
                "printf",
                "python",
                "query",
                "regex",
                "toml",
                "tsx",
                "typescript",
                "vim",
                "vimdoc",
                "xml",
                "yaml",
            },
        },
        ---@param opts TSConfig
        config = function(_, opts)
            require("nvim-treesitter.configs").setup(opts)
        end,
    },

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
                },

                format_on_save = {
                    timeout_ms = 500,
                },
            });
        end,
    },
}
