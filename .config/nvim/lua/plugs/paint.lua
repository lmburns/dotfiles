---@module 'plugs.paint'
local M = {}

local D = require("dev")
local paint = D.npcall(require, "paint")
if not paint then
    return
end

local hl = require("common.color")
local colors = require("kimbox.colors")

local F = vim.F

local ignore

local function filter(bufnr)
    return F.if_expr(ignore:contains(vim.bo[bufnr].ft), false, true)
end

function M.setup()
    -- Use this to make sure the highlighting starts at the beginning of comment
    --
    -- local bufnr = api.nvim_get_current_buf()
    -- local comment = vim.split(vim.bo[bufnr].commentstring, "%s", {trimempty = true})[1] or "#"

    paint.setup(
        {
            ---@type PaintHighlight[]
            highlights = {
                -- Filter can be a table of buffer options that should match,
                -- or a function called with buf as param that should return true.
                --
                {
                    -- URL: http://github.com/lmburns
                    filter = function(bufnr)
                        return filter(bufnr)
                    end,
                    pattern = [==[[%l][%l%d+-]*://[%a%d#%%_.!~*'();/?:@&=+$,-]+]==],
                    hl = "PaintURL"
                },
                {
                    -- URL: www.github.com/lmburns
                    filter = function(bufnr)
                        return filter(bufnr)
                    end,
                    pattern = [==[www%.[%a%d#%%_.!~*'();/?:@&=+$,-]*]==],
                    hl = "PaintURL"
                },
                {
                    -- Time: 08:22:22 PM
                    -- [0-9]{1,2}:[0-9]{2}(:[0-9]{2})?( ?(AM|PM|am|pm))?(+[+-][0-9]{4})?
                    filter = function(bufnr)
                        return filter(bufnr)
                    end,
                    -- There's gotta be a better way than this
                    pattern = [==[%d?%d:%d%d:?%d?%d?%s?[am]*[AM]*[pm]*[PM]*]==],
                    hl = "PaintURL"
                }

                -- {
                --     filter = {filetype = "markdown"},
                --     pattern = "%*.-%*", -- *foo*
                --     hl = "Title"
                -- },
                -- {
                --     filter = {filetype = "markdown"},
                --     pattern = "%*%*.-%*%*", -- **foo**
                --     hl = "Error"
                -- },
                -- {
                --     filter = {filetype = "markdown"},
                --     pattern = "%s_.-_", --_foo_
                --     hl = "MoreMsg"
                -- },
                -- {
                --     filter = {filetype = "markdown"},
                --     pattern = "%s%`.-%`", -- `foo`
                --     hl = "Keyword"
                -- },
                -- {
                --     filter = {filetype = "markdown"},
                --     pattern = "%`%`%`.*", -- ```foo<CR>...<CR>```
                --     hl = "MoreMsg"
                -- },
                -- {
                --     filter = {filetype = "c"},
                --     pattern = "%s?([@][%w%p_-]+):", -- @tag:
                --     hl = "@parameter"
                -- },
                -- {
                --     filter = {filetype = "python"},
                --     pattern = "%s?([@][%w%p_-]+):", -- @tag:
                --     hl = "@parameter"
                -- },
                -- {
                --     filter = {filetype = "lua"},
                --     pattern = "%s?([@][%w%p_-]+):", -- @tag:
                --     hl = "PaintType"
                -- },
                -- {
                --     filter = {filetype = "lua"},
                --     pattern = "%s?([@][%w_-]+):", -- @user123:
                --     hl = "ErrorMsg"
                -- },
                -- {
                --     filter = function(bufnr)
                --         if _t({"markdown", "vimwiki"}):contains(vim.bo[bufnr].ft) then
                --             return false
                --         end
                --         return true
                --     end,
                --     pattern = comment:escape() .. "%s?([%u_]+):", -- TITLE_CASE:
                --     hl = "PaintTag"
                -- },
                -- {
                --     filter = function(bufnr)
                --         if _t({"markdown", "vimwiki"}):contains(vim.bo[bufnr].ft) then
                --             return false
                --         end
                --         return true
                --     end,
                --     -- #33: Issue number
                --     -- (#33): Issue number
                --     pattern = comment:escape() .. "%s?(%(?#[%d]+%)?):",
                --     hl = "PaintTag"
                -- }
            }
        }
    )
end

local function init()
    hl.set("PaintTag", {fg = colors.oni_violet, bold = true})
    hl.set("PaintType", {fg = colors.vista_blue})
    hl.set("PaintURL", {fg = colors.deep_lilac, bold = true})

    ignore = _t({"markdown", "vimwiki", "mail"}):merge(BLACKLIST_FT)

    -- Needs to be deferred otherwise comment is incorrect
    vim.schedule(
        function()
            M.setup()
        end
    )
end

init()

return M
