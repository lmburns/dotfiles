local utils = require("common.utils")
local map = utils.map
local augroup = utils.augroup
local autocmd = utils.autocmd
local create_augroup = utils.create_augroup

-- augroup(
--     {"filetypedetect", false},
--     {
--         event = {"BufRead", "BufNewFile"},
--         pattern = "*",
--         command = function()
--             vim.filetype.match(vim.fn.expand("<afile>"))
--         end
--     }
-- )

-- === Restore Cursor Position === [[[
-- FIX: This autocmd prevents wilder from having a right border
-- I've noticed that `BufRead` works, but `BufReadPost` doesn't
-- at least, with allowing opening a file with `nvim +5`

augroup(
    "lmb__RestoreCursor",
    {
        event = "BufReadPost",
        pattern = "*",
        command = function()
            local types =
                _t(
                {
                    "nofile",
                    "fugitive",
                    "gitcommit",
                    "gitrebase",
                    "commit",
                    "rebase"
                }
            )
            if fn.expand("%") == "" or types:contains(b.filetype) or b.bt == "nofile" then
                return
            end

            local row, col = unpack(nvim.buf.get_mark(0, '"'))
            if {row, col} ~= {0, 0} and row <= nvim.buf.line_count(0) then
                nvim.win.set_cursor(0, {row, 0})
            end
        end
    }
)
-- ]]] === Restore cursor ===

-- === Format Options === [[[
-- Whenever set globally these don't seem to work, I'm assuming
-- this is because other plugins overwrite them.
--
-- Without FileType, the first buffer that is loaded does not have these settings applied
do
    local o = vim.opt_local

    augroup(
        "lmb__FormatOptions",
        {
            event = {"BufEnter", "FileType"},
            pattern = "*",
            command = function()
                -- Buffer option here doesn't work like global
                o.formatoptions:remove({"c", "r", "o"})
                o.conceallevel = 2
                o.concealcursor = "vc"

                -- Allows a shared statusline
                if b.ft ~= "fzf" then
                    o.laststatus = 3
                end
            end
        }
    )
end
-- ]]] === Format Options ===

-- ╭──────────────────────────────────────────────────────────╮
-- │                Colorscheme Modifications                 │
-- ╰──────────────────────────────────────────────────────────╯
augroup(
    "lmb__ColorschemeSetup",
    {
        event = "ColorScheme",
        pattern = "*",
        command = function()
            -- ex.hi("TSConstBuiltin gui=none")
            ex.hi("TSVariableBuiltin gui=none")
            ex.hi("TSTypeBuiltin gui=none")
            ex.hi("TSProperty gui=none")
            ex.hi("TSVariable gui=none")
            ex.hi("TSString gui=none")
            ex.hi("TSKeywordFunction gui=none")
            ex.hi("Function gui=bold")
            ex.hi("Todo guibg=none")
            ex.hi("FloatermBorder guifg=#A06469 gui=none")
        end
    }
)

-- === Remove Empty Buffers === [[[
augroup(
    "lmb__FirstBuf",
    {
        event = "BufHidden",
        command = function()
            require("common.builtin").wipe_empty_buf()
        end,
        buffer = 0,
        once = true,
        desc = "Remove first empty buffer"
    }
)
-- ]]]

-- === MRU === [[[
augroup(
    "lmb__MruWin",
    {
        event = "WinLeave",
        pattern = "*",
        command = function()
            require("common.win").record()
        end,
        description = "Add file to custom MRU list"
    }
)
-- ]]]

-- === Spelling === [[[
augroup(
    "lmb__Spellcheck",
    {
        event = "FileType",
        command = "setlocal spell",
        pattern = {"gitcommit", "markdown", "text", "mail"}
    },
    {
        event = {"BufRead", "BufNewFile"},
        command = "setlocal spell",
        pattern = "neomutt-archbox*"
    }
)
-- ]]] === Spelling ===

-- === Fix terminal highlights ===
augroup(
    "lmb__TermFix",
    {
        event = "TermEnter",
        command = function()
            vim.schedule(
                function()
                    cmd("nohlsearch")
                    fn.clearmatches()
                end
            )
        end,
        pattern = "*",
        desc = "Clear matches and highlights when entering a terminal"
    }
)
-- ]]] === Terminal ===

