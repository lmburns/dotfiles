local mpi = require("usr.api")
local bmap0 = mpi.bmap0
local o = vim.opt_local

-- o.comments = {":#"}
-- o.commentstring = "# %s"

mpi.map("n", "<Plug>TmuxExec", ":<C-U>set opfunc=tmux#filterop<CR>g@", {silent = true})
mpi.map("x", "<Plug>TmuxExec", ":<C-U>call tmux#filterop(visualmode())<CR>", {silent = true})
bmap0("n", "K", "tmux#man()", {ccmd = true, desc = "Open Tmux man"})
bmap0("n", "g!", "<Plug>TmuxExec", {noremap = false, desc = "TmuxExec operator"})
bmap0("x", "g!", "<Plug>TmuxExec", {noremap = false, desc = "TmuxExec"})
bmap0("x", "<Leader>r<CR>", "<Plug>TmuxExec", {noremap = false, desc = "TmuxExec"})
bmap0("n", "g!!", "<Plug>TmuxExec_", {noremap = false, desc = "TmuxExec_ operator"})
