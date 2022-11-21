local M = {}

local D = require("dev")
local paint = D.npcall(require, "paint")
if not paint then
    return
end

local hl = require("common.color")
local colors = require("kimbox.palette").colors

local fn = vim.fn

function M.setup()
    -- Use this to make sure the highlighting starts at the beginning of comment
    -- Would probably need to be reloaded when filetypes are switched
    local comment = vim.trim(fn.split(vim.bo.commentstring, "%s")[1])

    paint.setup(
        {
            -- @type PaintHighlight[]
            highlights = {
                {
                    -- @type Example
                    filter = {filetype = "lua"},
                    pattern = "%s?(@[%w]+)",
                    -- pattern = "%s*%-%-%-%s*(@%w+)",
                    hl = "PaintType"
                },
                {
                    -- TITLE_CASE: Here
                    filter = function(bufnr)
                        if _t({"markdown", "vimwiki"}):contains(vim.bo[bufnr].ft) then
                            return false
                        end
                        return true
                    end,
                    pattern = comment .. "%s?([%u_]+):",
                    hl = "PaintTag"
                },
                {
                    -- #33: Issue number
                    -- (#33): Issue number
                    filter = function(bufnr)
                        if _t({"markdown", "vimwiki"}):contains(vim.bo[bufnr].ft) then
                            return false
                        end
                        return true
                    end,
                    pattern = comment .. "%s?(%(?#[%d]+%)?):",
                    hl = "PaintTag"
                },
                -- {
                --     -- @user123:
                --     filter = {filetype = "lua"},
                --     pattern = "%s?(@[%a%d_-]+)",
                --     hl = "ErrorMsg"
                -- },
                {
                    filter = {filetype = "c"},
                    -- pattern = "%s*%/%/%/%s*(@%w+)",
                    pattern = "%s?(@%w+)",
                    hl = "@parameter"
                },
                {
                    filter = {filetype = "python"},
                    -- pattern = "%s*%/%/%/%s*(@%w+)",
                    pattern = "%s?(@%w+)",
                    hl = "@parameter"
                },
                {
                    filter = {filetype = "markdown"},
                    pattern = "%*.-%*", -- *foo*
                    hl = "Title"
                },
                {
                    filter = {filetype = "markdown"},
                    pattern = "%*%*.-%*%*", -- **foo**
                    hl = "Error"
                },
                {
                    filter = {filetype = "markdown"},
                    pattern = "%s_.-_", --_foo_
                    hl = "MoreMsg"
                },
                {
                    filter = {filetype = "markdown"},
                    pattern = "%s%`.-%`", -- `foo`
                    hl = "Keyword"
                },
                {
                    filter = {filetype = "markdown"},
                    pattern = "%`%`%`.*", -- ```foo<CR>...<CR>```
                    hl = "MoreMsg"
                }
            }
        }
    )
end

local function init()
    hl.set("PaintTag", {fg = colors.oni_violet, bold = true})
    hl.set("PaintType", {fg = colors.vista_blue})

    M.setup()
end

init()

return M
