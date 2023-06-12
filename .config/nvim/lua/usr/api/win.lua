---@module 'usr.api.win'
---@description Interaction with windows
---@class Api.Win
local M = {}

local lazy = require("usr.lazy")
local log = lazy.require("usr.lib.log") ---@module 'usr.lib.log'
local T = lazy.require("usr.api.tab") ---@module 'usr.api.tab'

local shared = require("usr.shared")
local utils = shared.utils
local F = shared.F
local C = shared.collection

local cmd = vim.cmd
local fn = vim.fn
local api = vim.api

---Execute a `wincmd` with escaped keys
function M.wincmd(c)
    cmd.wincmd(utils.termcodes[c])
end

---Determine if the window is the only one open
---@param winid? number
---@return boolean
function M.win_is_last(winid)
    winid = winid or api.nvim_get_current_win()
    local n = 0
    for _, tab in ipairs(api.nvim_list_tabpages()) do
        for _, win in ipairs(api.nvim_tabpage_list_wins(tab)) do
            if winid == win then
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
function M.win_is_float(winid)
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
function M.get_win_except_float(bufnr)
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
function M.win_of_type(wintype)
    return C.filter(
        api.nvim_list_wins(),
        function(winid)
            return fn.win_gettype(winid) == wintype
        end
    )
end

---Return a table of window ID's for quickfix windows
---@return number?
function M.win_type_qf()
    return M.win_of_type("quickfix")[1]
end

---Check if the buffer that contains the window is modified
---@param winid winid
---@return boolean
function M.win_is_modified(winid)
    return M.win_get_buf_option(winid, "modified")
end

---Return a list of all window ID's that contain the given buffer.
---API version of `fn.win_findbuf()`
---@param bufnr number Buffer ID
---@param tabpage? number Only search windows in given tabpage
---@return number[]
function M.win_findbuf(bufnr, tabpage)
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
function M.win_get_buf_option(winid, opt)
    local bufnr = api.nvim_win_get_buf(winid)
    return api.nvim_get_option_value(opt, {buf = bufnr})
end

---Get a buffer variable from a window
---@param winid winid
---@param var string variable to get
---@return any
function M.win_get_buf_var(winid, var)
    local buf = api.nvim_win_get_buf(winid)
    return api.nvim_buf_get_var(buf, var)
end

---@param tabid integer?
---@return vector<integer>
function M.find_usable(tabid)
    ---Make sure the tab's current window is first in the list.
    local wins = C.vec_join(
        api.nvim_tabpage_get_win(tabid or 0),
        api.nvim_tabpage_list_wins(tabid or 0)
    )

    return vim.tbl_filter(function(v)
        return vim.bo[api.nvim_win_get_buf(v)].buftype == ""
    end, wins)
end

--  ══════════════════════════════════════════════════════════════════════

---Close all floating windows
function M.win_close_all_floating()
    for _, win in ipairs(api.nvim_list_wins()) do
        if M.win_is_float(win) then
            api.nvim_win_close(win, false)
        end
    end
end

