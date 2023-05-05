local M = {}

local log = require("common.log")

local fn = vim.fn
local cmd = vim.cmd

local mods_action

--     {
--         event = {"QuickFixCmdPost"},
--         pattern = {"[^l]*"},
--         nested = true,
--         command = "cwindow",
--     },
--     {
--         event = {"QuickFixCmdPost"},
--         pattern = {"l*"},
--         nested = true,
--         command = "lwindow",
--     },

function M.do_action()
    if vim.v.event.abort then
        return
    end

    local raw_cmd = fn.getcmdline()
    local com_pat = raw_cmd:gsub("^%s*(%w+).*", "^%1")
    for c, mod in pairs(mods_action) do
        if c:match(com_pat) then
            cmd("let v:event.abort = v:true")
            vim.schedule(function()
                local ok, res = pcall(cmd, ("%s %s"):format(mod, raw_cmd))
                if not ok then
                    local _
                    _, _, res = res:find([[Vim%(.*%):(.*)$]])
                    log.err(res, {title = "cmdhijack"})
                end
            end)
            break
        end
    end
end

local function init()
    mods_action = {
        -- ["Man"] = "tab",
        ["cwindow"] = "bo",
        ["copen"] = "bo",
        ["lwindow"] = "abo",
        ["lopen"] = "abo",
    }

    nvim.autocmd.lmb__CmdHijack = {
        {
            event = "CmdlineLeave",
            pattern = ":",
            command = function()
                M.do_action()
            end,
        },
        {
            event = "CmdlineEnter",
            pattern = ":",
            command = "set nosmartcase",
        },
        {
            event = "CmdlineLeave",
            pattern = ":",
            command = "set smartcase",
        },
        {
            event = "CmdwinEnter",
            pattern = "*",
            command = "nnoremap <silent><buffer><nowait> q <C-W>c",
            desc = "Map 'q' to close command window when exiting",
        },
    }
end

init()

return M
