---@module 'plugs.undotree'
local M = {}

local mpi = require("usr.api")
local map = mpi.map
local command = mpi.command

local g = vim.g
local fn = vim.fn
local cmd = vim.cmd

function M.toggle()
    fn["undotree#UndotreeToggle"]()
    M.clean_undo()
end

function M.clean_undo()
    local u_dir = vim.o.undodir
    local pre_len = u_dir:len() + 2
    for file in vim.gsplit(fn.globpath(u_dir, "*"), "\n") do
        local fp_per = file:sub(pre_len, -1)
        local fp = fp_per:gsub("%%", "/")
        if fn.glob(fp) == "" then
            os.remove(fp)
        end
    end
end

local function init()
    cmd.packadd("undotree")
    g.undotree_SplitWidth = 45
    g.undotree_SetFocusWhenToggle = 1
    g.undotree_RelativeTimestamp = 1
    g.undotree_ShortIndicators = 1
    g.undotree_HelpLine = 0
    g.undotree_WindowLayout = 3

    cmd(
        [[
        function! Undotree_CustomMap()
            nunmap <buffer> u
            nmap <buffer> J <Plug>UndotreePreviousState
            nmap <buffer> K <Plug>UndotreeNextState
            nmap <buffer> D <Plug>UndotreeDiffToggle
            nmap <buffer> u <Plug>UndotreeUndo
            nmap <buffer> U <Plug>UndotreeRedo
        endfunc
    ]]
    )

    -- <plug>UndotreeHelp
    -- <plug>UndotreeClose
    -- <plug>UndotreeFocusTarget
    -- <plug>UndotreeClearHistory
    -- <plug>UndotreeTimestampToggle
    -- <plug>UndotreeDiffToggle
    -- <plug>UndotreeNextState
    -- <plug>UndotreePreviousState
    -- <plug>UndotreeNextSavedState
    -- <plug>UndotreePreviousSavedState
    -- <plug>UndotreeRedo
    -- <plug>UndotreeUndo
    -- <plug>UndotreeEnter

    map("n", "<Leader>ut", "<Cmd>UndotreeToggle<CR>", {desc = "Toggle undotree"})
    command("UndoTreeToggle", M.toggle, {desc = "Toggle UndoTree"})
end

init()

return M
