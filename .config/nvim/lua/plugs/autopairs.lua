---@module 'plugs.autopairs'
local M = {}

local F = Rc.F
local autopairs = F.npcall(require, "nvim-autopairs")
if not autopairs then
    return
end

local map = Rc.api.map

local Rule = require("nvim-autopairs.rule")
local cond = require("nvim-autopairs.conds")
local ts_conds = require("nvim-autopairs.ts-conds")

local opt

---@diagnostic disable-next-line:unused-function
local function basic(...)
    local move_func = opt.enable_moveright and cond.move_right or cond.none
    local rule = Rule(...):with_move(move_func()):with_pair(cond.not_add_quote_inside_quote())

    if #opt.ignored_next_char > 1 then
        rule:with_pair(cond.not_after_regex(opt.ignored_next_char))
    end
    rule:use_undo(true)
    return rule
end

---@diagnostic disable-next-line:unused-function, unused-local
local function bracket(...)
    local rule = basic(...)
    if opt.enable_check_bracket_line == true then
        rule:with_pair(cond.is_bracket_line()):with_move(cond.is_bracket_line_move())
    end
    if opt.enable_bracket_in_quote then
        -- still add bracket if text is quote "|" and next_char have "
        rule:with_pair(cond.is_bracket_in_quote(), 1)
    end
    return rule
end

function M.rules()
    -- add margin after cursor on space
    -- Before: (|)
    -- After: ( | )
    autopairs.add_rules({
        Rule(" ", " "):with_pair(
            function(opts)
                local pair = opts.line:sub(opts.col - 1, opts.col)
                return vim.tbl_contains({"()", "{}", "[]"}, pair)
            end
        ):with_move(cond.none()):with_cr(cond.none()):with_del(
            function(opts)
                local col = Rc.api.get_cursor_col()
                local context = opts.line:sub(col - 1, col + 2)
                return vim.tbl_contains({"(  )", "{  }", "[  ]"}, context)
            end
        ),
        Rule("", " )"):with_pair(cond.none()):with_move(
            function(opts)
                return opts.char == ")"
            end
        ):with_cr(cond.none()):with_del(cond.none()):use_key(")"),
        Rule("", " }"):with_pair(cond.none()):with_move(
            function(opts)
                return opts.char == "}"
            end
        ):with_cr(cond.none()):with_del(cond.none()):use_key("}"),
        Rule("", " ]"):with_pair(cond.none()):with_move(
            function(opts)
                return opts.char == "]"
            end
        ):with_cr(cond.none()):with_del(cond.none()):use_key("]"),
    })

    autopairs.add_rules({
        -- Allow matching curly braces in strings
        Rule("{", "}", {
            "rust",
            "javascript",
            "typescript",
            "javascriptreact",
            "typescriptreact",
            "php",
            "python",
        }):with_pair(ts_conds.is_ts_node({"string"})),
        -- Allows matching '<' '>' in Rust or C++ or Typescript
        -- bracket("<", ">", { "rust", "cpp", "typescript" }),

        -- Allows matching '' in strings
        Rule("'", "'", {"lua"}):with_pair(ts_conds.is_ts_node({"string"})),
        -- Allows matching () in strings
        Rule("(", ")", {"lua"}):with_pair(ts_conds.is_ts_node({"string"})),
        -- Allow matching bold in markdown
        Rule("**", "**", {"markdown", "vimwiki"}),
        -- Allow matching r#""# in rust
        Rule('r#"', '"#', {"rust"}),
        -- Allow () when a period proceeds in rust and others
        Rule("(", ")", {"rust"}),
        -- Allow matching closure pipes in rust
        -- Rule("|", "|", {"rust"}),
        -- Allow matching $$ in latex (maybe add markdown)
        Rule("$$", "$$", "tex"),
    })

    -- Add <> pair
    -- autopairs.add_rule(
    --     Rule("<", ">"):with_pair(cond.not_before_regex(" ", 1)):with_pair(
    --         cond.not_before_regex("<")
    --     ):with_pair(
    --         function(_)
    --             local excluded = {"markdown", "vimwiki"}
    --             if vim.tbl_contains(excluded, vim.o.ft) then
    --                 return false
    --             end
    --
    --             return true
    --         end
    --     )
    -- )

    -- Custom <C-h> binding
    autopairs.add_rule(
        Rule("(", ")"):use_key("<C-h>"):replace_endpair(
            function()
                return "<C-g>u<BS><Del>"
            end,
            true
        )
    )

    -- Rule("(", "")
    --   :use_key("<C-h>")
    --   :with_pair(cond.after_text(")")) -- check that text after cursor is `)`
    --   :replace_endpair(function() return "<BS><Del>" end)

    -- Match => {} in typescript
    -- autopairs.add_rule(
    --     Rule("%(.*%)%s*%=>$", " {  }", {"typescript", "typescriptreact", "javascript"}):use_regex(
    --         true
    --     ):set_end_pair_length(2)
    -- )

    -- Add a semicolon to the bracket pair
    -- autopairs.add_rule(
    --     Rule("{", "};"):with_pair(
    --         function(opts)
    --             local struct = string.match(opts.line, "struct%s*%S*%s*$")
    --             local class = string.match(opts.line, "class%s*%S*%s*$")
    --             return struct ~= nil or class ~= nil
    --         end
    --     )
    -- )

    -- autopairs.add_rule(
    --     Rule("<", ">", "rust"):with_pair(cond.before_regex("%a+")):with_pair(cond.not_after_regex("%a")):with_move(
    --         ts_conds.is_ts_node {"type_arguments", "type_parameters", "string"}
    --     )
    -- )

    -- autopairs.add_rule(
    --     Rule("then", "end", {"ruby", "lua"}):end_wise(
    --         function(opts)
    --             -- Add any context checks here, e.g. line starts with "if"
    --             return string.match(opts.line, "^%s*if") ~= nil
    --         end
    --     )
    -- )
