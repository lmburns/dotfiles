local M = {}

local C = require("common.color")

-- #A06469 #d3869b #4C96A8

function M.setup()
    require("indent_blankline").setup(
        {
            debug = true,
            viewport_buffer = 20,
            use_treesitter = true,
            indent_blankline_show_foldtext = false,
            show_first_indent_level = false,
            show_trailing_blankline_indent = false,
            show_current_context = true,
            show_current_context_start = false, -- underlines the start
            context_higlight_list = {"Error", "Warning"},
            show_end_of_line = false,
            char = "|",
            char_list = {"|", "¦", "┆", "┊"},
            -- char_list = {"", "┊", "┆", "¦", "|", "¦", "┆", "┊", ""},
            context_char = "▏",
            context_patterns = {
                "^do",
                "^for",
                "^if",
                "^object",
                "^switch",
                "^table",
                "^while",
                "arguments",
                "block",
                "catch_clause",
                "class",
                "else_clause",
                "function",
                "if_statement",
                "import_statement",
                "method",
                "operation_type",
                "return",
                "try_statement",
                "jsx_element",
                "jsx_self_closing_element"
            },
            -- space_char_blankline = " ",
            -- char_highlight_list = {
            --     "IndentBlanklineIndent1",
            --     "IndentBlanklineIndent2",
            --     "IndentBlanklineIndent3",
            --     "IndentBlanklineIndent4",
            --     "IndentBlanklineIndent5",
            --     "IndentBlanklineIndent6"
            -- },
            buftype_exclude = {"nofile", "terminal"},
            filetype_exclude = _t(BLACKLIST_FT):merge({"json", "jsonc"})
        }
    )
end

local function init()
    C.plugin("indent_blankline", {IndentBlanklineContextChar = {fg = "#DC3958", gui = "nocombine"}})
    M.setup()
end

init()

return M
