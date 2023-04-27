local mpi = require("common.api")
local map = mpi.map

map("n", "gu", "<Plug>(InfoUp)", {buffer = true})
map("n", "gn", "<Plug>(InfoNext)", {buffer = true})
map("n", "gp", "<Plug>(InfoPrev)", {buffer = true})
map("n", "gm", "<Plug>(InfoMenu)", {buffer = true})
map("n", "gf", "<Plug>(InfoFollow)", {buffer = true})
