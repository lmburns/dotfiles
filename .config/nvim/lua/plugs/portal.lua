local M = {}

local D = require("dev")
local portal = D.npcall(require, "portal")
if not portal then
    return
end

local style = require("style")
local utils = require("common.utils")
local map = utils.map

local api = vim.api

function M.setup()
    portal.setup(
        {
            ---The default queries used when searching the jumplist. An entry can
            ---be a name of a registered query item, an anonymous predicate, or
            ---a well-formed query item. See Queries section for more information.
            ---@type Portal.QueryLike[]
            query = {"modified", "different", "valid"},
            ---An ordered list of keys that will be used for labelling available jumps.
            ---Labels will be applied in same order as `query`.
            ---@type string[]
            labels = {"j", "k", "h", "l"},
            ---Keys used for exiting portal selection. To disable a key, set its value
            ---to `nil` or `false`.
            ---@type table<string, boolean | nil>
            escape = {
                ["<esc>"] = true
            },
            ---The jumplist is fixed at 100 items, which has the possibility to impact
            ---portal performance. Set this to a value less than 100 to limit the number
            ---of jumps in the jumplist that will be queried.
            lookback = 100,
            ---Keycodes used for jumping forward and backward. These are not overrides
            ---of the current keymaps, but instead will be used internally when a jump
            ---is selected.
            backward = "<c-o>",
            forward = "<c-i>",
            portal = {
                render_empty = true,
                ---feat(nvim-0.9) The raw window options used for the portal window
                options = {
                    relative = "win",
                    width = 80, -- implement as "min/max width",
                    height = 3, -- implement as "context lines"
                    col = (api.nvim_win_get_width(0) - 80) / 2,
                    row = (api.nvim_win_get_height(0) - 3) / 2,
                    style = "minimal",
                    focusable = false,
                    border = style.current.border,
                    noautocmd = true
                },
                title = {
                    --- When a portal is empty, render an default portal title
                    render_empty = true,
                    --- The raw window options used for the portal title window
                    options = {
                        relative = "win",
                        width = 80,
                        height = 1,
                        col = (api.nvim_win_get_width(0) - 80) / 2,
                        row = (api.nvim_win_get_height(0) - 1) / 2,
                        style = "minimal",
                        focusable = false,
                        border = style.current.border,
                        noautocmd = true,
                        zindex = 98
                    }
                },
                body = {
                    -- When a portal is empty, render an empty buffer body
                    render_empty = false,
                    --- The raw window options used for the portal body window
                    options = {
                        relative = "win",
                        width = 80,
                        height = 3,
                        col = (api.nvim_win_get_width(0) - 80) / 2,
                        row = (api.nvim_win_get_height(0) - 3) / 2,
                        focusable = false,
                        border = style.current.border,
                        noautocmd = true,
                        zindex = 99
                    }
                }
            },
            integrations = {
                ---cbochs/grapple.nvim: registers the "grapple" query item
                grapple = false,
                ---ThePrimeagen/harpoon: registers the "harpoon" query item
                harpoon = false
            }
        }
    )
end

local function init()
    M.setup()

    map("n", "<C-A-o>", portal.jump_backward, {desc = "Portal: jump backward"})
    map("n", "<C-A-i>", portal.jump_forward, {desc = "Portal: jump forward"})
end

init()

return M
