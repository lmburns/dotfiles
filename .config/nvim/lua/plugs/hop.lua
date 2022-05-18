local M = {}

local kutils = require("common.kutils")
local utils = require("common.utils")
local map = utils.map

-- =============================== Hop ================================
function M.setup()
    -- "etovxqpdygfblzhckisuran"
    require("hop").setup({keys = "asdfjklhmnwertzxcvbuio"})
end

local function init()
    M.setup()

    -- map("n", "<Leader><Leader>k", ":HopLineBC<CR>")
    -- map("n", "<Leader><Leader>j", ":HopLineAC<CR>")
    map("n", "<Leader><Leader>k", ":HopLineStartBC<CR>")
    map("n", "<Leader><Leader>j", ":HopLineStartAC<CR>")

    map("n", "<Leader><Leader>l", ":HopAnywhereCurrentLineAC<CR>", {desc = "Hop current line AC"})
    map("n", "<Leader><Leader>h", ":HopAnywhereCurrentLineBC<CR>", {desc = "Hop current line BC"})
    map("n", "<Leader><Leader>K", ":HopWordBC<CR>", {desc = "Hop any word BC"})
    map("n", "<Leader><Leader>J", ":HopWordAC<CR>", {desc = "Hop any word AC"})
    map("n", "<Leader><Leader>/", ":HopPattern<CR>", {desc = "Hop pattern"})
    map("n", "<C-S-:>", ":HopWord<CR>", {desc = "Hop any word"})
    map("n", "<C-S-<>", ":HopLine<CR>", {desc = "Hop any line"})

    -- ========================== f-Mapping ==========================

    -- Normal
    map(
        "n",
        "f",
        function()
            require("hop").hint_char1(
                {
                    direction = require("hop.hint").HintDirection.AFTER_CURSOR,
                    current_line_only = true
                }
            )
        end
    )

    -- Normal
    map(
        "n",
        "F",
        function()
            require("hop").hint_char1(
                {
                    direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
                    current_line_only = true
                }
            )
        end
    )

    -- Motions
    map(
        "o",
        "f",
        function()
            require("hop").hint_char1(
                {
                    direction = require("hop.hint").HintDirection.AFTER_CURSOR,
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
            require("hop").hint_char1(
                {
                    direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
                    current_line_only = true,
                    inclusive_jump = true
                }
            )
        end
    )

    -- Visual mode
    map(
        "x",
        "f",
        function()
            require("hop").hint_char1(
                {
                    direction = require("hop.hint").HintDirection.AFTER_CURSOR,
                    current_line_only = true,
                    inclusive_jump = true
                }
            )
        end
    )

    -- Visual mode
    map(
        "x",
        "F",
        function()
            require("hop").hint_char1(
                {
                    direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
                    current_line_only = true,
                    inclusive_jump = true
                }
            )
        end
    )

    -- ========================== t-Mapping ==========================

    -- Normal
    map(
        "n",
        "t",
        function()
            require("hop").hint_char1(
                {
                    direction = require("hop.hint").HintDirection.AFTER_CURSOR,
                    current_line_only = true,
                    inclusive_jump = false
                }
            )
            -- api.nvim_input("h")
            api.nvim_feedkeys(kutils.termcodes["h"], "n", false)
        end
    )

    -- Normal
    map(
        "n",
        "T",
        function()
            require("hop").hint_char1(
                {
                    direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
                    current_line_only = true,
                    inclusive_jump = false
                }
            )
            api.nvim_feedkeys(kutils.termcodes["l"], "n", false)
        end
    )

    -- Motions
    map(
        "o",
        "t",
        function()
            require("hop").hint_char1(
                {
                    direction = require("hop.hint").HintDirection.AFTER_CURSOR,
                    current_line_only = true,
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
            require("hop").hint_char1(
                {
                    direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
                    current_line_only = true,
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
            require("hop").hint_char1(
                {
                    direction = require("hop.hint").HintDirection.AFTER_CURSOR,
                    current_line_only = true,
                    inclusive_jump = false
                }
            )
            api.nvim_feedkeys(kutils.termcodes["h"], "v", false)
        end
    )

    -- Visual mode
    map(
        "x",
        "T",
        function()
            require("hop").hint_char1(
                {
                    direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
                    current_line_only = true,
                    inclusive_jump = false
                }
            )
            api.nvim_feedkeys(kutils.termcodes["l"], "v", false)
        end
    )
end

init()

return M
