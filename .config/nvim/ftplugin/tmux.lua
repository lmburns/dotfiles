-- local shared = require("usr.shared")
-- local F = shared.F
-- local it = F.ithunk
local mpi = require("usr.api")
local o = vim.opt_local

local map = function(...)
    mpi.bmap(0, ...)
end

-- o.comments = {":#"}
-- o.commentstring = "# %s"

mpi.map("n", "<Plug>TmuxExec", ":<C-U>set opfunc=tmux#filterop<CR>g@", {silent = true})
mpi.map("x", "<Plug>TmuxExec", ":<C-U>call tmux#filterop(visualmode())<CR>", {silent = true})
map("n", "K", "tmux#man()", {ccmd = true, desc = "Open Tmux man"})
map("n", "g!", "<Plug>TmuxExec", {noremap = false, desc = "TmuxExec operator"})
map("x", "g!", "<Plug>TmuxExec", {noremap = false, desc = "TmuxExec"})
map("x", "<Leader>r<CR>", "<Plug>TmuxExec", {noremap = false, desc = "TmuxExec"})
map("n", "g!!", "<Plug>TmuxExec_", {noremap = false, desc = "TmuxExec_ operator"})
