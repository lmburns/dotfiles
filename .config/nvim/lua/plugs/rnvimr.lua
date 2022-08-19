local M = {}

local utils = require("common.utils")
local map = utils.map
local augroup = utils.augroup
local hl = require("common.color")

local fn = vim.fn
local g = vim.g
local api = vim.api
-- local go = vim.go

function M.setup()
    -- g.rnvimr_ranger_cmd = {"ranger"} -- Vanilla
    g.rnvimr_ranger_cmd = {"ranger", "--cmd=set draw_borders both"} -- Draw border with both
    g.rnvimr_enable_ex = 1 -- Replace Netrw
    g.rnvimr_enable_picker = 1 -- Make ranger hide after picking a file
    g.rnvimr_draw_border = 1 -- Disable a border for floating window
    g.rnvimr_hide_gitignore = 0 -- Hide the files included in gitignore
    g.rnvimr_edit_cmd = "drop" -- Replace `$EDITOR` item with command to open file
    g.rnvimr_enable_bw = 1 -- Wipe the buffers corresponding to delete fileds
    g.rnvimr_shadow_winblend = 70 -- Add a shadow window (100 hides it)
    g.rnvimr_draw_border = 1 -- Disable a border for floating window
    -- g.rnvimr_border_attr = {fg = 14, bg = -1} -- Change the border's color
    g.rnvimr_border_attr = {fg = 3}

    g.rnvimr_action = {
        ["<C-t>"] = "NvimEdit tabedit",
        ["<C-x>"] = "NvimEdit split",
        ["<C-v>"] = "NvimEdit vsplit",
        gw = "JumpNvimCwd",
        yw = "EmitRangerCwd"
    }

    g.rnvimr_presets = {
        {width = 0.800, height = 0.800},
        {width = 0.600, height = 0.600},
        {width = 0.950, height = 0.950},
        {width = 0.500, height = 0.500, col = 0, row = 0},
        {width = 0.500, height = 0.500, col = 0, row = 0.5},
        {width = 0.500, height = 0.500, col = 0.5, row = 0},
        {width = 0.500, height = 0.500, col = 0.5, row = 0.5}
    }

    -- Adapt the size of floating window
    g.rnvimr_ranger_views = {
        {minwidth = 90, ratio = {}},
        {minwidth = 50, maxwidth = 89, ratio = {1, 1}},
        {maxwidth = 49, ratio = {1}}
    }

    -- Customize initial layout
    -- g.rnvimr_layout = {
    --     relative = "editor",
    --     width = fn.float2nr(fn.round(0.7 * go.columns)),
    --     height = fn.float2nr(fn.round(0.7 * go.lines)),
    --     col = fn.float2nr(fn.round(0.15 * go.columns)),
    --     row = fn.float2nr(fn.round(0.15 * go.lines)),
    --     style = "minimal"
    -- }

    g.rnvimr_layout = {
        relative = "editor",
        width = fn.float2nr(fn.round(0.7 * api.nvim_win_get_width(0))),
        height = fn.float2nr(fn.round(0.7 * api.nvim_win_get_height(0))),
        col = fn.float2nr(fn.round(0.15 * api.nvim_win_get_width(0))),
        row = fn.float2nr(fn.round(0.15 * api.nvim_win_get_height(0))),
        style = "minimal"
    }

    -- g.rnvimr_layout = {
    --     relative = "editor",
    --     width = api.nvim_win_get_width(0),
    --     height = api.nvim_win_get_height(0) - 2,
    --     col = 0,
    --     row = 0,
    --     style = "minimal"
    -- }
end

local function init()
    M.setup()
    hl.plugin(
        "Rnvimr",
        { RnvimrNormal = {link = "Normal"} }
    )

    map("n", "<M-i>", ":RnvimrToggle<CR>", {silent = true, desc = "Open Rnvimr"})

    augroup(
        "RnvimrKeymap",
        {
            event = "FileType",
            pattern = "rnvimr",
            command = function()
                map("t", "<M-o>", "<Cmd>RnvimrResize<CR>", {silent = true})
                map("t", "<M-i>", "<Cmd>RnvimrToggle<CR>", {silent = true})
            end
        }
    )
end

init()

return M