end

function M.setup()
    autopairs.setup(opt)
end

local function init()
    opt = {
        disable_filetype = {"TelescopePrompt", "toggleterm", "floaterm", "telescope"},
        disable_in_macro = false,
        disable_in_visualblock = false,
        disable_in_replace_mode = true,
        ignored_next_char = [=[[%w%%%'%[%"%.%`%$]]=],
        close_triple_quotes = true,
        enable_moveright = true,          -- ?? what is this
        enable_afterquote = true,         -- add bracket pairs after quote
        enable_check_bracket_line = true, --- check bracket in same line
        enable_bracket_in_quote = true,   --
        enable_abbr = true,               --
        break_undo = true,                -- start new undo sequence
        map_cr = false,
        map_bs = true,                    -- map the <BS> key
        map_c_h = false,                  -- hello(|) -> deletes pair
        map_c_w = false,                  -- hello()| -> deletes pair
        fast_wrap = {
            -- map = "<Nop>", -- (|foo -> (|foo), added below
            map = "<M-e>",
            chars = {"{", "[", "(", '"', "'", "`", "<"},
            pattern = [=[[%'%"%`%>%]%)%}%,]]=],
            end_key = "$",
            keys = "qwertyuiopzxcvbnmasdfghjkl",
            check_comma = true,
            highlight = "Search",
            highlight_grey = "Comment",
        },
        check_ts = true,
        ts_config = {
            lua = {"string", "source"},
            -- javascript = {"string", "template_string"}
        },
        html_break_line_filetype = {
            "html",
            "javascript",
            "javascriptreact",
            "svelte",
            "template",
            "typescriptreact",
            "vue",
        },
    }
    M.setup()
    M.rules()

    map("i", "<C-A-;>", "<M-e>", {remap = true, desc = "Autopairs: wrap"})
    -- map("i", "<M-,>", "<C-w>", {noremap = false, desc = "Delete previous word"})
end

init()

return M
