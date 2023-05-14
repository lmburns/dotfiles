---@module 'common.api.win'
---@description Interaction with windows
local M = {}

local log = require("common.log")
local D = require("dev")
local lazy = require("common.lazy")
local T = lazy.require("common.api.tab")
local utils = lazy.require_on.expcall("common.utils")

local cmd = vim.cmd
local fn = vim.fn
local api = vim.api
local F = vim.F

---Execute a `wincmd` with escaped keys
M.wincmd = function(c)
    cmd.wincmd(utils.termcodes[c])
end

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

---Check if the buffer that contains the window is modified
---@param winid winid
---@return boolean
M.win_is_modified = function(winid)
    return M.win_get_buf_option(winid, "modified")
end

---Return a list of all window ID's that contain the given buffer.
---API version of `fn.win_findbuf()`
---@param bufnr number Buffer ID
---@param tabpage? number Only search windows in given tabpage
---@return number[]
M.win_find_buf = function(bufnr, tabpage)
    -- fn.win_findbuf()
    local result = {}
    local wins = F.if_expr(tabpage, api.nvim_tabpage_list_wins(tabpage), api.nvim_list_wins())
    for _, id in ipairs(wins) do
        if api.nvim_win_get_buf(id) == bufnr then
            table.insert(result, id)
        end
    end

    return result
end

---Get a buffer option from a window
---@param winid winid
---@param opt string option to get
---@return table|string|number|boolean
M.win_get_buf_option = function(winid, opt)
    local bufnr = api.nvim_win_get_buf(winid)
    return api.nvim_buf_get_option(bufnr, opt)
end

---Get a buffer variable from a window
---@param winid winid
---@param var string variable to get
---@return any
M.win_get_buf_var = function(winid, var)
    local buf = api.nvim_win_get_buf(winid)
    return api.nvim_buf_get_var(buf, var)
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
    -- local winids = D.filter(
    --     api.nvim_tabpage_list_wins(0),
    --     function(winid)
    --         return vim.wo[winid].diff --[[@as boolean]]
    --     end
    -- )
    --
    -- if #winids > 1 then
    --     for _, winid in ipairs(winids) do
    --         local ok, msg = pcall(api.nvim_win_close, winid, false)
    --         if not ok and (msg and msg:match("^Vim:E444:")) then
    --             if api.nvim_buf_get_name(0):match("^fugitive://") then
    --                 cmd("Gedit")
    --             end
    --         end
    --     end
    -- end

    M.wincmd("<C-o>")
end

---@class mpi.smart_close.Opt
---@field keep_last boolean Don't close the window if it's the last window.

---Close the current window and bring focus to the last used window.
---@param opt? mpi.smart_close.Opt
M.win_smart_close = function(opt)
    opt = opt or {}
    local cur_win = api.nvim_get_current_win()
    local prev_win = fn.win_getid(fn.winnr("#"))
    local command = "q"
    local ok, err

    if opt.keep_last then
        local wins = vim.tbl_filter(
            function(v)
                return api.nvim_win_get_config(v).relative == ""
            end,
            api.nvim_list_wins()
        )

        if #wins == 1 then
            command = "bd"
        end
    end

    -- if fn.winnr("$") ~= 1 then
    --     api.nvim_win_close(0, true)
    -- end
    -- if fn.tabpagewinnr("$") ~= 1 then
    --     cmd.tabc()
    -- end

    -- if not vim.bo.modifiable or vim.bo.readonly then
    --     cmd.wincmd("q")
    -- else
    --     cmd.q()
    -- end

    ok, err = pcall(cmd, command)
    if not ok then
        log.err(err --[[@as string]])
    elseif cur_win ~= prev_win then
        api.nvim_set_current_win(prev_win)
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
            -- fn.win_gotoid(winid)
            api.nvim_set_current_win(winid)
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
    for _, winid in ipairs(api.nvim_list_wins()) do
        if api.nvim_win_get_buf(winid) == bufnr then
            api.nvim_win_call(winid, function()
                local view = fn.winsaveview()
                table.insert(win_positions, {winid, view})
            end)
        end
    end

    return {
        restore = function()
            for _, pair in ipairs(win_positions) do
                local winid, view = unpack(pair)
                api.nvim_win_call(winid, function()
                    pcall(fn.winrestview, view)
                end)
            end
        end,
    }
end

---Check whether or not the location or quickfix list is open
---@return boolean
M.is_vim_list_open = function()
    for _, win in ipairs(api.nvim_list_wins()) do
        local buf = api.nvim_win_get_buf(win)
        local location_list = fn.getloclist(0, {filewinid = 0})
        ---@diagnostic disable-next-line:undefined-field
        local is_loc_list = location_list.filewinid > 0
        if vim.bo[buf].filetype == "qf" or is_loc_list then
            return true
        end
    end
    return false
end

---There's `:buffers`, there's `:tabs`. Now - finally - there's `:Windows`.
---@param all boolean List windows from all tabpages.
M.windows = function(all)
    local tabs = all and api.nvim_list_tabpages() or {api.nvim_get_current_tabpage()}
    local curwin = api.nvim_get_current_win()
    local alt_tabid, alt_winid

    if all then
        local alt_tabnr = fn.tabpagenr("#")
        if alt_tabnr > 0 then
            alt_tabid = T.tab_nr2id(alt_tabnr)
            alt_winid = api.nvim_tabpage_get_win(alt_tabid)
        end
    end

    local res = {}
    local sigil_map = {
        [curwin] = ">",
        [alt_winid or -1] = "#",
    }

    for idx, tabid in ipairs(tabs) do
        -- res[#res+1] = "Tabpage " .. i
        table.insert(res, "    Tab |  ID  | NR  | buf |")
        table.insert(res, "   -----|------|-----|-----|--------")
        local wins = api.nvim_tabpage_list_wins(tabid)

        D.vec_push(res, unpack(vim.tbl_map(function(winid)
            local bufnr = api.nvim_win_get_buf(winid)
            local name = api.nvim_buf_get_name(bufnr)
            local typ = fn.win_gettype(winid)

            return ("  %s [%d] | %d | %3d | %3d | %s%s"):format(
                sigil_map[winid] or " ",
                idx,
                winid,
                fn.win_id2win(winid),
                bufnr,
                ("%s%s"):format(
                -- M.win_is_float(v) and "[float] " or (typ and ("[%s] "):format(type) or ""),
                    M.win_is_float(winid) and "[float] " or "",
                    (typ == "quickfix" or vim.bo[bufnr].bt == "quickfix") and "[quickfix] " or ""
                ),
                utils.str_quote(name)
            )
        end, wins) --[[@as vector]]))
    end

    p(table.concat(res, "\n"))
end

return M
