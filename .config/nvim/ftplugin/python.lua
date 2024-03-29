local mpi = require("usr.api")
local bmap0 = mpi.bmap0
local command = mpi.command

-- map("n", "<LocalLeader>l", "<Plug>SlimeLineSend", {desc = "Slime send"})
-- map("x", "<LocalLeader>l", "<Plug>SlimeRegionSend", {desc = "Slime region send"})
-- map("n", "<LocalLeader>p", "<Plug>SlimeParagraphSend", {desc = "Slime paragraph send"})
-- map("n", "<S-CR>", ":TREPLSendLine<CR><Esc><Home><Down>", {desc = "REPL send line"})
-- map("i", "<S-CR>", ":TREPLSendLine<CR><Esc>A", {desc = "REPL send line"})
-- map("x", "<S-CR>", ":TREPLSendSelection<CR><Esc><Esc>", {desc = "REPL send selection"})
-- map("n", "<LocalLeader>rp", ":SlimeSend1 <C-r><C-w><CR>", {desc = "Slime send 1"})
-- map("n", "<LocalLeader>rP", ":SlimeSend1 print(<C-r><C-w>)<CR>", {desc = "Slime print word"})
-- map("n", "<LocalLeader>rt", ":SlimeSend1 <C-r><C-w>.dtype<CR>", {desc = "Slime dtype info"})
-- map(
--     "n",
--     "<LocalLeader>rs",
--     ":SlimeSend1 print(len(<C-r><C-w>), type(<C-r><C-w>))<CR>",
--     {desc = "Slime type info"}
-- )

bmap0("n", "<Leader>r<CR>", "VT python %", {cmd = true, desc = "Python: run file (vert)"})
bmap0("n", "<Leader>rF", "T ptpython", {cmd = true, desc = "Ptpython"})
bmap0(
    "n",
    "<Leader>rf",
    "T ipython --no-autoindent --colors=Linux --matplotlib",
    {cmd = true, desc = "Ptpython matplotlib"}
)
bmap0(
    "n",
    "<LocalLeader>rr",
    [[:FloatermNew --autoclose=0 python %<space>]],
    {desc = "Python floaterm"}
)

command(
    "Py2to3",
    [[<line1>,<line2>s/^\v(\s*print)\s+(.*)/\1(\2)]],
    {range = "%", desc = "Convert Python2 to Python3"}
)
bmap0("n", "<Leader>3", "Py2to3", {cmd = true, desc = "Convert Python2 to Python3"})

-- Pyright
-- # type: ignore

-- Flake8
-- # flake8: noqa: E731 -- Global
-- # noqa: E731         -- Inline

-- Pylint
-- # pylint: disable-next=
-- # pylint: disable=
-- # pylint: enable=
