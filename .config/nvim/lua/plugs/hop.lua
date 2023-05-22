---@module 'plugs.hop'
local M = {}

local shared = require("usr.shared")
local F = shared.F
local hop = F.npcall(require, "hop")
if not hop then
    return
end

local mpi = require("usr.api")
local map = mpi.map

local hdir = require("hop.hint").HintDirection

local cmd = vim.cmd
local fn = vim.fn
local api = vim.api

-- =============================== Hop ================================
function M.setup()
    hop.setup({keys = "abcdefghijklmnopqrstuvwxyz;'"})
end

---Setup nvim-treehopper
function M.setup_treehopper()
    cmd.packadd("nvim-treehopper")
    local tsht = F.npcall(require, "tsht")
    if not tsht then
        return
    end

    tsht.config.hint_keys = {"h", "j", "f", "d", "n", "v", "s", "l", "a"}

    map("x", ",", [[:<C-u>lua require('tsht').nodes()<CR>]], {desc = "Treesitter node select"})
    map("o", ",", F.ithunk(tsht.nodes), {desc = "Treesitter node select"})
    map("n", "vx", F.ithunk(tsht.nodes), {desc = "Treesitter node select"})
    map("n", "<C-S-:>", F.ithunk(tsht.move, {side = "start"}), {desc = "TS node start"})
    map("n", "<Leader>sH", F.ithunk(tsht.move, {side = "start"}), {desc = "TS node start"})
    map("n", "<Leader>sL", F.ithunk(tsht.move, {side = "end"}), {desc = "TS node end"})
end

--  ╭─────────────────╮
--  │ Dot repeatable  │
--  ╰─────────────────╯

local builtin_targets = require("hop.jump_target")
local last_chars = nil

---@param chars string
local function repeatable_hop(chars)
    assert(chars ~= nil)
    last_chars = chars
    hop.hint_with(
        builtin_targets.jump_targets_for_current_line(
            builtin_targets.regex_by_case_searching(
                chars,
                true,
                {direction = hdir.AFTER_CURSOR, current_line_only = true}
            )
        ),
        hop.opts
    )

    fn["repeat#set"](":lua require'plugs.hop'.repeats()\r")
end

---Repeat last hop command
M.repeats = function()
    if last_chars == nil then
        return
    end
    repeatable_hop(last_chars)
end

---Rewrite of hop.hint_char1
M.hint_char1 = function()
    local char
    while true do
        api.nvim_echo({{"hop 1 char:", "Search"}}, false, {})
        local code = fn.getchar()
        -- fixme: custom char range by needs
        if code >= 61 and code <= 0x7a then
            -- [a-z]
            char = string.char(code)
            break
        elseif code == 0x20 or code == 0x1b then
            -- press space, esc to cancel
            char = nil
            break
        end
    end
    if not char then
        return
    end

    repeatable_hop(char)
end

