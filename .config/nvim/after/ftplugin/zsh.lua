local utils = require("usr.shared.utils")
local o = vim.opt_local

vim.b.coc_additional_keywords = {"-"}

o.autoindent = true
o.smartindent = true
o.cindent = true
-- o.copyindent = true -- copy structure of existing lines indent when autoindenting a new line
o.preserveindent = true -- preserve most indent structure as possible when reindenting line
o.breakindent = true -- each wrapped line will continue same indent level
o.breakindentopt = {
    "sbr",         -- display 'showbreak' value before applying indent
    "list:2",      -- add additional indent for lines matching 'formatlistpat'
    "min:20",      --- min width kept after breaking line
    "shift:2",     -- all lines after break are shifted N
}
o.linebreak = true -- lines wrap at words rather than random characters

-- which chars cause break with 'linebreak'
-- vim.o.breakat = "  !@*-+;:,./?"
o.breakat = {
    -- ["\t"] = true,
    [utils.termcodes["<Tab>"]] = true,
    [" "] = true,
    ["!"] = true,
    ["*"] = true,
    ["+"] = true,
    [","] = true,
    ["-"] = true,
    ["."] = true,
    ["/"] = true,
    [":"] = true,
    [";"] = true,
    ["?"] = true,
    ["@"] = true
}

-- strings that can start a comment line
-- o.comments = {
--     "n:>", -- nested comment prefix
--     "b:#", -- blank (<Space>, <Tab>, or <EOL>) required after prefix
--     "fb:-", -- only first line has comment string (e.g., a bullet-list)
--     "fb:*", -- only first line has comment string (e.g., a bullet-list)
--     "s1:/*", -- start of three-piece comment
--     "mb:*", -- middle of three-piece comment
--     "ex:*/", -- end of three-piece comment
--     "://",
--     ":%",
--     ":XCOMM"
-- }

-- Builtin
-- "s,e0,n0,f0,{0,}0,^0,L-1,:s,=s,l0,b0,gs,hs,N0,E0,ps,ts,is,+s,c3,C0,/0,(2s,us,U0,w0,W0,k0,m0,j0,J0,)20,*70,#0,P0"
o.cinoptions = {
    ">1s", -- any: amount added for "normal" indent
    "L0",  -- placement of jump labels
    "=1s", -- ? case: statement after case label: N chars from indent of label
    "l1",  -- N!=0 case: align w/ case label instead of statement after it on same line
    "b1",  -- N!=0 case: align final "break" w/ case label so it looks like block (0=break cinkeys)
    "g1s", -- ? C++ scope decls: N chars from indent of block they're in
    "h1s", -- ? C++: after scope decl: N chars from indent of label
    "N0",  -- ? C++: inside namespace: N chars extra
    "E0",  -- ? C++: inside linkage specifications: N chars extra
    "p1s", -- ? K&R: function decl: N chars from margin
    "t0",  -- K&R: return type of function decl: N chars from margin
    "i1s", -- ? C++: base class decl/constructor init if they start on newline
    "+0",  -- line continuation: N chars extra inside function; 2*N outside func if line end = '\'
    "c1s", -- comment lines: N chars from comment opener if no other text to align with
    "(1s", -- inside unclosed paren: N chars from line ('sw' for every unclosed paren)
    "u1s", -- same as (N but one level deeper
    "U1",  -- N!=0 : do not ignore nested parens that are on line by themselves
    -- "wN", "WN" --
    "k1s", -- unclosed paren in 'if' 'for' 'while' override '(N'
    "m1",  -- N!=0 line up line starting w/ closing paren w/ 1st char of line w/ opening
    "j1",  -- java: anon classes
    "J1",  -- javascript: object classes
    ")40", -- search for parens N lines away
    "*70", -- search for unclosed comments N lines away
    "#0",  -- N!=0 recognized '#' comments otherwise preproc (toggle this for files)
    "P1",  -- N!=0 format C pragmas
}

-- keys in insert mode that cause reindenting of current line 'cinkeys-format'
-- "0#" "0)"
-- o.cinkeys = {"0{", "0}", "0]", ":", "!^F", "o", "O", "e"}
o.cinkeys:remove({"0)", "0#"})
