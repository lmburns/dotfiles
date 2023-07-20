---@module 'plugs.textobj'
local M = {}

local F = Rc.F
local wk = require("which-key")

local utils = Rc.shared.utils
local map = Rc.api.map
local augroup = Rc.api.augroup

local cmd = vim.cmd
local fn = vim.fn
local g = vim.g
-- local api = vim.api

-- ╭──────────────────────────────────────────────────────────╮
-- │                        Sandwich                          │
-- ╰──────────────────────────────────────────────────────────╯
function M.sandwich()
    -- --Old--                   ---Input---        ---Output---
    -- "hello"                   ysiwtkey<cr>       "<key>hello</key>"
    -- "hello"                   ysiwF              |("hello")
    -- "hello"                   ysiwfprint<cr>     print("hello")
    -- print("hello")            dsf                "hello"

    -- TODO: Undojoin the changing of delimiters (allow undoing with 1 undo)
    -- TODO: These
    -- "hello"                   ysWFprint<cr>     print( "hello" )
    -- "hello"                   ysW<C-f>print<cr> (print "hello")

    g.sandwich_no_default_key_mappings = 1

    -- dsf
    g["sandwich#magicchar#f#patterns"] = {
        -- This: func(arg) => arg
        {
            header = [[\<\%(\.\|:\{1,2}\)\@<!\h\k*\%(\.\|:\{1,2}\)\@!]],
            bra = "(",
            ket = ")",
            footer = "",
        },
        -- This: macro!(arg) => arg
        {
            header = [[\<\h\k*!]],
            bra = "(",
            ket = ")",
            footer = "",
        },
        -- This: func.method.xx(arg) => arg
        {
            header = [[\<\%(\h\k*\.\)\+\h\k*]],
            bra = "(",
            ket = ")",
            footer = "",
        },
        -- This: Vim#method#xx(arg) => arg
        {
            header = [[\<\%(\h\k*#\)\+\h\k*]],
            bra = "(",
            ket = ")",
            footer = "",
        },
        -- This: func<T>(generic) => T(generic)
        {
            header = [[\<\h\k*]],
            bra = "<",
            ket = ">",
            footer = "",
        },
        -- This: Lua:method(arg) => arg
        {
            header = [[\<\%(\h\k*:\)\h\k*]],
            bra = "(",
            ket = ")",
            footer = "",
        },
        -- This: Vim#method(arg) => arg
        {
            header = [[\<\%(\h\k*#\)\h\k*]],
            bra = "(",
            ket = ")",
            footer = "",
        },
        -- This: func::method(arg) => arg
        {
            header = [[\<\%(\h\k*::\)\+\h\k*]],
            bra = "(",
            ket = ")",
            footer = "",
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

    cmd[==[
      let g:sandwich#recipes = deepcopy(g:sandwich#default_recipes)

      let g:sandwich#recipes += [
      \   {
      \     'buns':         ['<', '>'],
      \     'expand_range': 0,
      \     'input':        ['>', 'a'],
      \   },
      \   {
      \     'buns':         ['{ ', ' }'],
      \     'nesting':      1,
      \     'match_syntax': 1,
      \     'kind':         ['add', 'replace', 'delete'],
      \     'action':       ['add'],
      \     'input':        ['{']
      \   },
      \   {
      \     'buns':         ['[ ', ' ]'],
      \     'nesting':      1,
      \     'match_syntax': 1,
      \     'kind':         ['add', 'replace', 'delete'],
      \     'action':       ['add'],
      \     'input':        ['[']
      \   },
      \   {
      \     'buns':         ['( ', ' )'],
      \     'nesting':      1,
      \     'match_syntax': 1,
      \     'kind':         ['add', 'replace', 'delete'],
      \     'action':       ['add'],
      \     'input':        ['(']
      \   },
      \   {
      \     'buns':         ['< ', ' >'],
      \     'nesting':      1,
      \     'match_syntax': 1,
      \     'kind':         ['add', 'replace', 'delete'],
      \     'action':       ['add'],
      \     'input':        ['<']
      \   },
      \   {
      \     'buns':         ['{\s*', '\s*}'],
      \     'nesting':      1,
      \     'regex':        1,
      \     'match_syntax': 1,
      \     'kind':         ['delete', 'replace', 'textobj'],
      \     'action':       ['delete'],
      \     'input':        ['{']
      \   },
      \   {
      \     'buns':         ['\[\s*', '\s*\]'],
      \     'nesting':      1,
      \     'regex':        1,
      \     'match_syntax': 1,
      \     'kind':         ['delete', 'replace', 'textobj'],
      \     'action':       ['delete'],
      \     'input':        ['[']
      \   },
      \   {
      \     'buns':         ['(\s*', '\s*)'],
      \     'nesting':      1,
      \     'regex':        1,
      \     'match_syntax': 1,
      \     'kind':         ['delete', 'replace', 'textobj'],
      \     'action':       ['delete'],
      \     'input':        ['(']
      \   },
      \   {
      \     'buns':         ['<\s*', '\s*>'],
      \     'nesting':      1,
      \     'regex':        1,
      \     'match_syntax': 1,
      \     'kind':         ['delete', 'replace', 'textobj'],
      \     'action':       ['delete'],
      \     'input':        ['<']
      \   },
      \   {
      \     'buns':    ['[`', '`]'],
      \     'nesting': 1,
      \     'kind':    ['add', 'replace', 'delete', 'textobj'],
      \     'input':   ['1']
      \   },
      \   {
      \     'buns':     ['[[', ']]'],
      \     'filetype': ['zsh', 'sh', 'bash', 'lua'],
      \     'nesting':  1,
      \     'kind':     ['add', 'replace', 'delete', 'textobj'],
      \     'input':    ['D']
      \   },
      \   {
      \     'buns':  ['\s\+', '\s\+'],
      \     'regex': 1,
      \     'kind':  ['delete', 'replace', 'query'],
      \     'input': [' ']
      \   },
      \   {
      \     'buns':        ['{', '}'],
      \     'motionwise':  ['line'],
      \     'kind':        ['add'],
      \     'linewise':    1,
      \     'command':     ["'[+1,']-1normal! >>"],
      \   },
      \   {
      \     'buns':       ['{', '}'],
      \     'motionwise': ['line'],
      \     'kind':       ['delete'],
      \     'linewise':   1,
      \     'command':    ["'[,']normal! <<"],
      \   },
      \   {
      \     'buns':       ['', ''],
      \     'action':     ['add'],
      \     'motionwise': ['line'],
      \     'linewise':   1,
      \     'input':      ["\<CR>"]
      \   },
      \   {
      \     'buns':       ['^$', '^$'],
      \     'regex':      1,
      \     'linewise':   1,
      \     'input':      ["\<CR>"]
      \   },
      \   {
      \     'buns':       ['{', '}'],
      \     'nesting':    1,
      \     'skip_break': 1,
      \     'input':      ['}', 'B'],
      \   },
      \   {
      \     'buns':     ['[', ']'],
      \     'nesting':  1,
      \     'input':    [']', 'r'],
      \   },
      \   {
      \     'buns':     ['(', ')'],
      \     'nesting':  1,
      \     'input':    [')', 'b'],
      \   },
      \   {
      \     'buns':         ['`', '`'],
      \     'quoteescape':  1,
      \     'expand_range': 0,
      \     'nesting':      0,
      \     'linewise':     0,
      \     'kind':         ['add', 'replace', 'delete', 'textobj'],
      \     'input':        ['`', 'v'],
      \   },
      \   {
      \     'buns':         ['"', '"'],
      \     'quoteescape':  1,
      \     'expand_range': 0,
      \     'nesting':      0,
      \     'linewise':     0,
      \     'kind':         ['add', 'replace', 'delete', 'textobj'],
      \     'input':        ['"', 'q'],
      \   },
      \
      \   {
      \     'buns':         ["'", "'"],
      \     'quoteescape':  1,
      \     'expand_range': 0,
      \     'nesting':      0,
      \     'linewise':     0,
      \     'kind':         ['add', 'replace', 'delete', 'textobj'],
      \     'input':        ["'", 'Q'],
      \   },
      \   {
      \     'buns':   ['|', '|'],
      \     'kind':   ['add', 'replace', 'delete', 'textobj'],
      \     'input':  ['|'],
      \   },
      \   {
      \     'buns':    ['=== ', ' ==='],
      \     'nesting': 1,
      \     'kind':    ['add', 'replace', 'delete'],
      \     'action':  ['add'],
      \     'input':   ['='],
      \   },
      \   {
      \     'buns':    ["(\n", "\n)"],
      \     'nesting': 1,
      \     'kind':    ['add'],
      \     'action':  ['add'],
      \     'input':   ["\<C-S-)>"],
      \   },
      \   {
      \     'buns':    ["{\n", "\n}"],
      \     'nesting': 1,
      \     'kind':    ['add'],
      \     'action':  ['add'],
      \     'input':   ["\<C-S-}>", "U"],
      \   },
      \   {
      \     'buns':    ['(', ')'],
      \     'cursor':  'head',
      \     'command': ['startinsert'],
      \     'kind':    ['add', 'replace'],
      \     'action':  ['add'],
      \     'input':   ['F']
      \   },
      \ ]
    ]==]


    -- map({"x", "o"}, "iF", "<Plug>(textobj-sandwich-function-ip)", {desc = "Inner func parens"})
    -- map({"x", "o"}, "aF", "<Plug>(textobj-sandwich-function-a)", {desc = "Around func call"}) --?
    -- map({"x", "o"}, "im", "<Plug>(textobj-sandwich-literal-query-i)")
    -- map({"x", "o"}, "am", "<Plug>(textobj-sandwich-literal-query-a)")
    map({"x", "o"}, "is", "<Plug>(textobj-sandwich-query-i)", {desc = "Query inner delimiter"})
    map({"x", "o"}, "as", "<Plug>(textobj-sandwich-query-a)", {desc = "Query around delimiter"})
    map({"x", "o"}, "iss", "<Plug>(textobj-sandwich-auto-i)", {desc = "Auto delimiter"})
    map({"x", "o"}, "ass", "<Plug>(textobj-sandwich-auto-a)", {desc = "Auto delimiter"})

    wk.register({
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
        ["css"] = "Change auto delimiter",
    })

    wk.register({
        ["asi"] = "Around ask head-tail",
        ["isi"] = "Inner ask head-tail",
        ["si"] = "Surrounding ask head-tail",
    }, {mode = "o"})

    wk.register({
        -- ["mb"] = {"<Plug>(sandwich-add)*gV<Left><Plug>(sandwich-add)*", "Surround with bold (**)"},
        ["```"] = {
            "<esc>`<O<esc>S```<esc>`>o<esc>S```<esc>k$|",
            "Surround with code block (```)",
        },
        ["``;"] = {
            "<esc>`<O<esc>S```zsh<esc>`>o<esc>S```<esc>k$|",
            "Surround with code block (```zsh)",
        },
        ["``,"] = {
            "<esc>`<O<esc>S```perl<esc>`>o<esc>S```<esc>k$|",
            "Surround with code block (```perl)",
        },
    }, {mode = "x"})

    -- nvim.autocmd.lmb__Sandwich = {
    --     {
    --         event = "User",
    --         pattern = "OperatorSandwichDeletePost",
    --         command = "undojoin",
    --     },
    --     {
    --         event = "User",
    --         pattern = "OperatorSandwichReplacePost",
    --         command = "undojoin",
    --     },
    -- }

    map("x", "gS", ":<C-u>normal! V<CR><Plug>(sandwich-add)", {desc = "Surround entire line"})
    map("x", "zF", function()
        local cms = vim.split(vim.bo.cms, "%s", {trimempty = true})[1] or "#"
        utils.normal("n", ("<Esc>`<O<Esc>S%s [[[<Esc>`>o<Esc>S%s ]]]<Esc>k$|"):format(cms, cms))
    end, {desc = "Surround with foldmarker"}
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                         targets                          │
-- ╰──────────────────────────────────────────────────────────╯
function M.targets()
    local sep = {
        {d = ","},
        {d = "."},
        {d = ";"},
        {d = ":"},
        {d = "+"},
        {d = "-"},
        {d = "="},
        {d = "~"},
        {d = "_"},
        {d = "/"},
        {d = "|"},
        {d = [[\]]},
        {d = "&"},
        {d = "$"},
        {d = "#"},
        {d = "*"},
        {d = "%"},
    }

    augroup("lmb__Targets", {
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
                            {o = "<", c = ">", s = ","},
                        },
                    },
                    a = {pair = {{o = "<", c = ">"}}},
                    r = {pair = {{o = "[", c = "]"}}},
                    B = {pair = {{o = "{", c = "}"}}},
                    b = {pair = {{o = "(", c = ")"}, {o = "{", c = "}"}}},
                    A = {
                        pair = {
                            {o = "(", c = ")"},
                            {o = "{", c = "}"},
                            {o = "[", c = "]"},
                        },
                    },
                    ["-"] = {separator = {{d = "-"}}},
                    ["_"] = {separator = {{d = "_"}}},
                    ["?"] = {separator = {{d = "/"}}},
                    L = {line = {{c = 1}}},
                    -- Closest delimiter
                    O = {separator = sep},
                    -- Closest object
                    ["@"] = {
                        separator = sep,
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
    })

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
    -- g.targets_jumpRanges = "rr rb rB bb bB BB ll al Al aa Aa AA"
    g.targets_aiAI = "aIAi"
    -- g.targets_mapped_aiAI = 'aiAI'
    -- g.targets_gracious = 1 -- count too big selects last

    -- Seeking next/last objects
    g.targets_nl = "nm"
    -- g.targets_nl = {"n", "m"}

    map({"o", "x"}, "i", [[targets#e('o', 'I', 'i')]], {expr = true, noremap = false})
    map({"o", "x"}, "a", [[targets#e('o', 'a', 'a')]], {expr = true, noremap = false})
    map({"o"}, "I", [[targets#e('o', 'i', 'I')]], {expr = true, noremap = false})
    map({"o"}, "A", [[targets#e('o', 'A', 'A')]], {expr = true, noremap = false})

    map("o", "ie", [[<Cmd>execute "norm! m`"<Bar>keepj norm! ggVG<CR>]])
    map("x", "ie", [[:normal! ggVG"<CR>]])
    map("o", "ae", [[:<C-u>normal! HVL"<CR>]])
    map("x", "ae", [[:normal! HVL"<CR>]])

    -- map("x", "iF",
    --     [[:<C-u>lua require('usr.lib.textobj').select('func', true, true)<CR>]], {silent = true})
    -- map("x", "aF",
    --     [[:<C-u>lua require('usr.lib.textobj').select('func', false, true)<CR>]], {silent = true})
    -- map("o", "iF", [[<Cmd>lua require('usr.lib.textobj').select('func', true)<CR>]], {sil = true})
    -- map("o", "aF", [[<Cmd>lua require('usr.lib.textobj').select('func', false)<CR>]], {sil = true})

    -- map("x", "iK", [[:<C-u>lua require('usr.lib.textobj').select('class', true, true)<CR>]])
    -- map("x", "aK", [[:<C-u>lua require('usr.lib.textobj').select('class', false, true)<CR>]])
    -- map("o", "iK", [[<Cmd>lua require('usr.lib.textobj').select('class', true)<CR>]])
    -- map("o", "aK", [[<Cmd>lua require('usr.lib.textobj').select('class', false)<CR>]])

    -- map("x", "aL", "$o0")
    -- map("o", "aL", "<Cmd>norm vaL<CR>")
    -- map("x", "iL", [[<Esc>^vg_]])
    -- map("o", "iL", [[<Cmd>norm! ^vg_<CR>]])

    wk.register({
        ["ir"] = "Inner brace []",
        ["ar"] = "Around brace []",
        ["i>"] = "Inner brace <>",
        ["a>"] = "Around brace <>",
        -- ["i<"] = {"I<", "Inner brace < > (space)"},
        -- ["a<"] = {"A<", "Around brace < > (space)"},
        ["iB"] = "Inner brace {}",
        ["aB"] = "Around brace {}",
        ["ib"] = "Inner brace ({})",
        ["ab"] = "Around brace ({})",
        ["ia"] = "Inner angle bracket <>",
        ["aa"] = "Around angle bracket <>",
        ["iA"] = "Inner any bracket [({})]",
        ["aA"] = "Around any bracket [({})]",
        ["iq"] = "Inner quote",
        ["aq"] = "Around quote",
        ["in"] = "Next object",
        ["im"] = "Previous object",
        ["an"] = "Next object",
        ["am"] = "Previous object",
        ["i@"] = "Inner nearest object",
        ["a@"] = "Around nearest object",
        ["iO"] = "Inner nearest delim",
        ["aO"] = "Around nearest delim",
        ["iJ"] = "Inner parameter (comma)",
        ["aJ"] = "Around parameter (comma)",
        ["iL"] = "Inner line",
        ["aL"] = "Around line",
    }, {mode = {"o", "x"}})
end

---Comment text object. Treesitter provides one, but you cannot
---delete around a comment with da<MAP>
function M.comment()
    fn["textobj#user#plugin"]("comment", {
        ["-"] = {
            ["select-a-function"] = "textobj#comment#select_a",
            ["select-a"] = "iC",
            ["select-i-function"] = "textobj#comment#select_i",
            ["select-i"] = "iM",
        },
        big = {
            ["select-a-function"] = "textobj#comment#select_big_a",
            ["select-a"] = "aC",
        },
    })

    wk.register({
        ["iM"] = "Inner comment - top line",
        ["iC"] = "Inner comment",
        ["aC"] = "Around comment (+blanks)",
    }, {mode = "o"})
end

function M.column_up()
    local bo = vim.bo
    local u = require("various-textobjs.utils")

    local startRow = u.getCursor(0)[1]
    local trueCursorCol = fn.virtcol(".")
    local extraColumns = vim.v.count1 - 1
    local nextLnum = startRow

    repeat
        nextLnum = nextLnum - 1
        if nextLnum == 0 then break end
        local trueLineLength = #u.getline(nextLnum):gsub("\t", (" "):rep(bo.tabstop))
        local shorterLine = trueLineLength <= trueCursorCol
        local hitsIndent = trueCursorCol <= fn.indent(nextLnum)
    until hitsIndent or shorterLine
    local linesUp = startRow - nextLnum - 1

    -- start visual block mode
    if not (fn.mode() == "CTRL-V") then cmd.execute([["normal! \<C-v>"]]) end

    if linesUp > 0 then u.normal(tostring(linesUp) .. "k") end
    if extraColumns > 0 then u.normal(tostring(extraColumns) .. "l") end
end

--  ╭──────────────────────────────────────────────────────────╮
--  │                     VariousTextobjs                      │
--  ╰──────────────────────────────────────────────────────────╯
function M.various_textobjs()
    local vobjs = F.npcall(require, "various-textobjs")
    if not vobjs then
        return
    end

    vobjs.setup({
        lookForwardLines = 20,     -- set to 0 to only look in the current line
        useDefaultKeymaps = false, -- use suggested keymaps (see README)
    })

    -- https://github.com/chrisgrieser/nvim-various-textobjs#list-of-text-objects

    -- exclude start exclude end
    map({"o", "x"}, "iI", F.ithunk(vobjs.indentation, true, false))
    map({"o", "x"}, "ii", F.ithunk(vobjs.indentation, true, true))
    map({"x", "o"}, "aI", F.ithunk(vobjs.indentation, false, true))
    map({"o", "x"}, "ai", F.ithunk(vobjs.indentation, false, false))
    map({"o", "x"}, "iS", F.ithunk(vobjs.subword, true))
    map({"o", "x"}, "aS", F.ithunk(vobjs.subword, false))
    map({"o", "x"}, "iH", F.ithunk(vobjs.chainMember, true))
    map({"o", "x"}, "aH", F.ithunk(vobjs.chainMember, false))
    map("n", "sJ", vobjs.column)
    map("n", "sK", M.column_up)
    -- map({"o", "x"}, "a", F.ithunk(vobjs.mdFencedCodeBlocks, true))
    -- map({"o", "x"}, "i", F.ithunk(vobjs.mdFencedCodeBlocks, false))
    -- map({"o", "x"}, "a", F.ithunk(vobjs.key, true))
    -- map({"o", "x"}, "i", F.ithunk(vobjs.key, false))
    -- map({"o", "x"}, "a", F.ithunk(vobjs.value, true))
    -- map({"o", "x"}, "i", F.ithunk(vobjs.value, false))
    -- map({"o", "x"}, "a", F.ithunk(vobjs.cssSelector, true))
    -- map({"o", "x"}, "i", F.ithunk(vobjs.cssSelector, false))
    -- map({"o", "x"}, "a", F.ithunk(vobjs.htmlAttribute, true))
    -- map({"o", "x"}, "i", F.ithunk(vobjs.htmlAttribute, false))
    -- map({"o", "x"}, "a", F.ithunk(vobjs.jsRegex, true))
    -- map({"o", "x"}, "i", F.ithunk(vobjs.jsRegex, false))
    -- map({"o", "x"}, "a", F.ithunk(vobjs.shellPipe, true))
    -- map({"o", "x"}, "i", F.ithunk(vobjs.shellPipe, false))
    -- map({"o", "x"}, "", vobjs.url)

    wk.register({
        ["aI"] = "Indentation level (+ line above)",
        ["ai"] = "Indentation level (+ lines above/below)",
        ["iI"] = "Inner indentation level (+ line below)",
        ["ii"] = "Inner indentation level",
        ["aS"] = "Around subword (_-.=delims)",
        ["iS"] = "Around subword (_-.=delims)",
        ["aH"] = "Around [.chained()]",
        ["iH"] = "Inner .[chained()]",
    }, {mode = "o"})

    wk.register({
        ["sJ"] = "Select column down",
        ["sK"] = "Select column up",
        ["vJ"] = "Select line below",
        ["vK"] = "Select line above",
    })

    nvim.autocmd.VariousTextobjs = {
        event = "FileType",
        pattern = {"lua", "zsh", "sh", "bash"},
        command = function(args)
            local buf = args.buf

            map({"o", "x"}, "iD", F.ithunk(vobjs.doubleSquareBrackets, true), {buffer = buf})
            map({"o", "x"}, "aD", F.ithunk(vobjs.doubleSquareBrackets, false), {buffer = buf})

            wk.register({
                ["iD"] = "Inner [[",
                ["aD"] = "Outer [[",
            }, {mode = "o"})
        end,
    }
end

return M
