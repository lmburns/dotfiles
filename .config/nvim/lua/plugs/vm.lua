local M = {}

local F = Rc.F
local utils = Rc.shared.utils
local prequire = utils.mod.prequire

local command = Rc.api.command
local map = Rc.api.map
local disposable = Rc.lib.disposable
-- local ffi = Rc.lib.ffi

local cmd = vim.cmd
local g = vim.g

---@type Disposable[]|Table|table|tablelib
local disposables
local hlslens, noice, wilder
local config, lens_backup, cmdheight_backup
local n_km

-- local mode = ffi.enum.new("NORMAL, VISUAL")

---@alias VmMode {NORMAL: 0, VISUAL: 1}
---@type VmMode
local mode = {NORMAL = 0, VISUAL = 1}

function M.mode()
    if g.Vm.extend_mode == 1 then
        return mode.VISUAL
    else
        return mode.NORMAL
    end
end

local function bmap(...)
    local d = Rc.api.bmap(0, ...)
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
    -- prequire("noice"):thenCall(function(n)
    --     local c = require("noice.config")
    --     if c.is_running() then
    --         n.disable()
    --         cmdheight_backup = vim.o.cmdheight
    --         vim.opt_local.cmdheight = 1
    --         noice = n
    --     end
    -- end)

    prequire("hlslens"):thenCall(function(h)
        config = require("hlslens.config")
        lens_backup = config.override_lens
        config.override_lens = override_lens
        h.start()
        hlslens = h
    end)

    -- prequire("wilder"):thenCall(function(w)
    --     w.disable()
    --     wilder = w
    -- end)
end

---Cleanup function
function M.exit()
    disposable.dispose_all(disposables)
    -- disposables = {}
    map("n", "n", n_km, {silent = true})

    if hlslens then
        config.override_lens = lens_backup
        hlslens.start()
    end

    -- if wilder then
    --     wilder.enable()
    -- end

    -- Sometimes statusline doesn't clear properly
    local stl = "%{%v:lua.require'lualine'.statusline()%}"
    if not vim.o.stl == stl then
        pcall(cmd.VMClear)
        vim.o.stl = stl
    end

    -- if noice then
    --     noice.enable()
    --     vim.opt_local.cmdheight = cmdheight_backup
    -- end
end

