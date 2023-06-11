---@module 'plugs.indent_blankline'
local M = {}

local indent = Rc.F.npcall(require, "indent_blankline")
if not indent then
    return
end

function M.setup()
    -- ⎸ ┃ ‖ ▏ ║ ⫼ ⫿ ▮ ▯   ǀ ǁ
    -- ┆ ┇
    -- ╎ ╏ ¦
    -- ┊ ┋ ┊
    -- ┫ ⸡ ⸠ ╋ ┼ ⟊
    -- ⦚ ⸽ ╠ ╬
    -- Ͱ ͱ ͳ
    -- ꜋ ꜊ ꜉
    -- ╍ ┉ ╍ ╌ ┅ ┄
    -- ― ⎻ ⎺ ▔ ▁
    -- char_list = {"", "┊", "┆", "¦", "|", "¦", "┆", "┊", ""},

    indent.setup({
        -- debug = false,
        -- max_indent_increase = 20,
        disable_warning_message = true,
        disable_with_nolist = true,
        strict_tabs = false,
        indent_level = 20,
        viewport_buffer = 20,
        use_treesitter = false,
        -- use_treesitter_scope = true,
        show_foldtext = false,
        show_first_indent_level = false,
        show_trailing_blankline_indent = false,
        show_current_context = true,
        show_current_context_start = false, -- underlines the start
        show_current_context_start_on_current_line = true,
        show_end_of_line = false,
        char_priority = 1,
        context_start_priority = 1000,
        char = "|",
        char_list = {"|", "¦", "┇", "┋"},
        -- char_blankline = "╋",
        -- char_list_blankline = {"―", "╍", "┅", "┅"},
        -- char_highlight_list = {"┃"},
        -- space_char_highlight_list = {"┃"},
        -- space_char_blankline = {"┃"},
        -- space_char_blankline_highlight_list = {"┃"},
        context_char = "┃",
        -- context_char_blankline = "┃",
        -- context_char_list = {"┃"},
        -- context_char_list_blankline = {"┃"},
        -- context_pattern_highlight = {"┃"},
        context_highlight_list = {"ErrorMsg", "@constructor"},
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
            "jsx_self_closing_element",
            "list_literal",
            "selector",
        },
        bufname_exclude = {"option-window", [[__coc_refactor__[0-9]\{1,2}]], "Bufferize:.*"},
        buftype_exclude = {"nowrite", "nofile", "terminal", "quickfix", "prompt"},
        filetype_exclude = Rc.blacklist.ft:merge({"json", "jsonc", "make", "cmake"}),
    })
end

local function init()
    M.setup()
end

init()

return M
