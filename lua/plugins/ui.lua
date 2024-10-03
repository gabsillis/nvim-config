return {

    -- Tokyo Night color scheme
    -- available on startup
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            -- load the colorscheme here
            vim.cmd([[colorscheme tokyonight]])
        end,
    },

    -- startup time profiling
    {
        "dstein64/vim-startuptime",
        -- lazy-load on a command
        cmd = "StartupTime",
        -- init is called during startup. Configuration for vim plugins typically should be set in an init function
        init = function()
            vim.g.startuptime_tries = 10
        end,
    },

    -- web icons
    { "nvim-tree/nvim-web-devicons", lazy = true },

    -- display keymaps
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            spec = {
                mode = { "n", "v" },
                { "<leader>c", group = "code" },
                { "<leader>f", group = "file/find" },
            }
        },
        config = function(_, opts)
            local wk = require("which-key")
            wk.setup(opts)
        end,
    },

    -- Telescope my beloved finder of stuff :3
    {
        "nvim-telescope/telescope.nvim",
        keys = {
            -- find files
            { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
            { "<leader>fg", "<cmd>Telescope git_files<cr>",  desc = "Find git files" },

            -- live grep
            { "<leader>/",  "<cmd>Telescope live_grep<cr>",  desc = "Live grep" },
        }
    },

    -- neo-tree the file explorer tree (from LazyVim)
    {
        "nvim-neo-tree/neo-tree.nvim",
        cmd = "Neotree",
        keys = {
            {
                "<leader>fe",
                function()
                    require("neo-tree.command").execute({ toggle = true })
                end,
                desc = "Explorer NeoTree (Root Dir)",
            },
            {
                "<leader>fE",
                function()
                    require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
                end,
                desc = "Explorer NeoTree (cwd)",
            },
            { "<leader>e", "<leader>fe", desc = "Explorer NeoTree (Root Dir)", remap = true },
            { "<leader>E", "<leader>fE", desc = "Explorer NeoTree (cwd)",      remap = true },
            {
                "<leader>ge",
                function()
                    require("neo-tree.command").execute({ source = "git_status", toggle = true })
                end,
                desc = "Git Explorer",
            },
            {
                "<leader>be",
                function()
                    require("neo-tree.command").execute({ source = "buffers", toggle = true })
                end,
                desc = "Buffer Explorer",
            },
        },
        deactivate = function()
            vim.cmd([[Neotree close]])
        end,
        init = function()
            -- FIX: use `autocmd` for lazy-loading neo-tree instead of directly requiring it,
            -- because `cwd` is not set up properly.
            vim.api.nvim_create_autocmd("BufEnter", {
                group = vim.api.nvim_create_augroup("Neotree_start_directory", { clear = true }),
                desc = "Start Neo-tree with directory",
                once = true,
                callback = function()
                    if package.loaded["neo-tree"] then
                        return
                    else
                        local stats = vim.uv.fs_stat(vim.fn.argv(0))
                        if stats and stats.type == "directory" then
                            require("neo-tree")
                        end
                    end
                end,
            })
        end,
        opts = {
            sources = { "filesystem", "buffers", "git_status" },
            open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
            filesystem = {
                bind_to_cwd = false,
                follow_current_file = { enabled = true },
                use_libuv_file_watcher = true,
            },
            window = {
                mappings = {
                    ["l"] = "open",
                    ["h"] = "close_node",
                    ["<space>"] = "none",
                    ["Y"] = {
                        function(state)
                            local node = state.tree:get_node()
                            local path = node:get_id()
                            vim.fn.setreg("+", path, "c")
                        end,
                        desc = "Copy Path to Clipboard",
                    },
                    ["O"] = {
                        function(state)
                            require("lazy.util").open(state.tree:get_node().path, { system = true })
                        end,
                        desc = "Open with System Application",
                    },
                    ["P"] = { "toggle_preview", config = { use_float = false } },
                },
            },
            default_component_configs = {
                indent = {
                    with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
                    expander_collapsed = "",
                    expander_expanded = "",
                    expander_highlight = "NeoTreeExpander",
                },
                git_status = {
                    symbols = {
                        unstaged = "󰄱",
                        staged = "󰱒",
                    },
                },
            },
        },
        config = function(_, opts)
            local events = require("neo-tree.events")
            opts.event_handlers = opts.event_handlers or {}
            require("neo-tree").setup(opts)
            vim.api.nvim_create_autocmd("TermClose", {
                pattern = "*lazygit",
                callback = function()
                    if package.loaded["neo-tree.sources.git_status"] then
                        require("neo-tree.sources.git_status").refresh()
                    end
                end,
            })
        end,
    },

    -- make stuff look noice
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        opts = {
            lsp = {
                -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                    ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
                },
            },
            -- you can enable a preset for easier configuration
            presets = {
                bottom_search = true,         -- use a classic bottom cmdline for search
                command_palette = true,       -- position the cmdline and popupmenu together
                long_message_to_split = true, -- long messages will be sent to a split
                inc_rename = false,           -- enables an input dialog for inc-rename.nvim
                lsp_doc_border = false,       -- add a border to hover docs and signature help
            },
        }
    },

    -- buffer tabs
    {
        "akinsho/bufferline.nvim",
        event = "VeryLazy",
        enabled = true,
        opts = {
            options = {
                close_command = function(n) require("config.ui").bufremove(n) end,
                right_mouse_command = function(n) require('config.ui').bufremove(n) end,
                diagnostics = "nvim_lsp",
                always_show_bufferline = false,
                diagnostics_indicator = function(_, _, diag)
                    local icons = require("config.ui").icons.diagnostics
                    local ret = (diag.error and icons.Error .. diag.error .. " " or "")
                        .. (diag.warning and icons.Warn .. diag.warning or "")
                    return vim.trim(ret)
                end,

                offsets = {
                    {
                        filetype = "neo-tree",
                        text = "neo-tree",
                        highlight = "Directory",
                        text_align = "left",
                    },
                },
            },
        },
        keys = {
            { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
            { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
        },
    },

    -- info line at the bottom
    {
        "nvim-lualine/lualine.nvim",

        opts = {
            extension = { 'nvim-tree' },
            disable_filetypes = {
                statusline = { "dashboard", "alpha", "starter" },
                winbar = {
                    "help",
                    "starter",
                    "startify",
                    "dashboard",
                    "packer",
                    "neogitstatus",
                    "NvimTree",
                    "Trouble",
                    "alpha",
                    "lir",
                    "Outline",
                    "spectre_panel",
                    "toggleterm",
                },
            },


            winbar = {
                lualine_a = {},
                lualine_b = {
                    { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
                    {
                        "filename",
                        file_status = true,
                        symbols = {
                            modified = ' ●',
                        },
                    }
                },
                lualine_c = {
                    'diagnostics',
                    {
                        sources = { 'nvim_diagnostic' },
                        symbols = { error = ' ', warn = ' ', info = ' ' },
                        diagnostics_color = {
                            color_error = { fg = '#ed5149' },
                            color_warn = { fg = '#f7dd4c' },
                            color_info = { fg = '#4deaea' },
                        }
                    }
                },
                lualine_x = {},
                lualine_y = {},
                lualine_z = {},
            },
            inactive_winbar = {
                lualine_a = {},
                lualine_b = {
                    { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
                    {
                        "filename",
                        file_status = true,
                        symbols = {
                            modified = ' ●',
                        },
                    }
                },
                lualine_c = {},
                lualine_x = {},
                lualine_y = {},
                lualine_z = {},
            }
        }
    },

    -- pretty and interative folds
    {
        "kevinhwang91/nvim-ufo",
        dependencies = { "kevinhwang91/promise-async" },
        event = "VeryLazy",

        config = function()
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities.textDocument.foldingRange = {
                dynamicRegistration = false,
                lineFoldingOnly = true
            }
            local language_servers = require("lspconfig").util.available_servers() -- or list servers manually like {'gopls', 'clangd'}
            for _, ls in ipairs(language_servers) do
                require('lspconfig')[ls].setup({
                    capabilities = capabilities
                    -- you can add other fields for setting up lsp server in this table
                })
            end
            require('ufo').setup({})
        end,
    },


    -- diagnostics list and stuff (using LazyVim setup)
    {
        "folke/trouble.nvim",
        cmd = { "Trouble" },
        opts = {
            modes = {
                lsp = {
                    win = { position = "right" },
                },
            },
        },
        keys = {
            { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",              desc = "Diagnostics (Trouble)" },
            { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
            { "<leader>cs", "<cmd>Trouble symbols toggle<cr>",                  desc = "Symbols (Trouble)" },
            { "<leader>cS", "<cmd>Trouble lsp toggle<cr>",                      desc = "LSP references/definitions/... (Trouble)" },
            { "<leader>xL", "<cmd>Trouble loclist toggle<cr>",                  desc = "Location List (Trouble)" },
            { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>",                   desc = "Quickfix List (Trouble)" },
            {
                "[q",
                function()
                    if require("trouble").is_open() then
                        require("trouble").prev({ skip_groups = true, jump = true })
                    else
                        local ok, err = pcall(vim.cmd.cprev)
                        if not ok then
                            vim.notify(err, vim.log.levels.ERROR)
                        end
                    end
                end,
                desc = "Previous Trouble/Quickfix Item",
            },
            {
                "]q",
                function()
                    if require("trouble").is_open() then
                        require("trouble").next({ skip_groups = true, jump = true })
                    else
                        local ok, err = pcall(vim.cmd.cnext)
                        if not ok then
                            vim.notify(err, vim.log.levels.ERROR)
                        end
                    end
                end,
                desc = "Next Trouble/Quickfix Item",
            },
        },
    },

    -- highlight TODO: and stuff (using LazyVim) setup
    {
        "folke/todo-comments.nvim",
        cmd = { "TodoTrouble", "TodoTelescope" },
        event = { "BufReadPre", "BufWritePost", "BufNewFile", "VeryLazy" },
        opts = {},
        -- stylua: ignore
        keys = {
            { "]t",         function() require("todo-comments").jump_next() end,              desc = "Next Todo Comment" },
            { "[t",         function() require("todo-comments").jump_prev() end,              desc = "Previous Todo Comment" },
            { "<leader>xt", "<cmd>Trouble todo toggle<cr>",                                   desc = "Todo (Trouble)" },
            { "<leader>xT", "<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>", desc = "Todo/Fix/Fixme (Trouble)" },
            { "<leader>st", "<cmd>TodoTelescope<cr>",                                         desc = "Todo" },
            { "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>",                 desc = "Todo/Fix/Fixme" },
        },
    },

    -- Signs for Git and keys for auto doing stuff with git
    -- from LazyVim
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufWritePost", "BufNewFile" },
        opts = {
            signs = {
                add = { text = "▎" },
                change = { text = "▎" },
                delete = { text = "" },
                topdelete = { text = "" },
                changedelete = { text = "▎" },
                untracked = { text = "▎" },
            },
            signs_staged = {
                add = { text = "▎" },
                change = { text = "▎" },
                delete = { text = "" },
                topdelete = { text = "" },
                changedelete = { text = "▎" },
            },
            on_attach = function(buffer)
                local gs = package.loaded.gitsigns

                local function map(mode, l, r, desc)
                    vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
                end

                -- stylua: ignore start
                map("n", "]h", function()
                    if vim.wo.diff then
                        vim.cmd.normal({ "]c", bang = true })
                    else
                        gs.nav_hunk("next")
                    end
                end, "Next Hunk")
                map("n", "[h", function()
                    if vim.wo.diff then
                        vim.cmd.normal({ "[c", bang = true })
                    else
                        gs.nav_hunk("prev")
                    end
                end, "Prev Hunk")
                map("n", "]H", function() gs.nav_hunk("last") end, "Last Hunk")
                map("n", "[H", function() gs.nav_hunk("first") end, "First Hunk")
                map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
                map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
                map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
                map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
                map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
                map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
                map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
                map("n", "<leader>ghB", function() gs.blame() end, "Blame Buffer")
                map("n", "<leader>ghd", gs.diffthis, "Diff This")
                map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
                map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
            end,
        },
    },
}
