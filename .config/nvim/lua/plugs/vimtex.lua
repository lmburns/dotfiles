---@module 'plugs.vimtex'
local M = {}

local mpi = require("usr.api")
local augroup = mpi.augroup

local g = vim.g

function M.setup()
    g.tex_flavor = "latex"
    g.matchup_override_vimtex = 1
    g.vimtex_matchparen_deferred = 1
    g.vimtex_syntax_conceal = {
        accents = 1,
        fancy = 1,
        greek = 1,
        math_bounds = 1,
        math_delimiters = 1,
        math_fracs = 1,
        math_super_sub = 1,
        math_symbols = 1,
        styles = 1,
    }

    g.vimtex_quickfix_mode = 2
    g.vimtex_compiler_progname = "nvr"
    g.vimtex_fold_enabled = 1
    g.vimtex_view_method = "zathura"
    g.vimtex_compiler_method = "latexmk"
    -- g.vimtex_compiler_generic = {
    --     command = "ls *.tex | entr -n -c tectonic /_ --synctex --keep-logs",
    -- }
    g.vimtex_compiler_latexmk = {
        build_dir = "",
        callback = 1,
        continuous = 1,
        executable = "latexmk",
        options = {
            "-xelatex",
            "-verbose",
            "-file-line-error",
            "-synctex=1",
            "-interaction=nonstopmode",
        },
    }

    --   aug vimtex_events
    --     au!
    --     au User VimtexEventInitPost VimtexCompile
    --     au User VimtexEventQuit call OnQuit()
    --     au User VimtexEventCompileStarted VimtexView
    --   aug END
    --   " Close viewers when VimTeX buffers are closed
    --   fu! OnQuit()
    --     if executable('xdotool') && exists('b:vimtex')
    --         \ && exists('b:vimtex.viewer') && b:vimtex.viewer.xwin_id > 0
    --       call system('xdotool windowclose '. b:vimtex.viewer.xwin_id)
    --     endif
    --   endfu
    --   " FZF integration for VimTeX
    --   nn <localleader>lt :cal vimtex#fzf#run('cti', {'window': '50vnew'} )<CR>
end

local function init()
    M.setup()

    augroup(
        "lmb__Vimtex",
        {event = "InsertEnter", pattern = "*.tex", command = [[set conceallevel=0]]},
        {event = "InsertLeave", pattern = "*.tex", command = [[set conceallevel=2]]},
        {event = "BufEnter", pattern = "*.tex", command = [[set concealcursor-=n]]},
        {event = "VimLeave", pattern = "*.tex", command = [[!texclear %]]}
    )
end

init()

return M
