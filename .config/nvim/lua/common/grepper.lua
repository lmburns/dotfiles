---This is meant to be used in concert with `vim-grepper`
---Vim-grepper searches the current directory, this searches the current buffer
---@module 'common.grepper'
local M = {}

local log = require("common.log")
local utils = require("common.utils")
local mpi = require("common.api")
local xprequire = utils.mod.xprequire
local map = mpi.map
local op = require("common.op")

-- local api = vim.api
local cmd = vim.cmd
local fn = vim.fn
local F = vim.F

---FIX: Multiline

---@param ex fun(t: string)
---@param after fun()
---@param mode string
function M.exwrap(ex, after, mode)
    -- local regions = op.get_region(mode)
    -- local text = table.concat(op.get_text(regions, mode), " ")
    local text = op.get_selection(mode)
    local ok, ret = pcall(ex, text)
    if ok then
        xprequire("noice.message.router").dismiss()
        after()
    else
        log.err(ret, {title = "grepper"})
    end
end

---Execute `vimgrep` in current buffer only and show results in QF
---@param mode string
function M.vimgrep(mode)
    M.exwrap(function(text)
        cmd.vimgrep({([[/\C%s/]]):format(text), "%", bang = true, mods = {noautocmd = true}})
    end, cmd.copen, mode)
end

---'Operator function' function for `:vimgrep!`
---@param motion string text motion
function M.vimgrep_op(motion)
    op.operator({cb = "v:lua.require'common.grepper'.vimgrep", motion = motion})
end

---`:vimgrep` visual mode
function M.vimgrep_visual()
    utils.normal("x", "<esc>")
    M.vimgrep(fn.visualmode())
end

---Execute `helpgrep` and show results in QF
---@param mode string
function M.helpgrep(mode)
    M.exwrap(
        function(text)
            cmd.helpgrep({([[%s]]):format(text), mods = {keepjumps = true}})
        end,
        function()
            -- cmd.redraw({bang = true})
            cmd.copen()
            cmd.wincmd("k")
        end,
        mode
    )
end

---'Operator function' function for `:helpgrep!`
---@param motion string text motion
function M.helpgrep_op(motion)
    op.operator({cb = "v:lua.require'common.grepper'.helpgrep", motion = motion})
end

---`:helpgrep` visual mode
function M.helpgrep_visual()
    utils.normal("x", "<esc>")
    M.helpgrep(fn.visualmode())
end

---Execute `Ggrep` and show results in QF
---@param mode? string
function M.gitgrep(mode)
    M.exwrap(function(text)
        cmd.Ggrep({([['%s']]):format(text), bang = true, mods = {noautocmd = true}})
    end, cmd.copen, mode)
end

---'Operator function' function for `:Ggrep!`
---@param motion string text motion
function M.gitgrep_op(motion)
    op.operator({cb = "v:lua.require'common.grepper'.gitgrep", motion = motion})
end

---`:gitgrep` visual mode
function M.gitgrep_visual()
    utils.normal("x", "<esc>")
    M.gitgrep(fn.visualmode())
end

---Execute `Ggrep` on nvim dir and show results in QF
---@param mode? string
function M.nvimgrep(mode)
    M.exwrap(function(text)
        cmd.Ggrep({([['%s' .config/nvim]]):format(text), bang = true, mods = {noautocmd = true}})
    end, cmd.copen, mode)
end

---'Operator function' function for neovim `:Ggrep!`
---@param motion string text motion
function M.nvimgrep_op(motion)
    op.operator({cb = "v:lua.require'common.grepper'.nvimgrep", motion = motion})
end

---`:Ggrep` visual mode
function M.nvimgrep_visual()
    utils.normal("x", "<esc>")
    M.nvimgrep(fn.visualmode())
end

---Execute `grep` in current buffer only and show results in QF
---@param mode string
function M.grep(mode)
    M.exwrap(function(text)
        cmd.grep({([['%s']]):format(text), "%", bang = true, mods = {noautocmd = true}})
    end, cmd.copen, mode)
end

