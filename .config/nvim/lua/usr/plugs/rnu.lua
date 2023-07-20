---@module 'usr.plugs.rnu'
local M = {}

local shared = require("usr.shared")
local utils = shared.utils
local hl = shared.color

local mpi = require("usr.api")
local W = mpi.win
local lib = require("usr.lib")
local Mutex = lib.mutex
local async = require("async")

local cmd = vim.cmd
local fn = vim.fn
local api = vim.api

local delay = 50
-- local focus_lock = 1
local mtx = Mutex:new()
local ignore = {
    ft = _t({
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
        "vimwiki",
    }),
    bt = _t({"quickfix", "terminal"}),
    wt = _t({"popup", "command"}),
}

---Set the windows relative line number
---@param val boolean
local function set_win_rnu(val)
    local bufnr = api.nvim_get_current_buf()
    local wintype = fn.win_gettype()
    local cur_winid = api.nvim_get_current_win()

    if (ignore.wt:contains(wintype) or W.win_is_float(cur_winid))
        or ignore.ft:contains(vim.bo[bufnr].ft)
    then
        return
    end

    for _, winid in ipairs(api.nvim_tabpage_list_wins(0)) do
        if cur_winid == winid and vim.wo[cur_winid].nu then
            if not ignore.bt:contains(vim.bo.bt) then
                vim.wo[cur_winid].rnu = val
            end
        elseif not ignore.wt:contains(wintype) and vim.wo[winid].nu then
            vim.wo[winid].rnu = false
        end
    end
end

---Show the relative line number
local function set_rnu()
    set_win_rnu(true)
    -- hl.set("FoldColumn", {link = "LineNr"})
    hl.set("FoldColumn", {fg = require("kimbox.colors").fuzzy_wuzzy})
end

---Hide the relative line number
local function unset_rnu()
    set_win_rnu(false)
    hl.set("FoldColumn", {link = "Ignore"})
end

---Function to be ran on `FocusGained`, `FocusLost`, `InsertEnter`, `InsertLeave` events
---@param gained boolean
---@return Promise
function M.focus(gained)
    -- focus_lock = focus_lock - 1
    -- vim.defer_fn(function()
    --     if focus_lock >= 0 then
    --         if gained then
    --             set_rnu()
    --         else
    --             unset_rnu()
    --         end
    --     end
    --     focus_lock = focus_lock + 1
    -- end, delay)

    return mtx:use(function()
        return async(function()
            await(utils.async.scheduler())
            utils.async.wait(delay):thenCall(function()
                if gained then
                    set_rnu()
                else
                    unset_rnu()
                end
            end)
        end)
    end)
end

---Function to be ran on `WinEnter`
function M.win_enter()
    set_rnu()
end

---Function to be ran on `CmdlineEnter` when searching (i.e., `/`,`?`)
function M.scmd_enter()
    set_win_rnu(false)
    cmd.redraws()
end

---Function to be ran on `CmdlineLeave` when searching (i.e., `/`,`?`)
function M.scmd_leave()
    set_win_rnu(true)
end

return M
