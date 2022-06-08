local M = {}

local ex = nvim.ex
local cmd = vim.cmd

local delay = 50
local focus_lock = 1

local function set_win_rnu(val)
    if fn.win_gettype() == "popup" then
        return
    end

    local cur_winid = api.nvim_get_current_win()
    for _, winid in ipairs(api.nvim_tabpage_list_wins(0)) do
        if cur_winid == winid and vim.wo[cur_winid].nu then
            if b.bt ~= "quickfix" then
                vim.wo[cur_winid].rnu = val
            end
        elseif fn.win_gettype() ~= "popup" and vim.wo[winid].nu then
            vim.wo[winid].rnu = false
        end
    end
end

local function set_rnu()
    set_win_rnu(true)
    -- C.set_hl("FoldColumn", {link = "LineNr"})
    cmd("hi! link FoldColumn NONE")
end

local function unset_rnu()
    set_win_rnu(false)
    -- C.set_hl("FoldColumn", {fg = "NONE"})
    cmd("hi! link FoldColumn Ignore")
end

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

function M.win_enter()
    set_rnu()
end

function M.scmd_enter()
    set_win_rnu(false)
    ex.redraws()
end

function M.scmd_leave()
    set_win_rnu(true)
end

return M
