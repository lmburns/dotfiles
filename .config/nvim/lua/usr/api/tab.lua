---@module 'usr.api.tab'
---@description Interaction with tabpages
---@class Api.Tab
local M = {}

local lazy = require("usr.lazy")
local W = lazy.require("usr.api.win") ---@module 'usr.api.win'
local fn = vim.fn
local api = vim.api

---Get the nubmer of tabs
---@return number
function M.tabpage_get_count()
    return #fn.gettabinfo()
end

---Get the ID of a tabpage from its tab number
---@param tabnr number
---@return number?
function M.tab_nr2id(tabnr)
    for _, id in ipairs(api.nvim_list_tabpages()) do
        if api.nvim_tabpage_get_number(id) == tabnr then
            return id
        end
    end
end

---Check if any window within a tabpage contains a buffer that is modified
---@param tabpage integer
---@return boolean
function M.tabpage_is_modified(tabpage)
    for _, win in ipairs(api.nvim_tabpage_list_wins(tabpage)) do
        if W.win_is_modified(win) then
            return true
        end
    end
    return false
end

---List buffers within a tabpage
---API version of `fn.tabpagebuflist()`
---@param tabpage? integer
---@return bufnr[]
function M.tabpage_list_bufs(tabpage)
    tabpage = tabpage or api.nvim_get_current_tabpage()
    local bufs = {}

    return vim.tbl_filter(
        function(b)
            return b
        end,
        vim.tbl_map(function(winid)
            local buf = api.nvim_win_get_buf(winid)
            if bufs[buf] ~= nil then
                return false
            end
            bufs[buf] = true
            return buf
        end, api.nvim_tabpage_list_wins(tabpage))
    )
end

return M
