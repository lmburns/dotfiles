local mpi = require("usr.api")
local o = vim.opt_local

local function map(...)
    return mpi.bmap(0, ...)
end

map("n", "J", "gW", {noremap = false, desc = "Join lines & remove backslash"})

-- o.comments = {":#"}
-- o.commentstring = "# %s"
o.formatoptions:append({t = false, c = true, r = true, o = true, q = true, l = true})
-- o.iskeyword = {"@", "48-57", "_", "192-255", "#", "-"}
-- o.iskeyword = {"@", "48-57", "_", "192-255"}
