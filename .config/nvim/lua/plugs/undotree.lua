local M = {}

-- if not _G.packer_plugins["undotree"] then
--     return
-- end

local utils = require("common.utils")
local map = utils.map
local command = utils.command

local ex = nvim.ex
local g = vim.g

local bmap = function(...)
    utils.bmap(0, ...)
end

function M.toggle()
    fn["undotree#UndotreeToggle"]()
    require("plugs.undotree").clean_undo()
end

function M.clean_undo()
    local u_dir = vim.o.undodir
    local pre_len = u_dir:len(vim.o.undodir) + 2
    for file in vim.gsplit(fn.globpath(u_dir, "*"), "\n") do
        local fp_per = file:sub(pre_len, -1)
        local fp = fp_per:gsub("%%", "/")
        if fn.glob(fp) == "" then
            os.remove(fp)
        end
    end
end

-- This doesn't translate to global vim space
-- function Undotree_CustomMap()
--     ex.nunmap("<buffer> u")
--     ex.nunmap("<buffer> U")
--     bmap("n", "J", "<Plug>UndotreePreviousState")
--     bmap("n", "K", "<Plug>UndotreeNextState")
--     bmap("n", "D", "<Plug>UndotreeDiffToggle")
--     bmap("n", "u", "<Plug>UndotreeUndo")
--     bmap("n", "U", "<Plug>UndotreeRedo")
-- end

local function init()
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

    ex.packadd("undotree")

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

    require("which-key").register(
        {
            ["<Leader>ut"] = {":UndotreeToggle<CR>", "Toggle undotree"}
        }
    )

    command(
        "UndoTreeToggle",
        function()
            require("plugs.undotree").toggle()
        end,
        {nargs = 0}
    )
end

init()

return M
