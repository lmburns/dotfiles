local M = {}

local C = require("common.color")

local ex = nvim.ex
local fn = vim.fn
local api = vim.api

local delay = 50
local focus_lock = 1
local ignore = {
    ft = {
        "NeogitCommitMessage",
        "NvimTree",
        "Trouble",
        "coc-explorer",
        "coc-list",
        "dap-repl",
        "fugitive",
        "gitcommit",
        "help",
        "list",
        "log",
        "man",
        "markdown",
        "netrw",
        "org",
        "orgagenda",
        "startify",
        "toggleterm",
        "undotree",
        "vim-plug",
        "vimwiki"
    }
}

---Set the windows relative line number
---@param val boolean
local function set_win_rnu(val)
    local bufnr = api.nvim_get_current_buf()
    local wintype = fn.win_gettype()
    if _t({"popup", "command"}):contains(wintype) then
        return
    end

    if _t(ignore.ft):contains(vim.bo[bufnr].ft) then
        return
    end

    local cur_winid = api.nvim_get_current_win()
    for _, winid in ipairs(api.nvim_tabpage_list_wins(0)) do
        if cur_winid == winid and vim.wo[cur_winid].nu then
            if b.bt ~= "quickfix" then
                vim.wo[cur_winid].rnu = val
            end
        elseif not _t({"popup", "command"}):contains(wintype) and vim.wo[winid].nu then
            vim.wo[winid].rnu = false
        end
    end
end

---Show the relative line number
local function set_rnu()
    set_win_rnu(true)
    C.set_hl("FoldColumn", {link = "LineNr"})
    -- cmd("hi! link FoldColumn NONE")
end

---Hide the relative line number
local function unset_rnu()
    set_win_rnu(false)
    C.set_hl("FoldColumn", {link = "Ignore"})
    -- cmd("hi! link FoldColumn Ignore")
end

---Function to be ran on `WinFocus` event
---@param gained boolean
function M.focus(gained)
    focus_lock = focus_lock - 1
    vim.defer_fn(
        function()
            if focus_lock >= 0 then
                if gained then
                    set_rnu()
                else
                    unset_rnu()
                end
            end
            focus_lock = focus_lock + 1
        end,
        delay
    )
end

---Function to be ran on `WinEnter`
function M.win_enter()
    set_rnu()
end

---Function to be ran on `CmdlineEnter` when searching (i.e., `/`,`?`)
function M.scmd_enter()
    set_win_rnu(false)
    ex.redraws()
end

---Function to be ran on `CmdlineLeave` when searching (i.e., `/`,`?`)
function M.scmd_leave()
    set_win_rnu(true)
end

return M
