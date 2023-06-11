local mpi = require("usr.api")
local bmap0 = mpi.bmap0
local o = vim.opt_local

bmap0("n", "J", "gW", {noremap = false, desc = "Join lines & remove backslash"})

-- o.comments = {":#"}
-- o.commentstring = "# %s"
o.cinkeys:remove({"0}", "0#"})
o.formatoptions:append({t = false, c = true, r = true, o = true, q = true, l = true})
-- o.iskeyword = {"@", "48-57", "_", "192-255", "#", "-"}
-- o.iskeyword = {"@", "48-57", "_", "192-255"}
