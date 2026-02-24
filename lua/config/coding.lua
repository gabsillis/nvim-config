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
        "--clang-tidy",
        "--header-insertion=never"
    }
end
vim.lsp.config('clangd', {
    cmd = get_clangd_cmd(),
})
