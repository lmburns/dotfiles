local M = {}

local utils = require("common.utils")
local map = utils.map

local autopairs = utils.prequire("nvim-autopairs")
local Rule = require("nvim-autopairs.rule")
local cond = require("nvim-autopairs.conds")
local ts_conds = require("nvim-autopairs.ts-conds")

local opt = {
    disable_filetype = {"TelescopePrompt", "toggleterm", "floaterm", "telescope"},
    disable_in_macro = false,
    disable_in_visualblock = false,
    -- ignored_next_char = string.gsub([[ [%w%%%'%[%"%.] ]], "%s+", ""),
    ignored_next_char = [==[[%w%%%'%[%"%.]]==], -- %.
    enable_moveright = true, -- ?? what is this
    enable_afterquote = true, -- add bracket pairs after quote
    enable_check_bracket_line = true, --- check bracket in same line
    enable_bracket_in_quote = true, --
    map_cr = true,
    map_bs = true, -- map the <BS> key
    map_c_h = true, -- Map the <C-h> key to delete a pair
    map_c_w = true, -- map <c-w> to delete a pair if possible
    fast_wrap = {
        map = "<M-,>", -- (|foo -> (|foo)
        chars = {"{", "[", "(", '"', "'"},
        pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
        offset = -1, -- Offset from pattern match
        end_key = "$",
        keys = "qwertyuiopzxcvbnmasdfghjkl",
        check_comma = true,
        highlight = "Search",
        highlight_grey = "Comment"
    },
    check_ts = true,
    ts_config = {
        lua = {"string", "source"},
        javascript = {"string", "template_string"}
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
    -- <  > (  ) -- Spaces
    autopairs.add_rules {
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
        ):with_cr(cond.none()):with_del(cond.none()):use_key ")",
        Rule("", " }"):with_pair(cond.none()):with_move(
            function(opts)
                return opts.char == "}"
            end
        ):with_cr(cond.none()):with_del(cond.none()):use_key "}",
        Rule("", " ]"):with_pair(cond.none()):with_move(
            function(opts)
                return opts.char == "]"
            end
        ):with_cr(cond.none()):with_del(cond.none()):use_key "]"

        -- Rule("", " >"):with_pair(cond.none()):with_move(
        --     function(opts)
        --       return opts.char == ">"
        --     end
        -- ):with_cr(cond.none()):with_del(cond.none()):use_key(">"),
    }

    autopairs.add_rules {
        Rule("%(.*%)%s*%=>$", " {  }", {"typescript", "typescriptreact", "javascript"}):use_regex(true):set_end_pair_length(
            2
        )
    }

    autopairs.add_rule(Rule("$", "$", "tex"))

    -- Adds '<' '>' as pairs
    -- autopairs.add_rule(basic("<", ">", "-html"))

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

            --[[, {"rust", "cpp", "typescript"} ]]
            Rule("<", ">")
                :with_pair(cond.not_before_regex(" ", 1))
                :with_pair(cond.not_after_regex(opt.ignored_next_char))
                :with_pair(cond.not_before_regex("<")),
            -- Allows matching '' is strings
            Rule("'", "'", {"lua"}):with_pair(ts_conds.is_ts_node({"string"})),
            -- Allows matching () is strings
            Rule("(", ")", {"lua"}):with_pair(ts_conds.is_ts_node({"string"}))
        }
    )

    -- Allow () when a period proceeds in rust and others
    autopairs.add_rules(
        {
            Rule("(", ")", {"rust"})
        }
    )

    -- autopairs.add_rule(
    --     Rule("=", "", {"-sh", "-bash", "-zsh"}):with_pair(cond.not_inside_quote()):with_pair(
    --         function(opts)
    --             local last_char = opts.line:sub(opts.col - 1, opts.col - 1)
    --             if last_char:match("[%w%=%s]") then
    --                 return true
    --             end
    --             return false
    --         end
    --     ):replace_endpair(
    --         function(opts)
    --             local prev_2char = opts.line:sub(opts.col - 2, opts.col - 1)
    --             local next_char = opts.line:sub(opts.col, opts.col)
    --             next_char = next_char == " " and "" or " "
    --             if prev_2char:match("%w$") then
    --                 return "<bs> =" .. next_char
    --             end
    --             if prev_2char:match("%=$") then
    --                 return next_char
    --             end
    --             if prev_2char:match("=") then
    --                 return "<bs><bs>=" .. next_char
    --             end
    --             return ""
    --         end
    --     ):set_end_pair_length(0):with_move(cond.none()):with_del(cond.none()):with_pair(
    --         cond.not_filetypes({"sh", "bash", "zsh"})
    --     )
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

function M.ap_coc()
    if fn.pumvisible() ~= 0 then
        return vim.fn["coc#_select_confirm"]()
    else
        return autopairs.autopairs_cr()
    end
end

local function init()
    M.setup()
    M.rules()

    -- map("i", "<CR>", [[v:lua.lua require'plugs.autopairs'.ap_coc()]], {expr = true})
end

init()

return M
