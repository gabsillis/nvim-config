-- Returns a list of regular and extmark signs sorted by priority (low to high)
---@return Sign[]
---@param buf number
---@param lnum number
local get_signs = function(buf, lnum)
    -- Get regular signs
    ---@type Sign[]
    local signs = {}

    if vim.fn.has("nvim-0.10") == 0 then
        -- Only needed for Neovim <0.10
        -- Newer versions include legacy signs in nvim_buf_get_extmarks
        for _, sign in ipairs(vim.fn.sign_getplaced(buf, { group = "*", lnum = lnum })[1].signs) do
            local ret = vim.fn.sign_getdefined(sign.name)[1] --[[@as Sign]]
            if ret then
                ret.priority = sign.priority
                signs[#signs + 1] = ret
            end
        end
    end

    -- Get extmark signs
    local extmarks = vim.api.nvim_buf_get_extmarks(
        buf,
        -1,
        { lnum - 1, 0 },
        { lnum - 1, -1 },
        { details = true, type = "sign" }
    )
    for _, extmark in pairs(extmarks) do
        signs[#signs + 1] = {
            name = extmark[4].sign_hl_group or extmark[4].sign_name or "",
            text = extmark[4].sign_text,
            texthl = extmark[4].sign_hl_group,
            priority = extmark[4].priority,
        }
    end

    -- Sort by priority
    table.sort(signs, function(a, b)
        return (a.priority or 0) < (b.priority or 0)
    end)

    return signs
end

local get_mark = function(buf, lnum)
    local marks = vim.fn.getmarklist(buf)
    vim.list_extend(marks, vim.fn.getmarklist())
    for _, mark in ipairs(marks) do
        if mark.pos[1] == buf and mark.pos[2] == lnum and mark.mark:match("[a-zA-Z]") then
            return { text = mark.mark:sub(2), texthl = "DiagnosticHint" }
        end
    end
end


---@param sign? Sign
---@param len? number
local icon = function(sign, len)
    sign = sign or {}
    len = len or 2
    local text = vim.fn.strcharpart(sign.text or "", 0, len) ---@type string
    text = text .. string.rep(" ", len - vim.fn.strchars(text))
    return sign.texthl and ("%#" .. sign.texthl .. "#" .. text .. "%*") or text
end

return {

    -- centralized icons list
    -- icons used by other plugins
    -- stylua: ignore
    icons = {
        misc = {
            dots = "󰇘",
        },
        ft = {
            octo = "",
        },
        dap = {
            Stopped             = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
            Breakpoint          = " ",
            BreakpointCondition = " ",
            BreakpointRejected  = { " ", "DiagnosticError" },
            LogPoint            = ".>",
        },
        diagnostics = {
            Error = " ",
            Warn  = " ",
            Hint  = " ",
            Info  = " ",
        },
        git = {
            added    = " ",
            modified = " ",
            removed  = " ",
        },
        kinds = {
            Array         = " ",
            Boolean       = "󰨙 ",
            Class         = " ",
            Codeium       = "󰘦 ",
            Color         = " ",
            Control       = " ",
            Collapsed     = " ",
            Constant      = "󰏿 ",
            Constructor   = " ",
            Copilot       = " ",
            Enum          = " ",
            EnumMember    = " ",
            Event         = " ",
            Field         = " ",
            File          = " ",
            Folder        = " ",
            Function      = "󰊕 ",
            Interface     = " ",
            Key           = " ",
            Keyword       = " ",
            Method        = "󰊕 ",
            Module        = " ",
            Namespace     = "󰦮 ",
            Null          = " ",
            Number        = "󰎠 ",
            Object        = " ",
            Operator      = " ",
            Package       = " ",
            Property      = " ",
            Reference     = " ",
            Snippet       = " ",
            String        = " ",
            Struct        = "󰆼 ",
            TabNine       = "󰏚 ",
            Text          = " ",
            TypeParameter = " ",
            Unit          = " ",
            Value         = " ",
            Variable      = "󰀫 ",
        },
    },


    -- Fancy numbering in the statuscolumn
    statuscolumn = function()
        local win = vim.g.statusline_winid;
        local buf = vim.api.nvim_win_get_buf(win);
        local is_file = vim.bo[buf].buftype == "";
        local show_signs = vim.wo[win].signcolumn ~= "no";

        -- colorscheme colors
        local tn_colors = require("tokyonight.colors").setup()

        -- famcy gradient
        local colors = {
            "#4eaa08",
            "#00a13b",
            "#00925f",
            "#008370",
            "#007577",
            "#006778",
            "#005b77",
            "#004d78",
            "#113e6b",
            "#292f56",
        };
        for i, color in ipairs(colors) do
            vim.api.nvim_set_hl(0, "StatuslineGradientFG_" .. i, { fg = color });
            vim.api.nvim_set_hl(0, "StatuslineGradientBG_" .. i, { bg = color });
        end
        -- Border

        local border = function()
            if vim.v.relnum < 9 then
                return "%#StatuslineGradientFG_" .. (vim.v.relnum + 1) .. "#│";
            else
                return "%#StatuslineGradientFG_10#│";
            end
        end

        local apply_bg_gradient = function()
            if vim.v.relnum < 9 then
                return "%#StatuslineGradientBG_" .. (vim.v.relnum + 1) .. "#";
            else
                return "%#StatuslineGradientBG_10#";
            end
        end

        vim.api.nvim_set_hl(0, "colorscheme_bg", { bg = tn_colors.bg });
        local apply_bg_colorscheme = function()
            return "%#colorscheme_bg#";
        end

        -- folds
        local folds = function()
            local foldlevel = vim.fn.foldlevel(vim.v.lnum);
            local foldlevel_before = vim.fn.foldlevel((vim.v.lnum - 1) >= 1 and vim.v.lnum - 1 or 1);
            local foldlevel_after = vim.fn.foldlevel((vim.v.lnum + 1) <= vim.fn.line("$") and (vim.v.lnum + 1) or
                vim.fn.line("$"));


            local foldclosed = vim.fn.foldclosed(vim.v.lnum);

            -- Line has nothing to do with folds so we will skip it
            if foldlevel == 0 then
                return " ";
            end

            -- Line is a closed fold(I know second condition feels unnecessary but I will still add it)
            if foldclosed ~= -1 and foldclosed == vim.v.lnum then
                return "▶";
            end

            -- I didn't use ~= because it couldn't make a nested fold have a lower level than it's parent fold and it's not something I would use
            if foldlevel > foldlevel_before then
                return "▽"
            end

            -- The line is the last line in the fold
            if foldlevel > foldlevel_after then
                return "╰";
            end

            -- Line is in the middle of an open fold
            return "╎";
        end

        -- signs
        local signs = get_signs(buf, vim.v.lnum)

        local left, right
        for _, s in ipairs(signs) do
            if s.name and (s.name:find("GitSign") or s.name:find("MiniDiffSign")) then
                right = s
            else
                left = s
            end
        end
        -- Left: mark or non-git sign
        local left_icon = icon(get_mark(buf, vim.v.lnum) or left)
        --
        local git_or_fold_icon = icon(right);
        if (right == nil) then
            git_or_fold_icon = folds()
        end



        local number = function()
            vim.api.nvim_set_hl(0, "StatuslineCurrentNumber", { fg = tn_colors.orange, bold = true });
            local output;

            -- Adapted from LazyVim
            -- Numbers in Neovim are weird
            -- They show when either number or relativenumber is true
            local is_num = vim.wo[win].number
            local is_relnum = vim.wo[win].relativenumber
            if (is_num or is_relnum) and vim.v.virtnum == 0 then
                if vim.fn.has("nvim-0.11") == 1 then
                    output = "%#StatuslineCurrentNumber#%l" -- 0.11 handles both the current and other lines with %l
                else
                    if vim.v.relnum == 0 then
                        output = is_num and "%#StatuslineCurrentNumber#%l" or
                            "%#StatuslineCurrentNumber#%r"  -- the current line
                    else
                        output = is_relnum and "%r" or "%l" -- other lines
                    end
                end
                output = "%=" .. output .. "" -- right align
            end

            if vim.v.virtnum ~= 0 then
                output = "%="
            end

            return output;
        end;

        return table.concat({
            git_or_fold_icon,
            left_icon,
            number(),
            border(),
        });
    end,

    -- close a buffer nicely
    -- adapted from LazyVim
    bufremove = function(buf)
        buf = buf or 0
        buf = buf == 0 and vim.api.nvim_get_current_buf() or buf

        if vim.bo.modified then
            local choice = vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
            if choice == 0 or choice == 3 then -- 0 for <Esc>/<C-c> and 3 for Cancel
                return
            end
            if choice == 1 then -- Yes
                vim.cmd.write()
            end
        end

        for _, win in ipairs(vim.fn.win_findbuf(buf)) do
            vim.api.nvim_win_call(win, function()
                if not vim.api.nvim_win_is_valid(win) or vim.api.nvim_win_get_buf(win) ~= buf then
                    return
                end
                -- Try using alternate buffer
                local alt = vim.fn.bufnr("#")
                if alt ~= buf and vim.fn.buflisted(alt) == 1 then
                    vim.api.nvim_win_set_buf(win, alt)
                    return
                end

                -- Try using previous buffer
                local has_previous = pcall(vim.cmd, "bprevious")
                if has_previous and buf ~= vim.api.nvim_win_get_buf(win) then
                    return
                end

                -- Create new listed buffer
                local new_buf = vim.api.nvim_create_buf(true, false)
                vim.api.nvim_win_set_buf(win, new_buf)
            end)
        end
        if vim.api.nvim_buf_is_valid(buf) then
            pcall(vim.cmd, "bdelete! " .. buf)
        end
    end
}