--FIX: why does this hang now
---Close a diff file
function M.win_close_diff()
    if vim.in_fast_event() or require("usr.ffi").nvim_is_locked() then
        return vim.schedule(function()
            M.win_close_diff()
        end)
    end

    local winids = C.filter(
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

    -- M.wincmd("<C-o>")
end

---@class Rc.api.smart_close.Opt
---@field keep_last boolean Don't close the window if it's the last window.

---Close the current window and bring focus to the last used window.
---@param opt? Rc.api.smart_close.Opt
function M.win_smart_close(opt)
    opt = opt or {}
    local cur_win = api.nvim_get_current_win()
    local prev_win = fn.win_getid(fn.winnr("#"))
    local command = "q"
    local ok, err

    if opt.keep_last then
        local wins = C.filter(
            api.nvim_list_wins(),
            function(v)
                return api.nvim_win_get_config(v).relative == ""
            end
        )

        if #wins == 1 then
            command = "bd"
        end
    end
    if not vim.bo.modifiable or vim.bo.readonly then
        command = "wincmd q"
    end

    ok, err = pcall(cmd, command)
    if not ok then
        log.err(err --[[@as string]])
    elseif cur_win ~= prev_win then
        api.nvim_set_current_win(prev_win)
    end
end

---Focus the floating window
function M.win_focus_floating()
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

-- Go to prev window (or another if there is no previous)
function M.win_switch_alt()
    -- local curwin = api.nvim_get_current_win()
    -- cmd.wincmd("p")
    -- if api.nvim_get_current_win() == curwin then
    --     cmd.wincmd("w")
    -- end

    local curwin = fn.winnr()
    cmd.wincmd("p")
    if fn.winnr() == curwin then
        cmd.wincmd("w")
    end
end

---Save a window's positions
---@param bufnr? number buffer to save position
---@return SaveWinPositionsReturn
function M.win_save_positions(bufnr)
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

---Save a window's positions just for a command/func call
---@generic A, R
---@param bufnr? bufnr
---@param func string|fun(...: A): R?
---@param ... A
---@return R?
function M.win_save_positions_fn(bufnr, func, ...)
    local positions = M.win_save_positions(bufnr)
    local res = utils.wrap_fn_call(func, ...)
    positions.restore()
    return res
end

---Check whether or not the location or quickfix list is open
---@return boolean
function M.is_vim_list_open()
    for _, win in ipairs(api.nvim_list_wins()) do
        local buf = api.nvim_win_get_buf(win)
        local loclist = fn.getloclist(0, {filewinid = 0})
        ---@diagnostic disable-next-line:undefined-field
        local is_loc_list = loclist.filewinid > 0
        if vim.bo[buf].filetype == "qf" or is_loc_list then
            return true
        end
    end
    return false
end

---There's `:buffers`, there's `:tabs`. Now - finally - there's `:Windows`.
---@param all boolean List windows from all tabpages.
function M.windows(all)
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

    local res = _j({})
    local sigil_map = {
        [curwin] = ">",
        [alt_winid or -1] = "#",
    }

    for idx, tabid in ipairs(tabs) do
        res:insert("  tabnr | winnr | winid | bufnr | bufname")
        res:insert("  ----- | ----- | ----- | ----- | -------")
        local wins = api.nvim_tabpage_list_wins(tabid)

        C.vec_push(res, unpack(vim.tbl_map(function(winid)
            local bufnr = api.nvim_win_get_buf(winid)
            local name = api.nvim_buf_get_name(bufnr)
            local typ = fn.win_gettype(winid)

            return ("  %s %3d | %5d | %5d | %5d | %s%s"):format(
                sigil_map[winid] or " ",
                idx,
                fn.win_id2win(winid),
                winid,
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
    p(res:concat("\n"))
end

--List all buffers in all tabs
-- function M.tabs()
--     local winid2bufnr = {}
--     for _, bufnr in ipairs(fn.range(1, fn.bufnr("$"))) do
--         for _, winid in ipairs(fn.win_findbuf(bufnr)) do
--             winid2bufnr[winid] = bufnr
--         end
--     end
--
--     local res = _j({})
--     local cur_tabnr = fn.tabpagenr()
--     for _, tabnr in ipairs(fn.range(1, fn.tabpagenr("$"))) do
--         local cur_winnr = fn.tabpagewinnr(tabnr)
--         local symbol1 = (tabnr == cur_tabnr) and ">" or " "
--         res:insert(("%s Tab: %s"):format(symbol1, tabnr))
--         res:insert("     bufnr | winnr | winid | bufname")
--         res:insert("     ----- | ----- | ----- | -------")
--         for _, winnr in ipairs(fn.range(1, fn.tabpagewinnr(tabnr, "$"))) do
--             local winid = fn.win_getid(winnr, tabnr)
--             local bufnr = winid2bufnr[winid]
--             local symbol2 = (winnr == cur_winnr) and "*" or " "
--             local c = ("%5d | %5d | %5d | %s"):format(bufnr, winnr, winid, fn.bufname(bufnr))
--             res:insert(("   %s %s"):format(symbol2, c))
--         end
--     end
--     p(res:concat("\n"))
-- end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

return M