-- === Help/Man pages in vertical ===

local split_should_return = function()
    -- do nothing for floating windows
    local cfg = api.nvim_win_get_config(0)
    if cfg and (cfg.external or cfg.relative and #cfg.relative > 0) then
        return true
    end
    -- do not run if Diffview is open
    if g.diffview_nvim_loaded and require("diffview.lib").get_current_view() then
        return true
    end

    return false
end

nvim.autocmd.lmb__Help = {
    {
        event = "BufEnter",
        pattern = "*.txt",
        command = function()
            local bufnr = nvim.buf.nr()
            if b[bufnr].bt == "help" then
                if split_should_return() then
                    return
                end

                local width = math.floor(vim.o.columns * 0.75)
                ex.wincmd("L")
                cmd("vertical resize " .. width)
                map("n", "qq", "q", {cmd = true, buffer = bufnr})
            end
        end
    },
    {
        -- This is ran more than once
        -- Using help for this won't open vertical when opening the same thing twice in a row
        event = "FileType",
        pattern = {"man"},
        once = false,
        command = function()
            local bufnr = nvim.buf.nr()
            if split_should_return() then
                return
            end

            local width = math.floor(vim.o.columns * 0.75)
            ex.wincmd("L")
            cmd("vertical resize " .. width)
            map("n", "qq", "q", {cmd = true, buffer = bufnr})
        end
    },
    -- Works when opening man with ':Man' but not with telescope or fzf-lua
    -- if the event is BufHidden. However, BufLeave fixes this problem
    {
        event = "BufLeave",
        pattern = "*",
        command = function()
            if b.ft == "man" then
                local bufnr = nvim.buf.nr()
                vim.defer_fn(
                    function()
                        if nvim.buf.is_valid(bufnr) then
                            nvim.buf.delete(bufnr, {force = true})
                        end
                    end,
                    0
                )
            end
        end
    }
}
-- ]]] === Help ===

-- === Tmux === [[[
if vim.env.TMUX ~= nil and vim.env.NORENAME == nil then
    -- vim.cmd [[
    --   augroup rename_tmux
    --     au!
    --     au BufEnter * if empty(&buftype) | let &titlestring = '' . expand('%(%m%)%(%{expand("%:~")}%)') | endif
    --     au VimLeave * call system('tmux set-window automatic-rename on')
    --   augroup END
    -- ]]

    nvim.autocmd.lmb__RenameTmux = {
        {
            event = {"FileType", "BufEnter"},
            pattern = "*",
            once = false,
            description = "Automatic rename of tmux window",
            command = function()
                local bufnr = nvim.buf.nr()

                -- I have TMUX already automatically change title
                -- It sets it to titlestring
                if vim.bo[bufnr].bt == "" then
                    o.titlestring = fn.expand("%:t")
                elseif vim.bo[bufnr].bt == "terminal" then
                    -- FIX: This block is never picked up
                    -- if b.ft == "toggleterm" then
                    --     o.titlestring = "ToggleTerm #" .. vim.b.toggle_number
                    -- else
                    o.titlestring = "Terminal"
                end
            end
        },
        {
            event = {"FileType"},
            pattern = "toggleterm",
            command = function()
                -- Buffer variable is not set yet, so b.toggle_number isn't working
                o.titlestring = ("ToggleTerm #%d"):format(F.if_nil(vim.b.toggle_number, 1))
            end
        },
        {
            event = "VimLeave",
            pattern = "*",
            description = "Turn back on Tmux auto-rename",
            command = function()
                os.execute("tmux set-window automatic-rename on")
            end
        }
    }
end
-- ]]] === Tmux ===

-- === Clear cmd line message === [[[
do
    local timer
    local timeout = 6000

    -- Automatically clear command-line messages after a few seconds delay
    -- Source: https://unix.stackexchange.com/a/613645
    nvim.autocmd.lmb__ClearCliMsgs = {
        event = "CmdlineLeave",
        pattern = ":",
        command = function()
            if timer then
                timer:stop()
            end
            timer =
                vim.defer_fn(
                function()
                    if fn.mode() == "n" then
                        api.nvim_echo({}, false, {})
                    end
                end,
                timeout
            )
        end,
        desc = ("Clear command-line messages after %d seconds"):format(timeout / 1000)
    }
end -- ]]]

