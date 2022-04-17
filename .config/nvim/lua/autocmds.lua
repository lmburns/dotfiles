local utils = require("common.utils")
local map = utils.map
local au = utils.au
local augroup = utils.augroup
local create_augroup = utils.create_augroup

-- === Restore Cursor Position === [[[
--
-- I've noticed that `BufRead` works, but `BufReadPost` doesn't
-- at least, with allowing opening a file with `nvim +5`
augroup(
    "lmb__RestoreCursor",
    {
        {
            event = "BufRead",
            command = function()
                -- local ft = vim.api.nvim_get_option_value("filetype", {})
                local row, col = unpack(api.nvim_buf_get_mark(0, '"'))
                if {row, col} ~= {0, 0} and row <= api.nvim_buf_line_count(0) then
                    api.nvim_win_set_cursor(0, {row, 0})
                end
            end,
            pattern = "*",
            once = false
        }
    }
)
-- ]]] === Restore cursor ===

-- === Format Options === [[[
-- Whenever set globally these don't seem to work, I'm assuming
-- this is because other plugins overwrite them
do
    local o = vim.opt_local

    api.nvim_create_autocmd(
        "BufEnter",
        {
            callback = function()
                -- Buffer option here doesn't work like global
                o.formatoptions:remove({"c", "r", "o"})
                o.conceallevel = 2
                o.concealcursor = "vc"

                -- Allows a shared statusline
                if b.ft ~= "fzf" then
                    vim.opt_local.laststatus = 3
                end
            end,
            group = create_augroup("lmb__FormatOptions"),
            pattern = "*"
        }
    )
end
-- ]]] === Format Options ===

-- === Remove Empty Buffers === [[[
api.nvim_create_autocmd(
    "BufHidden",
    {
        callback = function()
            require("common.builtin").wipe_empty_buf()
        end,
        buffer = 0,
        once = true,
        group = create_augroup("lmb__FirstBuf"),
        desc = "Remove empty, hidden buffers"
    }
)
-- ]]]

-- === MRU === [[[
api.nvim_create_autocmd(
    "WinLeave",
    {
        callback = function()
            require("common.win").record()
        end,
        pattern = "*",
        group = create_augroup("lmb__MruWin"),
        desc = "Add file to custom MRU list"
    }
) -- ]]]

-- === Spelling === [[[
do
    local id = create_augroup("lmb__Spellcheck")
    api.nvim_create_autocmd(
        "FileType",
        {
            command = "setlocal spell",
            group = id,
            pattern = {"gitcommit", "markdown", "text", "mail"}
        }
    )

    api.nvim_create_autocmd(
        {"BufRead", "BufNewFile"},
        {command = "setlocal spell", group = id, pattern = "neomutt-archbox*"}
    )
end

-- Fix terminal highlights
api.nvim_create_autocmd(
    "TermEnter",
    {
        callback = function()
            vim.schedule(
                function()
                    cmd("nohlsearch")
                    vim.fn.clearmatches()
                end
            )
        end,
        pattern = "*",
        group = create_augroup("lmb__TermFix"),
        desc = "Clear matches and highlights when entering a terminal"
    }
)
-- ]]] === Spelling ===

