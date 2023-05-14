local M = {}

local D = require("dev")
local it = D.ithunk
local utils = require("common.utils")

local lazy = require("common.lazy")
local W = require("common.api.win")
local mpi = require("common.api")
local op = require("common.op")

local fns = lazy.require("functions")
local builtin = lazy.require("common.builtin")
local qf = lazy.require("common.qf")
local qfext = lazy.require("common.qfext")

local wk = require("which-key")

M.deferred = {}
local function map(modes, lhs, rhs, opts)
    table.insert(M.deferred, {modes, lhs, rhs, opts})
end

-- ============== General mappings ============== [[[

--  ╭──────────────────────────────────────────────────────────╮
--  │                       Insert Mode                        │
--  ╰──────────────────────────────────────────────────────────╯

map("i", '<M-S-">', "<Home>", {desc = "Goto begin of lne"})
map("i", "<M-'>", "<End>", {desc = "Goto end of line"})
map("i", "<M-b>", "<C-Left>", {desc = "Go word back"})
map("i", "<M-f>", "<C-Right>", {desc = "Go word forward"})
map("i", "<C-S-h>", "<C-Left>", {desc = "Go word back"})
map("i", "<C-S-l>", "<C-Right>", {desc = "Go word forward"})
map("i", "<C-S-m>", "<Left>", {desc = "Go one char left"})
map("i", "<C-S-n>", "<Right>", {desc = "Go one char right"})
map("i", "<C-S-k>", "<C-o>gk", {desc = "Go one line up"})
map("i", "<C-S-j>", "<C-o>gj", {desc = "Go one line down"})
map("i", "<Down>", "<C-o>gj", {desc = "Goto next screen-line"})
map("i", "<Up>", "<C-o>gk", {desc = "Goto prev screen-line"})

map("i", "<M-/>", "<C-a>", {desc = "Insert last inserted text"})
map("i", "<C-S-p>", "<C-o>p", {desc = "Paste"})
map("i", "<C-M-p>", "<C-o>ghp", {noremap = false, desc = "Paste formatted"})
map("i", "<C-M-,>", "<C-o>ghp", {noremap = false, desc = "Paste formatted"})
map("i", "<M-p>", "<C-o>g2p", {noremap = false, desc = "Paste commented"})
map("i", "<C-M-.>", "<C-o>g2p", {noremap = false, desc = "Paste commented"})
map("i", "<C-n>", "<C-o>:", {desc = "Command mode"})

-- map("i", "<C-M-n>", "<C-n>", {desc = "Complete word (search forward)"})
-- map("i", "<C-M-p>", "<C-p>", {desc = "Complete word (search backward)"})
-- map("i", "<C-j>", "<C-o><Cmd>m +1<CR>")
-- map("i", "<C-k>", "<C-o><Cmd>m -2<CR>")

-- map("i", "<C-r>", "<C-g>u<C-r>", {desc = "Show registers"})
-- map("i", "<C-o>U", "<C-g>u<C-o><Cmd>redo<CR>", {desc = "Redo"})
-- map("i", "<C-Left>", [[<C-o>u]], {desc = "Undo"})
-- map("i", "<C-Right>", [[<C-o><Cmd>norm! ".p<CR>]], {desc = "Redo"})

map("i", ",", ",<C-g>u", {desc = "ignore"})
map("i", ".", ".<C-g>u", {desc = "ignore"})
map("i", "!", "!<C-g>u", {desc = "ignore"})
map("i", "?", "?<C-g>u", {desc = "ignore"})
map("i", "<CR>", "<CR><C-g>u", {desc = "ignore"})
map("i", "<C-S-u>", "<C-g>u", {desc = "Start new undo sequence"})
map("i", "<C-/>", "<C-g>u", {desc = "Start new undo sequence"})
map("i", "<C-o>u", "<C-g>u<C-o>u", {desc = "Undo typed text"})
map("i", "<C-o>U", "<C-g>u<C-o><C-r>", {desc = "Redo"})
map("i", "<M-u>", "<C-g>u<C-o>u", {desc = "Undo typed text"})
map("i", "<M-S-u>", "<C-g>u<C-o><C-r>", {desc = "Redo"})
map("i", "<M-BS>", "<C-g>u<C-w>", {desc = "Delete previous word"})
map("i", "<C-u>", "<C-g>u<C-u>", {desc = "Delete all typed in insert (before cursor)"})
map("i", "<C-l>", "<C-g>u<Del>", {desc = "Delete character to right"})
map("i", "<M-d>", "<C-g>u<C-o>de", {desc = "Delete to end of word"})
map("i", "<M-[>", "<C-g>u<C-o>dg^", {desc = "Left kill line"})
map("i", "<M-]>", "<C-g>u<C-o>dg$", {desc = "Right kill line"})
map("i", "<M-,>", "<C-g>u<C-o>dg$", {desc = "Right kill line"})
map("i", "<M-x>", "<C-g>u<C-o>cc", {desc = "Kill whole line"})

-- map("i", "<C-w>", "<C-g>u<C-w>", {desc = "Delete previous word"})
-- map("i", "<C-h>", "<C-g>u<C-h>", {desc = "Delete character to left"})
-- map("i", "<C-M-u>", "<C-g>u<C-o>ciL", {desc = "Kill whole line (except indent)", noremap = false})
-- map("i", "<M-,>", "<C-w>", {desc = "Delete previous word", noremap = false})

map("i", "<M-o>", "<C-g>u<C-o>o", {desc = "Equivalent: 'norm! o'"})
map("i", "<M-CR>", "<C-g>u<C-o>o", {desc = "Equivalent: 'norm! o'"})
map("i", "<M-i>", "<C-g>u<C-o>O", {desc = "Move current line down"})
map("i", "<M-S-o>", "<C-g>u<C-o>O", {desc = "Move current line down"})
map("i", "<C-M-i>", "<C-g>u<C-o>zk", {noremap = false, desc = "Insert line above"})
map("i", "<C-M-o>", "<C-g>u<C-o>zj", {noremap = false, desc = "Insert line below"})
map("i", "<M-s>", "<C-g>u<Esc>[s1z=`]a<C-g>u", {desc = "Fix last spelling mistake"})

map("i", "<F1>", "<C-R>=expand('%')<CR>", {desc = "Insert file name"})
map("i", "<F2>", "<C-R>=expand('%:p:h')<CR>", {desc = "Insert directory"})

wk.register(
    {
        ["<C-t>"] = "Insert one shift level at beginning of line",
        ["<C-d>"] = "Delete one shift level at beginning of line",
        ["<C-o>"] = "Run command, resume insert mode",
        ["<C-e>"] = "Insert char from line below",
        ["<C-y>"] = "Insert char from line above",
        ["<C-b>"] = "Move one char left",
        ["<C-f>"] = "Move one char right",
    },
    {mode = "i"}
)

--  ╭──────────────────────────────────────────────────────────╮
--  │                       Command Mode                       │
--  ╰──────────────────────────────────────────────────────────╯
map("c", "<C-b>", "<Left>")
map("c", "<C-f>", "<Right>")
map("c", "<C-,>", "<Home>")
map("c", "<C-.>", "<End>")
map("c", '<M-S-">', "<Home>")
map("c", "<M-'>", "<End>")
map("c", "<C-h>", "<BS>")
map("c", "<C-l>", "<Del>")
map("c", "<C-d>", "<Del>")
map("c", "<C-S-k>", "<Up>")
map("c", "<C-S-j>", "<Down>")
map("c", "<M-b>", "<C-Left>", {noremap = false, desc = "Move one word left"})
map("c", "<M-f>", "<C-Right>", {desc = "Move one word right", noremap = false})
map("c", "<C-S-h>", "<C-Left>", {desc = "Move one word left"})
map("c", "<C-S-l>", "<C-Right>", {desc = "Move one word right"})
map("c", "<F1>", "<C-r>=fnameescape(expand('%'))<CR>", {desc = "Insert current filename"})
map("c", "<F2>", "<C-r>=fnameescape(expand('%:p:h'))<CR>/", {desc = "Insert current directory"})
map("c", "*", [[getcmdline() =~ '.*\*\*$' ? '/*' : '*']], {expr = true, desc = "Insert glob"})
map(
    "c",
    "<C-o>",
    [[<C-\>egetcmdline()[:getcmdpos() - 2]<CR>]],
    {silent = true, desc = "Delete to end of line"}
)
map(
    "c",
    "<M-]>",
    [[<C-\>egetcmdline()[:getcmdpos() - 2]<CR>]],
    {silent = true, desc = "Delete to end of line"}
)

-- cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'

--  ╭──────────────────────────────────────────────────────────╮
--  │                       Normal Mode                        │
--  ╰──────────────────────────────────────────────────────────╯

map("n", ";q", [[q]], {cmd = true, desc = "Quit"})
map("n", ";w", [[update]], {cmd = true, desc = "Update file"})
map("n", "<BS>", "<C-^>", {desc = "Alternate file"})

map("n", "-", '"_', {desc = "Black hole register"})
map("x", "-", '"_', {desc = "Black hole register"})

-- ╓                                                          ╖
-- ║                          Macro                           ║
-- ╙                                                          ╜
map(
    "x",
    "@",
    ":<C-u>lua require('functions').macro_visual()<CR>",
    {silent = false, desc = "Exec macro visually"}
)
-- map(
--     "x",
--     "Q",
--     ":<C-u>lua require('functions').macro_visual('q')<CR>",
--     {silent = false, desc = "Exec macro 'q' visually"}
-- )

map({"n", "x"}, "<F2>", "@:", {desc = "Repeat last command"})
map({"n", "x"}, "<Leader>r.", "@:", {desc = "Repeat last command"})
map("x", ".", ":norm .<CR>", {desc = "Dot commands over visual blocks"})

-- Use qq to record, qq to stop, Q to play a macro (@q)
-- Use qk to record, qk|qq to stop, Q|@k to play a macro (@k)
-- map("n", "Q", "@q", {desc = "Play 'q' macro"})
map("n", "qq", it(fns.record_macro, "q"), {expr = true, desc = "Record macro 'q'"})
map("n", "ql", it(fns.record_macro, "l"), {expr = true, desc = "Record macro 'l'"})
map("n", "qk", it(fns.record_macro, "k"), {expr = true, desc = "Record macro 'k'"})

mpi.map("n", "q:", "<Nop>")
mpi.map("n", "q/", "<Nop>")
mpi.map("n", "q?", "<Nop>")
mpi.map("n", "q", "<Nop>", {silent = true})

map(
    "n",
    "zk",
    it(op.operator, {cb = "require'functions'.empty_line_above", motion = "l"}),
    {desc = "Insert empty line above"}
)
map(
    "n",
    "zj",
    it(op.operator, {cb = "require'functions'.empty_line_below", motion = "l"}),
    {desc = "Insert empty line below"}
)
map("n", "<C-,>,", fns.modify_line_end_delimiter(","), {desc = "Add comma to eol"})
map("n", "<C-,>;", fns.modify_line_end_delimiter(";"), {desc = "Add semicolon to eol"})

-- map("v", "J", ":m '>+1<CR>gv=gv")
-- map("v", "K", ":m '<-2<CR>gv=gv")
-- map("n", "<C-,>", "<Cmd>m +1<CR>")
-- map("n", "<C-.>", "<Cmd>m -2<CR>")

-- Use tab and shift tab to indent and de-indent code
map("n", "<Tab>", ">>", {desc = "Indent line"})
map("n", "<S-Tab>", "<<", {desc = "De-indent line"})
map("x", "<Tab>", ">><Esc>gv", {desc = "Indent line", silent = true})
map("x", "<S-Tab>", "<<<Esc>gv", {desc = "De-indent line", silent = true})
map("x", ">", ">gv", {desc = "Indent line"})
map("x", "<", "<gv", {desc = "De-indent line"})

map("n", "<Leader>b.", "<Cmd>ls!<CR>", {desc = "List buffers"})
map("n", "<Leader>b,", "<Cmd>CleanEmptyBuf<CR>", {desc = "Clean empty buffers"})
map("n", "<Leader>c;", it(fns.toggle_formatopts_r), {desc = "Opt: toggle comment cont."})
map("n", "<Leader>co", it(mpi.toggle_option, "cursorcolumn"), {desc = "Opt: toggle cursorcolumn"})
map("n", "<Leader>ci", it(mpi.toggle_option, "showtabline", {0, 2}), {desc = "Opt: toggle tabline"})
map("n", "<Leader>cv", it(mpi.toggle_option, "conceallevel", {0, 2}), {desc = "Opt: tog conceallvl"})

map("n", "<Leader>a;", "<Cmd>h pattern-overview<CR>", {desc = "Help: vim patterns"})
map("n", "<Leader>am", "<Cmd>h index<CR>", {desc = "Help: mapping overview"})
map("n", "<Leader>ab", "<Cmd>h builtin<CR>", {desc = "Help: builtin overview"})
map("n", "<Leader>ae", "<Cmd>h ex-commands<CR>", {desc = "Help: ex commands"})
map("n", "<Leader>aq", "<Cmd>h quickref<CR>", {desc = "Help: quickref"})

map("n", "<Leader>rt", "setl et", {cmd = true, desc = "Set expandtab"})
map("n", "<Leader>re", "setl et<CR><Cmd>retab", {cmd = true, desc = "Retab whole file"})
map("x", "<Leader>re", "retab", {cmd = true, desc = "Retab selection"})
map("n", "<Leader>cd", "lcd %:p:h<CR><Cmd>pwd", {cmd = true, desc = "'lcd' to filename directory"})

map("n", "c*", ":let @/='\\<'.expand('<cword>').'\\>'<CR>cgn", {desc = "cgn start `cword`"})
map("x", "C", '"cy:let @/=@c<CR>cgn', {desc = "Change text (dot repeatable)"})
map("n", "cc", [[getline('.') =~ '^\s*$' ? '"_cc' : 'cc']], {expr = true, noremap = true})

map("n", "<Leader>sg", ":%s//g<Left><Left>", {desc = "Global replace"})
map("n", "dM", [[:%s/<C-r>//g<CR>]], {desc = "Delete all search matches"})
map("n", "cm", [[:%s/<C-r>///g<Left><Left>]], {desc = "Change all matches"})

-- map("i", "dM", ":%g/<C-r>//d<CR>", {desc = "Delete all lines with search matches"})
-- map(
--     "i",
--     "z/",
--     [[/\%><C-r>=line("w0")-1<CR>l\%<<C-r>=line("w$")+1<CR>l]],
--     {desc = "Search in visible screen"}
-- )

map(
    "n",
    "z/",
    function()
        local scrolloff = vim.wo.scrolloff
        vim.wo.scrolloff = 0
        utils.normal("n", "m`HVL<Esc>/\\%V")

        vim.defer_fn(
            function()
                utils.normal("n", "``zz")
                vim.wo.scrolloff = scrolloff
            end,
            10
        )
    end,
    {desc = "Search in visible screen"}
)

map("n", "gI", it(utils.normal, "n", "`^"), {desc = "Goto last insert spot"})
map("n", "gA", it(utils.normal, "n", "ga"), {desc = "Get ASCII value"})
map("n", "<C-g>", "2<C-g>", {desc = "Show buffer info"})
-- map("n", "U", "<C-r>", {desc = "Redo action"})
map("n", "U", "<Plug>(RepeatRedo)", {desc = "Redo action"})
map("n", "<C-S-u>", "<Plug>(RepeatUndoLine)", {desc = "Undo entire line"})
map("n", ";U", "<Cmd>execute('later ' . v:count1 . 'f')<CR>", {desc = "Go to newer text state"})
map("n", ";u", "<Cmd>execute('earlier ' . v:count1 . 'f')<CR>", {desc = "Go to older state"})
wk.register(
    {
        ["g+"] = "Go to newer text state",
        ["g-"] = "Go to older text state",
    }
)

-- Yank mappings
map(
    "n",
    "yd",
    ":lua require('common.yank').yank_reg(vim.v.register, vim.fn.expand('%:p:h'))<CR>",
    {desc = "Copy directory"}
)
map(
    "n",
    "yn",
    ":lua require('common.yank').yank_reg(vim.v.register, vim.fn.expand('%:t'))<CR>",
    {desc = "Copy file name"}
)
map(
    "n",
    "yP",
    ":lua require('common.yank').yank_reg(vim.v.register, vim.fn.expand('%:p'))<CR>",
    {desc = "Copy full path"}
)

wk.register(
    {
        ["y"] = {[[v:lua.require'common.yank'.wrap()]], "Yank motion"},
        ["yw"] = {[[v:lua.require'common.yank'.wrap('iw')]], "Yank word (iw)"},
        ["yW"] = {[[v:lua.require'common.yank'.wrap('iW')]], "Yank word (iW)"},
        ["yl"] = {[[v:lua.require'common.yank'.wrap('aL')]], "Yank line (aL)"},
        ["yL"] = {[[v:lua.require'common.yank'.wrap('iL')]], "Yank line, no newline (iL)"},
        ["yu"] = {[[v:lua.require'common.yank'.wrap('au')]], "Yank unit (au)"},
        ["yh"] = {[[v:lua.require'common.yank'.wrap('ai')]], "Yank indent (ai)"},
        ["yp"] = {[[v:lua.require'common.yank'.wrap('ip')]], "Yank paragraph (ip)"},
        ["yo"] = {[[v:lua.require'common.yank'.wrap('iss')]], "Yank inside nearest object (iss)"},
        ["yO"] = {[[v:lua.require'common.yank'.wrap('ass')]], "Yank around nearest object (ass)"},
        ["yq"] = {[[v:lua.require'common.yank'.wrap('iq')]], "Yank inside quote (iq)"},
        ["yQ"] = {[[v:lua.require'common.yank'.wrap('aq')]], "Yank around quote (aq)"},
        ["gV"] = {[['`[' . strpart(getregtype(), 0, 1) . '`]']], "Reselect pasted text"},
    },
    {expr = true, remap = true}
)

map("n", "D", [["_D]], {desc = "Delete to end of line (blackhole)"})
map("n", "S", [[^"_D]], {desc = "Delete line (blackhole)"})
map("n", "Y", [[y$]], {desc = "Yank to EOL (without newline)"})
map("n", "x", [["_x]], {desc = "Cut letter (blackhole)"})
map("n", "vv", [[^vg_]], {desc = "Select entire line (without newline)"})
map("n", "<A-a>", [[VggoG]], {desc = "Select entire file"})
map("n", "cn", [[*``cgn]], {desc = "Change text; search forward"})
map("n", "cN", [[*``cgN]], {desc = "Change text; search backward"})
map("n", "g.", [[/\V<C-r>"<CR>cgn<C-a><Esc>]], {desc = "Last change init `cgn`"})
-- map("n", "J", [[mzJ`z]], {desc = "Join lines, keep curpos"})

wk.register({["&"] = "Repeat last substitution"})

map("x", "d", [["_d]], {desc = "Delete (blackhole)"})
map("x", "y", [[ygv<Esc>]], {desc = "Place the cursor at end of yank"})
map("x", "<C-g>", [[g<C-g>]], {desc = "Show word count"})
map("x", "&", ":&&<CR>", {desc = "Repeat last substitution"})
map("x", "z/", "<Esc>/\\%V", {desc = "Search visual selection"})
map("x", "g/", [[y/<C-R>"<CR>]], {desc = "Search for visual selection"})

map({"n", "x", "o"}, "H", "g^", {desc = "Start of line"})
map(
    "n",
    "L",
    [[<Cmd>norm! g$<CR><Cmd>exe (getline('.')[col('.') - 1] == ' ' ? 'norm! ge' : '')<CR>]],
    {desc = "End of line"}
)
-- map(
--     "x",
--     "L",
--     [[<Cmd>norm! g$<CR><Cmd>exe (getline('.')[col('.')] == ' ' ? 'norm! ge' : '')<CR>]],
--     {desc = "End of line"}
-- )
map("x", "L", "g_", {desc = "End of line"})
map("o", "L", "g$", {desc = "End of screen-line"})
-- fn.nr2char(fn.strgetchar(fn.getline('.'):sub(fn.col('.')), 0))

map("n", "j", [[v:count ? (v:count > 1 ? "m`" . v:count : '') . 'j' : 'gj']], {expr = true})
map("n", "k", [[v:count ? (v:count > 1 ? "m`" . v:count : '') . 'k' : 'gk']], {expr = true})
map("x", "j", "<Cmd>norm! gj<CR>", {desc = "Next screen-line", silent = true})
map("x", "k", "<Cmd>norm! gk<CR>", {desc = "Prev screen-line", silent = true})
map({"n", "x"}, "gj", "<Cmd>norm! j<CR>", {desc = "Next line", silent = true})
map({"n", "x"}, "gk", "<Cmd>norm! k<CR>", {desc = "Prev line", silent = true})

map("n", "<Down>", "<Cmd>norm! }<CR>", {desc = "Next blank line", silent = true})
map("n", "<Up>", "<Cmd>norm! {<CR>", {desc = "Prev blank line", silent = true})

map(
    {"n", "x", "o"},
    "0",
    [[v:lua.require'common.builtin'.jump0()]],
    {expr = true, desc = "Toggle first (non-blank) char"}
)

-- Quickfix
map("n", "[q", [[<Cmd>execute(v:count1 . 'cprev')<CR>]], {desc = "Prev item in quickfix"})
map("n", "]q", [[<Cmd>execute(v:count1 . 'cnext')<CR>]], {desc = "Next item in quickfix"})
map("n", "[Q", "<Cmd>cfirst<CR>", {desc = "First item in quickfix"})
map("n", "]Q", "<Cmd>clast<CR>", {desc = "Last item in quickfix"})
map("n", "]e", "<Cmd>cnewer<CR>", {desc = "Next quickfix list"})
map("n", "[e", "<Cmd>colder<CR>", {desc = "Prev quickfix list"})
map("n", "qi", "<Cmd>cc<CR>", {desc = "Show curr quickfix item"})
map("n", "qn", "<Cmd>cnfile<CR>", {desc = "Goto next file in quickfix"})
map("n", "qp", "<Cmd>cpfile<CR>", {desc = "Goto prev file in quickfix"})
-- Loclist
map("n", "qw", "<Cmd>lopen<CR>", {desc = "Open loclist"})
map("n", "[w", [[<Cmd>execute(v:count1 . 'lprev')<CR>]], {desc = "Prev item in loclist"})
map("n", "]w", [[<Cmd>execute(v:count1 . 'lnext')<CR>]], {desc = "Next item in loclist"})
map("n", "[W", "<Cmd>lfirst<CR>", {desc = "First item in loclist"})
map("n", "]W", "<Cmd>llast<CR>", {desc = "Last item in loclist"})
map("n", "]E", "<Cmd>lnewer<CR>", {desc = "Next loclist"})
map("n", "[E", "<Cmd>lolder<CR>", {desc = "Prev loclist"})
-- Tab
map("n", "[t", "<Cmd>tabp<CR>", {desc = "Previous tab"})
map("n", "]t", "<Cmd>tabn<CR>", {desc = "Next tab"})

-- map("x", "iz", [[:<C-u>keepj norm [zjv]zkL<CR>]], {desc = "Inside folding block"})
-- map("o", "iz", [[:norm viz<CR>]], {desc = "Inside folding block"})
-- map("x", "az", [[:<C-u>keepj norm [zv]zL<CR>]], {desc = "Around folding block"})
-- map("o", "az", [[:norm vaz<CR>]], {desc = "Around folding block"})

map("x", "iz", [[<Cmd>keepj norm [zjo]zkL<CR>]], {desc = "Inside folding block"})
map("o", "iz", [[:norm viz<CR>]], {desc = "Inside folding block"})
map("x", "az", [[<Cmd>keepj norm [zo]zjLV<CR>]], {desc = "Around fold block"})
map("o", "az", [[:norm vaz<CR>]], {desc = "Around fold block"})

-- map("x", "aZ", [[<Cmd>keepj norm [zo]zL<CR>]], {desc = "Around fold block (exclude last line)"})
-- map("o", "aZ", [[:norm vaZ<CR>]], {desc = "Around fold block (exclude last line)"})

map("n", "<LocalLeader>z", [[zMzvzz]], {noremap = false, desc = "Refocus folds"})
map(
    "n",
    "zz",
    ([[(winline() == (winheight(0) + 1)/ 2) ?  %s : %s]]):format(
        [['zt' : (winline() == 1) ? 'zb']],
        [['zz']]
    ),
    {expr = true, desc = "Center or top current line"}
)

-- Window/Buffer
-- Grepping for keybindings is more difficult with this
map("n", "<C-w><C-v>", it(builtin.split_lastbuf, true), {desc = "Split: last buffer (vert)"})
map("n", "<C-w><C-,>", builtin.split_lastbuf, {desc = "Split: last buffer (horiz)"})
map("n", "<C-w><C-.>", it(builtin.split_lastbuf, true), {desc = "Split: last buffer (vert)"})
map("n", "<C-w><lt>", "<C-w>t<C-w>K", {desc = "Change vertical to horizontal"})
map("n", "<C-w>>", "<C-w>t<C-w>H", {desc = "Change horizontal to vertical"})
map("n", "<C-w>;", [[<Cmd>lua require('common.win').go2recent()<CR>]], {desc = "Focus last window"})
map("n", "<C-w>X", W.win_close_all_floating, {desc = "Close all floating windows"})
map("n", "<C-w><C-w>", W.win_focus_floating, {desc = "Focus floating window"})
map("n", "<C-w>T", "<Cmd>tab sp<CR>", {desc = "Open curwin in tab"})
map("n", "<C-w>O", "<Cmd>tabo<CR>", {desc = "Close all tabs except current"})
map("n", "<C-w>0", "<C-w>=", {desc = "Equally high and wide"})
-- H = {"<C-w>t<C-w>K", "Change vertical to horizontal"},
-- V = {"<C-w>t<C-w>H", "Change horizontal to vertical"},

map("n", "qc", qf.close, {desc = "Close quickfix"})
map("n", "qd", W.win_close_diff, {desc = "Close diff"})
map("n", "qt", [[tabc]], {cmd = true, desc = "Close tab"})
map(
    "n",
    "qD",
    [[<Cmd>tabdo lua require('common.utils').close_diff()<CR><Cmd>noa tabe<Bar> noa bw<CR>]],
    {desc = "Close diff (tab)"}
)
map("n", "qC", qfext.conflicts2qf, {desc = "Conflicts to quickfix"})
map("n", "qs", builtin.spellcheck, {desc = "Spell errors to quickfix"})
map("n", "qj", builtin.jumps2qf, {desc = "Jumps to quickfix"})
map("n", "qz", builtin.changes2qf, {desc = "Changes to quickfix"})
map("n", "<A-u>", builtin.switch_lastbuf, {desc = "Switch to last buffer"})

map("n", "<Leader>fk", it(qfext.outline, {fzf = true}), {desc = "Quickfix outline (coc fzf)"})
map("n", "<Leader>ff", qfext.outline, {desc = "Quickfix outline (coc)"})
map("n", "<Leader>fw", qfext.outline_treesitter, {desc = "Quickfix outline (treesitter)"})
map("n", "<Leader>fa", qfext.outline_aerial, {desc = "Quickfix outline (aerial)"})
map(
    "n",
    "<Leader>fv",
    it(qfext.outline, {filter_kind = false}),
    {desc = "Quickfix outline all (coc)"}
)
map(
    "n",
    "<Leader>fV",
    it(qfext.outline, {filter_kind = false, fzf = true}),
    {desc = "Quickfix outline all (coc fzf)"}
)

map(
    "n",
    "<Leader>fi",
    D.ithunk(
        qfext.outline,
        {
            filter_kind = {
                "Class",
                "Constructor",
                "Enum",
                "Function",
                "Interface",
                "Method",
                "Module",
                "Package",
                "Struct",
                "Type",
            },
        }
    ),
    {desc = "Quickfix outline func/if/for (coc)"}
)

map(
    "n",
    "<Leader>fm",
    it(
        qfext.outline,
        {
            filter_kind = {
                "Class",
                "Constructor",
                "Enum",
                "Function",
                "Interface",
                "Method",
                "Module",
                "Object",
                "Package",
                "Struct",
                "Type",
                -- "File",
                -- "TypeParameter",
                -- "Event"
            },
        }
    ),
    {desc = "Quickfix outline more (coc)"}
)
-- ]]] === General mappings ===

-- ================== Spelling ================== [[[
map("n", "<Leader>ss", "<Cmd>setl spell!<CR>", {desc = "Spell: toggle"})
map("n", "<Leader>sn", "]s", {desc = "Spell: next mistake"})
map("n", "<Leader>sp", "[s", {desc = "Spell: prev mistake"})
map("n", "<Leader>sa", "zg", {desc = "Spell: add to list"})
map("n", "<Leader>s?", "z=", {desc = "Spell: view corrections"})
map("n", "<Leader>su", "zuw", {desc = "Spell: undo list add"})
map("n", "<Leader>sl", "<c-g>u<Esc>[s1z=`]a<c-g>u", {desc = "Spell: correct next"})
-- ]]] === Spelling ===

-- ==================== Other =================== [[[
map("n", "<Leader>ec", "<cmd>CocConfig<CR>", {desc = "Edit: coc-settings.json"})
map("n", "<Leader>ev", "e $NVIMRC", {cmd = true, desc = "Edit: nvim/init.lua"})
map("n", "<Leader>ez", "e $ZDOTDIR/.zshrc", {cmd = true, desc = "Edit: .zshrc"})
map("n", "<Leader>ep", "e $NVIMD/lua/plugins.lua", {cmd = true, desc = "Edit: plugins.lua"})
map("n", "<Leader>sv", "luafile $NVIMRC", {cmd = true, desc = "Source nvim/init.lua"})
-- ]]] === Other ===

-- ============== Function Mappings ============= [[[
-- Allow the use of extended function keys
local fkey = 1
for i = 13, 24, 1 do
    map({"n", "x"}, ("<F%d>"):format(i), ("<S-F%d>"):format(fkey), {silent = true, desc = "ignore"})
    fkey = fkey + 1
end

fkey = 1
for i = 25, 36, 1 do
    map({"n", "x"}, ("<F%d>"):format(i), ("<C-F%d>"):format(fkey), {silent = true, desc = "ignore"})
    fkey = fkey + 1
end
-- ]]] === Function Mappings ===

-- map("n", "<C-o>", [[<C-o>]], {desc = "Previous item jumplist"})
-- map("n", "<C-i>", [[<C-i>]], {desc = "Next item jumplist"})

-- Keep focused in center of screen when searching
-- map("n", "n", "(v:searchforward ? 'nzzzv' : 'Nzzzv')", { expr = true })
-- map("n", "N", "(v:searchforward ? 'Nzzzv' : 'nzzzv')", { expr = true })

-- map("x", "c", [["_c]], {desc = "Change (blackhole)"})
-- map("x", "<C-CR>", [[g<C-g>]], {desc = "Show word count"})
-- map("n", "j", [[(v:count > 1 ? 'm`' . v:count : '') . 'j']], {noremap = true, expr = true})
-- map("n", "k", [[(v:count > 1 ? 'm`' . v:count : '') . 'k']], {noremap = true, expr = true})
-- map({"n", "x", "o"}, "H", "g0", {desc = "Start of screen-line"})
-- map({"n", "x", "o"}, "L", "g_", {desc = "End of line"})

return M
