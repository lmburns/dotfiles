---@module 'common.api.tab'
---@description Interaction with tabpages
local M = {}

local W = require("common.api.win")
local fn = vim.fn
local api = vim.api

---Get the nubmer of tabs
---@return number
M.tabpage_get_count = function()
    return #fn.gettabinfo()
end

---Get the ID of a tabpage from its tab number
---@param tabnr number
---@return number?
M.tab_nr2id = function(tabnr)
    for _, id in ipairs(api.nvim_list_tabpages()) do
        if api.nvim_tabpage_get_number(id) == tabnr then
            return id
        end
    end
end

---Check if any window within a tabpage contains a buffer that is modified
---@param tabpage integer
---@return boolean
M.tabpage_is_modified = function(tabpage)
    for _, win in ipairs(api.nvim_tabpage_list_wins(tabpage)) do
        if W.win_is_modified(win) then
            return true
        end
    end
    return false
end

---List buffers within a tabpage
---@param tabpage integer
---@return bufnr[]
M.tabpage_list_bufs = function(tabpage)
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
