local mpi = require("usr.api")
local o = vim.opt_local

o.comments = {":#"}
o.commentstring = "# %s"
o.cinkeys:remove({"0}"})
o.formatoptions:append({t = false, c = true, r = true, o = true, q = true, l = true})
-- o.iskeyword = {"@", "48-57", "_", "192-255", "#", "-"}
-- o.iskeyword = {"@", "48-57", "_", "192-255"}

local function map(...)
    mpi.bmap(0, ...)
end

map("n", "J", "gW", {noremap = false, desc = "Join lines & remove backslash"})

map("n", "[a", "[(", {desc = "Prev parenthesis"})
map("n", "]a", "])", {desc = "Next parenthesis"})
map("n", "[b", "[{", {desc = "Prev curly brace"})
map("n", "]b", "]}", {desc = "Next curly brace"})

map("n", "(", "[(", {desc = "Prev parenthesis"})
map("n", ")", "])", {desc = "Next parenthesis"})
map("n", "[[", "[{", {desc = "Prev curly brace"})
map("n", "]]", "]}", {desc = "Next curly brace"})

map("n", "{", "[m", {desc = "Prev start of method"})
map("n", "}", "]m", {desc = "Next start of method"})
map("n", "[f", "[m", {desc = "Prev start of method"})
map("n", "]f", "]m", {desc = "Next start of method"})
map("n", "[F", "[M", {desc = "Prev end of method"})
map("n", "]F", "]M", {desc = "Next end of method"})

map("n", "[d", "[<C-i>", {desc = "Prev line with keyword"})
map("n", "]d", "]<C-i>", {desc = "Next line with keyword"})
map("n", "[r", "[i", {desc = "Disp prev line w/ keyword"})
map("n", "]r", "]i", {desc = "Disp next line w/ keyword"})

-- map("n", "", "[*", {desc = "Prev start of '/*' comment"})
-- map("n", "", "]*", {desc = "Next end of '/*' comment"})
-- map("n", "", "[#", {desc = "Prev unmatched #if/#else"})
-- map("n", "", "]#", {desc = "Next unmatched #else/#endif"})
