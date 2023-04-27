local M = {}

local D = require("dev")
local wk = require("which-key")

local utils = require("common.utils")
local mpi = require("common.api")
local map = mpi.map
local augroup = mpi.augroup

local cmd = vim.cmd
local fn = vim.fn
local g = vim.g
-- local api = vim.api

-- ╭──────────────────────────────────────────────────────────╮
-- │                        Sandwich                          │
-- ╰──────────────────────────────────────────────────────────╯
function M.sandwich()
    -- == Add ==
    -- ySi       = ask head and tail
    -- yS        = to end of line
    -- yss       = whole line
    -- ys{a,i}   = surround delimiter
    -- ygs       = (\n<line>\n)
    -- vSv       = `...`
    -- vS1       = [`...`]
    -- vSD       = [[...]]
    -- vS<C-S-)> = (\n...\n)
    -- vS<C-S-}> = {\n...\n}
    -- vSU       = {\n...\n}
    -- vSF       = insert mode here |(...)

    -- == Delete ==
    -- dss       = automatic deletion
    -- ds<CR>    = empty line above/below
    -- ds<Space> = surrounding space

    -- == Change ==
    -- css       = automatic change detection

    -- y{a,i}si  = yank head - tail
    -- yiss      = yank inside nearest delimiter

    -- --Old--                   ---Input---        ---Output---
    -- "hello"                   ysiwtkey<cr>       "<key>hello</key>"
    -- "hello"                   ysiwF              |("hello")
    -- "hello"                   ysiwfprint<cr>     print("hello")
    -- print("hello")            dsf                "hello"

    -- TODO: These
    -- "hello"                   ysWFprint<cr>     print( "hello" )
    -- "hello"                   ysW<C-f>print<cr> (print "hello")

    -- dsf
    g["sandwich#magicchar#f#patterns"] = {
        -- This: func(arg) => arg
        {
            header = [[\<\%(\.\|:\{1,2}\)\@<!\h\k*\%(\.\|:\{1,2}\)\@!]],
            bra = "(",
            ket = ")",
            footer = ""
        },
        -- This: macro!(arg) => arg
        {
            header = [[\<\h\k*!]],
            bra = "(",
            ket = ")",
            footer = ""
        },
        -- This: func.method.xx(arg) => arg
        {
            header = [[\<\%(\h\k*\.\)\+\h\k*]],
            bra = "(",
            ket = ")",
            footer = ""
        },
        -- This: func<T>(generic) => T(generic)
        {
            header = [[\<\h\k*]],
            bra = "<",
            ket = ">",
            footer = ""
        },
        -- This: Lua:method(arg) => arg
        {
            header = [[\<\%(\h\k*:\)\h\k*]],
            bra = "(",
            ket = ")",
            footer = ""
        },
        -- This: func::method(arg) => arg
        {
            header = [[\<\%(\h\k*::\)\+\h\k*]],
            bra = "(",
            ket = ")",
            footer = ""
        },
    }

    cmd.runtime("macros/sandwich/keymap/surround.vim")

    --  Available keys are listed below.
    --    * kind
    --      - query
    --      - auto
    --    * option
    --      - nesting
    --      - expand_range
    --      - regex
    --      - skip_regex
    --      - skip_regex_head
    --      - skip_regex_tail
    --      - quoteescape
    --      - expr
    --      - noremap
    --      - syntax
    --      - inner_syntax
    --      - match_syntax
    --      - skip_break
    --      - skip_expr

    cmd(
        [==[
      let g:sandwich#recipes = deepcopy(g:sandwich#default_recipes)

      let g:sandwich#recipes += [
      \   {
      \     'buns':         ['<', '>'],
      \     'expand_range': 0,
      \     'input':        ['>', 'a'],
      \   },
      \   {
      \     'buns': ['{ ', ' }'],
      \     'nesting': 1,
      \     'match_syntax': 1,
      \     'kind': ['add', 'replace', 'delete'],
      \     'action': ['add'],
      \     'input': ['{']
      \   },
      \   {
      \     'buns': ['[ ', ' ]'],
      \     'nesting': 1,
      \     'match_syntax': 1,
      \     'kind': ['add', 'replace', 'delete'],
      \     'action': ['add'],
      \     'input': ['[']
      \   },
      \   {
      \     'buns': ['( ', ' )'],
      \     'nesting': 1,
      \     'match_syntax': 1,
      \     'kind': ['add', 'replace', 'delete'],
      \     'action': ['add'],
      \     'input': ['(']
      \   },
      \   {
      \     'buns': ['< ', ' >'],
      \     'nesting': 1,
      \     'match_syntax': 1,
      \     'kind': ['add', 'replace', 'delete'],
      \     'action': ['add'],
      \     'input': ['<']
      \   },
      \   {
      \     'buns': ['{\s*', '\s*}'],
      \     'nesting': 1,
      \     'regex': 1,
      \     'match_syntax': 1,
      \     'kind': ['delete', 'replace', 'textobj'],
      \     'action': ['delete'],
      \     'input': ['{']
      \   },
      \   {
      \     'buns': ['\[\s*', '\s*\]'],
      \     'nesting': 1,
      \     'regex': 1,
      \     'match_syntax': 1,
      \     'kind': ['delete', 'replace', 'textobj'],
      \     'action': ['delete'],
      \     'input': ['[']
      \   },
      \   {
      \     'buns': ['(\s*', '\s*)'],
      \     'nesting': 1,
      \     'regex': 1,
      \     'match_syntax': 1,
      \     'kind': ['delete', 'replace', 'textobj'],
      \     'action': ['delete'],
      \     'input': ['(']
      \   },
      \   {
      \     'buns': ['<\s*', '\s*>'],
      \     'nesting': 1,
      \     'regex': 1,
      \     'match_syntax': 1,
      \     'kind': ['delete', 'replace', 'textobj'],
      \     'action': ['delete'],
      \     'input': ['<']
      \   },
      \   {
      \     'buns': ['[`', '`]'],
      \     'nesting': 1,
      \     'kind': ['add', 'replace', 'delete', 'textobj'],
      \     'input': ['1']
      \   },
      \   {
      \     'buns': ['[[', ']]'],
      \     'filetype': ['zsh', 'sh', 'bash', 'lua'],
      \     'nesting': 1,
      \     'kind': ['add', 'replace', 'delete', 'textobj'],
      \     'input': ['D']
      \   },
      \   {
      \     'buns': ['\s\+', '\s\+'],
      \     'regex': 1,
      \     'kind': ['delete', 'replace', 'query'],
      \     'input': [' ']
      \   },
      \   {
      \     'buns'        : ['{', '}'],
      \     'motionwise'  : ['line'],
      \     'kind'        : ['add'],
      \     'linewise'    : 1,
      \     'command'     : ["'[+1,']-1normal! >>"],
      \   },
      \   {
      \     'buns'        : ['{', '}'],
      \     'motionwise'  : ['line'],
      \     'kind'        : ['delete'],
      \     'linewise'    : 1,
      \     'command'     : ["'[,']normal! <<"],
      \   },
      \   {
      \     'buns':         ['', ''],
      \     'action':       ['add'],
      \     'motionwise':   ['line'],
      \     'linewise':     1,
      \     'input':        ["\<CR>"]
      \   },
      \   {
      \     'buns':         ['^$', '^$'],
      \     'regex':        1,
      \     'linewise':     1,
      \     'input':        ["\<CR>"]
      \   },
      \   {
      \     'buns':         ['{', '}'],
      \     'nesting':      1,
      \     'skip_break':   1,
      \     'input':        ['}', 'B'],
      \   },
      \   {
      \     'buns':         ['[', ']'],
      \     'nesting':      1,
      \     'input':        [']', 'r'],
      \   },
      \   {
      \     'buns':         ['(', ')'],
      \     'nesting':      1,
      \     'input':        [')', 'b'],
      \   },
      \   {
      \     'buns':         ['`', '`'],
      \     'quoteescape':  1,
      \     'expand_range': 0,
      \     'nesting':      0,
      \     'linewise':     0,
      \     'kind':   ['add', 'replace', 'delete', 'textobj'],
      \     'input':  ['`', 'v'],
      \   },
      \   {
      \     'buns':         ['"', '"'],
      \     'quoteescape':  1,
      \     'expand_range': 0,
      \     'nesting':      0,
      \     'linewise':     0,
      \     'kind':   ['add', 'replace', 'delete', 'textobj'],
      \     'input':  ['"', 'q'],
      \   },
      \
      \   {
      \     'buns':         ["'", "'"],
      \     'quoteescape':  1,
      \     'expand_range': 0,
      \     'nesting':      0,
      \     'linewise':     0,
      \     'kind':   ['add', 'replace', 'delete', 'textobj'],
      \     'input':  ["'", 'Q'],
      \   },
      \   {
      \     'buns':   ['=== ', ' ==='],
      \     'nesting':      1,
      \     'kind':   ['add', 'replace', 'delete'],
      \     'action': ['add'],
      \     'input':  ['='],
      \   },
      \   {
      \     'buns': ["(\n", "\n)"],
      \     'nesting': 1,
      \     'kind': ['add'],
      \     'action': ['add'],
      \     'input':  ["\<C-S-)>"],
      \   },
      \   {
      \     'buns': ["{\n", "\n}"],
      \     'nesting': 1,
      \     'kind': ['add'],
      \     'action': ['add'],
      \     'input':  ["\<C-S-}>", "U"],
      \   },
      \   {
      \     'buns': ['(', ')'],
      \     'cursor': 'head',
      \     'command': ['startinsert'],
      \     'kind': ['add', 'replace'],
      \     'action': ['add'],
      \     'input': ['F']
      \   },
      \ ]
    ]==]
    )

    -- map({"x", "o"}, "iF", "<Plug>(textobj-sandwich-function-ip)", {desc = "Inner func parens"})
    -- map({"x", "o"}, "aF", "<Plug>(textobj-sandwich-function-a)", {desc = "Around func call"}) --?
    -- map({"x", "o"}, "im", "<Plug>(textobj-sandwich-literal-query-i)")
    -- map({"x", "o"}, "am", "<Plug>(textobj-sandwich-literal-query-a)")
    map({"x", "o"}, "is", "<Plug>(textobj-sandwich-query-i)", {desc = "Query inner delimiter"})
    map({"x", "o"}, "as", "<Plug>(textobj-sandwich-query-a)", {desc = "Query around delimiter"})
    map({"x", "o"}, "iss", "<Plug>(textobj-sandwich-auto-i)", {desc = "Auto delimiter"})
    map({"x", "o"}, "ass", "<Plug>(textobj-sandwich-auto-a)", {desc = "Auto delimiter"})

    wk.register(
        {
            -- ["<Leader>o"] = {"<Plug>(sandwich-add)iw", "Surround a word"},
            ["y;"] = {"<Plug>(sandwich-add)iw", "Surround a word"},
            ["m."] = {"<Plug>(sandwich-add)iw'", "Surround a word with quotes"},
            ["yf"] = {"<Plug>(sandwich-add)iwf", "Surround a cword with function"},
            ["yF"] = {"<Plug>(sandwich-add)iWf", "Surround a cWORD with function"},
            ["ygs"] = {"<Plug>(sandwich-add)aL", "Surround entire line"},
            ["yss"] = "Surround line (only text)",
            ["yS"] = "Surround to EOL",
            ["dss"] = "Delete auto delimiter",
            ["dsf"] = "Delete surrounding function",
            ["css"] = "Change auto delimiter"
        }
    )

    wk.register(
        {
            ["asi"] = "Around ask head-tail",
            ["isi"] = "Inner ask head-tail",
            ["si"] = "Surrounding ask head-tail"
        },
        {mode = "o"}
    )

    wk.register(
        {
            -- ["mb"] = {"<Plug>(sandwich-add)*gV<Left><Plug>(sandwich-add)*", "Surround with bold (**)"},
            ["```"] = {
                "<esc>`<O<esc>S```<esc>`>o<esc>S```<esc>k$|",
                "Surround with code block (```)"
            },
            ["``;"] = {
                "<esc>`<O<esc>S```zsh<esc>`>o<esc>S```<esc>k$|",
                "Surround with code block (```zsh)"
            },
            ["``,"] = {
                "<esc>`<O<esc>S```perl<esc>`>o<esc>S```<esc>k$|",
                "Surround with code block (```perl)"
            },
        },
        {mode = "x"}
    )

    map("x", "gS", ":<C-u>normal! V<CR><Plug>(sandwich-add)", {desc = "Surround entire line"})
    map(
        "x",
        "zF",
        function()
            local cms = vsm.split(vim.bo.cms, "%s", {trimempty = true})[1] or "#"
            utils.normal("n", ("<Esc>`<O<Esc>S%s [[[<Esc>`>o<Esc>S%s ]]]<Esc>k$|"):format(cms, cms))
        end,
        {desc = "Surround with foldmarker"}
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                         targets                          │
-- ╰──────────────────────────────────────────────────────────╯
-- http://vimdoc.sourceforge.net/htmldoc/motion.html#operator
function M.targets()
    -- Cheatsheet: https://github.com/wellle/targets.vim/blob/master/cheatsheet.md
    -- vI) = contents inside pair
    -- in( an( In( An( il( al( Il( Al( ... next and last pair
    -- {a,I,A}{,.;+=...} = a/inside/around separator
    -- inb anb Inb Anb ilb alb Ilb Alb = any block
    -- inq anq Inq Anq ilq alq Ilq Alq == any quote

    augroup(
        "lmb__Targets",
        {
            event = "User",
            pattern = "targets#mappings#user",
            command = function()
                fn["targets#mappings#extend"](
                    {
                        -- Parameter
                        J = {
                            argument = {
                                {o = "(", c = ")", s = ","},
                                {o = "{", c = "}", s = ","},
                                {o = "[", c = "]", s = ","},
                            },
                        },
                        a = {pair = {{o = "<", c = ">"}}},
                        r = {pair = {{o = "[", c = "]"}}},
                        B = {pair = {{o = "{", c = "}"}}},
                        b = {
                            pair = {
                                {o = "(", c = ")"},
                                {o = "{", c = "}"},
                            },
                        },
                        A = {
                            pair = {
                                {o = "(", c = ")"},
                                {o = "{", c = "}"},
                                {o = "[", c = "]"},
                            },
                        },
                        ["-"] = {separator = {{d = "-"}}},
                        L = {line = {{c = 1}}},
                        -- Closest delimiter
                        O = {
                            separator = {
                                {d = ","},
                                {d = "."},
                                {d = ";"},
                                {d = "="},
                                {d = "+"},
                                {d = "-"},
                                {d = "="},
                                {d = "~"},
                                {d = "_"},
                                {d = "*"},
                                {d = "#"},
                                {d = "/"},
                                {d = [[\]]},
                                {d = "|"},
                                {d = "&"},
                                {d = "$"},
                            },
                            pair = {
                                {o = "(", c = ")"},
                                {o = "[", c = "]"},
                                {o = "{", c = "}"},
                                {o = "<", c = ">"},
                            },
                            quote = {{d = "'"}, {d = '"'}, {d = "`"}},
                            tag = {{}},
                        },
                    }
                )
            end,
        }
    )

    wk.register(
        {
            ["ir"] = "Inner brace [ ]",
            ["ar"] = "Around brace [ ]",
            ["iB"] = "Inner brace { }",
            ["aB"] = "Around brace { }",
            ["ib"] = "Inner brace ({ })",
            ["ab"] = "Around brace ({ })",
            ["ia"] = "Inner angle bracket < >",
            ["aa"] = "Around angle bracket < >",
            ["iA"] = "Inner any bracket [({ })]",
            ["aA"] = "Around any bracket [({ })]",
            ["iq"] = "Inner quote",
            ["aq"] = "Around quote",
            ["in"] = "Next object",
            ["im"] = "Previous object",
            ["an"] = "Next object",
            ["am"] = "Previous object",
            ["iO"] = "Inner nearest object",
            ["aO"] = "Around nearest object",
            ["iJ"] = "Inner parameter (comma)",
            ["aJ"] = "Around parameter (comma)",
            ["iL"] = "Inner line",
            ["aL"] = "Around line"
        },
        {mode = "o"}
    )

    -- c: on cursor position
    -- l: left of cursor in current line
    -- r: right of cursor in current line
    -- a: above cursor on screen
    -- b: below cursor on screen
    -- A: above cursor off screen
    -- B: below cursor off screen
    g.targets_seekRanges =
    "cc cr cb cB lc ac Ac lr lb ar ab lB Ar aB Ab AB rr ll rb al rB Al bb aa bB Aa BB AA"
    g.targets_jumpRanges = g.targets_seekRanges
    g.targets_aiAI = "aIAi"
    -- g.targets_mapped_aiAI = 'aiAI'

    -- Seeking next/last objects
    g.targets_nl = "nm"

    -- FIX: I here triggers unable to change text in window with coc with progress enabled
    map({"o", "x"}, "I", [[targets#e('o', 'i', 'I')]], {expr = true, noremap = false})
    map({"o", "x"}, "a", [[targets#e('o', 'a', 'a')]], {expr = true, noremap = false})
    map({"o", "x"}, "i", [[targets#e('o', 'I', 'i')]], {expr = true, noremap = false})
    map({"o", "x"}, "A", [[targets#e('o', 'A', 'A')]], {expr = true, noremap = false})
end

--  ╭──────────────────────────────────────────────────────────╮
--  │                     VariousTextobjs                      │
--  ╰──────────────────────────────────────────────────────────╯
function M.various_textobjs()
    local vobjs = D.npcall(require, "various-textobjs")
    if not vobjs then
        return
    end

    vobjs.setup{
        lookForwardLines = 5,      -- set to 0 to only look in the current line
        useDefaultKeymaps = false, -- use suggested keymaps (see README)
    }

    -- https://github.com/chrisgrieser/nvim-various-textobjs#list-of-text-objects

    -- exclude start exclude end
    map({"o", "x"}, "ii", D.ithunk(vobjs.indentation, true, true))
    map({"o", "x"}, "aI", D.ithunk(vobjs.indentation, false, true))
    map({"o", "x"}, "iI", D.ithunk(vobjs.indentation, true, false))
    map({"o", "x"}, "ai", D.ithunk(vobjs.indentation, false, false))

    wk.register(
        {
            ["aI"] = "Indentation level (+ line above)",
            ["ai"] = "Indention level (+ lines above/below)",
            ["iI"] = "Inner Indentation level (+ line below)",
            ["ii"] = "Inner Indentation level"
        },
        {mode = "o"}
    )

    nvim.autocmd.VariousTextobjs = {
        event = "FileType",
        pattern = {"lua", "zsh", "sh", "bash"},
        command = function(args)
            local buf = args.buf

            map({"o", "x"}, "iD", D.ithunk(vobjs.doubleSquareBrackets, true), {buffer = buf})
            map({"o", "x"}, "aD", D.ithunk(vobjs.doubleSquareBrackets, false), {buffer = buf})

            wk.register(
                {
                    ["iD"] = "Inner [[",
                    ["aD"] = "Outer [["
                },
                {mode = "o"}
            )
        end,
    }
end

return M