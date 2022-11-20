local M = {}

local D = require("dev")
local notify = D.npcall(require, "notify")
if not notify then
    return
end

local style = require("style")
local hl = require("common.color")
local utils = require("common.utils")
local bmap = utils.bmap

local wk = require("which-key")

local api = vim.api

function M.setup()
    ---@type table<string, fun(bufnr: number, notif: table, highlights: table, config: table)>
    local renderer = require("notify.render")
    -- local stages_util = require("notify.stages.util")

    notify.setup(
        {
            stages = "fade_in_slide_out", -- slide
            top_down = true,
            fps = 60,
            timeout = 3000,
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
                local style = notif.title[1] == "" and "minimal" or "default"
                renderer[style](bufnr, notif, highlights, config)
            end,
            icons = {
                ERROR = " ",
                WARN = " ",
                INFO = " ",
                DEBUG = " ",
                TRACE = " "
            }
        }
    )
end

local function init()
    hl.plugin(
        "notify",
        {
            NotifyERRORBorder = {bg = {from = "NormalFloat"}},
            NotifyWARNBorder = {bg = {from = "NormalFloat"}},
            NotifyINFOBorder = {bg = {from = "NormalFloat"}},
            NotifyDEBUGBorder = {bg = {from = "NormalFloat"}},
            NotifyTRACEBorder = {bg = {from = "NormalFloat"}},
            NotifyERRORBody = {link = "NormalFloat"},
            NotifyWARNBody = {link = "NormalFloat"},
            NotifyINFOBody = {link = "NormalFloat"},
            NotifyDEBUGBody = {link = "NormalFloat"},
            NotifyTRACEBody = {link = "NormalFloat"}
        }
    )

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
