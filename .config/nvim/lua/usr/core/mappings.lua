---@module 'usr.core.mappings'
local M = {}

local F = Rc.F
-- local utils = Rc.shared.utils
local it = F.ithunk

local lazy = require("usr.lazy")
local W = Rc.api.win

local lib = Rc.lib
local op = lib.op
local builtin = lib.builtin
local qf = lib.qf
local qfext = lazy.require("usr.plugs.qfext") ---@module 'usr.plugs.qfext'
-- local win = lazy.require("usr.plugs.win") ---@module 'usr.plugs.win'

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

-- map("i", "<C-r>", "<C-g>u<C-r>", {desc = "Show registers"})
-- map("i", "<C-o>U", "<C-g>u<C-o><Cmd>redo<CR>", {desc = "Redo"})
-- map("i", "<C-Left>", [[<C-o>u]], {desc = "Undo"})
-- map("i", "<C-Right>", [[<C-o><Cmd>norm! ".p<CR>]], {desc = "Redo"})


-- map("n", "<C-S-j>", "<Cmd>m +1<CR>", {desc = "Move line up"})
-- map("n", "<C-S-k>", "<Cmd>m -2<CR>", {desc = "Move line down"})
-- map("i", "<C-S-i>", "<C-o><Cmd>m -2<CR>", {desc = "Move line up"})
-- map("i", "<C-S-o>", "<C-o><Cmd>m +1<CR>", {desc = "Move line down"})
map("n", "<C-S-k>", ":m .-2<CR>==", {desc = "Move line up"})
map("n", "<C-S-j>", ":m .+1<CR>==", {desc = "Move line down"})
map("i", "<C-S-i>", "<Esc>:m -2<CR>==gi", {desc = "Move line up"})
map("i", "<C-S-o>", "<Esc>:m +1<CR>==gi", {desc = "Move line down"})
map("x", "J", ":m '>+1<CR>gv=gv", {desc = "Move selected text down"})
map("x", "K", ":m '<-2<CR>gv=gv", {desc = "Move selected text up"})

map("i", ",", ",<C-g>u", {desc = "ignore"})
map("i", ".", ".<C-g>u", {desc = "ignore"})
map("i", "!", "!<C-g>u", {desc = "ignore"})
map("i", "?", "?<C-g>u", {desc = "ignore"})

-- map("i", "<CR>", "<CR><C-g>u", {desc = "ignore"})
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
-- FIX: Doesn't redraw with noice
map("c", "<C-o>", [[<C-\>egetcmdline()[:getcmdpos() - 2]<CR>]], {desc = "Delete to end of line"})
map("c", "<M-]>", [[<C-\>egetcmdline()[:getcmdpos() - 2]<CR>]], {desc = "Delete to end of line"})
-- map("c", "<M-]>", [[<C-\>egetcmdline()[:getcmdpos() - 2]<Bar>redraw!<CR>]], {desc = "Delete to end of line"})
map("c", "<F1>", "<C-r>=fnameescape(expand('%'))<CR>", {desc = "Insert current filename"})
map("c", "<F2>", "<C-r>=fnameescape(expand('%:p:h'))<CR>/", {desc = "Insert current directory"})
map(
    "c",
    "<M-/>",
    [[\v^(()@!.)*$<Left><Left><Left><Left><Left><Left><Left>]],
    {desc = "Inverse search"}
)

-- nice, but hangs, and nowait doesn't work
-- map("c", "*", [[getcmdline() =~ '.*\*\*$' ? '/*' : '*']], {expr = true, desc = "Insert glob"})
-- map("c", "%%", [[getcmdtype() == ':' ? expand('%:h').'/' : '%%']], {expr = true, desc = "Insert current dir"})

--  ╭──────────────────────────────────────────────────────────╮
--  │                       Normal Mode                        │
--  ╰──────────────────────────────────────────────────────────╯

map("n", "ZZ", [[v:count ? ':<C-u>xa!<CR>' : '@_ZZ']], {expr = true, desc = "ignore"})
map("n", "ZQ", [[v:count ? ':<C-u>qa!<CR>' : '@_ZQ']], {expr = true, desc = "ignore"})
map("n", ";q", [[q]], {cmd = true, desc = "Quit"})
-- map("n", ";w", [[update]], {cmd = true, desc = "Update file"})
map("n", ";w", it(lib.fn.save_change_marks, "update"), {desc = "Update file"})
map("n", ";W", it(lib.fn.save_change_marks, "w ++p"), {desc = "Write file, create dir"})
map("n", "<BS>", "<C-^>", {desc = "Alternate file"})

map("n", "-", '"_', {desc = "Black hole register"})
map("x", "-", '"_', {desc = "Black hole register"})

map("n", "v", "m`v", {desc = "ignore"})
map("n", "V", "m`V", {desc = "ignore"})
map("n", "<C-v>", "m`<C-v>", {desc = "ignore"})

-- ╓                                                          ╖
-- ║                          Macro                           ║
-- ╙                                                          ╜
map(
    "x",
    "@",
    ":<C-u>lua require('functions').macro_visual()<CR>",
    {silent = false, desc = "Exec macro visually"}
)

-- Use qq to record, qq to stop, Q to play a macro (@q)
-- Use qQ to append, qq to stop
-- Use qk to record, qk|qq to stop, Q|@k to play a macro (@k)
map("n", "Q", "@q", {desc = "Play 'q' macro"})
map("n", "qq", it(lib.fn.record_macro, "q"), {expr = true, desc = "Record macro 'q'"})
map("n", "ql", it(lib.fn.record_macro, "l"), {expr = true, desc = "Record macro 'l'"})
map("n", "qk", it(lib.fn.record_macro, "k"), {expr = true, desc = "Record macro 'k'"})

Rc.api.del_keymap("n", "q")
Rc.api.del_keymap("n", "q:")
Rc.api.del_keymap("n", "q/")
Rc.api.del_keymap("n", "q?")

map(
    "n",
    "zk",
    it(op.operator, {cb = "require'usr.lib.fn'.empty_line_above", motion = "l"}),
    {desc = "Insert empty line above"}
)
map(
    "n",
    "zj",
    it(op.operator, {cb = "require'usr.lib.fn'.empty_line_below", motion = "l"}),
    {desc = "Insert empty line below"}
)
map("n", "<C-,>,", lib.fn.modify_line_end_delimiter(","), {desc = "Add comma to eol"})
map("n", "<C-,>;", lib.fn.modify_line_end_delimiter(";"), {desc = "Add semicolon to eol"})
map("n", "<Leader>ha", lib.fn.diffsaved, {desc = "Diff: saved"})
map("n", ";p", "Profile", {cmd = true, desc = "Start profiling"})

-- Use tab and shift tab to indent and de-indent code
map("n", "<Tab>", ">>", {desc = "Indent line"})
map("n", "<S-Tab>", "<<", {desc = "De-indent line"})
map("x", "<Tab>", ">><Esc>gv", {desc = "Indent line", silent = true})
map("x", "<S-Tab>", "<<<Esc>gv", {desc = "De-indent line", silent = true})
map("x", ">", ">gv", {desc = "Indent line"})
map("x", "<", "<gv", {desc = "De-indent line"})

map("n", "<Leader>w.", "Wins", {cmd = true, desc = "List windows"})
map("n", "<Leader>ls", "ls!", {cmd = true, desc = "List buffers"})
map("n", "<Leader>b.", "ls!", {cmd = true, desc = "List buffers"})
map("n", "<Leader>b,", "BufCleanEmpty", {cmd = true, desc = "Clean empty buffers"})
map("n", "<Leader>b<lt>", "BufCleanHidden", {cmd = true, desc = "Clean hidden buffers"})
map("n", "<Leader>c;", it(lib.fn.toggle_formatopts_r), {desc = "Opttog: comment cont"})
map("n", "<Leader>co", it(Rc.api.opt.toggle_option, "cuc"), {desc = "Opttog: cursorcolumn"})
map("n", "<Leader>ci", it(Rc.api.opt.toggle_option, "stal", {0, 2}), {desc = "Opttog: tabline"})
map("n", "<Leader>cv", it(Rc.api.opt.toggle_option, "cole", {0, 2}), {desc = "Opttog: conceallevel"})
map(
    "n",
    "<Leader>cx",
    [[exec 'syntax '.(exists('g:syntax_on') ? 'off' : 'enable')]],
    {cmd = true, desc = "Opttog: syntax"}
)

-- :set cursorcolumn! cursorcolumn?<CR>
-- :exec "set fo"..(stridx(&fo, 'r') == -1 ? "+=ro" : "-=ro").." fo?"<CR>
-- :exec "set stal="..(&stal == 2 ? "0" : "2").." stal?"<CR>
-- :exec "set cole="..(&cole == 2 ? "0" : "2").." cole?"<CR>

map("n", "<Leader>a;", "h pattern-overview", {cmd = true, desc = "Help: vim patterns"})
map("n", "<Leader>ab", "h builtin-function-list", {cmd = true, desc = "Help: builtin overview"})
map("n", "<Leader>aB", "h function-list", {cmd = true, desc = "Help: function overview"})
map("n", "<Leader>am", "h index", {cmd = true, desc = "Help: all overview"})
map("n", "<Leader>ae", "exusage", {cmd = true, desc = "Help: ex commands"})
map("n", "<Leader>an", "viusage", {cmd = true, desc = "Help: normal mode"})
map("n", "<Leader>ai", "h insert-index", {cmd = true, desc = "Help: insert mode"})
map("n", "<Leader>aQ", "h quickref", {cmd = true, desc = "Help: quickref"})
map("n", "<Leader>ag", "h Q_fl", {cmd = true, desc = "Help: q args"})
map("n", "<Leader>au", "h Q_bu", {cmd = true, desc = "Help: q buffer"})
map("n", "<Leader>aw", "h Q_wi", {cmd = true, desc = "Help: q window"})
map("n", "<Leader>at", "h tab-page-commands", {cmd = true, desc = "Help: tabpage"})
map("n", "<Leader>af", "h Q_fo", {cmd = true, desc = "Help: q folding"})
map("n", "<Leader>ac", "h Q_ce", {cmd = true, desc = "Help: q cli"})
map("n", "<Leader>aq", "h Q_qf", {cmd = true, desc = "Help: q quickfix"})
map("n", "<Leader>ao", "h Q_op", {cmd = true, desc = "Help: q options"})

map("n", "<Leader>rt", "setl et", {cmd = true, desc = "Set expandtab"})
map("n", "<Leader>re", "setl et<CR><Cmd>retab", {cmd = true, desc = "Retab whole file"})
map("x", "<Leader>re", ":retab<CR>", {desc = "Retab selection"})
map("n", "<Leader>cd", "lcd %:p:h<CR><Cmd>pwd", {cmd = true, desc = "'lcd' to filename directory"})

map("n", "g:", ":lua =", {desc = "Start Lua print"})
map("n", "gb:", ":Bufferize lua p(", {desc = "Start Bufferize Lua"})
map("n", "c:", ":lua require('", {desc = "Start Lua require"})

-- map("n", "gn", ":normal n.<CR>:<C-U>call repeat#set('n.')<CR>", {desc = "Repeat edit next matches"})
map("n", "c*", [[:let @/='\\<'.expand('<cword>').'\\>'<CR>cgn]], {desc = "cgn start `cword`"})
map("x", "C", [["cy:let @/=@c<CR>cgn]], {desc = "Change text (dot repeat)"})
map("n", "cn", [[*``cgn]], {desc = "Change text; search forward"})
map("n", "cN", [[*``cgN]], {desc = "Change text; search backward"})
map("n", "g.", [[/\V<C-r>"<CR>cgn<C-a><Esc>]], {desc = "Last change init `cgn`"})
map("n", "cc", [[getline('.') =~# '^\s*$' ? '"_cc' : 'cc']], {expr = true})
map("x", "I", [[mode() =~# '[vV]' ? '<C-v>^o^I' : 'I']], {expr = true, desc = "Nice block"})
map("x", "A", [[mode() =~# '[vV]' ? '<C-v>0o$A' : 'A']], {expr = true, desc = "Nice block"})
map("n", "gM", [[(virtcol('$') / 2) . '<Bar>']], {expr = true})

map("n", "<Leader>sg", [[:%s//g<Left><Left>]], {desc = "Global replace"})
map("n", "cM", [[:%s/<C-r>///g<Left><Left>]], {desc = "Change all matches"})
map("n", "dM", [[:%s/<C-r>//g<CR>]], {desc = "Delete all search matches"})
-- map("n", "dM", [[:%g/<C-r>//d<CR>]], {desc = "Delete all search matches"})

map({"n", "x"}, "<F2>", "@:", {desc = "Repeat last command"})
map({"n", "x"}, "<Leader>r.", "@:", {desc = "Repeat last command"})
map("x", ".", ":norm .<CR>", {desc = "Dot commands visually"})

wk.register({["g&"] = "Repeat subst with search patt"})
map("n", "z&", [[:%&&<CR>]], {desc = "Repeat last subst on whole file"})
map({"n", "x"}, "&", [[:&&<CR>]], {desc = "Repeat last substitution"})
map("x", "z/", [[<Esc>/\%V]], {desc = "Search visual selection"})
map("x", "s/", [[<Esc>:s/\%V/g<Left><Left>]], {desc = "Substitute in visual selection"})
map("x", "g/", [[y/<C-R>"<CR>]], {desc = "Search for visual selection"})
map(
    "n",
    "z/",
    [[:let old=&so<Bar>setl so=0<CR>m`HVL<Esc>:let &so=old<CR>``<C-y>/\%V]],
    {desc = "Search in visible screen"}
)
map(
    "n",
    "gW",
    [[getline('.')[strlen(getline('.'))-1] == '\' ? '$xJ' : 'J']],
    {expr = true, desc = "Join lines & remove backslash"}
)

-- [[keepp s/\s*\%#\s*/\r/e <Bar> norm! ==^<CR>]],
map("n", "X", [[i<C-j><Esc>k$]], {desc = "Split line"})
map(
    "n",
    "<M-->",
    [[exe min([winheight('%'),line('$')]).'wincmd _'<Bar>setl winfixheight]],
    {cmd = true, desc = "Fit curwin (vert) to the buffer text"}
)
map(
    "x",
    "<M-->",
    [[<Esc><Cmd>exe (line("'>") - line("'<") + 1).'wincmd _'<Bar>setl winfixheight<CR>]],
    {desc = "Fit curwin (vert) to selected text"}
)

map("n", "gI", "`^", {desc = "Goto last insert spot"})
map("n", "gA", "ga", {desc = "Get ASCII value"})
map("n", "<C-g>", [[2<C-g>]], {desc = "Show buffer info"})
map("x", "<C-g>", [[g<C-g>]], {desc = "Show word count"})

-- map("n", "u", "<Plug>(RepeatUndo)", {desc = "Undo action"})
-- map("n", "U", "<Plug>(RepeatRedo)", {desc = "Redo action"})
-- map("n", "<C-S-u>", "<Plug>(RepeatUndoLine)", {desc = "Undo entire line"})
-- map("n", "u", "<Plug>(highlightedundo-undo)", {desc = "Undo action"})
-- map("n", "U", "<Plug>(highlightedundo-redo)", {desc = "Redo action"})
-- map("n", "<C-S-u>", "<Plug>(highlightedundo-Undo)", {desc = "Undo entire line"})
map("n", ";U", "<Cmd>execute('later ' . v:count1 . 'f')<CR>", {desc = "Go to newer text state"})
map("n", ";u", "<Cmd>execute('earlier ' . v:count1 . 'f')<CR>", {desc = "Go to older state"})
-- wk.register({
--     ["g+"] = {"<Plug>(highlightedundo-gplus)", "Go to newer text state"},
--     ["g-"] = {"<Plug>(highlightedundo-gminus)", "Go to older text state"},
-- })

-- Yank mappings
map(
    "n",
    "yd",
    "require('usr.lib.yank').yank_reg(vim.v.register, '%:p:h')",
    {lcmd = true, desc = "Copy directory"}
)
map(
    "n",
    "yn",
    "require('usr.lib.yank').yank_reg(vim.v.register, '%:t')",
    {lcmd = true, desc = "Copy file name"}
)
map(
    "n",
    "yP",
    "require('usr.lib.yank').yank_reg(vim.v.register, '%:p')",
    {lcmd = true, desc = "Copy full path"}
)

wk.register(
    {
        ["y"] = {[[v:lua.require'usr.lib.yank'.wrap()]], "Yank motion"},
        ["yw"] = {[[v:lua.require'usr.lib.yank'.wrap('iw')]], "Yank word (iw)"},
        ["yW"] = {[[v:lua.require'usr.lib.yank'.wrap('iW')]], "Yank word (iW)"},
        ["yl"] = {[[v:lua.require'usr.lib.yank'.wrap('aL')]], "Yank line (aL)"},
        ["yL"] = {[[v:lua.require'usr.lib.yank'.wrap('iL')]], "Yank line, no newline (iL)"},
        ["yu"] = {[[v:lua.require'usr.lib.yank'.wrap('au')]], "Yank unit (au)"},
        ["yh"] = {[[v:lua.require'usr.lib.yank'.wrap('ai')]], "Yank indent (ai)"},
        ["yp"] = {[[v:lua.require'usr.lib.yank'.wrap('ip')]], "Yank paragraph (ip)"},
        ["yo"] = {[[v:lua.require'usr.lib.yank'.wrap('iss')]], "Yank inside nearest object (iss)"},
        ["yO"] = {[[v:lua.require'usr.lib.yank'.wrap('ass')]], "Yank around nearest object (ass)"},
        ["yq"] = {[[v:lua.require'usr.lib.yank'.wrap('iq')]], "Yank inside quote (iq)"},
        ["yQ"] = {[[v:lua.require'usr.lib.yank'.wrap('aq')]], "Yank around quote (aq)"},
        ["gV"] = {[['`[' . strpart(getregtype(), 0, 1) . '`]']], "Reselect pasted text"},
    },
    {expr = true, remap = true}
)

map("x", "gA", [[<Esc>`.``gvP``P]], {desc = "Swap prev selected w current"})
map("n", "d", '"xd', {desc = "Delete"})
map("n", "D", [["xD]], {desc = "Delete to end of line"})
map("n", "S", [[^"xD]], {desc = "Delete line"})
map("n", "x", [["_x]], {desc = "Cut letter (blackhole)"})
map("n", "'x", [["x]], {desc = "Register: x"})
map("n", "Y", [[y$]], {desc = "Yank to EOL (without newline)"})
map("n", "vv", [[^vg_]], {desc = "Select entire line (without newline)"})
map("n", "<A-a>", [[ggVG]], {desc = "Select entire file"})
-- map("n", "J", [[mzJ`z]], {desc = "Join lines, keep curpos"})

map("x", "d", [["_d]], {desc = "Delete (blackhole)"})
map("x", "y", [[ygv<Esc>]], {desc = "Place the cursor at end of yank"})
map("x", "p", [[p<Cmd>let @+ = @0<CR><Cmd>let @" = @0<CR>]], {desc = "Swap clipboard with pasted"})
map("x", "P", [[P<Cmd>let @+ = @0<CR><Cmd>let @" = @0<CR>]], {desc = "Swap clipboard with pasted"})

map({"n", "x", "o"}, "H", "g^", {desc = "Start of line"})
map(
    "n",
    "L",
    [[v:count > 0 ? '@_1g_' : 'g$'.(getline('.')[strlen(getline('.'))-1] == ' ' ? 'ge' : '')]],
    {expr = true, desc = "End of line"}
)

map("x", "L", "mode() =~# '[vV]' ? 'g_' : '$'", {expr = true, desc = "End of line"})
map("o", "L", "g$", {desc = "End of screen-line"})

map("n", "j", [[v:count ? (v:count > 1 ? "m`" . v:count : '') . 'j' : 'gj']], {expr = true})
map("n", "k", [[v:count ? (v:count > 1 ? "m`" . v:count : '') . 'k' : 'gk']], {expr = true})
map("x", "j", "gj", {desc = "Next screen-line"})
map("x", "k", "gk", {desc = "Prev screen-line"})
map({"n", "x"}, "gj", "j", {desc = "Next line"})
map({"n", "x"}, "gk", "k", {desc = "Prev line"})

map({"n", "x", "o"}, "<LocalLeader>L", "L", {desc = "Bottom of screen"})
map({"n", "x", "o"}, "<LocalLeader>H", "H", {desc = "Top of screen"})
map("n", "<Down>", "}", {desc = "Next blank line"})
map("n", "<Up>", "{", {desc = "Prev blank line"})

map(
    {"n", "x", "o"},
    "0",
    [[v:lua.require'usr.lib.builtin'.jump0()]],
    {expr = true, desc = "Toggle first (non-blank) char"}
)

map("x", "iz", [[<Cmd>keepj norm [zjo]zkL<CR>]], {desc = "Inside foldblock"})
map("o", "iz", [[:norm viz<CR>]], {desc = "Inside foldblock"})
map("x", "az", [[<Cmd>keepj norm [zo]zjLV<CR>]], {desc = "Around foldblock"})
map("o", "az", [[:norm vaz<CR>]], {desc = "Around foldblock"})

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
map(
    "n",
    "zt",
    [[(v:count > 0 ? '@_zt'.v:count.'<C-y>' : 'zt')]],
    {expr = true, desc = "Top line [count]"}
)
map(
    "n",
    "zb",
    [[(v:count > 0 ? '@_zb'.v:count.'<C-e>' : 'zb')]],
    {expr = true, desc = "Bottom line [count]"}
)

-- Window/Buffer
map("n", "<C-w><C-v>", it(builtin.split_lastbuf, true), {desc = "Split: last buffer (vert)"})
map("n", "<C-w><C-,>", builtin.split_lastbuf, {desc = "Split: last buffer (horiz)"})
map("n", "<C-w><C-.>", it(builtin.split_lastbuf, true), {desc = "Split: last buffer (vert)"})
map("n", "<C-w><lt>", "<C-w>t<C-w>K", {desc = "Change vertical to horizontal"})
map("n", "<C-w>>", "<C-w>t<C-w>H", {desc = "Change horizontal to vertical"})
map(
    "n",
    "<C-w>;",
    [[require('usr.plugs.win').go2recent()]],
    {lcmd = true, desc = "Focus last window"}
)
map("n", "<C-w>X", W.win_close_all_floating, {desc = "Close all floating windows"})
map("n", "<C-w><C-w>", W.win_focus_floating, {desc = "Focus floating window"})
map("n", "<C-w>a", W.win_switch_alt, {desc = "Switch any window"})
map("n", "<C-w>T", "<Cmd>tab sp<CR>", {desc = "Open curwin in tab"})
map("n", "<C-w>O", "<Cmd>tabo<CR>", {desc = "Close all tabs except current"})
map("n", "<C-w>0", "<C-w>=", {desc = "Equally high and wide"})
-- map("n", "qu", lib.fn.toggle_netrw, {desc = "Toggle netrw"})
-- H = {"<C-w>t<C-w>K", "Change vertical to horizontal"},
-- V = {"<C-w>t<C-w>H", "Change horizontal to vertical"},

-- Quickfix
map("n", "[q", [[execute(v:count1 . 'cprev')]], {cmd = true, desc = "QF: prev item"})
map("n", "]q", [[execute(v:count1 . 'cnext')]], {cmd = true, desc = "QF: next item"})
map("n", "[Q", "cfirst", {cmd = true, desc = "QF: first item"})
map("n", "]Q", "clast", {cmd = true, desc = "QF: last item"})
map("n", "[e", "colder", {cmd = true, desc = "QF: prev quickfix list"})
map("n", "]e", "cnewer", {cmd = true, desc = "QF: next quickfix list"})
map("n", "qp", "cpfile", {cmd = true, desc = "QF: goto prev file"})
map("n", "qn", "cnfile", {cmd = true, desc = "QF: goto next file"})
map("n", "qi", "cc", {cmd = true, desc = "QF: view error"})
map("n", "qX", "setqflist([], 'f')", {ccmd = true, desc = "QF: clear all"})
map("n", "qc", qf.close, {desc = "Close quickfix"})
map(
    "n",
    "<M-e>",
    [['@_:'.(&bt !=# 'quickfix'<Bar><Bar>]] ..
    [[!empty(getloclist(0)) ? 'lclose<Bar>bo cope' : 'ccl<Bar>bo lop')]] ..
    [[.(v:count ? '<Bar>wincmd L' : '').'<CR>']],
    {expr = true, desc = "Open or switch QF to loclist"}
)
-- Loclist
map("n", "qw", "lopen", {cmd = true, desc = "Open loclist"})
map("n", "[w", [[execute(v:count1 . 'lprev')]], {cmd = true, desc = "LOCL: prev item"})
map("n", "]w", [[execute(v:count1 . 'lnext')]], {cmd = true, desc = "LOCL: next item"})
map("n", "[W", "lfirst", {cmd = true, desc = "LOCL: first item"})
map("n", "]W", "llast", {cmd = true, desc = "LOCL: last item"})
map("n", "[E", "lolder", {cmd = true, desc = "LOCL: prev loclist"})
map("n", "]E", "lnewer", {cmd = true, desc = "LOCL: next loclist"})
-- Tab
map("n", "[t", "tabp", {cmd = true, desc = "Prev tab"})
map("n", "]t", "tabn", {cmd = true, desc = "Next tab"})
map("n", "qt", "tabc", {cmd = true, desc = "Close tab"})

map(
    "n",
    "dO",
    [[:set <C-R>=(&dip =~# 'iwhiteall') ? 'dip-=iwhiteall' : 'dip+=iwhiteall'<CR><CR>]],
    {desc = "Diff: toggle ignore whitespace"}
)
map("n", "qd", W.win_close_diff, {desc = "Close diff"})
-- map("n", "qd", [[<C-w><C-o>]], {desc = "Close diff"})
map(
    "n",
    "qD",
    [[<Cmd>tabdo lua require('usr.api.win').win_close_diff()<CR><Cmd>noa tabe<Bar> noa bw<CR>]],
    {desc = "Close diff (tab)"}
)
map("n", "qC", qfext.conflicts2qf, {desc = "Conflicts to quickfix"})
map("n", "qs", builtin.spellcheck, {desc = "Spell errors to quickfix"})
map("n", "qj", builtin.jumps2qf, {desc = "Jumps to quickfix"})
map("n", "qz", builtin.changes2qf, {desc = "Changes to quickfix"})
map("n", "<A-u>", builtin.switch_lastbuf, {desc = "Switch to last buffer"})

map("n", "<Leader>fk", it(qfext.outline, {fzf = true}), {desc = "QF: outline (coc fzf)"})
map("n", "<Leader>ff", qfext.outline, {desc = "QF: outline (coc)"})
map("n", "<Leader>fw", qfext.outline_treesitter, {desc = "QF: outline (treesitter)"})
map("n", "<Leader>fa", qfext.outline_aerial, {desc = "QF: outline (aerial)"})
map("n", "<Leader>fv", it(qfext.outline, {filter_kind = false}), {desc = "QF: outline all (coc)"})
map(
    "n",
    "<Leader>fV",
    it(qfext.outline, {filter_kind = false, fzf = true}),
    {desc = "QF: outline all (coc fzf)"}
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
    {desc = "QF: outline more (coc)"}
)
map(
    "n",
    "<Leader>fi",
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
                "Package",
                "Struct",
                "Type",
            },
        }
    ),
    {desc = "QF: outline fn/if/for (coc)"}
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
map("n", "<Leader>ec", "CocConfig", {cmd = true, desc = "Edit: coc-settings.json"})
map("n", "<Leader>ev", "e $NVIMRC", {cmd = true, desc = "Edit: nvim/init.lua"})
map("n", "<Leader>ei", "e $MYVIMRC", {cmd = true, desc = "Edit: .vimrc"})
map("n", "<Leader>eo", "e $NVIMD/lua/usr/core/options.lua", {cmd = true, desc = "Edit: options"})
map("n", "<Leader>em", "e $NVIMD/lua/usr/core/mappings.lua", {cmd = true, desc = "Edit: mappings"})
map("n", "<Leader>ed", "e $NVIMD/lua/usr/core/commands.lua", {cmd = true, desc = "Edit: commands"})
map("n", "<Leader>ea", "e $NVIMD/lua/usr/core/autocmds.lua", {cmd = true, desc = "Edit: autocmds"})
map("n", "<Leader>ep", "e $NVIMD/lua/plugins.lua", {cmd = true, desc = "Edit: plugins"})
map("n", "<Leader>sv", "luafile $NVIMRC", {cmd = true, desc = "Source nvim/init.lua"})
map("n", "<Leader>ez", "e $ZDOTDIR/.zshrc", {cmd = true, desc = "Edit: .zshrc"})

map(
    "n",
    "<Leader>et",
    "require('usr.lib.fn').open_file_ftplugin()",
    {lcmd = true, desc = "Edit: ftplugin"}
)
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

return M