-- === Clear cmd line message === [[[
do
    local timer
    local timeout = 10000

    -- Automatically clear command-line messages after a few seconds delay
    -- Source: https://unix.stackexchange.com/a/613645
    api.nvim_create_autocmd(
        "CmdlineLeave",
        {
            group = create_augroup("lmb__ClearCliMsgs"),
            pattern = ":",
            callback = function()
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
    )
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
                cmd [[tabdo wincmd =]]
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
au(
    "lmb__CustomFileType",
    {
        {{"BufRead", "BufNewFile"}, "*.ztst", "setl ft=ztst"},
        {{"BufRead", "BufNewFile"}, "*.pre-commit", "setl ft=sh"},
        {{"BufRead", "BufNewFile"}, "coc-settings.json", "setl ft=jsonc"},
        {
            {"BufRead", "BufNewFile"},
            {"calcurse-note*", "~/.local/share/calcurse/notes/*"},
            "set ft=markdown"
        },
        {{"BufRead", "BufNewFile"}, "*.ms,*.me,*.mom,*.man", "set ft=groff"},
        {{"BufRead", "BufNewFile"}, "*.tex", "setl ft=tex"},
        {"FileType", "json", [[syntax match Comment +\/\/.\+$+]]},
        {"FileType", "nroff", [[setl wrap textwidth=85 colorcolumn=+1]]},
        {"FileType", "json", [[setl shiftwidth=2]]},
        {"FileType", "qf", [[set nobuflisted]]},
        {
            "BufWritePre",
            "*",
            function()
                -- Delete trailing spaces
                require("common.utils").preserve("%s/\\s\\+$//ge")
                -- Delete trailing blank lines
                require("common.utils").preserve([[%s#\($\n\s*\)\+\%$##e]])
                -- Delete blank lines if more than 2 in a row
                -- require("common.utils").squeeze_blank_lines()
            end
        },
        {"BufWritePre", {"*.odt", "*.rtf"}, [[silent set ro]]},
        {
            "BufWritePre",
            "*.odt",
            [[%!pandoc --columns=78 -f odt -t markdown "%"]]
        },
        {"BufWritePre", "*.rt", [[silent %!unrtf --text]]}
    }
)
-- ]]] === Custom file type ===

-- === Custom syntax groups === [[[
au(
    "lmb__CommentTitle",
    {
        {
            "Syntax",
            "*",
            [[syn match cmTitle /\v(#|--|\/\/|\%)\s*(\u\w*|\=+)(\s+\u\w*)*(:|\s*\w*\s*\=+)/ ]] ..
                [[contained containedin=.*Comment,vimCommentTitle,rustCommentLine ]]
        },
        {
            "Syntax",
            "*",
            [[syn match myTodo ]] ..
                [[/\v(#|--|\/\/|")\s(FIXME|FIX|DISCOVER|NOTE|NOTES|INFO|OPTIMIZE|XXX|EXPLAIN|TODO|CHECK|HACK|BUG|BUGS):/]] ..
                    [[ contained containedin=.*Comment.*,vimCommentTitle ]]
        },
        {
            "Syntax",
            "*",
            [[syn keyword cmTitle contained=Comment]]
        },
        {
            "Syntax",
            "*",
            [[syn keyword myTodo contained=Comment]]
        }
    }
)

cmd [[hi def link cmTitle vimCommentTitle]]
cmd [[hi def link myTodo Todo]]
-- cmd [[ hi def link cmLineComment Comment ]]

-- ]]] === Custom syntax groups ===

-- ================================ Zig =============================== [[[
augroup(
    "lmb__ZigEnv",
    {
        {
            event = "FileType",
            pattern = "zig",
            description = "Setup zig environment",
            command = function()
                map("n", "<Leader>r<CR>", "<cmd>FloatermNew --autoclose=0 zig run ./%<CR>")
                map("n", ";ff", ":Format<CR>")
            end
        }
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

api.nvim_create_autocmd(
    "FileType",
    {
        pattern = "c",
        group = create_augroup("CEnv"),
        callback = function()
            map("n", "<Leader>r<CR>", ":FloatermNew --autoclose=0 gcc % -o %< && ./%< <CR>")
        end
    }
)

api.nvim_create_autocmd(
    "FileType",
    {
        pattern = "cpp",
        group = create_augroup("CppEnv"),
        callback = function()
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

augroup(
    "lmb__AutoReloadFile",
    {
        {
            event = {"BufEnter", "CursorHold"},
            command = function()
                local bufnr = tonumber(fn.expand "<abuf>")
                local name = api.nvim_buf_get_name(bufnr)
                if
                    name == "" or -- Only check for normal files
                        vim.bo[bufnr].buftype ~= "" or -- To avoid: E211: File "..." no longer available
                        not fn.filereadable(name)
                 then
                    return
                end

                vim.cmd(bufnr .. "checktime")
            end,
            description = "Reload file when modified outside of the instance"
        },
        {
            event = "FileChangedShellPost",
            pattern = "*",
            command = [[echohl WarningMsg | echo "File changed on disk. Buffer reloaded!" | echohl None]],
            description = "Display a message if the buffer is changed outside of instance"
        }
    }
)
-- ]]] === Buffer Reload ===

-- =========================== RNU Column ============================= [[[
-- Toggle relative/non-relative nubmers:
--   - Only in the active window
--   - Ignore quickfix window
--   - Only when searching in cmdline or in insert mode

augroup(
    "RnuColumn",
    {
        {
            event = {"BufLeave", "FocusLost", "InsertEnter", "WinLeave"},
            pattern = "*",
            command = function()
                require("common.rnu").focus(false)
            end
        },
        {
            event = {"BufEnter", "FocusGained", "InsertLeave", "WinEnter"},
            pattern = "*",
            command = function()
                require("common.rnu").focus(true)
            end
        },
        {
            event = "WinEnter",
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
)
-- ]]] === RNU Column ===

-- ============================== Unused ============================== [[[

-- ]]] === Unused ===