---Mappings while vim-visual-multi is active
function M.mappings()
    local nk = Rc.api.get_keymap("n", "n")
    n_km = nk.callback or nk.rhs

    -- Rc.api.reset_keymap("n", '"', {noremap = false})
    -- bmap("n", ".", "<Plug>(VM-Dot)", {silent = true})
    -- bmap("n", "u", "<Plug>(VM-Undo)", {noremap = false})
    -- bmap("n", "U", "<Plug>(VM-Redo)", {noremap = false})
    bmap("n", "s", "<Plug>(VM-Select-Operator)", {nowait = true})
    bmap("n", "<CR>", "<C-n>", {noremap = false})
    bmap("n", "n", "<C-n>", {noremap = false})
    bmap("n", "N", "N", {noremap = false})
    bmap("n", '"', '"', {noremap = false})
    bmap("n", ")", "n", {noremap = true})
    bmap("n", "(", "N", {noremap = false})

    bmap({"o"}, "f", "f", {noremap = true})
    bmap({"o"}, "F", "F", {noremap = true})
    bmap({"o"}, "t", "t", {noremap = true})
    bmap({"o"}, "T", "T", {noremap = true})

    --         ["Align"] = "<Leader>a",                -- Align regions
    --         ["Align Char"] = "<Leader><",           -- Align by character
    --         ["Align Regex"] = "<Leader>>",          -- Align by regex

    -- bmap("n", "<C-s>", "<Plug>(VM-Run-Normal)<Cmd>lua require('substitute').operator()<CR>")
    -- bmap("n", "crt", "<Plug>(VM-Run-Normal)crt")
    -- bmap("n", "css", "<Plug>(sandwich-replace-auto)")
    -- bmap("n", "cs", "<Plug>(sandwich-replace)")
    -- bmap("n", "ys", "<Plug>(sandwich-add)")

    bmap("n", "<C-c>", "<Plug>(VM-Exit)", {silent = true})
    bmap("n", ";i", "<Plug>(VM-Show-Regions-Info)", {silent = true})
    bmap("n", ";e", "<Plug>(VM-Filter-Lines)", {silent = true})
    bmap("n", "v", "b:VM_Selection.Global.extend_mode()", {ccmd = true, noremap = false})
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
    -- g.VM_recursive_operations_at_cursors = 1
    -- g.VM_verbose_commands = 1

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

    -- g.VM_custom_remaps = {}
    -- g.VM_custom_commands = {}

    g.VM_user_operators = {
        "dss",     -- delete surround automatic detection
        {css = 1}, -- change surround automatic detection
        {yss = 1}, -- surround line
        {cs = 2},  -- change surround
        {ds = 1},  -- delete surround
        "gc",      -- comment
        "gb",      -- comment
        -- {crt = 2},
        -- {crc = 2},
        -- "cr",
        -- {cr = 3},  -- change case FIX: not all work; breaks cs/css if mapped above
        -- {ys = 3},        -- add surround
        -- {["<C-s>"] = 2}, -- FIX: substitute (replaces with second letter or only last line)
    }

    -- g.VM_plugins_compatibilty = {
    --     noice = {
    --         test = function()
    --             return require('noice.config').is_running()
    --         end,
    --         enable = ":NoiceEnable",
    --         disable = ":NoiceDisable"
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

    map("n", "<M-S-i>", "<Plug>(VM-Add-Cursor-Up)", {desc = "VM: Add-Cursor-Up"})
    map("n", "<M-S-o>", "<Plug>(VM-Add-Cursor-Down)", {desc = "VM: Add-Cursor-Down"})
    map("n", "<C-S-Up>", "<Plug>(VM-Select-Cursor-Up)", {desc = "VM: Select-Cursor-Up"})
    map("n", "<C-S-Down>", "<Plug>(VM-Select-Cursor-Down)", {desc = "VM: Select-Cursor-Down"})
    map("n", "<C-A-S-Right>", "<Plug>(VM-Select-l)", {desc = "VM: Select-l"})
    map("n", "<C-A-S-Left>", "<Plug>(VM-Select-h)", {desc = "VM: Select-h"})
    map("n", [[<Leader>\]], "<Plug>(VM-Add-Cursor-At-Pos)", {desc = "VM: Add-Cursor-At-Pos"})

    map("n", "<Leader>/", "<Plug>(VM-Start-Regex-Search)", {desc = "VM: Start-Regex-Search"})
    map("x", "<Leader>/", "<Plug>(VM-Visual-Regex)", {desc = "VM: Visual-Regex"})
    map("n", "<C-n>", "<Plug>(VM-Find-Under)", {desc = "VM: Find-Under"})
    map("x", "<C-n>", "<Plug>(VM-Find-Subword-Under)", {desc = "VM: Find-Subword-Under"})

    map("n", "<Leader>A", "<Plug>(VM-Select-All)", {desc = "VM: Select-All"})
    map("x", "<Leader>A", "<Plug>(VM-Visual-All)", {desc = "VM: Visual-All"})
    map("x", ";A", "<Plug>(VM-Visual-All)", {desc = "VM: Visual-All"})
    map("x", ";a", "<Plug>(VM-Visual-Add)", {desc = "VM: Visual-Add"})
    map("x", ";F", "<Plug>(VM-Visual-Find)", {desc = "VM: Visual-Find"})
    map("x", ";C", "<Plug>(VM-Visual-Cursors)", {desc = "VM: Visual-Cursors"})

    map("n", "<Leader>gs", "<Plug>(VM-Reselect-Last)", {desc = "VM: Reselect-Last"})
    map("n", "g/", "<Cmd>VMSearch<CR>", {desc = "Start VM with last search"})

    command(
        "VMFixStl",
        function()
            cmd.VMClear()
            vim.o.statusline = "%{%v:lua.require'lualine'.statusline()%}"
        end,
        {desc = "VM: manually set Lualine STL back"}
    )
    command(
        "VMClearHl",
        F.pithunk(cmd, "call vm#clearmatches()"),
        {desc = "VM: clear highlights only"}
    )
end

local function init()
    M.setup()

    disposables = _t({})
    cmd([[sil! call repeat#set("\<Plug>mg979/vim-visual-multi", v:count)]])

    nvim.autocmd.lmb__VisualMulti = {
        {
            event = "User",
            pattern = "visual_multi_start",
            command = M.start,
        },
        {
            event = "User",
            pattern = "visual_multi_exit",
            command = M.exit,
        },
        {
            event = "User",
            pattern = "visual_multi_mappings",
            command = M.mappings,
        },
    }
end

init()

return M
