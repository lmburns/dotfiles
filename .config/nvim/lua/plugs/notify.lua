---@module 'plugs.notify'
local M = {}

local shared = require("usr.shared")
local F = shared.F
local notify = F.npcall(require, "notify")
if not notify then
    return
end

local log = require("usr.lib.log")
local style = require("usr.style")

local api = vim.api
local env = vim.env

local max_width = 65

function M.setup()
    ---@type table<string, fun(bufnr: number, notif: table, highlights: table, config: table)>
    local renderer = require("notify.render")
    -- local stages_util = require("notify.stages.util")

    notify.setup({
        level = env.NVIM_NOTIFY or log.levels.INFO,
        stages = "fade_in_slide_out", -- slide
        top_down = true,
        fps = 60,
        timeout = 3000,
        max_width = nil,
        max_height = nil,
        minimum_width = 30,
        background_color = "NormalFloat",
        -- max_width = math.floor(vim.o.columns * 0.4),
        -- on_close = function()
        -- -- Could create something to write to a file
        -- end,
        on_open = function(winnr)
            if api.nvim_win_is_valid(winnr) then
                api.nvim_win_set_config(winnr, {
                    border = style.current.border,
                    zindex = 500,
                })
            end
            local bufnr = api.nvim_win_get_buf(winnr)
            -- bmap(bufnr, "n", "q", "<Cmd>bdelete<CR>", {nowait = true})

            api.nvim_buf_call(bufnr, function()
                vim.wo[winnr].wrap = true
                vim.wo[winnr].showbreak = "NONE"
            end)
        end,
        render = function(bufnr, notif, highlights, config)
            ---@type RenderType
            local style =
                F.if_expr(notif.title[1] == "", "minimal",
                    F.if_expr(notif.title[2] and not notif.title[2]:match("%d%d:%d%d"), "default",
                        F.if_expr(#notif.title[1] + #notif.message[1] <= max_width, "compact",
                            "default"
                        )
                    )
                )

            -- local style = notif.title[1] == "" and "minimal" or "default"
            renderer[style](bufnr, notif, highlights, config)
        end,
        icons = style.plugins.notify,
    })
end

local function init()
    M.setup()

    -- Mappings are set in mappings.lua
    -- They need to be set earlier in case there is an error loading modules
    -- So that way I can actually close the notification

    require("telescope").load_extension("notify")
end

init()

return M
