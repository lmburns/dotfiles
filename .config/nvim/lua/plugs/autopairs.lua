local M = {}

local utils = require("common.utils")
local map = utils.map

local api = vim.api

local autopairs = require("nvim-autopairs")
local Rule = require("nvim-autopairs.rule")
local cond = require("nvim-autopairs.conds")
local ts_conds = require("nvim-autopairs.ts-conds")

local opt = {
    disable_filetype = {"TelescopePrompt", "toggleterm", "floaterm", "telescope"},
    disable_in_macro = false,
    disable_in_visualblock = false,
    ignored_next_char = ([[ [%w%%%'%[%"%.] ]]):gsub("%s+", ""),
    -- ignored_next_char = [==[[%w%%%'%[%"%.]]==], -- %.
    close_triple_quotes = true,
    enable_moveright = true, -- ?? what is this
    enable_afterquote = true, -- add bracket pairs after quote
    enable_check_bracket_line = true, --- check bracket in same line
    enable_bracket_in_quote = true, --
    map_cr = false,
    map_bs = true, -- map the <BS> key
    map_c_h = true, -- Map the <C-h> key to delete a pair
    map_c_w = true, -- map <c-w> to delete a pair if possible
    fast_wrap = {
        map = "<M-,>", -- (|foo -> (|foo)
        chars = {"{", "[", "(", '"', "'"},
        pattern = ([[ [%'%"%)%>%]%)%}%,] ]]):gsub("%s+", ""),
        offset = -1, -- Offset from pattern match
        end_key = "$",
        keys = "qwertyuiopzxcvbnmasdfghjkl",
        check_comma = true,
        highlight = "Search",
        highlight_grey = "Comment"
    },
    check_ts = true,
    ts_config = {
        lua = {"string", "source"}
        -- javascript = {"string", "template_string"}
    }
}

function M.setup()
    autopairs.setup(opt)
end

local function basic(...)
    local move_func = opt.enable_moveright and cond.move_right or cond.none
    local rule = Rule(...):with_move(move_func()):with_pair(cond.not_add_quote_inside_quote())

    if #opt.ignored_next_char > 1 then
        rule:with_pair(cond.not_after_regex(opt.ignored_next_char))
    end
    rule:use_undo(true)
    return rule
end

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
    autopairs.add_rules {
        -- Rule(" ", " "):with_pair(
        --     function(opts)
        --         local pair = opts.line:sub(opts.col - 1, opts.col)
        --         return vim.tbl_contains({"()", "{}", "[]"}, pair)
        --     end
        -- ):with_move(cond.none()):with_cr(cond.none()):with_del(
        --     function(opts)
        --         local col = api.nvim_win_get_cursor(0)[2]
        --         local context = opts.line:sub(col - 1, col + 2)
        --         return vim.tbl_contains({"(  )", "{  }", "[  ]"}, context)
        --     end
        -- ),
        -- Rule("", " )"):with_pair(cond.none()):with_move(
        --     function(opts)
        --         return opts.char == ")"
        --     end
        -- ):with_cr(cond.none()):with_del(cond.none()):use_key ")",
        -- Rule("", " }"):with_pair(cond.none()):with_move(
        --     function(opts)
        --         return opts.char == "}"
        --     end
        -- ):with_cr(cond.none()):with_del(cond.none()):use_key "}",
        -- Rule("", " ]"):with_pair(cond.none()):with_move(
        --     function(opts)
        --         return opts.char == "]"
        --     end
        -- ):with_cr(cond.none()):with_del(cond.none()):use_key "]"

        -- Rule("", " >"):with_pair(cond.none()):with_move(
        --     function(opts)
        --       return opts.char == ">"
        --     end
        -- ):with_cr(cond.none()):with_del(cond.none()):use_key(">"),

        Rule(" ", " "):with_pair(
            function(opts)
                local pair = opts.line:sub(opts.col - 1, opts.col)
                return vim.tbl_contains({"()", "{}", "[]"}, pair)
            end
        ):with_move(cond.none()):with_cr(cond.none()):with_del(
            function(opts)
                local col = api.nvim_win_get_cursor(0)[2]
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
        ):with_cr(cond.none()):with_del(cond.none()):use_key("]")
    }

    -- autopairs.add_rule(
    --     Rule("%(.*%)%s*%=>$", " {  }", {"typescript", "typescriptreact", "javascript"}):use_regex(true):set_end_pair_length(
    --         2
    --     )
    -- )

    autopairs.add_rule(Rule("$", "$", "tex"))

    autopairs.add_rules(
        {
            -- Allow matching curly braces in strings
            Rule(
                "{",
                "}",
                {
                    "rust",
                    "javascript",
                    "typescript",
                    "javascriptreact",
                    "typescriptreact",
                    "php",
                    "python"
                }
            ):with_pair(ts_conds.is_ts_node({"string"})),
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
            Rule("(", ")", {"rust"})
            -- Allow matching closure pipes in rust
            -- Rule("|", "|", {"rust"}),
        }
    )

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

    -- Add <> pair
    -- autopairs.add_rule(
    --     Rule("<", ">"):with_pair(cond.not_before_regex(" ", 1)):with_pair(cond.not_after_regex(opt.ignored_next_char)):with_pair(
    --         cond.not_before_regex("<")
    --     )
    -- )

    autopairs.add_rule(Rule("<", ">"):with_pair(cond.not_before_regex(" ", 1)):with_pair(cond.not_before_regex("<")))

    -- autopairs.add_rule(
    --     Rule("<", ">", "rust"):with_pair(cond.before_regex("%a+")):with_pair(cond.not_after_regex("%a")):with_move(
    --         ts_conds.is_ts_node {"type_arguments", "type_parameters", "string"}
    --     )
    -- )

    -- Alternative to the above
    -- autopairs.add_rule(
    --     Rule("<", ">"):with_move(
    --         function(opts)
    --             if opts.char == ">" then
    --                 return true
    --             end
    --             return false
    --         end
    --     )
    -- )

    -- autopairs.add_rule(
    --     Rule("", ">"):use_key(">"):with_pair(cond.none()):with_move(
    --         function(opts)
    --             return opts.char == ">"
    --         end
    --     )
    -- )
    --
    -- autopairs.add_rule(
    --     Rule("<", "<del>"):with_pair(
    --         function(opts)
    --             local prev_char = nil
    --             if opts.col > 1 then
    --                 local pos = opts.col - 1
    --                 prev_char = opts.line:sub(pos, pos)
    --             end
    --             return prev_char ~= nil and prev_char == "<" and opts.next_char == ">"
    --         end
    --     )
    -- )

    -- autopairs.add_rules(
    --     {
    --         -- Auto add space on =
    --         Rule("=", ""):with_pair(cond.not_inside_quote()):with_pair(
    --             function(opts)
    --                 local excluded = {"rust", "sh", "bash", "zsh"}
    --                 if vim.tbl_contains(excluded, vim.o.filetype) then
    --                     return false
    --                 end
    --
    --                 local last_char = opts.line:sub(opts.col - 1, opts.col - 1)
    --
    --                 if last_char:match("[%w%=%s]") then
    --                     return true
    --                 end
    --                 return false
    --             end
    --         ):replace_endpair(
    --             function(opts)
    --                 local prev_2char = opts.line:sub(opts.col - 2, opts.col - 1)
    --                 local next_char = opts.line:sub(opts.col, opts.col)
    --                 next_char = next_char == " " and "" or " "
    --                 if prev_2char:match("%w$") then
    --                     return "<bs> =" .. next_char
    --                 end
    --                 if prev_2char:match("%=$") then
    --                     return next_char
    --                 end
    --                 if prev_2char:match("=") then
    --                     return "<bs><bs>=" .. next_char
    --                 end
    --                 return ""
    --             end
    --         ):set_end_pair_length(0):with_move(cond.none()):with_del(cond.none())
    --     }
    -- )

    -- Example: tab = b1234s => B1234S124S
    -- autopairs.add_rules(
    --     {
    --         Rule("b%d%d%d%d%w$", "", "vim"):use_regex(true, "<tab>"):replace_endpair(
    --             function(opts)
    --                 return opts.prev_char:sub(#opts.prev_char - 4, #opts.prev_char) .. "<esc>viwU"
    --             end
    --         )
    --     }
    -- )

    -- local endwise = require("nvim-autopairs.ts-rule").endwise
    -- -- TODO: Crystal
    -- autopairs.add_rules(
    --     {
    --         -- 'then$' is a lua regex
    --         -- 'end' is a match pair
    --         -- 'lua' is a filetype
    --         -- 'if_statement' is a treesitter name. set it = nil to skip check with treesitter
    --         endwise("then$", "end", "teal", "if_statement")
    --     }
    -- )
end

local function init()
    M.setup()
    M.rules()
end

init()

return M
