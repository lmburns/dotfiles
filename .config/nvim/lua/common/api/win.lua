--@module common.api.win
---@description: Interaction with windows
local M = {}

local D = require("dev")

local cmd = vim.cmd
local fn = vim.fn
local api = vim.api
local F = vim.F

---Determine if the window is the only one open
---@param win_id? number
---@return boolean
M.win_is_last = function(win_id)
    win_id = win_id or api.nvim_get_current_win()
    local n = 0
    for _, tab in ipairs(api.nvim_list_tabpages()) do
        for _, win in ipairs(api.nvim_tabpage_list_wins(tab)) do
            if win_id == win then
                n = n + 1
            end
            if n > 1 then
                return false
            end
        end
    end
    return true
end

---Determine whether the window is floating
---@param winid? number
---@return boolean
M.win_is_float = function(winid)
    local wincfg = api.nvim_win_get_config(winid or 0)
    return fn.win_gettype() == "popup"
        or (wincfg and (wincfg.external or wincfg.relative ~= ""))

    -- return fn.win_gettype() == "popup" or api.nvim_win_get_config(winid or 0).relative ~= ""
    --
    -- These two commands here are not equivalent as the docs might suggest
    -- In the function below `M.get_win_except_float`,
    -- they act the same about 200ms into starting Neovim
    --
    -- return fn.win_gettype() == 'popup'
end

---Find a window that is not floating
---@param bufnr number
---@return number
M.get_win_except_float = function(bufnr)
    local winid = fn.bufwinid(bufnr)
    if M.win_is_float(winid) then
        local f_winid = winid
        winid = 0
        for _, wid in ipairs(api.nvim_list_wins()) do
            if f_winid ~= wid and api.nvim_win_get_buf(wid) == bufnr then
                winid = wid
                break
            end
        end
    end
    return winid
end

---Get windows of a given type
---@param wintype string
---@return number[]?
M.win_of_type = function(wintype)
    return D.filter(
        api.nvim_list_wins(),
        function(winid)
            return fn.win_gettype(winid) == wintype
        end
    )
end

---Return a table of window ID's for quickfix windows
---@return number?
M.win_type_qf = function()
    return M.win_of_type("quickfix")[1]
end

---Return a list of all window ID's that contain the given buffer.
---API version of `fn.win_findbuf()`
---@param bufnr number Buffer ID
---@param tabpage? number Only search windows in given tabpage
---@return number[]
M.win_find_buf = function(bufnr, tabpage)
    local result = {}
    local wins

    if tabpage then
        wins = api.nvim_tabpage_list_wins(tabpage)
    else
        wins = api.nvim_list_wins()
    end

    for _, id in ipairs(wins) do
        if api.nvim_win_get_buf(id) == bufnr then
            table.insert(result, id)
        end
    end

    return result
end

--  ══════════════════════════════════════════════════════════════════════

---Close all floating windows
M.win_close_all_floating = function()
    for _, win in ipairs(api.nvim_list_wins()) do
        if M.win_is_float(win) then
            api.nvim_win_close(win, false)
        end
    end
end

---Close a diff file
M.win_close_diff = function()
    local winids =
        D.filter(
            api.nvim_tabpage_list_wins(0),
            function(winid)
                return vim.wo[winid].diff --[[@as boolean]]
            end
        )

    if #winids > 1 then
        for _, winid in ipairs(winids) do
            local ok, msg = pcall(api.nvim_win_close, winid, false)
            if not ok and (msg and msg:match("^Vim:E444:")) then
                if api.nvim_buf_get_name(0):match("^fugitive://") then
                    cmd("Gedit")
                end
            end
        end
    end
end

---Focus the floating window
M.win_focus_floating = function()
    if M.win_is_float(fn.win_getid()) then
        cmd.wincmd("p")
        return
    end
    for _, winnr in ipairs(fn.range(1, fn.winnr("$"))) do
        local winid = fn.win_getid(winnr)
        local conf = api.nvim_win_get_config(winid)
        if conf.focusable and conf.relative ~= "" then
            fn.win_gotoid(winid)
            return
        end
    end
end

---Save a window's positions
---@param bufnr number? buffer to save position
---@return SaveWinPositionsReturn
M.win_save_positions = function(bufnr)
    bufnr = F.if_expr(bufnr == nil or bufnr == 0, api.nvim_get_current_buf(), bufnr)
    local win_positions = {}
    for _, winid in pairs(api.nvim_list_wins()) do
        if api.nvim_win_get_buf(winid) == bufnr then
            api.nvim_win_call(
                winid,
                function()
                    local view = fn.winsaveview()
                    table.insert(win_positions, {winid, view})
                end
            )
        end
    end

    return {
        restore = function()
            for _, pair in pairs(win_positions) do
                local winid, view = unpack(pair)
                api.nvim_win_call(
                    winid,
                    function()
                        pcall(fn.winrestview, view)
                    end
                )
            end
        end,
    }
end

return M
