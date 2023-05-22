local mpi = require("usr.api")

local function map(...)
    mpi.bmap(0, ...)
end

map("n", "]t", [[:FloatermNext<CR><C-\><C-n>]], {desc = "FloatermNext"})
map("n", "[t", [[:FloatermPrev<CR><C-\><C-n>]], {desc = "FloatermPrev"})

-- nmap <buffer><silent> ]t :FloatermNext<CR><C-\><C-n>
-- nmap <buffer><silent> [t :FloatermPrev<CR><C-\><C-n>
