local M = {}

local C = require("common.color")
local utils = require("common.utils")
local map = utils.map

local api = vim.api
local fn = vim.fn

local function truncate(str, max_len)
    assert(str and max_len, "string and max_len must be provided")
    return api.nvim_strwidth(str) > max_len and str:sub(1, max_len) .. "…" or str
end

local function render(props)
    local devicons = require("nvim-web-devicons")
    local bufname = api.nvim_buf_get_name(props.buf)
    if bufname == "" then
        return "[No name]"
    end
    -- FIX: Sometimes the directory is cut off
    local directory_color = C.get_hl("Comment", "fg")
    local fname = fn.fnamemodify(bufname, ":.")
    fname = fname:gsub("^/home/lucas/.config/nvim/", "$NVIM/")
    fname = fname:gsub("^/home/lucas/.local/share/", "$DATA/")
    fname = fname:gsub("^/home/lucas/.config/", "$CONFIG/")
    fname = fname:gsub("^/home/lucas/", "$HOME/")
    local parts = vim.split(fname, "/")
    local result = {}
    -- 
    for idx, part in ipairs(parts) do
        if next(parts, idx) then
            local guifg = "WinBar"
            if part:match("^%$") then
                guifg = "WarningMsg"
            end

            vim.list_extend(
                result,
                {
                    {truncate(part, 20), guifg = C.get_hl(guifg, "fg")},
                    {("%s"):format("/"), guifg = directory_color}
                }
            )
        else
            -- File tail
            table.insert(result, {part, gui = "bold", guisp = directory_color})
        end
    end
    local icon, color = devicons.get_icon_color(bufname, nil, {default = true})
    table.insert(result, #result, {icon .. " ", guifg = color})
    return result
end

function M.setup()
    require("incline").setup(
        {
            -- render = function(props)
            --     local bufname = api.nvim_buf_get_name(props.buf)
            --     if bufname == "" then
            --         return "[No name]"
            --     else
            --         -- bufname = fn.fnamemodify(bufname, ":h")
            --         bufname = Path:new(bufname):shorten(3, {-2, -1})
            --         bufname = bufname:gsub("^/hom/luc/.co/nvi/", "$NVIM/")
            --         bufname = bufname:gsub("^/hom/luc/.lo/sha/", "$DATA/")
            --         bufname = bufname:gsub("^/hom/luc/.co/", "$CONFIG/")
            --         bufname = bufname:gsub("^/hom/luc/", "~/")
            --     end
            --     return bufname
            -- end,
            render = render,
            debounce_threshold = 30,
            window = {
                winhighlight = {
                    inactive = {
                        Normal = "Directory"
                    }
                },
                width = "fit",
                placement = {horizontal = "right", vertical = "top"},
                margin = {
                    horizontal = {left = 1, right = 1},
                    vertical = {bottom = 0, top = 1}
                },
                padding = {left = 1, right = 1},
                padding_char = " ",
                zindex = 100
            },
            -- hide = {
            --     cursorline = true,
            --     focused_win = false,
            --     only_win = false
            -- },
            ignore = {
                floating_wins = true,
                unlisted_buffers = true,
                filetypes = {},
                buftypes = "special",
                wintypes = "special"
            },
            highlight = {
                groups = {
                    InclineNormal = "WinBar",
                    InclineNormalNC = "InclineNormal"
                }
            }
        }
    )

    map("n", "<Leader>wb", "<Cmd>lua require('incline').toggle()<CR>", {desc = "Toggle winbar"})
end

local function init()
    M.setup()
end

init()

return M