---'Operator function' function for `:grep!`
---@param motion string text motion
function M.grep_op(motion)
    op.operator({cb = "v:lua.require'common.grepper'.grep", motion = motion})
end

---`:grep` visual mode
function M.grep_visual()
    utils.normal("x", "<esc>")
    M.grep(fn.visualmode())
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                      Telescope Grep                      │
-- ╰──────────────────────────────────────────────────────────╯

---Execute grep and show results in telescope
---@param mode? string
---@param only_curr? boolean grep only current buffer
function M.tsgrep(mode, only_curr)
    local text = op.get_selection(mode)
    -- local curr = fn.expand("%:p")
    -- local cwd = fn.fnamemodify(curr, ":h")
    local root = require("common.gittool").root()
    cmd.lcd(cwd)

    local opts = {
        layout_strategy = "vertical",
        layout_config = {prompt_position = "top"},
        sorting_strategy = "ascending",
        search_dirs = {F.if_expr(only_curr, curr, (#root == 0 and cwd or root))},
        search = text,
    }

    require("telescope.builtin").grep_string(opts)
end

---'Operator function' function for telescope grep
---@param motion string text motion
function M.tsgrep_op(motion)
    op.operator({cb = "v:lua.require'common.grepper'.tsgrep", motion = motion})
end

---`:grep` visual mode
function M.tsgrep_visual()
    utils.normal("x", "<esc>")
    M.tsgrep(fn.visualmode())
end

---Execute grep and show results in telescope of current buffer only
---@param mode? string
function M.tsgrep_curbuf(mode)
    M.tsgrep(mode, true)
end

---'Operator function' function for telescope grep for current buffer
---@param motion string text motion
function M.tsgrep_curbuf_op(motion)
    op.operator({cb = "v:lua.require'common.grepper'.tsgrep_curbuf", motion = motion})
end

---`:grep` visual mode
function M.tsgrep_curbuf_visual()
    utils.normal("x", "<esc>")
    M.tsgrep_curbuf(fn.visualmode())
end

--  ══════════════════════════════════════════════════════════════════════

---Reverse text
---@param mode string
function M.reverse(mode)
    local regions = op.get_region(mode)
    cmd(("%d,%dg/^/m%d"):format(regions.start.row, regions.finish.row, regions.start.row - 1))
    cmd("nohl")
end

---'Operator function' function to reverse text
---@param motion string text motion
function M.reverse_op(motion)
    op.operator({cb = "v:lua.require'common.grepper'.reverse", motion = motion})
end

---Reverse in visual mode
function M.reverse_visual()
    utils.normal("x", "<esc>")
    M.reverse(fn.visualmode())
end

--  ══════════════════════════════════════════════════════════════════════

local function init()
    -- TODO: grepa vimgrepa command
    --       Checkout: startreplace startgreplace
    map("n", "go", M.vimgrep_op, {desc = "Grep: vimgrep %"})
    map("x", "go", M.vimgrep_visual, {desc = "Grep: vimgrep %"})
    map("n", "gH", M.helpgrep_op, {desc = "Grep: helpgrep"})
    map("x", "gH", M.helpgrep_visual, {desc = "Grep: helpgrep"})
    map("n", "gx", M.gitgrep_op, {desc = "Grep: Ggrep repo"})
    map("x", "gx", M.gitgrep_visual, {desc = "Grep: Ggrep .config/nvim"})
    map("n", "gt", M.nvimgrep_op, {desc = "Grep: Ggrep .config/nvim"})
    map("x", "gt", M.nvimgrep_visual, {desc = "Grep: Ggrep .config/nvim"})
    map("n", "gT", M.tsgrep_curbuf_op, {desc = "Grep: telescope curbuf"})
    map("x", "gT", M.tsgrep_curbuf_visual, {desc = "Grep: telescope curbuf"})
    -- map("n", "gt", M.tsgrep_op, {desc = "Grep: telescope cwd"})
    -- map("x", "gt", M.tsgrep_visual, {desc = "Grep: telescope cwd"})

    map("n", "gY", M.reverse_op, {desc = "Reverse: operator"})
    map("x", "gY", M.reverse_visual, {desc = "Reverse lines"})
end

init()

return M
