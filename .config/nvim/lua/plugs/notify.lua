local M = {}

local D = require("dev")
local notify = D.npcall(require, "notify")
if not notify then
    return
end

local hl = require("common.color")
local utils = require("common.utils")
local bmap = utils.bmap

local wk = require("which-key")

local api = vim.api

function M.setup()
    ---@type table<string, fun(bufnr: number, notif: table, highlights: table, config: table)>
    local renderer = require("notify.render")
    local stages_util = require("notify.stages.util")

    ---@diagnostic disable-next-line:unused-local
    local fade_in_slide_out_bottom = {
        function(state)
            local next_height = state.message.height + 2
            local next_row =
                stages_util.available_slot(state.open_windows, next_height, stages_util.DIRECTION.BOTTOM_UP)
            if not next_row then
                return nil
            end
            return {
                relative = "editor",
                anchor = "NE",
                width = state.message.width,
                height = state.message.height,
                col = vim.opt.columns:get(),
                row = next_row,
                border = "rounded",
                style = "minimal",
                opacity = 0
            }
        end,
        function(state, win)
            return {
                opacity = {100},
                col = {vim.o.columns},
                row = {
                    stages_util.slot_after_previous(win, state.open_windows, stages_util.DIRECTION.BOTTOM_UP),
                    frequency = 3,
                    complete = function()
                        return true
                    end
                }
            }
        end,
        function(state, win)
            return {
                col = {vim.o.columns},
                time = true,
                row = {
                    stages_util.slot_after_previous(win, state.open_windows, stages_util.DIRECTION.BOTTOM_UP),
                    frequency = 3,
                    complete = function()
                        return true
                    end
                }
            }
        end,
        function(state, win)
            return {
                width = {
                    1,
                    frequency = 2.5,
                    damping = 0.9,
                    complete = function(cur_width)
                        return cur_width < 3
                    end
                },
                opacity = {
                    0,
                    frequency = 2,
                    complete = function(cur_opacity)
                        return cur_opacity <= 4
                    end
                },
                col = {vim.o.columns},
                row = {
                    stages_util.slot_after_previous(win, state.open_windows, stages_util.DIRECTION.BOTTOM_UP),
                    frequency = 3,
                    complete = function()
                        return true
                    end
                }
            }
        end
    }

    notify.setup(
        {
            stages = "fade_in_slide_out", -- slide
            -- stages = fade_in_slide_out_bottom,
            fps = 60,
            timeout = 3000,
            minimum_width = 30,
            max_width = math.floor(vim.o.columns * 0.4),
            background_color = "NormalFloat",
            -- on_close = function()
            -- -- Could create something to write to a file
            -- end,
            on_open = function(winnr)
                api.nvim_win_set_config(winnr, {zindex = 500})
                local bufnr = api.nvim_win_get_buf(winnr)
                bmap(bufnr, "n", "q", "<Cmd>bdelete<CR>", {nowait = true})
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
