local M = {}

-- local D = require("dev")
local debounce = require("common.debounce")
local disposable = require("common.disposable")
local utils = require("common.utils")
local prequire = utils.mod.prequire
local mpi = require("common.api")
local map = mpi.map

local cmd = vim.cmd
local g = vim.g

local last_cmdheight

local hlslens, noice
local config, lens_backup
local n_keymap

---@type Disposable[]
local disposables
local debounced

local MODE = {
    NORMAL = "NORMAL",
    VISUAL = "VISUAL",
}

M.mode = function()
    if g["Vm"].extend_mode == 1 then
        return MODE.VISUAL
    else
        return MODE.NORMAL
    end
end

local bmap = function(...)
    local d = mpi.bmap(0, ...)
    disposables:insert(d)
end

local override_lens = function(render, plist, nearest, idx, r_idx)
    local _ = r_idx
    local lnum, col = unpack(plist[idx])

    local text, chunks
    if nearest then
        text = ("[%d/%d]"):format(idx, #plist)
        chunks = {{" ", "Ignore"}, {text, "VM_Extend"}}
    else
        text = ("[%d]"):format(idx)
        chunks = {{" ", "Ignore"}, {text, "HlSearchLens"}}
    end
    render.setVirt(0, lnum - 1, col - 1, chunks, nearest)
end

function M.start()
    prequire("noice"):thenCall(function(n)
        local c = require("noice.config")
        if c.is_running() then
            n.disable()
            -- cmd("silent! Noice disable")
            last_cmdheight = vim.opt.cmdheight:get()
            vim.opt_local.cmdheight = 1
            noice = n
        end
    end)

    prequire("hlslens"):thenCall(function(h)
        config = require("hlslens.config")
        lens_backup = config.override_lens
        config.override_lens = override_lens
        h.start()
        hlslens = h
    end)
end

function M.exit()
    if noice then
        noice.enable()
        vim.opt_local.cmdheight = last_cmdheight
    end

    if hlslens then
        config.override_lens = lens_backup
        hlslens.start()
    end

    disposable.dispose_all(disposables)
    map("n", "n", n_keymap, {silent = true})

    -- Sometimes this doesn't clear properly
    local stl = "%{%v:lua.require'lualine'.statusline()%}"
    if not vim.o.stl == stl then
        pcall(cmd.VMClear)
        vim.o.stl = stl
    end
end

function M.mappings()
    if not debounced then
        -- FIX: This needs to not call setup again
        debounced =
            debounce(
                function()
                    n_keymap = mpi.get_keymap("n", "n").rhs
                    prequire("registers"):thenCall(function(reg)
                        reg.setup({bind_keys = {false}})
                        mpi.del_keymap("n", '"')
                    end)
                end,
                10
            )
        debounced()
    end

    -- bmap("n", ".", "<Plug>(VM-Dot)", {silent = true})
    bmap("n", "s", "<Plug>(VM-Select-Operator)", {silent = true, nowait = true})
    bmap("n", "n", "<C-n>", {silent = true, noremap = false})
    bmap("n", "<C-c>", "<Plug>(VM-Exit)", {silent = true})
    bmap("n", ";i", "<Plug>(VM-Show-Regions-Info)", {silent = true})
    bmap("n", ";e", "<Plug>(VM-Filter-Lines)", {silent = true})
    bmap("n", "<C-s>", "<Cmd>lua require('substitute').operator()<CR>", {silent = true})
    bmap(
        "n",
        "v",
        ":call b:VM_Selection.Global.extend_mode()<CR>",
        {silent = true, noremap = false}
    )
    bmap(
        "i",
        "<CR>",
        [[coc#pum#visible() ? "\<C-y>" : "\<Plug>(VM-I-Return)"]],
        {expr = true, noremap = false}
    )
    bmap(
        "n",
        "<Esc>",
        function()
            if M.mode() == MODE.VISUAL then
                cmd("call b:VM_Selection.Global.cursor_mode()")
            else
                utils.normal("n", "<Plug>(VM-Exit)")
            end
        end,
        {nowait = true}
    )
end

local function init()
    disposables = _t({})
end

init()

return M
