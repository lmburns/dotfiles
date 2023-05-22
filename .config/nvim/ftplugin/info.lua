local mpi = require("usr.api")

local map = function(...)
    return mpi.bmap(0, ...)
end

map("n", "gu", "<Plug>(InfoUp)", {desc = "Info: up"})
map("n", "gn", "<Plug>(InfoNext)", {desc = "Info: next"})
map("n", "gp", "<Plug>(InfoPrev)", {desc = "Info: prev"})
map("n", "gm", "<Plug>(InfoMenu)", {desc = "Info: menu"})
map("n", "gf", "<Plug>(InfoFollow)", {desc = "Info: follow"})