-- ====================================================================
local function init()
    M.setup()
    M.setup_treehopper()

    map("n", "<Leader><Leader>k", ":HopLineStartBC<CR>")
    map("n", "<Leader><Leader>j", ":HopLineStartAC<CR>")

    map("n", "<Leader><Leader>l", ":HopAnywhereCurrentLineAC<CR>", {desc = "Hop current line AC"})
    map("n", "<Leader><Leader>h", ":HopAnywhereCurrentLineBC<CR>", {desc = "Hop current line BC"})

    -- map("n", "<Leader><Leader>K", ":HopWordBC<CR>", {desc = "Hop any word BC"})
    -- map("n", "<Leader><Leader>J", ":HopWordAC<CR>", {desc = "Hop any word AC"})
    -- map("n", "<Leader><Leader>/", ":HopPattern<CR>", {desc = "Hop pattern"})
    -- map("n", "<C-S-:>", ":HopWord<CR>", {desc = "Hop any word"})

    -- map("n", "g[", ":HopVertical<CR>", {desc = "Hop vertical"})
    map("n", "<C-S-<>", ":HopLine<CR>", {desc = "Hop any line"})
    map("n", ";a", ":HopWordMW<CR>", {desc = "Hop any word"})

    -- map("n", "g(", "require'hop'.hint_patterns({}, '(')", {desc = "Hop left brace", luacmd = true})
    -- map("n", "g)", "require'hop'.hint_patterns({}, ')')", {desc = "Hop right brace", luacmd = true})
    -- map("n", "g{", "require'hop'.hint_patterns({}, '{')", {desc = "Hop left cbrace", luacmd = true})
    -- map("n", "g}", "require'hop'.hint_patterns({}, '}')", {desc = "Hop right cbrace", luacmd = true})

    map(
        "n",
        "g(",
        F.ithunk(
            hop.hint_patterns,
            {direction = hdir.BEFORE_CURSOR},
            "("
        ),
        {desc = "Hop prev brace"}
    )
    map(
        "n",
        "g)",
        F.ithunk(
            hop.hint_patterns,
            {direction = hdir.AFTER_CURSOR},
            ")"
        ),
        {desc = "Hop next brace"}
    )
    map(
        "n",
        "g{",
        F.ithunk(
            hop.hint_patterns,
            {direction = hdir.BEFORE_CURSOR},
            "{"
        ),
        {desc = "Hop prev cbrace"}
    )
    map(
        "n",
        "g}",
        F.ithunk(
            hop.hint_patterns,
            {direction = hdir.AFTER_CURSOR},
            "}"
        ),
        {desc = "Hop next cbrace"}
    )

    -- ========================== f-Mapping ==========================

    -- map("n", [[f]], [[<Cmd>lua require'plugs.hop'.hint_char1()<CR>]], {desc = "Hop"})

    -- Normal
    map(
        "n",
        "f",
        F.ithunk(hop.hint_char1, {
            direction = hdir.AFTER_CURSOR,
            current_line_only = true,
        })
    )
    map(
        "n",
        "F",
        F.ithunk(hop.hint_char1, {
            direction = hdir.BEFORE_CURSOR,
            current_line_only = true,
        })
    )

    -- Motions
    map(
        "o",
        "f",
        F.ithunk(hop.hint_char1, {
            direction = hdir.AFTER_CURSOR,
            current_line_only = true,
            inclusive_jump = true,
        })
    )
    map(
        "o",
        "F",
        F.ithunk(hop.hint_char1, {
            direction = hdir.BEFORE_CURSOR,
            current_line_only = true,
        })
    )

    -- Visual mode
    map(
        "x",
        "f",
        F.ithunk(hop.hint_char1, {
            direction = hdir.AFTER_CURSOR,
            current_line_only = true,
        })
    )
    map(
        "x",
        "F",
        F.ithunk(hop.hint_char1, {
            direction = hdir.BEFORE_CURSOR,
            current_line_only = true,
        })
    )

    -- ========================== t-Mapping ==========================

    -- Normal
    map(
        "n",
        "t",
        F.ithunk(hop.hint_char1, {
            direction = hdir.AFTER_CURSOR,
            current_line_only = true,
            hint_offset = -1,
        })
    )
    map(
        "n",
        "T",
        F.ithunk(hop.hint_char1, {
            direction = hdir.BEFORE_CURSOR,
            current_line_only = true,
            hint_offset = 1,
            inclusive_jump = false,
        })
    )

    -- Motions
    map(
        "o",
        "t",
        F.ithunk(hop.hint_char1, {
            direction = hdir.AFTER_CURSOR,
            current_line_only = true,
            hint_offset = -1,
            inclusive_jump = false,
        })
    )
    map(
        "o",
        "T",
        F.ithunk(hop.hint_char1, {
            direction = hdir.BEFORE_CURSOR,
            current_line_only = true,
            hint_offset = 1,
            inclusive_jump = false,
        })
    )

    -- Visual mode
    map(
        "x",
        "t",
        F.ithunk(hop.hint_char1, {
            direction = hdir.AFTER_CURSOR,
            current_line_only = true,
            hint_offset = -1,
            inclusive_jump = false,
        })
    )
    map(
        "x",
        "T",
        F.ithunk(hop.hint_char1, {
            direction = hdir.BEFORE_CURSOR,
            current_line_only = true,
            hint_offset = 1,
            inclusive_jump = false,
        })
    )
end

init()

return M
