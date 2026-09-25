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

local MEM_LIMIT  = "12G" -- hard cap: clangd is killed if it exceeds this
local INDEX_JOBS = 1    -- background-index workers, each holds an AST

-- Wrap clangd so a runaway can't take the box down.
local function wrap_with_limit(cmd)
    if vim.uv.os_uname().sysname == "Linux"
        and vim.fn.executable("systemd-run") == 1
        and vim.env.XDG_RUNTIME_DIR
    then
        return vim.list_extend({
            "systemd-run", "--user", "--scope", "--quiet", "--collect",
            "-p", "MemoryMax=" .. MEM_LIMIT,
            "-p", "MemorySwapMax=0", -- no swap thrash; die fast instead
            "--",
        }, cmd)
    end
    -- macOS / no systemd: coarser (address space, not RSS) and often a no-op,
    -- but harmless -- exec still runs if ulimit is rejected.
    local kb = tonumber(MEM_LIMIT:match("^(%d+)G")) * 1024 * 1024
    return vim.list_extend(
        { "sh", "-c", ("ulimit -v %d 2>/dev/null; exec \"$@\""):format(kb), "sh" },
        cmd
    )
end

local function get_clangd_cmd()
    return wrap_with_limit({
        "clangd",
        "--header-insertion=never",
        "--log=error",
        "--malloc-trim",
        "--pch-storage=disk",     -- preambles to disk, not RAM
        "-j=" .. INDEX_JOBS,
        "--limit-references=100",
        "--limit-results=100",
        "--background-index=false",
    })
end

local clang_capabilities = vim.lsp.protocol.make_client_capabilities()
clang_capabilities.general.positionEncodings = { "utf-16" }

vim.lsp.config('clangd', {
    filetypes = { 'c', 'cpp', 'cuda' },
    cmd = get_clangd_cmd(),
    capabilities = clang_capabilities,
    on_exit = function(code, signal)
        if signal == 9 or code == 137 then
            vim.schedule(function()
                vim.notify(("clangd hit the %s cap and was killed."):format(MEM_LIMIT),
                    vim.log.levels.ERROR)
            end)
        end
    end,
})

-- :ClangdMem -- where the memory actually is (index vs. ASTs vs. preambles)
vim.api.nvim_create_user_command("ClangdMem", function()
    local client = vim.lsp.get_clients({ name = "clangd", bufnr = 0 })[1]
    if not client then
        return vim.notify("clangd not attached", vim.log.levels.WARN)
    end
    client:request("$/memoryUsage", vim.empty_dict(), function(err, res)
        if err or not res then
            return vim.notify("memoryUsage failed", vim.log.levels.ERROR)
        end
        local function mb(n) return string.format("%8.1f MB", (n or 0) / 1048576) end
        local out = { "clangd total " .. mb(res._total) }
        for _, c in ipairs(res._children or {}) do
            table.insert(out, ("  %-24s%s"):format(c.name or "?", mb(c._total)))
        end
        vim.notify(table.concat(out, "\n"))
    end, 0)
end, {})

vim.lsp.log.set_level(vim.log.levels.WARN)
vim.lsp.enable('clangd')
