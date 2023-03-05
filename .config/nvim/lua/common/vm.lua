local M = {}

local D = require("dev")
local debounce = require("common.debounce")
local utils = require("common.utils")
local map = utils.map

local cmd = vim.cmd
local g = vim.g

local last_cmdheight

local hlslens
local config
local lens_backup

local dispose0, dispose1, dispose2, dispose3, dispose4, dispose5, dispose6, dispose7
local dispose8
local n_keymap, s_keymap, y_keymap
local debounced

local MODE = {
    NORMAL = "NORMAL",
    VISUAL = "VISUAL"
}

M.mode = function()
    if g["Vm"].extend_mode == 1 then
        return MODE.VISUAL
    else
        return MODE.NORMAL
    end
end

local bmap = function(...)
    return utils.bmap(0, ...)
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
    if D.plugin_loaded("noice.nvim") then
        cmd("silent! Noice disable")
        -- FIX: This bounces back and forth between 2 and 1
        last_cmdheight = vim.opt.cmdheight:get()
        vim.opt_local.cmdheight = 1
    end

    if hlslens then
        config = require("hlslens.config")
        lens_backup = config.override_lens
        config.override_lens = override_lens
        hlslens.start()
    end
end

function M.exit()
    if D.plugin_loaded("noice.nvim") then
        cmd("silent! Noice enable")
        vim.opt_local.cmdheight = last_cmdheight
    end

    if hlslens then
        config.override_lens = lens_backup
        hlslens.start()
    end

    dispose0:dispose()
    dispose1:dispose()
    dispose2:dispose()
    dispose3:dispose()
    dispose4:dispose()
    dispose5:dispose()
    dispose6:dispose()
    dispose7:dispose()
    dispose8:dispose()
    map("n", "n", n_keymap, {silent = true})
    map("n", "s", s_keymap, {silent = true})
    -- map("n", "y", y_keymap, {silent = true, expr = true})

    -- Sometimes this doesn't clear properly
    local stl = "%{%v:lua.require'lualine'.statusline()%}"
    if not vim.o.stl == stl then
        pcall(cmd.VMClear)
        vim.o.stl = stl
    end
end

function M.mappings()
    if not debounced then
        debounced =
            debounce(
            function()
                n_keymap = utils.get_keymap("n", "n").rhs
                s_keymap = utils.get_keymap("n", "s").rhs
                -- y_keymap = utils.get_keymap("n", "y").rhs
            end,
            10
        )
        debounced()
    end

    dispose0 = bmap("n", "s", "<Plug>(VM-Select-Operator)", {silent = true, nowait = true})
    dispose1 = bmap("n", "n", "<C-n>", {silent = true, noremap = false})
    dispose2 =
        bmap(
        "n",
        "v",
        ":call b:VM_Selection.Global.extend_mode()<CR>",
        {silent = true, noremap = false}
    )
    dispose3 = bmap("n", "<C-c>", "<Plug>(VM-Exit)", {silent = true})
    dispose4 =
        bmap(
        "i",
        "<CR>",
        [[coc#pum#visible() ? "\<C-y>" : "\<Plug>(VM-I-Return)"]],
        {expr = true, noremap = false}
    )
    dispose5 = bmap("n", "<C-c>", "<Plug>(VM-Exit)", {silent = true})
    dispose6 =
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
    dispose7 = bmap("n", ";i", "<Plug>(VM-Show-Regions-Info)", {silent = true})
    dispose8 = bmap("n", ";e", "<Plug>(VM-Filter-Lines)", {silent = true})

    -- dispose7 = bmap("n", "<Leader>y", '"+y', {silent = true})
    -- dispose8 = bmap("n", "y", "<Plug>(VM-Yank)", {silent = true})

    -- bmap("n", ".", "<Plug>(VM-Dot)", {silent = true})
    -- bmap("n", "m", "<Plug>(VM-Find-Operator)", {silent = true, nowait = true})
end

local function init()
    local ok, res = pcall(require, "hlslens")
    if ok then
        hlslens = res
    end
end

init()

return M
