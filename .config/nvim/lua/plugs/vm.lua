local M = {}

local D = require("dev")

local mpi = require("common.api")
local command = mpi.command

local ffi = require("common.ffi")
local disposable = require("common.disposable")
local utils = require("common.utils")
local prequire = utils.mod.prequire
local mpi = require("common.api")
local map = mpi.map

local cmd = vim.cmd
local g = vim.g

---@type Disposable[]|Table
local disposables
local hlslens, noice
local config, lens_backup, cmdheight_backup
local n_km, dq_km

---@alias VmMode {NORMAL: 0, VISUAL: 1}
---@type VmMode
local mode = ffi.enum.new('NORMAL, VISUAL')

function M.mode()
    if g.Vm.extend_mode == 1 then
        return mode.VISUAL
    else
        return mode.NORMAL
    end
end

local function bmap(...)
    local d = mpi.bmap(0, ...)
    disposables:insert(d)
end

local function override_lens(render, plist, nearest, idx, r_idx)
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
    render.set_virt(0, lnum - 1, col - 1, chunks, nearest)
end

---Startup function
function M.start()
    prequire("noice"):thenCall(function(n)
        local c = require("noice.config")
        if c.is_running() then
            n.disable()
            cmdheight_backup = vim.o.cmdheight
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

---Cleanup function
function M.exit()
    if noice then
        noice.enable()
        vim.opt_local.cmdheight = cmdheight_backup
    end

    if hlslens then
        config.override_lens = lens_backup
        hlslens.start()
    end

    disposable.dispose_all(disposables)
    map("n", "n", n_km, {silent = true})
    -- map("n", "N", N_km, {silent = true})
    if dq_km then
        dq_km.restore()
    end

    -- Sometimes this doesn't clear properly
    local stl = "%{%v:lua.require'lualine'.statusline()%}"
    if not vim.o.stl == stl then
        pcall(cmd.VMClear)
        vim.o.stl = stl
    end
end

---Mappings while vim-visual-multi is active
function M.mappings()
    -- D.once(function()
        local nk = mpi.get_keymap("n", "n")
        n_km = nk.callback or nk.rhs

        prequire("registers"):thenCall(function(reg)
            -- reg.setup({bind_keys = {false}})
            -- N(mpi.get_keymap("n", '"'))
            dq_km = mpi.del_keymap("n", '"')
        end)
    -- end)()

    -- bmap("n", ".", "<Plug>(VM-Dot)", {silent = true})
    bmap("n", "s", "<Plug>(VM-Select-Operator)", {silent = true, nowait = true})
    bmap("n", "<CR>", "<C-n>", {silent = true, noremap = false})
    bmap("n", "n", "<C-n>", {silent = true, noremap = false})
    bmap("n", "N", "N", {silent = true, noremap = false})
    bmap("n", ")", "n", {silent = true, noremap = true})
    bmap("n", "(", "N", {silent = true, noremap = false})
    bmap("n", "<C-c>", "<Plug>(VM-Exit)", {silent = true})
    bmap("n", ";i", "<Plug>(VM-Show-Regions-Info)", {silent = true})
    bmap("n", ";e", "<Plug>(VM-Filter-Lines)", {silent = true})
    -- FIX: Only does last line
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
            if M.mode() == mode.VISUAL then
                cmd("call b:VM_Selection.Global.cursor_mode()")
            else
                utils.normal("n", "<Plug>(VM-Exit)")
            end
        end,
        {nowait = true}
    )
end

