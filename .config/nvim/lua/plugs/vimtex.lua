local M = {}

local au = require("common.utils").au

function M.setup()
    g.vimtex_view_method = "zathura"
    g.tex_flavor = "latex"
    g.vimtex_compiler_latexmk = {
        executable = "latexmk",
        options = {
            "-xelatex",
            "-file-line-error",
            "-synctex=1",
            "-interaction=nonstopmode"
        }
    }
end

local function init()
    M.setup()

    au(
        "lmb__Vimtex",
        {
            {"InsertEnter", "*.tex", [[set conceallevel=0]]},
            {"InsertLeave", "*.tex", [[set conceallevel=2]]},
            {"BufEnter", "*.tex", [[set concealcursor-=n]]},
            {"VimLeave", "*.tex", [[!texclear %]]}
        }
    )
end

init()

return M
