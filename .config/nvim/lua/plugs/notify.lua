local M = {}

local D = require("dev")
local notify = D.npcall(require, "notify")
if not notify then
    return
end

local log = require("common.log")
local style = require("style")
local wk = require("which-key")

local F = vim.F
local api = vim.api

function M.setup()
    ---@type table<string, fun(bufnr: number, notif: table, highlights: table, config: table)>
    local renderer = require("notify.render")
    -- local stages_util = require("notify.stages.util")

    notify.setup(
        {
            level = log.levels.INFO,
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
                    api.nvim_win_set_config(
                        winnr,
                        {
                            border = style.current.border,
                            zindex = 500
                        }
                    )
                end
                local bufnr = api.nvim_win_get_buf(winnr)
                -- bmap(bufnr, "n", "q", "<Cmd>bdelete<CR>", {nowait = true})

                api.nvim_buf_call(
                    bufnr,
                    function()
                        vim.wo[winnr].wrap = true
                        vim.wo[winnr].showbreak = "NONE"
                    end
                )
            end,
            render = function(bufnr, notif, highlights, config)
                ---@type RenderType
                local style =
                    F.tern(
                    notif.title[1] == "",
                    "minimal",
                    (F.tern(
                        (#(notif.title[1]:split()) > 1) or
                            (notif.title[2] and not notif.title[2]:match("%d%d:%d%d")),
                        "default",
                        "compact"
                    ))
                )
                renderer[style](bufnr, notif, highlights, config)
            end,
            icons = style.plugins.notify
        }
    )
end

local function init()
    M.setup()

    wk.register(
        {
            ["<C-S-N>"] = {notify.dismiss, "Dismiss notification"}
        }
    )

    require("telescope").load_extension("notify")
end

init()

return M
