-- Set up the lsp config
vim.lsp.config('lua_ls', {
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
    },
})


local function get_clangd_cmd()
    -- TODO: detect hipcc
    -- if vim.fn.executable("hipcc") == 1 then
    --     return {
    --         "clangd",
    --         "--query-driver=/usr/bin/hipcc",
    --     }
    -- else
    --     return {
    --         "clangd"
    --     }
    -- end
    return {
        "clangd",
        "--header-insertion=never",
        "--log=error",
        "--malloc-trim"
    }
end

local clang_capabilities = vim.lsp.protocol.make_client_capabilities()
clang_capabilities.general.positionEncodings = { "utf-16" }

vim.lsp.config('clangd', {
    filetypes = { 'c', 'cpp', 'hpp', 'cuda' },
    cmd = get_clangd_cmd(),
    capabilities = clang_capabilities
})

vim.lsp.log.set_level(vim.log.levels.WARN)
vim.lsp.enable('clangd')
