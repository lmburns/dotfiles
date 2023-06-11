local mpi = require("usr.api")
local bmap0 = mpi.bmap0
local o = vim.opt_local
local fn = vim.fn
local cmd = vim.cmd

o.conceallevel = 2
o.concealcursor = "nvic"

-- syn match logDate \
--     /\v(Mon|Tue|Wed|Thu|Fri|Sat|Sun)\ \d{1,2}\ (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\ \d{2,4}/

if fn.bufname():match("diffview.log$") then
    cmd([[syn match logPath /\v\S*\/\S*\/diffview.nvim\/lua\/diffview\// conceal]])
end
