---@module 'plugs.incline'
local M = {}

local F = Rc.F
local incline = F.npcall(require, "incline")
if not incline then
    return
end

local map = Rc.api.map
local I = Rc.icons
local hl = Rc.shared.hl
local utils = Rc.shared.utils

local g = vim.g
local fn = vim.fn
local api = vim.api

local after = F.after(2, function(fname)
    local git = utils.git.root()
    if #git ~= 0 then
        fname = ("%s/%s"):format(fn.fnamemodify(git, ":t"), fname)
    end
    return fname
end)


local function render(props)
    local devicons = F.npcall(require, "nvim-web-devicons")
    local bufname = api.nvim_buf_get_name(props.buf)
    if bufname == "" then
        return "[No name]"
    end

    local directory_color = hl.Comment.fg
    local fname = fn.fnamemodify(bufname, ":.")
    fname = after(fname)
    fname = fname:gsub("^/home/lucas/.config/nvim/", "$NVIM/")
    fname = fname:gsub("^/home/lucas/.config/zsh/", "$ZDOTDIR/")
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
                guifg = vim.bo[props.buf].modified and hl.TypeDef.fg or hl["@constant"].fg,
            })
        end
    end
    local icon, color
    if devicons then
        icon, color = devicons.get_icon_color(bufname)
    else
        icon, color = I.symbols.hash, hl.get("WarningMsg", "fg")
    end
    table.insert(result, #result + 1, {" " .. icon, guifg = color}) -- $NVIM/lua/plugs/incline 
    -- table.insert(result, vim.bo[props.buf].modified and {" [+]", guifg = hl.get("MoreMsg", "fg")} or nil)
    return result
end

function M.setup()
    incline.setup({
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
            filetypes = {"scratchpad", "oil"},
            buftypes = "special",
            wintypes = "special",
        },
        highlight = {
            groups = {
                InclineNormal = {group = "WinBar", default = true},
                InclineNormalNC = {group = "NormalFloat", default = true},
            },
        },
    })
end

local function init()
    hl.plugin("Incline", {
        InclineNormal = {default = true, bold = true},
        InclineNormalNC = {default = true, bold = true},
    })

    M.setup()

    map(
        "n",
        "<Leader>wb",
        "require('incline').toggle()",
        {lcmd = true, desc = "Toggle winbar"}
    )
end

init()

return M
