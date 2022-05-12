local M = {}

local map = require("common.utils").map

function M.setup()
    require("todo-comments").setup(
        {
            signs = true,
            keywords = {
                -- #E46876
                FIX = {
                    icon = " ",
                    color = "#ea6962",
                    alt = {"FIXME", "BUG", "FIXIT", "FIX", "ISSUE"}
                },
                TODO = {icon = " ", color = "#d16d9e"},
                TEST = {icon = " ", color = "#819c3b"},
                HACK = {icon = " ", color = "#fe8019"},
                WARN = {icon = " ", color = "#EC5f67", alt = {"WARNING", "XXX"}},
                TIP = {icon = " ", color = "#9a9a9a", alt = {"HINT"}},
                FEATURE = {icon = " ", color = "#957FB8", alt = {"NEW"}},
                MAYBE = {icon = " ", color = "#FF5D62", alt = {"POSSIBLE", "TODO_MAYBE"}},
                DONE = {icon = " ", color = "#98BB6C", alt = {"FINISHED"}},
                CHANGED = {
                    icon = " ",
                    color = "#89b482",
                    alt = {"ALTERED", "ALTER", "MOD", "MODIFIED"}
                },
                PERF = {
                    icon = " ",
                    alt = {"#a7c777", "PERFORMANCE", "OPTIMIZE", "FUNCTION"}
                },
                NOTE = {
                    icon = " ",
                    color = "#62b3b2",
                    alt = {"INFO", "NOTES", "SUBSECTION"}
                },
                CHECK = {
                    icon = "",
                    color = "#e78a4e",
                    alt = {"EXPLAIN", "DISCOVER", "SECTION"}
                }
            },
            merge_keywords = true, -- when true, custom keywords will be merged with the defaults
            -- highlighting of the line containing the todo comment
            -- * before: highlights before the keyword (typically comment characters)
            -- * keyword: highlights of the keyword
            -- * after: highlights after the keyword (todo text)
            highlight = {
                before = "", -- "fg" or "bg" or empty
                keyword = "fg", -- "fg", "bg", "wide"
                after = "fg", -- "fg" or "bg" or empty
                -- before = "",
                -- keyword = "fg",
                -- after = "",

                -- before = "",
                -- keyword = "wide",
                -- after = "fg",

                pattern = [[.*<(KEYWORDS)\s*:]], -- pattern or table of patterns, used for highlightng (vim regex)
                comments_only = true, -- uses treesitter to match keywords in comments only
                max_line_len = 400, -- ignore lines longer than this
                exclude = {} -- list of file types to exclude highlighting
            },
            -- list of named colors where we try to extract the guifg from the
            -- list of hilight groups or use the hex color if hl not found as a fallback
            colors = {
                error = {"DiagnosticError", "ErrorMsg", "#EF1D55"},
                warning = {"DiagnosticWarning", "WarningMsg", "#FF9500"},
                info = {"DiagnosticInfo", "#4C96A8"},
                hint = {"DiagnosticHint", "#10B981"},
                default = {"Identifier", "#7E5053"}
            },
            search = {
                command = "rg",
                args = {
                    "--color=never",
                    "--no-heading",
                    "--with-filename",
                    "--line-number",
                    "--column"
                },
                -- regex that will be used to match keywords.
                -- don't replace the (KEYWORDS) placeholder
                pattern = [[\b(KEYWORDS):]] -- ripgrep regex
                -- pattern = [[\b(KEYWORDS)\b]], -- match without the extra colon. You'll likely get false positives
            }
        }
    )
end

local function init()
    M.setup()

    require("telescope").load_extension("todo-comments")
    map("n", "<LocalLeader>T", ":TodoTelescope<CR>", {silent = true})
    map("n", ";t", ":TodoQuickFix<CR>", {silent = true})
    map("n", ";T", ":TodoTrouble<CR>", {silent = true})
end

init()

return M
