local M = {}

local D = require("dev")
local hop = D.npcall(require, "hop")
if not hop then
    return
end

local utils = require("common.utils")
local map = utils.map

local hint_direction = require("hop.hint").HintDirection

local cmd = vim.cmd

-- =============================== Hop ================================
function M.setup()
    -- "etovxqpdygfblzhckisuran"
    -- "asdfjklhmnwertzxcvbuio"
    hop.setup({keys = "abcdefghijklmnopqrstuvwxyz;',."})
end

---Setup nvim-treehopper
M.setup_treehopper = function()
    cmd.packadd("nvim-treehopper")
    local tsht = D.npcall(require, "tsht")
    if not tsht then
        return
    end

    tsht.config.hint_keys = {"h", "j", "f", "d", "n", "v", "s", "l", "a"}

    map("x", ",", [[:<C-u>lua require('tsht').nodes()<CR>]], {desc = "Treesitter node select"})
    map("o", ",", D.ithunk(tsht.nodes), {desc = "Treesitter node select"})
    map("n", "vx", D.ithunk(tsht.nodes), {desc = "Treesitter node select"})
    map("n", "<C-S-:>", D.ithunk(tsht.move, {side = "start"}), {desc = "TS node start"})
    map("n", "[n", D.ithunk(tsht.move, {side = "start"}), {desc = "TS node start"})
    map("n", "]n", D.ithunk(tsht.move, {side = "end"}), {desc = "TS node end"})
end

local function init()
    M.setup()
    M.setup_treehopper()

    -- map("n", "<Leader><Leader>k", ":HopLineBC<CR>")
    -- map("n", "<Leader><Leader>j", ":HopLineAC<CR>")
    map("n", "<Leader><Leader>k", ":HopLineStartBC<CR>")
    map("n", "<Leader><Leader>j", ":HopLineStartAC<CR>")

    map("n", "<Leader><Leader>l", ":HopAnywhereCurrentLineAC<CR>", {desc = "Hop current line AC"})
    map("n", "<Leader><Leader>h", ":HopAnywhereCurrentLineBC<CR>", {desc = "Hop current line BC"})
    map("n", "<Leader><Leader>K", ":HopWordBC<CR>", {desc = "Hop any word BC"})
    map("n", "<Leader><Leader>J", ":HopWordAC<CR>", {desc = "Hop any word AC"})
    map("n", "<Leader><Leader>/", ":HopPattern<CR>", {desc = "Hop pattern"})
    -- map("n", "<C-S-:>", ":HopWord<CR>", {desc = "Hop any word"})
    map("n", "<C-S-<>", ":HopLine<CR>", {desc = "Hop any line"})

    map("n", "g(", "require'hop'.hint_patterns({}, '(')", {desc = "Previous brace", luacmd = true})
    map("n", "g)", "require'hop'.hint_patterns({}, ')')", {desc = "Next brace", luacmd = true})

    -- ========================== f-Mapping ==========================

    -- Normal
    map(
        "n",
        "f",
        function()
            hop.hint_char1({direction = hint_direction.AFTER_CURSOR, current_line_only = true})
        end
    )

    -- Normal
    map(
        "n",
        "F",
        function()
            hop.hint_char1({direction = hint_direction.BEFORE_CURSOR, current_line_only = true})
        end
    )

    -- Motions
    map(
        "o",
        "f",
        function()
            hop.hint_char1(
                {
                    direction = hint_direction.AFTER_CURSOR,
                    current_line_only = true,
                    inclusive_jump = true
                }
            )
        end
    )

    -- Motions
    map(
        "o",
        "F",
        function()
            hop.hint_char1(
                {
                    direction = hint_direction.BEFORE_CURSOR,
                    current_line_only = true
                    -- inclusive_jump = true
                }
            )
        end
    )

    -- Visual mode
    map(
        "x",
        "f",
        function()
            hop.hint_char1({direction = hint_direction.AFTER_CURSOR, current_line_only = true})
        end
    )

    -- Visual mode
    map(
        "x",
        "F",
        function()
            hop.hint_char1({direction = hint_direction.BEFORE_CURSOR, current_line_only = true})
        end
    )

    -- ========================== t-Mapping ==========================

    -- Normal
    map(
        "n",
        "t",
        function()
            hop.hint_char1(
                {
                    direction = hint_direction.AFTER_CURSOR,
                    current_line_only = true,
                    hint_offset = -1
                }
            )
        end
    )

    -- Normal
    map(
        "n",
        "T",
        function()
            hop.hint_char1(
                {
                    direction = hint_direction.BEFORE_CURSOR,
                    current_line_only = true,
                    hint_offset = 1,
                    inclusive_jump = false
                }
            )
        end
    )

    -- Motions
    map(
        "o",
        "t",
        function()
            hop.hint_char1(
                {
                    direction = hint_direction.AFTER_CURSOR,
                    current_line_only = true,
                    hint_offset = -1,
                    inclusive_jump = false
                }
            )
        end
    )

    -- Motions
    map(
        "o",
        "T",
        function()
            hop.hint_char1(
                {
                    direction = hint_direction.BEFORE_CURSOR,
                    current_line_only = true,
                    hint_offset = 1,
                    inclusive_jump = false
                }
            )
        end
    )

    -- Visual mode
    map(
        "x",
        "t",
        function()
            hop.hint_char1(
                {
                    direction = hint_direction.AFTER_CURSOR,
                    current_line_only = true,
                    hint_offset = -1,
                    inclusive_jump = false
                }
            )
        end
    )

    -- Visual mode
    map(
        "x",
        "T",
        function()
            hop.hint_char1(
                {
                    direction = hint_direction.BEFORE_CURSOR,
                    current_line_only = true,
                    hint_offset = 1,
                    inclusive_jump = false
                }
            )
        end
    )
end

init()

return M
