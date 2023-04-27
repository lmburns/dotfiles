local coc = require("plugs.coc")
local mpi = require("common.api")
local map = mpi.map

vim.bo.include = [[\v<((do|load)file|require)[^''"]*[''"]\zs[^''"]+]]
-- o.matchpairs:append({"if:end", "function:end"})

map("n", "<Leader>tt", "<Plug>PlenaryTestFile", {desc = "Plenary test"})

map(
    "n",
    "<Leader>jR",
    function()
        coc.run_command("sumneko-lua.restart", {})
    end,
    {buffer = true, desc = "Reload Lua workspace"}
)
