local map = require("common.utils").map

-- Pyright
-- # type: ignore

-- Flake8
-- # flake8: noqa: E731 -- Global
-- # noqa: E731         -- Inline

-- Pylint
-- # pylint: disable-next=
-- # pylint: disable=
-- # pylint: enable=

map("n", "<LocalLeader>l", "<Plug>SlimeLineSend", {buffer = true, desc = "Slime send"})
map("x", "<LocalLeader>l", "<Plug>SlimeRegionSend", {buffer = true, desc = "Slime region send"})
map("n", "<LocalLeader>p", "<Plug>SlimeParagraphSend", {buffer = true, desc = "Slime paragraph send"})

map("n", "<S-CR>", ":TREPLSendLine<CR><Esc><Home><Down>", {buffer = true, desc = "REPL send line"})
map("i", "<S-CR>", ":TREPLSendLine<CR><Esc>A", {buffer = true, desc = "REPL send line"})
map("x", "<S-CR>", ":TREPLSendSelection<CR><Esc><Esc>", {buffer = true, desc = "REPL send selection"})

map("n", "<LocalLeader>rr", [[:FloatermNew --autoclose=0 python %<space>]], {buffer = true, desc = "Python floaterm"})
map("n", "<Leader>r<CR>", ":VT python %<CR>", {buffer = true, desc = "Run file"})
map("n", "<Leader>rF", ":T ptpython<CR>", {buffer = true, desc = "Ptpython"})
map(
    "n",
    "<Leader>rf",
    ":T ipython --no-autoindent --colors=Linux --matplotlib<CR>|",
    {buffer = true, desc = "Ptpython matplotlib"}
)

map("n", "<LocalLeader>rp", ":SlimeSend1 <C-r><C-w><CR>", {buffer = true, desc = "Slime send 1"})
map("n", "<LocalLeader>rP", ":SlimeSend1 print(<C-r><C-w>)<CR>", {buffer = true, desc = "Slime print word"})
map(
    "n",
    "<LocalLeader>rs",
    ":SlimeSend1 print(len(<C-r><C-w>), type(<C-r><C-w>))<CR>",
    {buffer = true, desc = "Slime type info"}
)
map("n", "<LocalLeader>rt", ":SlimeSend1 <C-r><C-w>.dtype<CR>", {buffer = true, desc = "Slime dtype info"})
map("n", "223", [[::%s/^\(\s*print\)\s\+\(.*\)/\1(\2)<CR>]], {buffer = true, desc = "Convert Python2 to Python3"})
