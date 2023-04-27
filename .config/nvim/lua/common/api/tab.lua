--@module common.api.tab
---@description: Interaction with tabpages
local M = {}

local fn = vim.fn
local api = vim.api

---Get the nubmer of tabs
---@return number
M.tab_get_count = function()
    return #fn.gettabinfo()
end

---Get the ID of a tabpage from its tab number
---@param tabnr number
---@return number?
M.tabnr_to_id = function(tabnr)
    for _, id in ipairs(api.nvim_list_tabpages()) do
        if api.nvim_tabpage_get_number(id) == tabnr then
            return id
        end
    end
end

return M
