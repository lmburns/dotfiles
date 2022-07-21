local M = {}

local D = require("dev")
local todo = D.npcall(require, "todo-comments")
if not todo then
    return
end

local wk = require("which-key")
local Search = require("todo-comments.search")

local fn = vim.fn

function M.setup()
    local hl = require("todo-comments.highlight")
    local highlight_win = hl.highlight_win
    hl.highlight_win = function(win, force)
        pcall(highlight_win, win, force)
    end

    todo.setup(
        {
            signs = true, -- show icons in the signs column
            sign_priority = 8, -- sign priority
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
                -- ["???"] = {icon = "", color = "#38A89D"},
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

                -- Matches:
                --      TODO: hi
                --      TODO  : hi
                --      TODO (xx): hi
                --      TODO(lmburns):
                -- Special vim regex: %[] means optional group
                -- pattern = [[.*<(KEYWORDS)(\s*\(.*\))?\s*:]], -- pattern or table of patterns (vim regex)
                pattern = [[.*<(KEYWORDS)%[(\s*\(.*\))]\s*:]], -- pattern or table of patterns (vim regex)
                comments_only = true, -- uses treesitter to match keywords in comments only
                max_line_len = 400, -- ignore lines longer than this
                exclude = BLACKLIST_FT -- list of file types to exclude highlighting
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
                pattern = [[\b(KEYWORDS)(\s*\(.*\))?\s*:]] -- ripgrep regex
                -- pattern = [[\b(KEYWORDS)\b]], -- match without the extra colon. You'll likely get false positives
            }
        }
    )
end

-- FIX: Why is this not inserting into table?
---Get the number of `TODO` comments in the current buffer
---@param cwd string?
---@return integer
---@diagnostic disable:unused-local
function M.get_todo_count(cwd)
    local result = {}
    Search.search(
        function(r)
            for _, item in pairs(r) do
                table.insert(result, item.message)
            end
            -- table.insert(count, r)
        end,
        {cwd = fn.expand("%"), open = false}
    )

    return #result
end

-- p(R("plugs.todo-comments").get_todo_count())

local function init()
    M.setup()

    require("telescope").load_extension("todo-comments")

    wk.register(
        {
            ["<LocalLeader>T"] = {":TodoTelescope<CR>", "Todo telescope (workspace)"},
            [";t"] = {":TodoQuickFix<CR>", "Todo quickfix (workspace)"},
            [";T"] = {":TodoTrouble<CR>", "Todo trouble (workspace)"},
            ["<LocalLeader>t"] = {
                function()
                    Search.setqflist({cwd = fn.expand("%")})
                end,
                "Todo quickfix (current file)"
            }
        },
        {mode = "n", silent = true}
    )
end

init()

return M
