local M = {}

local utils = require("common.utils")
local augroup = utils.augroup
local wk = require("which-key")

local api = vim.api

local Search = require("todo-comments.search")

function M.setup()
    require("todo-comments").setup(
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

-- FIX: Why is this not inserting into table?
---Get the number of `TODO` comments in the current buffer
---@param cwd string?
---@return table
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

    -- vim.defer_fn(
    --     function()
    --         vim.cmd("au! Todo BufWinEnter")

    --         -- TODO: Figure this out
    --         augroup(
    --             {"Todo", false},
    --             {
    --                 event = "BufWinEnter",
    --                 pattern = "*",
    --                 command = function()
    --                     local bufnr = api.nvim_get_current_buf()
    --                     local bufname = api.nvim_buf_get_name(bufnr)
    --                     if
    --                         not bufname:match("%[Command Line%]") or not bufname:match("%[Wilder Float %d%]") or
    --                             bufname ~= "" or
    --                             vim.bo[bufnr].bt ~= "nofile"
    --                      then
    --                         vim.notify(bufname)
    --                         require("todo-comments.highlight").attach()
    --                     end
    --                 end
    --             }
    --         )
    --     end,
    --     1000
    -- )
end

init()

return M
