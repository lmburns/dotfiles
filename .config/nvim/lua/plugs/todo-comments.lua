---@module 'plugs.todo-comments'
local M = {}

local F = Rc.F
local todo = F.npcall(require, "todo-comments")
if not todo then
    return
end

local wk = require("which-key")
local Search = require("todo-comments.search")
local I = Rc.icons

local fn = vim.fn

---Pad the icons for this plugin
---@param icon string
---@return string
local function pad(icon)
    -- 32 is a space
    if icon:sub(2, 2):byte() == 32 then
        return icon:sub(2, 2)
    end

    return ("%s "):format(icon)
end

function M.setup()
    -- #7DAEA3 #F79A32 #F06431 #C2A383
    -- #A25BC4 #FF5813 #A83232 #989719
    -- #98676A #A06469 #A3B95A #A0936A
    -- #FFA066 #FF5D62 #89B482 #D3869B
    -- #719190 #957FB8 #938AA9 #EA6962
    -- #E46876
    todo.setup({
        signs = true,      -- show icons in the signs column
        sign_priority = 8, -- sign priority
        keywords = {
            FIX = {
                icon = pad(I.misc.bug),
                color = "#EA6962",
                alt = {"FIXME", "BUG", "FIXIT", "FIX", "ISSUE"},
            },
            TODO = {
                icon = pad(I.ui.check_thick),
                color = "#d16d9e",
                alt = {"TODOS"},
            },
            TEST = {
                icon = pad(I.ui.check_thick),
                color = "#819c3b",
                alt = {"TESTING"},
            },
            DEBUG = {
                icon = pad(I.misc.code),
                color = "#F06431",
                alt = {"PRIORITY"},
            },
            HACK = {
                icon = pad(I.ui.fire),
                color = "#fe8019",
                alt = {},
            },
            WARN = {
                icon = pad(I.ui.warning),
                color = "#EC5f67",
                alt = {"WARNING", "XXX"},
            },
            TIP = {
                icon = pad(I.ui.tip),
                color = "#9a9a9a",
                alt = {"HINT", "TIPS"},
            },
            FEATURE = {
                icon = pad(I.box.plus),
                color = "#957FB8",
                alt = {"NEW", "FEAT"},
            },
            MAYBE = {
                icon = pad(I.shape.circle_o),
                color = "#FF5D62",
                alt = {"POSSIBLY", "POSSIBLE_TODO", "MAYBE_TODO"},
            },
            DONE = {
                icon = pad(I.ui.check_box),
                color = "#98BB6C",
                alt = {"FINISHED"},
            },
            FINISH = {
                icon = pad(I.ui.check_box),
                color = "#DC3958",
                alt = {"COMPLETE"},
            },
            CHANGED = {
                icon = pad(I.ui.arrow_swap),
                color = "#89b482",
                alt = {"CHANGE", "ALTERED", "ALTER", "MOD", "MODIFIED"},
            },
            PERF = {
                icon = pad(I.ui.clock),
                color = "#a7c777",
                alt = {"PERFORMANCE", "OPTIMIZE", "FUNCTION"},
            },
            NOTE = {
                icon = pad(I.ui.text_outline),
                color = "#62b3b2",
                alt = {"INFO", "NOTES", "SUBSECTION"},
            },
            CHECK = {
                icon = pad(I.ui.check_circle),
                color = "#e78a4e",
                alt = {"EXPLAIN", "DISCOVER", "SECTION", "REVISIT", "CHECKOUT"},
            },
        },
        gui_style = {
            fg = "NONE",       -- The gui style to use for the fg highlight group.
            bg = "NONE",       -- The gui style to use for the bg highlight group.
        },
        merge_keywords = true, -- when true, custom keywords will be merged with the defaults
        -- highlighting of the line containing the todo comment
        -- * before: highlights before the keyword (typically comment characters)
        -- * keyword: highlights of the keyword
        -- * after: highlights after the keyword (todo text)
        highlight = {
            multiline = true,                -- enable multine todo comments
            multiline_pattern = "^%s%s%s%s", -- lua pattern to match next ML from start of the matched keyword
            multiline_context = 10,          -- extra lines that will be re-evaluated when changing a line
            before = "",                     -- "fg" or "bg" or empty
            keyword = "fg",                  -- "fg", "bg", "wide"
            after = "fg",                    -- "fg" or "bg" or empty

            -- before = "",
            -- keyword = "wide",
            -- after = "fg",

            -- Matches:
            --      TODO: hi
            --      TODO  : hi
            --      TODO (xx): hi
            --      TODO(lmburns):
            --
            --        [[.*<(KEYWORDS)(\s*\(.*\))?\s*:]], -- pattern or table of patterns (vim regex)
            pattern = [[.*<(KEYWORDS)%[(\s*\(.*\))]\s*:]], -- pattern or table of patterns (vim regex)
            comments_only = true,                          -- uses treesitter to match keywords in comments only
            max_line_len = 400,                            -- ignore lines longer than this
            exclude = Rc.blacklist.ft:filter(function(i)
                return not _j({"markdown", "vimwiki", "gitconfig"}):contains(i)
            end), -- list of file types to exclude highlighting
        },
        -- list of named colors where we try to extract the guifg from the
        -- list of highlight groups or use the hex color if hl not found as a fallback
        colors = {
            error = {"DiagnosticError", "ErrorMsg", "#EF1D55"},
            warning = {"DiagnosticWarning", "WarningMsg", "#FF9500"},
            info = {"DiagnosticInfo", "#4C96A8"},
            hint = {"DiagnosticHint", "#10B981"},
            default = {"Identifier", "#7E5053"},
        },
        search = {
            command = "rg",
            args = {
                "--color=never",
                "--no-heading",
                "--with-filename",
                "--line-number",
                "--column",
            },
            -- regex that will be used to match keywords.
            -- don't replace the (KEYWORDS) placeholder
            pattern = [[\b(KEYWORDS)(\s*\(.*\))?\s*:]], -- ripgrep regex
        },
    })
end

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

    wk.register({
        ["]T"] = {"<Cmd>lua require('todo-comments').jump_next()<CR>", "Next todo comment"},
        ["[T"] = {"<Cmd>lua require('todo-comments').jump_prev()<CR>", "Prev todo comment"},
        ["]n"] = {"<Cmd>lua require('todo-comments').jump_next()<CR>", "Next todo comment"},
        ["[n"] = {"<Cmd>lua require('todo-comments').jump_prev()<CR>", "Prev todo comment"},
        -- ["],"] = {":lua require('todo-comments').jump_next()<CR>", "Next todo comment"},
        -- ["[,"] = {":lua require('todo-comments').jump_prev()<CR>", "Prev todo comment"},
        [";t"] = {"<Cmd>TodoQuickFix<CR>", "Todo quickfix (workspace)"},
        [";T"] = {"<Cmd>TodoTrouble<CR>", "Todo trouble (workspace)"},
        ["<LocalLeader>T"] = {"<Cmd>TodoTelescope<CR>", "Todo telescope (workspace)"},
        ["<LocalLeader>t"] = {
            function()
                Search.setqflist({cwd = fn.expand("%")})
            end,
            "Todo quickfix (current file)",
        },
    }, {mode = "n", silent = true})
end

init()

return M
