---This is meant to be used in concert with `vim-grepper`
---Vim-grepper searches the current directory, this searches the current buffer
---@module "common.grepper"
local M = {}

local D = require("dev")
local utils = require("common.utils")
local mpi = require("common.api")
local map = mpi.map
local op = require("common.op")

-- local api = vim.api
local cmd = vim.cmd
local fn = vim.fn
local F = vim.F

--TODO: Reverse lines as an operatorfunc

---Execute `vimgrep`
---@param mode string
function M.vimgrep_qf(mode)
    local regions = op.get_region(mode)
    local txt = op.get_text(regions, mode)
    -- FIX: Multiline
    local text = table.concat(txt, "\n")
    cmd.vimgrep(([[/\C%s/]]):format(text), "%")
    cmd.copen()
end

---'Operator function' function
---@param motion string text motion
function M.vg_motion(motion)
    op.operator({cb = "v:lua.require'common.grepper'.vimgrep_qf", motion = motion})
end

---Execute `helpgrep`
---@param mode string
function M.helpgrep_qf(mode)
    local regions = op.get_region(mode)
    local text = table.concat(op.get_text(regions, mode), " ")
    cmd.helpgrep(([[%s]]):format(text))
    vim.defer_fn(function()
        cmd.copen()
        cmd.wincmd("k")
    end, 300)
end

---'Operator function' function
---@param motion string text motion
function M.hg_motion(motion)
    op.operator({cb = "v:lua.require'common.grepper'.helpgrep_qf", motion = motion})
end

---Execute `Ggrep`
---@param path? string
---@param mode? string
function M.gitgrep_qf(path, mode)
    local regions = op.get_region(mode)
    local txt = op.get_text(regions, mode)
    local text = table.concat(txt, "\n")
    cmd.Ggrep({([["%s" "%s"]]):format(text, path or ".config/nvim"), bang = true})
    utils.mod.prequire("noice.message.router"):thenCall(function(noice)
        vim.defer_fn(function()
            noice.dismiss()
        end, 1)
    end)
    cmd.copen()
end

---'Operator function' function
---@param motion string text motion
function M.gg_motion(motion)
    op.operator({cb = "v:lua.require'common.grepper'.ggrep_qf", motion = motion})
end

---Execute `Ggrep` on nvim dir
---@param path? string
---@param mode? string
function M.nvimgrep_qf(path, mode)
    M.gitgrep_qf(".config/nvim", mode)
end

---'Operator function' function
---@param motion string text motion
function M.ng_motion(motion)
    op.operator({cb = "v:lua.require'common.grepper'.nvimgrep_qf", motion = motion})
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                      Telescope Grep                      │
-- ╰──────────────────────────────────────────────────────────╯

---Show grep results in telescope
---@param type string
---@param only_curr boolean grep only current buffer
M.telescope_grep = function(type, only_curr)
    local select_save = vim.o.selection
    vim.o.selection = "inclusive"
    local reg_save = nvim.reg["@"]

    if type:match("v") then
        cmd.normal({"`<v`>y", bang = true})
    elseif type:match("char") then
        cmd.normal({"`[v`]y", bang = true})
    else
        return
    end

    local curr = fn.expand("%:p")
    local cwd = fn.expand("%:p:h")
    local root = require("common.gittool").root(cwd)
    cmd.lcd(cwd)

    local opts = {
        layout_strategy = "vertical",
        layout_config = {prompt_position = "top"},
        sorting_strategy = "ascending",
        search_dirs = {F.if_expr(only_curr, curr, (#root == 0 and cwd or root))},
        search = nvim.reg["@"],
    }

    require("telescope.builtin").grep_string(opts)

    -- This sets the register to what is queried
    vim.o.selection = select_save
    nvim.reg["@"] = reg_save
end

---Show grep results of the current buffer in telescope
---@param type string
M.telescope_grep_current_buffer = function(type)
    M.telescope_grep(type, true)
end

--  ══════════════════════════════════════════════════════════════════════

-- TODO: Finish

function M.reverse_cb(motion)
    -- local select_save = vim.o.selection
    -- vim.o.selection = "inclusive"
    -- local reg_save = nvim.reg["@"]

    local regions = op.get_region(mode)
    nvim.mark["<"] = {regions.start.row, regions.start.col}
    nvim.mark[">"] = {regions.finish.row, regions.finish.col}

    -- vim.o.selection = select_save
    -- nvim.reg["@"] = reg_save

    cmd.Reverse()
end

---'Operator function' function
---@param motion string text motion
function M.reverse_motion(motion)
    op.operator({cb = "v:lua.require'common.grepper'.reverse_cb", motion = motion})
end

--  ══════════════════════════════════════════════════════════════════════

local function init()
    map("n", "go", M.vg_motion, {desc = "Grep current file"})
    map("x", "go", D.ithunk(M.vimgrep_qf, fn.visualmode()), {desc = "Grep current file"})
    map("n", "gH", M.hg_motion, {desc = "Help grep"})
    map("n", "gt", M.ng_motion, {desc = "Ggrep .config/nvim"})
    map("x", "gt", D.ithunk(M.nvimgrep_qf, fn.visualmode()), {desc = "Grep .config/nvim"})

    -- map(
    --     "n",
    --     "gY",
    --     [[:lua R('common.grepper').reverse_motion()<CR>]],
    --     {desc = "Grep current file"}
    -- )

    -- map(
    --     "n",
    --     "gt",
    --     [[:sil! set operatorfunc=v:lua.require'common.grepper'.telescope_grep<cr>g@]],
    --     {desc = "Telescope grep"}
    -- )
    -- map(
    --     "x",
    --     "gt",
    --     [[:call v:lua.require'common.grepper'.telescope_grep(visualmode())<cr>]],
    --     {desc = "Telescope grep"}
    -- )

    map(
        "n",
        "gT",
        D.ithunk(op.operator, {cb = "require'common.grepper'.telescope_grep_current_buffer"}),
        {desc = "Telescope grep (current buf)"}
    )
    map(
        "x",
        "gT",
        [[:call v:lua.require'common.grepper'.telescope_grep_current_buffer(visualmode())<cr>]],
        {desc = "Telescope grep (current buf)"}
    )
end

init()

-- ╭──────────────────────────────────────────────────────────╮
-- │                     Alternative Grep                     │
-- ╰──────────────────────────────────────────────────────────╯

---An alternative to the above functions
---@param type string
function M.grep_operator(type)
    -- local saved_unnamed_register = fn.getreg("@@")
    if type:match("v") then
        cmd.normal({"`<v`>y", bang = true})
    elseif type:match("char") then
        cmd.normal({"`[v`]y", bang = true})
    else
        return
    end

    -- local row, col = unpack(api.nvim_win_get_cursor(0))
    local escaped = fn.shellescape(fn.getreg("@@"))

    -- cmd(("vimgrep! %s %s"):format(escaped, fn.expand("%")))
    cmd.vimgrep(("%s %s"):format(escaped, fn.expand("%")))
    -- vim.cmd([[silent execute 'grep! ' . shellescape(@@) . ' %%']])

    -- fn.setreg("@@", saved_unnamed_register)
    -- mpi.set_cursor(0, row, col)
    -- p(("%s %s"):format(winnr, fn.winnr()))

    cmd.copen()
end

return M