-- === Auto Resize on Resize Event === [[[
do
    local id = create_augroup("lmb__VimResize")
    local o = vim.o

    api.nvim_create_autocmd(
        "VimResized",
        {
            group = id,
            callback = function()
                local last_tab = api.nvim_get_current_tabpage()
                ex.tabdo("wincmd =")
                api.nvim_set_current_tabpage(last_tab)
            end,
            desc = "Equalize windows across tabs"
        }
    )

    api.nvim_create_autocmd(
        {"VimEnter", "VimResized"},
        {
            group = id,
            callback = function()
                o.previewheight = math.floor(o.lines / 3)
            end,
            desc = "Update previewheight as per the new Vim size"
        }
    )
end -- ]]]

-- === Custom file type settings === [[[
augroup(
    "lmb__CustomFileType",
    {event = "FileType", pattern = "qf", command = [[set nobuflisted]]},
    {event = "BufWritePre", pattern = {"*.odt", "*.rtf"}, command = [[silent set ro]]},
    {
        event = "BufWritePre",
        pattern = "*.odt",
        command = [[%!pandoc --columns=78 -f odt -t markdown "%"]]
    },
    {event = "BufWritePre", pattern = "*.rt", command = [[silent %!unrtf --text]]}
)

a.async_void(
    vim.schedule_wrap(
        function()
            augroup(
                "lmb__TrimWhitespace",
                {
                    event = "BufWritePre",
                    pattern = "*",
                    command = function()
                        -- Delete trailing spaces
                        require("common.utils").preserve("%s/\\s\\+$//ge")

                        -- Delete trailing blank lines
                        require("common.utils").preserve([[%s#\($\n\s*\)\+\%$##e]])

                        -- Delete blank lines if more than 2 in a row
                        -- require("common.utils").squeeze_blank_lines()
                    end
                }
            )
        end
    )
)()

-- nvim.create_autocmd(
--     {"BufNewFile", "BufRead"},
--     {
--         pattern = "*",
--         callback = function()
--             require("filetype").resolve()
--         end
--     }
-- )
-- ]]] === Custom file type ===

-- === Custom syntax groups === [[[
augroup(
    "lmb__CommentTitle",
    {
        event = "Syntax",
        pattern = "*",
        command = [[syn match cmTitle /\v(#|--|\/\/|\%)\s*(\u\w*|\=+)(\s+\u\w*)*(:|\s*\w*\s*\=+)/ ]] ..
            [[contained containedin=.*Comment,vimCommentTitle,rustCommentLine ]]
    },
    {
        event = "Syntax",
        pattern = "*",
        command = [[syn match myTodo ]] ..
            [[/\v(#|--|\/\/|")\s(FIXME|FIX|DISCOVER|NOTE|NOTES|INFO|OPTIMIZE|XXX|EXPLAIN|TODO|CHECK|HACK|BUG|BUGS):/]] ..
                [[ contained containedin=.*Comment.*,vimCommentTitle ]]
    },
    {
        event = "Syntax",
        pattern = "*",
        command = [[syn keyword cmTitle contained=Comment]]
    },
    {
        event = "Syntax",
        pattern = "*",
        command = [[syn keyword myTodo contained=Comment]]
    }
)

ex.hi("def link cmTitle vimCommentTitle")
-- ex.hi("def link myTodo Todo")
-- ex.hi("def link cmLineComment Comment")

-- ]]] === Custom syntax groups ===

-- ================================ Zig =============================== [[[
augroup(
    "lmb__ZigEnv",
    {
        event = "FileType",
        pattern = "zig",
        description = "Setup zig environment",
        command = function()
            map("n", "<Leader>r<CR>", "<cmd>FloatermNew --autoclose=0 zig run ./%<CR>")
            map("n", ";ff", ":Format<CR>")
        end
    }
)
-- ]]] === Zig ===

-- ============================== C/Cpp =============================== [[[
cmd [[
  function! s:FullCppMan()
      let old_isk = &iskeyword
      setl iskeyword+=:
      let str = expand("<cword>")
      let &l:iskeyword = old_isk
      execute 'Man ' . str
  endfunction

  command! Fcman :call s:FullCppMan()
]]

-- augroup(
--     "lmb__CEnv",
--     {
--         event = "FileType",
--         pattern = "c",
--         command = function()
--             map("n", "<Leader>r<CR>", ":FloatermNew --autoclose=0 gcc % -o %< && ./%< <CR>")
--         end
--     }
-- )

augroup(
    "lmb__CppEnv",
    {
        event = "FileType",
        pattern = "cpp",
        command = function()
            map("n", "<Leader>r<CR>", ":FloatermNew --autoclose=0 g++ % -o %:r && ./%:r <CR>")
            map("n", "<Leader>kk", ":Fcman<CR>")
        end
    }
)
-- ]]]

-- ======================= CursorLine Control ========================= [[[
-- Cursorline highlighting control
--  Only have it on in the active buffer
do
    local id = create_augroup("lmb__CursorLineControl")
    local set_cursorline = function(event, value, pattern)
        api.nvim_create_autocmd(
            event,
            {
                group = id,
                pattern = pattern,
                callback = function()
                    opt_local.cursorline = value
                end
            }
        )
    end

    set_cursorline("WinLeave", false)
    set_cursorline("WinEnter", true)
    set_cursorline("FileType", false, "TelescopePrompt")
end
-- ]]]

-- ========================== Buffer Reload =========================== [[[
-- autocmd(
--     "auto_read", {
--       [[FocusGained,BufEnter,CursorHold,CursorHoldI * if mode() == 'n' && getcmdwintype() == '' | checktime | endif]],
--       [[FileChangedShellPost * echohl WarningMsg | echo "File changed on disk. Buffer reloaded!" | echohl None]],
--     }, true
-- )

nvim.autocmd.lmb__AutoReloadFile = {
    {
        event = {"BufEnter", "CursorHold", "FocusGained"},
        command = function()
            -- local bufnr = tonumber(fn.expand "<abuf>")
            local bufnr = nvim.buf.nr()
            local name = nvim.buf.get_name(bufnr)
            if
                name == "" or -- Only check for normal files
                    vim.bo[bufnr].buftype ~= "" or -- To avoid: E211: File "..." no longer available
                    not fn.filereadable(name)
             then
                return
            end

            cmd(bufnr .. "checktime")
        end,
        description = "Reload file when modified outside of the instance"
    },
    {
        event = "FileChangedShellPost",
        pattern = "*",
        command = function()
            api.nvim_echo({{"File changed on disk. Buffer reloaded!", "WarningMsg"}}, true, {})
        end,
        description = "Display a message if the buffer is changed outside of instance"
    }
}
-- ]]] === Buffer Reload ===

-- =========================== RNU Column ============================= [[[
-- Toggle relative/non-relative nubmers:
--   - Only in the active window
--   - Ignore quickfix window
--   - Only when searching in cmdline or in insert mode

-- FIX: Rnu not working on startup until insert mode (focus not working either)
--      It has worked before
nvim.autocmd.RnuColumn = {
    {
        event = {"FocusLost", "InsertEnter"},
        pattern = "*",
        command = function()
            require("common.rnu").focus(false)
        end
    },
    {
        -- FIX: This works sometimes
        event = {"FocusGained", "InsertLeave"},
        pattern = "*",
        command = function()
            require("common.rnu").focus(true)
        end
    },
    -- {
    --     -- FIX: Bufferize filetype
    --     event = "FileType",
    --     pattern = {"bufferize"},
    --     command = function()
    --         require("common.rnu").focus(false)
    --     end
    -- },
    {
        event = {"WinEnter", "BufEnter"},
        pattern = "*",
        command = function()
            require("common.rnu").win_enter()
        end
    },
    {
        event = "CmdlineEnter",
        pattern = [[/,\?]],
        command = function()
            require("common.rnu").scmd_enter()
        end
    },
    {
        event = "CmdlineLeave",
        pattern = [[/,\?]],
        command = function()
            require("common.rnu").scmd_leave()
        end
    }
}
-- ]]] === RNU Column ===

autocmd(
    {
        event = "VimEnter",
        pattern = "*",
        command = [[call vista#RunForNearestMethodOrFunction()]]
    }
)

-- ============================== Unused ============================== [[[

-- ]]] === Unused ===
