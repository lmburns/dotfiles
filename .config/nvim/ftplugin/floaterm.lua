local mpi = require("usr.api")
local bmap0 = mpi.bmap0

bmap0("n", "]t", [[:FloatermNext<CR><C-\><C-n>]], {desc = "FloatermNext"})
bmap0("n", "[t", [[:FloatermPrev<CR><C-\><C-n>]], {desc = "FloatermPrev"})

-- nmap <buffer><silent> ]t :FloatermNext<CR><C-\><C-n>
-- nmap <buffer><silent> [t :FloatermPrev<CR><C-\><C-n>
