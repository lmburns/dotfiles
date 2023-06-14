---@module 'plugs.paint'
local M = {}

local F = Rc.F
local paint = F.npcall(require, "paint")
if not paint then
    return
end

local hl = Rc.shared.hl
local colors = require("kimbox.colors")

local ignore

local function filter(filetypes, bufnr)
    return F.if_expr(_j(filetypes):contains(vim.bo[bufnr].ft), true, false)
end

local function filter_ignore(bufnr)
    return not filter(ignore, bufnr)
end

local function tmux(pattern, hl)
    return {filter = {filetype = "tmux"}, pattern = pattern, hl = hl}
end

local function ecma(pattern, hl)
    return {
        filter = F.thunk(filter, {
            "typescript",
            "typescriptreact",
            "javascript",
        }),
        pattern = pattern,
        hl = hl,
    }
end

local function md(pattern, hl)
    return {
        filter = F.thunk(filter, {"markdown", "vimwiki"}),
        pattern = pattern,
        hl = hl,
    }
end

function M.setup()
    -- local bufnr = api.nvim_get_current_buf()
    -- local comment = vim.split(vim.bo[bufnr].commentstring, "%s", {trimempty = true})[1] or "#"

    paint.setup({
        ---@type PaintHighlight[]
        highlights = {
            {
                -- URL: http://github.com/lmburns
                filter = F.thunk(filter_ignore),
                pattern = [==[[%l][%l%d+-]*://[%a%d#%%_.!~*'();/?:@&=+$,-]+]==],
                hl = "PaintURL",
            },
            {
                -- URL: www.github.com/lmburns
                filter = F.thunk(filter_ignore),
                pattern = [==[www%.[%a%d#%%_.!~*'();/?:@&=+$,-]*]==],
                hl = "PaintURL",
            },
            {
                -- Time: 08:22:22 PM
                -- [0-9]{1,2}:[0-9]{2}(:[0-9]{2})?( ?(AM|PM|am|pm))?(+[+-][0-9]{4})?
                filter = F.thunk(filter_ignore),
                pattern = [==[%d?%d:%d%d:?%d?%d?%s?[am]*[AM]*[pm]*[PM]*]==],
                hl = "PaintURL",
            },
            {
                filter = {filetype = "python"},
                pattern = "%s?([@][%w%p_-]+):", -- @tag:
                hl = "@keyword.luadoc",
            },
            {
                filter = {filetype = "c"},
                pattern = "%s*%*%s*(@[%w_-.]+)", -- @tag:
                hl = "@keyword.luadoc",
            },
            --  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            -- tmux("%s*#%s*(%[.-]:)", "@method"),
            -- tmux("%s*#%s*@(.*)", "Constant"),
            -- tmux("<prefix>", "@attribute"),
            -- tmux("<prefix> (%+)", "@constructor"),
            -- tmux("<prefix> %+ (.+)", "@character"),
            -- tmux("<prefix> %+ (.+)", "@character"),
            --  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            --     -- ---@tag
            --     pattern = "%s*%-%-%-%s*(@%w+)",
            --     hl = "Constant",
            --
            --     -- *foo*
            --     pattern = "%*.-%*",
            --     hl = "Title"
            --
            --     -- **foo**
            --     pattern = "%*%*.-%*%*",
            --     hl = "Error"
            --
            --     -- _foo_
            --     pattern = "%s_.-_",
            --     hl = "MoreMsg"
            --
            --     -- `foo`
            --     pattern = "%s%`.-%`",
            --     hl = "Keyword"
            --
            --     -- ```foo<CR>...<CR>```
            --     pattern = "%`%`%`.*",
            --     hl = "MoreMsg"
            --
            --     -- TITLE_CASE:
            --     pattern = comment:escape() .. "%s?([%u_]+):",
            --     hl = "PaintTag"
            --
            --     -- #33: Issue number -- (#33): Issue number
            --     pattern = comment:escape() .. "%s?(%(?#[%d]+%)?):",
            --     hl = "PaintTag"
            -- }
        },
    })
end

local function init()
    hl.set("PaintTag", {fg = colors.oni_violet, bold = true})
    hl.set("PaintType", {fg = colors.vista_blue})
    hl.set("PaintURL", {fg = colors.deep_lilac, bold = true})

    ignore = Rc.blacklist.ft:merge({"markdown", "vimwiki", "mail"})

    -- Needs to be deferred otherwise comment is incorrect
    vim.schedule(function()
        M.setup()
    end)
end

init()

return M
