local M = {}

local D = require("dev")
local incline = D.npcall(require, "incline")
if not incline then
    return
end

local hl = require("common.color")
local utils = require("common.utils")
local mpi = require("common.api")
local map = mpi.map

local g = vim.g
local fn = vim.fn
local api = vim.api

local function render(props)
    local devicons = D.npcall(require, "nvim-web-devicons")
    if not devicons then
        return
    end

    local bufname = api.nvim_buf_get_name(props.buf)
    if bufname == "" then
        return "[No name]"
    end

    local directory_color = hl.Comment.fg
    local fname = fn.fnamemodify(bufname, ":.")
    fname = fname:gsub("^/home/lucas/.config/nvim/", "$NVIM/")
    fname = fname:gsub("^/home/lucas/.local/share/", "$DATA/")
    fname = fname:gsub("^/home/lucas/.config/", "$CONFIG/")
    fname = fname:gsub("^/home/lucas/", "$HOME/")
    local parts = fname:split("/")
    local result = {}
    -- 
    for idx, part in ipairs(parts) do
        if next(parts, idx) then
            local guifg = g.colors_name == "kimbox" and "InclineNormal" or "Directory"
            if part:match("^%$") then
                guifg = "WarningMsg"
            end

            vim.list_extend(result, {
                {utils.truncate(part, 20), guifg = hl.get(guifg, "fg"), gui = "bold"},
                {("%s"):format("/"), guifg = directory_color},
            })
        else
            -- File tail
            table.insert(result, {
                part,
                gui = "bold",
                guifg = vim.bo[props.buf].modified and hl.TypeDef.fg or nil,
            })
        end
    end
    local icon, color = devicons.get_icon_color(bufname, nil, {default = true})
    table.insert(result, #result + 1, {" " .. icon, guifg = color}) -- $NVIM/lua/plugs/incline 
    -- table.insert(result, vim.bo[props.buf].modified and {" [+]", guifg = hl.get("MoreMsg", "fg")} or nil)
    return result
end

function M.setup()
    incline.setup(
        {
            render = render,
            debounce_threshold = 30,
            window = {
                winhighlight = {
                    inactive = {
                        Normal = "Directory",
                    },
                },
                width = "fit",
                placement = {horizontal = "right", vertical = "top"},
                margin = {
                    horizontal = {left = 1, right = 1},
                    vertical = {bottom = 0, top = 1},
                },
                padding = {left = 1, right = 1},
                padding_char = " ",
                zindex = 100,
            },
            hide = {
                cursorline = true,
                focused_win = false,
                only_win = false,
            },
            ignore = {
                floating_wins = true,
                unlisted_buffers = true,
                filetypes = {"scratchpad"},
                buftypes = "special",
                wintypes = "special",
            },
            highlight = {
                groups = {
                    InclineNormal = {group = "WinBar", default = true},
                    InclineNormalNC = {group = "NormalFloat", default = true},
                },
            },
        }
    )
end

local function init()
    hl.plugin("Incline", {
        InclineNormal = {default = true, bold = true},
        InclineNormalNC = {default = true, bold = true},
    })

    M.setup()

    -- FIX: this stopped working
    map("n", "<Leader>wb", "<Cmd>lua require('incline').toggle()<CR>", {desc = "Toggle winbar"})
end

init()

return M
