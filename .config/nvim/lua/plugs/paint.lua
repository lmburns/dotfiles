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

---If given filetypes contain current filetype, return true, else false
---@param filetypes string[]
---@param bufnr bufnr
---@return bool
local function filter(filetypes, bufnr)
    return F.tern(_j(filetypes):contains(vim.bo[bufnr].ft), true, false)
end

---If ignored filetypes contain current filetype, return false, else true
---@param bufnr bufnr
---@return bool
local function filter_ignored(bufnr)
    return not filter(ignore, bufnr)
end

---Generate a filetype table for *Paint*
---  - `filter` can be a table of bufopts or a fun(buf):bool
---@param filter string[]|fun(b: bufnr):bool
---@param patt string
---@param hl string
---@return PaintHighlight
local function gen(filter, patt, hl)
    return {filter = filter, pattern = patt, hl = hl}
end
---Generate a filetype table for *Paint*
---@param ft string[]
---@param patt string
---@param hl string
---@return PaintHighlight
local function gen_fn(ft, patt, hl)
    return gen(F.thunk(filter, ft), patt, hl)
end
---@param patt string
---@param hl string
---@return PaintHighlight
local function gen_ign(patt, hl)
    return gen(F.thunk(filter_ignored), patt, hl)
end
---@param ft string
---@param patt string
---@param hl string
---@return PaintHighlight
local function gen_ft(ft, patt, hl)
    return gen({filetype = ft}, patt, hl)
end

-- local function tmux(patt, hl)
--     return gen_ft("tmux", patt, hl)
-- end
-- local function ecma(patt, hl)
--     return gen_fn({"typescript", "typescriptreact", "javascript"}, patt, hl)
-- end
-- local function md(patt, hl)
--     return gen_fn({"markdown", "vimwiki"}, patt, hl)
-- end

function M.setup()
    -- local bufnr = api.nvim_get_current_buf()
    -- local comment = vim.split(vim.bo[bufnr].commentstring, "%s", {trimempty = true})[1] or "#"

    paint.setup({
        ---@type PaintHighlight[]
        highlights = {
            -- URL: http://github.com/lmburns
            -- gen_ign([==[[%l][%l%d+-]*://[%a%d#%%_.!~*'();/?:@&=+$,-]+]==], "PaintURL"),
            --
            -- URL: www.github.com/lmburns
            -- gen_ign([==[www%.[%a%d#%%_.!~*'();/?:@&=+$,-]*]==], "PaintURL"),
            --
            -- Time: 08:22:22 PM
            -- [0-9]{1,2}:[0-9]{2}(:[0-9]{2})?( ?(AM|PM|am|pm))?(+[+-][0-9]{4})?
            gen_ign([==[%d?%d:%d%d:?%d?%d?%s?[am]*[AM]*[pm]*[PM]*]==], "PaintURL"),
            --
            -- @tag
            gen_ft("python", "%s?([@][%w%p._-]+):", "@keyword.luadoc"),
            --
            -- @tag
            gen_ft("c", "%s*%*%s*(@[%w%p_.-]+)", "@keyword.luadoc"),
            --
            -- @tag
            gen_fn({"zsh", "tmux", "lf"}, "%s*#%s*(@[%w%p_.-]+)", "@keyword.luadoc"),
            --
            -- `code`
            gen_fn({"zsh", "tmux", "lf"}, "%s*#.*(%`.-%`)", "@code"),
            --
            -- *bold*
            gen_fn({"zsh", "tmux", "lf"}, "%s*#.*(%*.-%*)", "@bold"),
            --  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            -- gen_ft("tmux", "%s*#%s*(%[.-]:)", "@method"),
            -- gen_ft("tmux", "%s*#%s*@(.*)", "Constant"),
            -- gen_ft("tmux", "<prefix>", "@attribute"),
            -- gen_ft("tmux", "<prefix> (%+)", "@constructor"),
            -- gen_ft("tmux", "<prefix> %+ (.+)", "@character"),
            -- gen_ft("tmux", "<prefix> %+ (.+)", "@character"),
            --  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            ---@tag
            -- gen_ft(ft, "%s*%-%-%-%s*(@%w+)", "Constant"),
            --
            -- *foo*
            -- gen_ft(ft, "%*.-%*", "Title"),
            --
            -- **foo**
            -- gen_ft(ft, "%*%*.-%*%*", "Error"),
            --
            -- _foo_
            -- gen_ft(ft, "%s_.-_", "MoreMsg"),
            --
            -- `foo`
            -- gen_ft(ft, "%s%`.-%`", "Keyword"),
            --
            -- ```foo<CR>...<CR>```
            -- gen_ft(ft, "%`%`%`.*", "MoreMsg"),
            --
            -- TITLE_CASE:
            -- gen_ft(ft, comment:escape() .. "%s?([%u_]+):", "PaintTag"),
            --
            -- #33: Issue number -- (#33): Issue number
            -- gen_ft(ft, comment:escape() .. "%s?(%(?#[%d]+%)?):", "PaintTag"),
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
