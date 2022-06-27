local M = {}

local api = vim.api
local fn = vim.fn

function M.tabline()
    local tl = {}
    for i, tp in ipairs(api.nvim_list_tabpages()) do
        if tp == api.nvim_get_current_tabpage() then
            table.insert(tl, "%#TabLineSel#")
        else
            table.insert(tl, "%#TabLine#")
        end
        table.insert(tl, " " .. i .. " ")
        local name
        local winid = api.nvim_tabpage_get_win(tp)
        local bufnr = api.nvim_win_get_buf(winid)
        name = fn.fnamemodify(api.nvim_buf_get_name(bufnr), ":t")
        if not name or name == "" then
            local win_type = fn.win_gettype(winid)
            if win_type == "loclist" then
                name = "[Location]"
            elseif win_type == "quickfix" then
                name = "[Quickfix]"
            else
                name = "[No Name]"
            end
        end
        table.insert(tl, name .. " ")
    end
    table.insert(tl, "%#TabLineFill#%T")
    return table.concat(tl)
end

local function init()
    -- vim.o.statusline = [[%!v:lua.require'stl'.statusline()]]
    vim.o.tabline = [[%!v:lua.require'common.stl'.tabline()]]
end

init()

return M