---Setup `vim-visual-multi`
function M.setup()
    g.VM_highlight_matches = ""
    g.VM_show_warnings = 0
    g.VM_silent_exit = 1
    g.VM_default_mappings = 0
    g.VM_set_statusline = 0 -- 3 if you want to use this STL
    g.VM_case_setting = "smart"
    g.VM_recursive_operations_at_cursors = true

    g.VM_Mono_hl = "DiffText"  -- ErrorMsg DiffText
    g.VM_Extend_hl = "DiffAdd" -- PmenuSel DiffAdd
    g.VM_Cursor_hl = "Visual"
    g.VM_Insert_hl = "DiffChange"

    g.VM_custom_motions = {
        ["L"] = "$",
        ["H"] = "^",
    }
    g.VM_custom_noremaps = {
        ["=="] = "==",
        ["<<"] = "<<",
        [">>"] = ">>",
    }

    g.VM_user_operators = {
        "dss",           -- delete surround automatic detection
        {css = 1},       -- change surround automatic detection
        {yss = 1},       -- surround line
        {cs = 2},        -- change surround
        {ds = 1},        -- delete surround
        "gc",            -- comment
        {ys = 3},
        {cr = 3},        -- FIX: change case
        {["<C-s>"] = 2}, -- FIX: substitute (replaces with second letter or only last line)
    }

    -- g.VM_custom_commands = {}
    --
    -- g.VM_custom_remaps = {
    --   -- ["<C-c>"] = "<Esc>"
    -- }
    --
    -- g.VM_plugins_compatibilty = {
    --     plugin_name = {
    --         test = function()
    --         end,
    --         enable = ":PluginEnableCommand",
    --         disable = ":PluginDisableCommand"
    --     }
    -- }

    -- https://github.com/mg979/vim-visual-multi/wiki/Special-commands
    -- https://github.com/mg979/vim-visual-multi/wiki/Mappings
    g.VM_maps = {
        Delete = "d",
        Yank = "y",
        ["Select Operator"] = "s",
        ["Find Operator"] = "m",
        Undo = "u",
        Redo = "U",
        ["Switch Mode"] = ",",
        i = "i",
        I = "I",
        ["Add Cursor At Pos"] = [[<Leader>\]],
        -- ["Add Cursor Up"] = "<A-S-i>",
        -- ["Add Cursor Down"] = "<A-S-o>",
        -- ["Select Cursor Up"] = "<C-S-Up>",
        -- ["Select Cursor Down"] = "<C-S-Down>",
        ["Slash Search"] = "g/",              -- Extend/move cursors with /
        ["Move Left"] = "<C-S-i>",            -- Move region left
        ["Move Right"] = "<C-S-o>",           -- Move region right
        -- Region cycling and removal
        ["Find Next"] = "]",                  -- Same as "n"
        ["Find Prev"] = "[",                  -- Same as "N"
        ["Goto Next"] = "}",                  -- Go to next selected region
        ["Goto Prev"] = "{",                  -- Go to prev selected region
        ["Seek Next"] = "<C-f>",              -- Fast go to next (from next page)
        ["Seek Prev"] = "<C-b>",              -- Fast go to previous (from previous page)
        ["Skip Region"] = "q",                -- Skip and find to next
        ["Remove Region"] = "Q",              -- Remove region under cursor
        ["Remove Last Region"] = "<Leader>q", -- Remove last added region
        ["Remove Every n Regions"] = "<Leader>R",
        -- Special Commands
        ["Surround"] = "S",
        ["Replace Pattern"] = "R",
        ["Increase"] = "<C-A-i>", -- Increase numbers/letters
        ["Decrease"] = "<C-A-o>", -- Decrease numbers/letters
        -- ["gIncrease"] = "<C-S-i>", -- Progressively increase numbers
        -- ["gDecrease"] = "<C-S-o>", -- Progressively decrease numbers
        -- ["Alpha-Increase"] = "<C-S-i>",
        -- ["Alpha-Decrease"] = "<C-S-o>",

        -- Commands
        ["Invert Direction"] = "o",             -- Change direction cursor is within region
        ["Shrink"] = "<",                       -- Reduce regions from the sides
        ["Enlarge"] = ">",                      -- Enlarge regions from the sides
        ["Transpose"] = "<Leader>t",            -- Transpose selected regions
        ["Align"] = "<Leader>a",                -- Align regions
        ["Align Char"] = "<Leader><",           -- Align by character
        ["Align Regex"] = "<Leader>>",          -- Align by regex
        ["Split Regions"] = "<Leader>s",        -- Subtract pattern from regions
        ["Filter Regions"] = "<Leader>f",       -- Filter regions by pattern/expression
        ["Merge Regions"] = "<Leader>m",        -- Merge overlapping regions
        ["Transform Regions"] = "<Leader>e",    -- Transform regions with expression
        ["Rewrite Last Search"] = "<Leader>r",  -- Rewrite last pattern to match current region
        ["Duplicate"] = "<Leader>d",            -- Duplicate regions
        ["One Per Line"] = "<Leader>L",         -- Keep at most one region per line
        ["Numbers"] = "<Leader>n",              -- Insert numbers before cursor
        ["Numbers Append"] = "<Leader>N",       -- Insert numbers after cursor
        ["Zero Numbers"] = "<Leader>0n",        -- Insert numbers before cursor
        ["Zero Numbers Append"] = "<Leader>0N", -- Insert numbers after cursor
        --
        ["Run Normal"] = "<Leader>z",
        ["Run Last Normal"] = "<Leader>Z",
        ["Run Visual"] = "<Leader>v",
        ["Run Last Visual"] = "<Leader>V",
        ["Run Ex"] = "<Leader>x",
        ["Run Last Ex"] = "<Leader>X",
        ["Run Macro"] = "<Leader>@",
        ["Run Dot"] = "<Leader>.",
        --
        ["Tools Menu"] = "<Leader>`",           -- Filter lines to buffer, etc
        ["Case Setting"] = "<Leader>c",         -- Cycle case setting ('scs' -> 'noic' -> 'ic')
        ["Case Conversion Menu"] = "<Leader>C", -- Works better in extend mode
        ["Search Menu"] = "<Leader>S",
        ["Show Registers"] = '<Leader>"',       -- Show VM registers in the command line
        ["Show Infoline"] = "<Leader>l",        -- Shows information about current regions and patterns and modes
        --
        ["Toggle Whole Word"] = "<Leader>w",    -- Toggle whole word search
        ["Toggle Block"] = "<Leader><BS>",
        ["Toggle Multiline"] = "<Leader>M",
        ["Toggle Single Region"] = "<Leader><CR>", -- Toggle single region mode
        ["Toggle Mappings"] = "<Leader><Leader>",  -- Toggle VM buffer mappings
        -- Visual
        ["Visual Subtract"] = "<Leader>s",         -- Remove visual from region
        ["Visual Find"] = "<Leader>f",             -- Find from visually selection region
        ["Visual Add"] = "<Leader>a",
        ["Visual All"] = "<Leader>A",
        -- Insert Mode
        ["I Arrow w"] = "<C-Right>",
        ["I Arrow b"] = "<C-Left>",
        ["I Arrow W"] = "<C-S-Right>",
        ["I Arrow B"] = "<C-S-Left>",
        ["I Arrow ge"] = "<C-Up>",
        ["I Arrow e"] = "<C-Down>",
        ["I Arrow gE"] = "<C-S-Up>",
        ["I Arrow E"] = "<C-S-Down>",
        -- ["I Prev"] = "<C-k>", -- Insert mode to go prev cursor
        -- ["I Next"] = "<C-j>", -- Insert mode to go next cursor
    }

    map("n", "<M-S-i>", "<Plug>(VM-Add-Cursor-Up)")
    map("n", "<M-S-o>", "<Plug>(VM-Add-Cursor-Down)")
    map("n", "<C-S-Up>", "<Plug>(VM-Select-Cursor-Up)")
    map("n", "<C-S-Down>", "<Plug>(VM-Select-Cursor-Down)")
    map("n", "<C-A-S-Right>", "<Plug>(VM-Select-l)")
    map("n", "<C-A-S-Left>", "<Plug>(VM-Select-h)")
    map("n", [[<Leader>\]], "<Plug>(VM-Add-Cursor-At-Pos)")

    map("n", "<Leader>/", "<Plug>(VM-Start-Regex-Search)")
    map("x", "<Leader>/", "<Plug>(VM-Visual-Regex)")
    map("n", "<C-n>", "<Plug>(VM-Find-Under)")
    map("x", "<C-n>", "<Plug>(VM-Find-Subword-Under)")

    map("n", "<Leader>A", "<Plug>(VM-Select-All)")
    map("x", "<Leader>A", "<Plug>(VM-Visual-All)")
    map("x", ";A", "<Plug>(VM-Visual-All)")
    map("x", ";a", "<Plug>(VM-Visual-Add)")
    map("x", ";F", "<Plug>(VM-Visual-Find)")
    map("x", ";C", "<Plug>(VM-Visual-Cursors)")

    map("n", "<Leader>gs", "<Plug>(VM-Reselect-Last)", {desc = "VM: Select last"})
    map("n", "g/", "<Cmd>VMSearch<CR>", {desc = "Start VM with last search"})

    command(
        "VMFixStl",
        function()
            cmd.VMClear()
            vim.o.statusline = "%{%v:lua.require'lualine'.statusline()%}"
        end
    )
end

local function init()
    M.setup()

    disposables = _t({})

    nvim.autocmd.lmb__VisualMulti = {
        {
            event = "User",
            pattern = "visual_multi_start",
            command = D.ithunk(M.start),
        },
        {
            event = "User",
            pattern = "visual_multi_exit",
            command = D.ithunk(M.exit),
        },
        {
            event = "User",
            pattern = "visual_multi_mappings",
            command = D.ithunk(M.mappings),
        },
    }
end

init()

return M
