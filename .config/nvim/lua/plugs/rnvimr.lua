local M = {}

local utils = require("common.utils")
local map = utils.map
local augroup = utils.augroup
local color = require("common.color")

function M.setup()
    -- Replace Netrw
    g.rnvimr_enable_ex = 1
    -- Make ranger hide after picking a file
    g.rnvimr_enable_picker = 1
    g.rnvimr_draw_border = 1
    g.rnvimr_hide_gitignore = 0
    -- Border colors
    g.rnvimr_border_attr = {fg = 14, bg = -1}
    -- Wipe the buffers corresponding to delete fileds
    g.rnvimr_enable_bw = 1
    -- Add a shadow window (100 hides it)
    g.rnvimr_shadow_winblend = 70

    -- g.rnvimr_ranger_cmd = "ranger --cmd='set draw_borders both'"
    -- g.rnvimr_ranger_cmd = "lf"

    g.rnvimr_action = {
        ["<C-t>"] = "NvimEdit tabedit",
        ["<C-x>"] = "NvimEdit split",
        ["<C-v>"] = "NvimEdit vsplit",
        gw = "JumpNvimCwd",
        yw = "EmitRangerCwd"
    }

    -- Adapt the size of floating window
    g.rnvimr_ranger_views = {
        {minwidth = 90, ratio = {}},
        {minwidth = 50, maxwidth = 89, ratio = {1, 1}},
        {maxwidth = 49, ratio = {1}}
    }

    -- Customize initial layout
    g.rnvimr_layout = {
        relative = "editor",
        width = fn.float2nr(fn.round(0.7 * go.columns)),
        height = fn.float2nr(fn.round(0.7 * go.lines)),
        col = fn.float2nr(fn.round(0.15 * go.columns)),
        row = fn.float2nr(fn.round(0.15 * go.lines)),
        style = "minimal"
    }

    -- Customize multiple preset layouts
    -- '{}' represents the initial layout

    -- g.rnvimr_presets = {
    --   { width = 0.600, height = 0.600 },
    --   {},
    --   { width = 0.800, height = 0.800 },
    --   { width = 0.950, height = 0.950 },
    --   { width = 0.500, height = 0.500, col = 0, row = 0 },
    --   { width = 0.500, height = 0.500, col = 0, row = 0.5 },
    --   { width = 0.500, height = 0.500, col = 0.5, row = 0 },
    --   { width = 0.500, height = 0.500, col = 0.5, row = 0.5 },
    --   { width = 0.500, height = 1.000, col = 0, row = 0 },
    --   { width = 0.500, height = 1.000, col = 0.5, row = 0 },
    --   { width = 1.000, height = 0.500, col = 0, row = 0 },
    --   { width = 1.000, height = 0.500, col = 0, row = 0.5 },
    -- }

    -- Fullscreen for initial layout
    -- let g:rnvimr_layout = {
    --            \ 'relative': 'editor',
    --            \ 'width': &columns,
    --            \ 'height': &lines - 2,
    --            \ 'col': 0,
    --            \ 'row': 0,
    --            \ 'style': 'minimal'
    --            \ }
end

local function init()
    M.setup()

    color.link("RnvimrNormal", "CursorLine")

    -- map("t", "<C-i>", [[<C-\><C-n>:RnvimrToggle<CR>]], { silent = true })
    -- map("t", "<C-o>", [[<C-\><C-n>:RnvimrResize<CR>]], { silent = true })

    map("n", "<M-i>", ":RnvimrToggle<CR>", {silent = true})

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
