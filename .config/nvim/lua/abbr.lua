local M = {}

require("common.utils")

---Create a `cnoreabbrev`
---@param input string: Thing to be replaced
---@param replace string: The abbreviation
function M.cabbrev(input, replace)
    -- ex.cnoreabbrev(input, M.command(input, replace))

    local cmd = [[cnoreabbrev <expr> %s v:lua.require'abbr'.command("%s", "%s")]]
    vim.cmd(cmd:format(input, input, replace))
end

function M.command(cmd, match)
    if fn.getcmdtype() == ":" and fn.getcmdline():match("^" .. cmd) then
        return match
    else
        return cmd
    end
end

M.cabbrev("W!", "w!")
M.cabbrev("Q!", "q!")
M.cabbrev("Qall!", "qll!")
M.cabbrev("Qall", "qll")
M.cabbrev("Wq", "wq")
M.cabbrev("Wa", "wa")
M.cabbrev("wQ", "wq")
M.cabbrev("WQ", "wq")
M.cabbrev("W", "w")

M.cabbrev("tel", "Telescope")
M.cabbrev("Review", "DiffviewOpen")

M.cabbrev("PI", "PackerInstall")
M.cabbrev("PU", "PackerUpdate")
M.cabbrev("PS", "PackerSync")
M.cabbrev("PC", "PackerCompile")

g.no_man_maps = 1
M.cabbrev("man", "Man")
M.cabbrev("vg", "vimgrep")
M.cabbrev("grep", "Grep")
M.cabbrev("lgrep", "LGrep")
M.cabbrev("buf", "Bufferize")
M.cabbrev("req", "lua require('")

return M
