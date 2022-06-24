local utils = require("common.utils")
local C = require("common.color")
local debounce = require("common.debounce")
local log = require("common.log")
-- local funcs = require("functions")
local map = utils.map
local augroup = utils.augroup
local autocmd = utils.autocmd
-- local create_augroup = utils.create_augroup

local ex = nvim.ex
local api = vim.api
local fn = vim.fn
local g = vim.g

local debounced
local has_sourced

augroup(
    "lmb__Testing",
    {
        event = "BufRead",
        pattern = ("%s*"):format(fn.stdpath("config")),
        desc = "Set git environment variables for nvim bare repo",
        command = function()
            if not has_sourced then
                has_sourced =
                    debounce(
                    function()
                        vim.env.GIT_WORK_TREE = os.getenv("DOTBARE_TREE")
                        vim.env.GIT_DIR = os.getenv("DOTBARE_DIR")
                        log.info("Sourced git variables")
                    end,
                    10
                )
                has_sourced()
            end
        end
    }
)

-- === Highlight Disable === [[[
--[[
Credit: github.com/akinsho

The mappings below are essentially faked user input this is because in order to automatically turn off
the search highlight just changing the value of 'hlsearch' inside a function does not work
read `:h nohlsearch`.

To have this work, check that the current mouse position is not a search
result, if it is we leave highlighting on, otherwise I turn it off on cursor moved by faking my input
using the expr mappings below

This has been modified to only display the error message once

This is based on the implementation discussed here:
https://github.com/neovim/neovim/issues/5581
--]]
map({"n", "v", "o", "i", "c"}, "<Plug>(StopHL)", 'execute("nohlsearch")[-1]', {expr = true})
map("n", "<Esc><Esc>", "<Esc>:nohlsearch<CR>", {desc = "Disable hlsearch"})

local function stop_hl()
    if vim.v.hlsearch == 0 or api.nvim_get_mode().mode ~= "n" then
        return
    end
    api.nvim_feedkeys(utils.t("<Plug>(StopHL)"), "m", false)
end

---Check whether or not the current line matches the search string
---@return number, boolean, table|string
local function hl_search_ret()
    local col = nvim.win.get_cursor(0)[2]
    local curr_line = nvim.buf.line()
    return col, pcall(fn.matchstrpos, curr_line, nvim.reg["/"], 0)
end

---Determine when the highlighting is supposed to stop
---@param col number
---@param match table|string Can be: `Vim:E55:` or `{ "str", 20, 23 }`
local function hl_search_match(col, match)
    -- This shouldn't ever be called here
    if type(match) == "string" and match:match(":E55:") then
        stop_hl()
        return
    end

    local _, p_start, p_end = unpack(match)
    -- If the cursor is in a search result, leave highlighting on
    if col < p_start or col > p_end then
        stop_hl()
    end
end

---Execute the highlight search
---@param overwrite boolean should the register be overwritten
local function hl_search(overwrite)
    -- 0 false Vim:E55: Unmatched \)
    -- 20 true { "deb", 20, 23 }

    local col, ok, match = hl_search_ret()
    if not ok then
        if overwrite then
            nvim.reg["/"] = fn.histget("/", -2)
            log.warn("Register has been overwritten", true, {title = "HLSearch"})
        end

        if not debounced then
            debounced =
                debounce(
                function()
                    vim.notify(match, "error", {title = "HLSearch"})
                end,
                10
            )
            debounced()
        end
        return
    end

    hl_search_match(col, match)
end

augroup(
    "lmb__VimrcIncSearchHighlight",
    {
        event = {"CursorMoved"},
        command = function()
            hl_search(true)
        end
    },
    {
        event = {"InsertEnter"},
        command = function()
            stop_hl()
        end
    },
    {
        event = {"OptionSet"},
        pattern = {"hlsearch"},
        command = function()
            vim.schedule(
                function()
                    cmd("redrawstatus")
                    -- ex.redrawstatus()
                end
            )
        end
    }
)
-- === Highlight Disable ===

-- === Restore Cursor Position === [[[
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
                if fn.line("w$") ~= row then
                    cmd("norm! zz")
                -- ex.normal_("zz")
                end
            end
        end
    },
    {
        -- @source: https://vim.fandom.com/wiki/Use_gf_to_open_a_file_via_its_URL
        event = {"BufReadCmd"},
        pattern = {"file:///*"},
        nested = true,
        command = function(args)
            cmd(("bd!|edit %s"):format(vim.uri_to_fname(args.file)))
        end
    }
)

-- nvim.autocmd.lmb__RememberFolds = {
--     {
--         event = {"BufWritePre", "BufWinLeave"},
--         pattern = "?*",
--         command = function()
--             if funcs.makeview() then
--                 ex.silent_("mkview")
--             end
--         end,
--         desc = "Save folds"
--     },
--     {
--         event = "BufWinEnter",
--         pattern = "?*",
--         command = function()
--             if funcs.makeview() then
--                 ex.silent_("loadview")
--             end
--         end,
--         desc = "Restore folds from previous session"
--     }
-- }
-- ]]] === Restore cursor ===

-- === Set winbar === [[[
-- nvim.autocmd.lmb__WinbarSplit = {
--     event = "FileType",
--     pattern = "*",
--     command = function()
--         local bufnr = api.nvim_get_current_buf()
--         local tp = api.nvim_get_current_tabpage()
--         local wins = #api.nvim_tabpage_list_wins(tp)
--
--         if vim.bo[bufnr].bt == "" then
--             if wins > 1 then
--                 o.winbar = [[%m %F]]
--             else
--                 o.winbar = nil
--             end
--         end
--     end,
--     desc = "Enable winbar when window is split"
-- }
--- ]]]

-- === Telescope Fixes === [[[
nvim.autocmd.lmb__TelescopeFixes = {
    event = "FileType",
    pattern = "Telescope*",
    command = function()
        -- map("i", "<Leader>", " ", {nowait = true})

        autocmd(
            {
                event = "CmdlineEnter",
                pattern = "*",
                once = true,
                command = function()
                    require("wilder").disable()
                end
            }
        )
    end,
    desc = "Disable Wilder in Telescope"
}
-- ]]] === Telescope Fixes ===

-- === Format Options === [[[
-- Whenever set globally these don't seem to work, I'm assuming
-- this is because other plugins overwrite them.
--
-- Without FileType, the first buffer that is loaded does not have these settings applied
do
    local o = vim.opt_local

    nvim.autocmd.lmb__FormatOptions = {
        event = {"BufEnter", "FileType"},
        pattern = "*",
        command = function()
            -- Buffer option here doesn't work like global
            -- o.formatoptions:remove({"c", "r", "o"})
            o.formatoptions = {
                ["1"] = true,
                ["2"] = true, -- Use indent from 2nd line of a paragraph
                q = true, -- Continue comments with gq"
                n = true, -- Recognize numbered lists
                j = true, -- Remove a comment leader when joining lines.
                -- Only break if the line was not longer than 'textwidth' when the insert
                -- started and only at a white character that has been entered during the
                -- current insert command.
                l = true,
                v = true, -- Only break line at blank line I've entered
                c = true, -- Auto-wrap comments using textwidth
                r = false, -- Continue comments when pressing Enter
                t = false, -- Autowrap lines using text width value
                o = false --- Automatically insert comment leader after <enter>
            }
            o.conceallevel = 2
            o.concealcursor = "vc"

            -- Allows a shared statusline
            if b.ft ~= "fzf" then
                o.laststatus = 3
            end
        end,
        desc = "Setup format options"
    }
end
-- ]]] === Format Options ===

-- ╭──────────────────────────────────────────────────────────╮
-- │                Colorscheme Modifications                 │
-- ╰──────────────────────────────────────────────────────────╯
nvim.autocmd.lmb__ColorschemeSetup = {
    event = "ColorScheme",
    pattern = "*",
    command = function()
        C.all(
            {
                TSVariableBuiltin = {default = true, gui = "none"},
                TSTypeBuiltin = {default = true, gui = "none"},
                TSProperty = {default = true, gui = "none"},
                TSVariable = {default = true, gui = "none"},
                TSKeyword = {default = true, gui = "none"},
                TSConditional = {default = true, gui = "none"},
                TSString = {default = true, gui = "none"},
                TSKeywordFunction = {default = true, gui = "none"},
                TSFunction = {default = true, bold = true},
                TSFuncBuiltin = {default = true, bold = true},
                Function = {default = true, gui = "bold"},
                Todo = {default = true, bg = "none"},
                QuickFixLine = {default = true, fg = "none"}
                -- TSConstBuiltin = {default = true, gui = "none"},
                -- TSMethod = {default = true, gui = "bold"},
                -- Hlargs = {link = "TSParameter"} -- This overrides TSParameter
            }
        )

        if g.colors_name ~= "kimbox" then
            C.all(
                {
                    Hlargs = {link = "TSParameter"}
                }
            )
        end
    end,
    desc = "Override highlight groups"
}

-- === Remove Empty Buffers === [[[
nvim.autocmd.lmb__FirstBuf = {
    event = "BufHidden",
    command = function()
        require("common.builtin").wipe_empty_buf()
    end,
    buffer = 0,
    once = true,
    desc = "Remove first empty buffer"
}
-- ]]]

-- === Disable Undofile === [[[
nvim.autocmd.lmb__DisableUndofile = {
    event = "BufWritePre",
    pattern = {"COMMIT_EDITMSG", "MERGE_MSG", "gitcommit", "*.tmp", "*.log"},
    command = function()
        vim.bo.undofile = false
    end
}
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
        desc = "Add file to custom MRU list"
    }
)
-- ]]]

-- === Spelling === [[[
augroup(
    "lmb__Spellcheck",
    {
        event = "FileType",
        pattern = {"gitcommit", "markdown", "text", "mail", "vimwiki"},
        command = "setlocal spell",
        desc = "Automatically enable spelling"
    },
    {
        event = {"BufRead", "BufNewFile"},
        pattern = "neomutt-archbox*",
        command = "setlocal spell",
        desc = "Automatically enable spelling"
    }
)
-- ]]] === Spelling ===

-- === Terminal === [[[
nvim.autocmd.lmb__TermFix = {
    event = "TermEnter",
    pattern = "*",
    command = function()
        vim.schedule(
            function()
                ex.nohlsearch()
                fn.clearmatches()
            end
        )
    end,
    desc = "Clear matches and highlights when entering a terminal"
}

nvim.autocmd.lmb__TermMappings = {
    -- pattern = "term://*toggleterm#*",
    event = "TermOpen",
    pattern = "term://*",
    command = function()
        -- vim.wo.statusline = "%{b:term_title}"
        require("plugs.neoterm").set_terminal_keymaps()
        vim.wo.number = false
        vim.wo.relativenumber = false
    end,
    desc = "Set terminal mappings"
}

-- nvim.autocmd.lmb__TermClose = {
--     event = {"TermClose"},
--     pattern = "*",
--     command = function()
--         if vim.v.event.status == 0 then
--             local info = api.nvim_get_chan_info(vim.opt.channel._value)
--             if not info or not info.argv then
--                 return
--             end
--             if info.argv[1] == vim.env.SHELL then
--                 pcall(api.nvim_buf_delete, 0, {})
--             end
--         end
--     end,
--     desc = "Automatically close a terminal buffer"
-- }
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
                -- pcall needed when opening a TOC inside a help page and returning to help page
                pcall(ex.wincmd, "L")
                cmd("vertical resize " .. width)
                map("n", "qq", "q", {cmd = true, buffer = bufnr})
            end
        end,
        desc = "Equalize and create mapping for help pages"
    },
    {
        -- This is ran more than once
        -- NOTE: Using help for this won't open vertical when opening the same thing twice in a row
        --      since the FileType autocmd is only ran once
        event = "FileType",
        pattern = {"man"},
        once = false,
        command = function()
            local bufnr = nvim.buf.nr()
            if split_should_return() then
                return
            end

            local width = math.floor(vim.o.columns * 0.75)
            pcall(ex.wincmd, "L")
            cmd("vertical resize " .. width)
            map("n", "qq", "q", {cmd = true, buffer = bufnr})
        end,
        desc = "Equalize and create mapping for manpages"
    },
    -- NOTE: Works when opening man with ':Man' but not with telescope or fzf-lua
    --       if the event is BufHidden. However, BufLeave fixes this problem
    {
        -- event = "BufLeave",
        event = "BufHidden",
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
        end,
        desc = "Delete hidden man buffers"
    }
}
-- ]]] === Help ===

-- === Smart Close === [[[
local smart_close_filetypes = {
    -- 'help',
    -- 'qf',
    "godoc",
    "git",
    "git-status",
    "git-log",
    "bufferize",
    "gitcommit",
    "dbui",
    "fugitive",
    "fugitiveblame",
    "LuaTree",
    "log",
    "Outline",
    "tsplayground",
    "floggraph",
    "vista",
    "aerial", -- has its own mapping but is slow
    "scratchpad",
    "startuptime"
}

local function smart_close()
    if fn.winnr("$") ~= 1 then
        api.nvim_win_close(0, true)
    end
    -- For floggraph
    -- if fn.tabpagewinnr("$") ~= 1 then
    --     ex.tabc()
    -- end
end

nvim.autocmd.lmb__SmartClose = {
    {
        event = "FileType",
        pattern = "*",
        command = function()
            local is_unmapped = fn.hasmapto("q", "n") == 0
            local is_eligible = is_unmapped or vim.wo.previewwindow or _t(smart_close_filetypes):contains(vim.bo.ft)

            if is_eligible then
                map("n", "qq", smart_close, {buffer = 0, nowait = true})
            end
        end,
        desc = "Create qq mapping"
    },
    {
        -- Close quick fix window if the file containing it was closed
        event = "BufEnter",
        pattern = "*",
        command = function()
            if fn.winnr("$") == 1 and vim.bo.buftype == "quickfix" then
                api.nvim_buf_delete(0, {force = true})
            end

            -- Hide cursorline on popup
            local bufnr = api.nvim_get_current_buf()
            local bufname = api.nvim_buf_get_name(bufnr)
            if bufname == "[No Name]" then
                vim.opt_local.cursorline = false
            end

            -- if bufname:match("%[Wilder Float %d%]") then
            --     vim.opt_local.buflisted = false
            -- end
        end,
        desc = "Close QuickFix if last window, disable cursorline on [No Name]"
    },
    {
        -- Automatically close corresponding loclist when quitting a window
        event = "QuitPre",
        pattern = "*",
        nested = true,
        command = function()
            if vim.bo.filetype ~= "qf" then
                cmd("sil! lcl")
            -- ex.silent_("lclose")
            end
        end,
        desc = "Close loclist when quitting window"
    }
}
-- ]]]

-- === Filetype Detection === [[[
-- Used for something like a file named 'x' and then #!/usr/bin/env zsh is written as a shebang
nvim.autocmd.lmb__FiletypeDetect = {
    event = {"BufWritePost"},
    pattern = {"*"},
    nested = true,
    command = function()
        if utils.empty(vim.bo.filetype) or fn.exists("b:ftdetect") == 1 then
            vim.b.ftdetect = nil
            ex.filetype("detect")
            utils.cool_echo(("Filetype set to %s"):format(vim.bo.ft), "Macro")
        end
    end,
    desc = "Set filetype after modification"
}
-- ]]]

-- === File Enhancements === [[[
nvim.autocmd.lmb__LargeFileEnhancement = {
    event = "BufRead",
    desc = "Optimize the viewing of larger files",
    command = function()
        if vim.bo.ft == "help" then
            return
        end

        local size = fn.getfsize(fn.expand("%"))
        if size > 1024 * 1024 * 5 then
            local hlsearch = vim.opt.hlsearch
            local lazyredraw = vim.opt.lazyredraw
            local showmatch = vim.opt.showmatch

            vim.bo.undofile = false
            vim.wo.colorcolumn = ""
            vim.wo.relativenumber = false
            vim.wo.foldmethod = "manual"
            vim.wo.spell = false
            vim.opt.hlsearch = false
            vim.opt.lazyredraw = true
            vim.opt.showmatch = false

            autocmd(
                {
                    event = "BufDelete",
                    buffer = 0,
                    command = function()
                        vim.opt.hlsearch = hlsearch
                        vim.opt.lazyredraw = lazyredraw
                        vim.opt.showmatch = showmatch
                    end,
                    desc = "Restore settings from optimizing large files"
                }
            )
        end
    end
}
-- ]]]

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
            event = {"TermEnter", "BufEnter"},
            pattern = "*",
            once = false,
            command = function()
                local bufnr = nvim.buf.nr()

                -- I have TMUX already automatically change title
                -- It sets it to titlestring
                if vim.bo[bufnr].bt == "" then
                    o.titlestring = fn.expand("%:t")
                elseif vim.bo[bufnr].bt == "terminal" then
                    if vim.bo[bufnr].ft == "toggleterm" then
                        o.titlestring = "ToggleTerm #" .. vim.b.toggle_number
                    else
                        o.titlestring = "Terminal"
                    end
                end
            end,
            desc = "Automatic rename of tmux window"
        },
        {
            event = "VimLeave",
            pattern = "*",
            command = function()
                os.execute("tmux set-window automatic-rename on")
            end,
            desc = "Turn back on Tmux auto-rename"
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
                    if api.nvim_get_mode().mode == "n" then
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
    local o = vim.o

    nvim.autocmd.lmb__VimResize = {
        -- {
        --     event = "VimResized",
        --     command = function()
        --         local last_tab = api.nvim_get_current_tabpage()
        --         ex.tabdo("wincmd =")
        --         api.nvim_set_current_tabpage(last_tab)
        --     end,
        --     desc = "Equalize windows across tabs"
        -- },
        {
            event = {"VimEnter", "VimResized"},
            command = function()
                o.previewheight = math.floor(o.lines / 3)
            end,
            desc = "Update previewheight as per the new Vim size"
        }
    }
end -- ]]]

-- === Custom file type settings === [[[
augroup(
    "lmb__CustomFileType",
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
                        require("common.utils").preserve("keepj keepp %s/\\s\\+$//ge")

                        -- Delete trailing blank lines
                        require("common.utils").preserve([[keepj keepp %s#\($\n\s*\)\+\%$##e]])

                        -- Delete trailing blank lines at end of file
                        -- require("common.utils").preserve([[keepj keepp 0;/^\%(\n*.\)\@!/,$d]])

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
--         command = function()
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

C.all({cmTitle = {link = "vimCommentTitle", default = true}})
-- ex.hi("def link cmTitle vimCommentTitle")
-- ex.hi("def link myTodo Todo")
-- ex.hi("def link cmLineComment Comment")

-- ]]] === Custom syntax groups ===

-- ======================= CursorLine Control ========================= [[[
---Cursorline highlighting control
--- Only have it on in the active buffer
do
    local id = utils.create_augroup("lmb__CursorLineControl")
    local set_cursorline = function(event, value, pattern)
        nvim.autocmd.add(
            {
                event = event,
                group = id,
                pattern = pattern,
                command = function()
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
        desc = "Reload file when modified outside of the instance"
    },
    {
        event = "FileChangedShellPost",
        pattern = "*",
        command = function()
            nvim.p("File changed on disk. Buffer reloaded!", "WarningMsg")
        end,
        desc = "Display a message if the buffer is changed outside of instance"
    }
}
-- ]]] === Buffer Reload ===

-- =========================== RNU Column ============================= [[[
---Toggle relative/non-relative nubmers:
---  - Only in the active window
---  - Ignore quickfix window
---  - Only when searching in cmdline or in insert mode

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

-- augroup(
--     "lmb__SetFocus",
--     {
--         event = "FocusGained",
--         desc = "Set `nvim_focused` to true",
--         command = function()
--             g.nvim_focused = true
--         end
--     },
--     {
--         event = "FocusLost",
--         desc = "Set `nvim_focused` to false",
--         command = function()
--             g.nvim_focused = false
--         end
--     }
-- )

-- autocmd(
--     {
--         event = "VimEnter",
--         pattern = "*",
--         command = [[call vista#RunForNearestMethodOrFunction()]]
--     }
-- )

-- ============================== Unused ============================== [[[
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
-- ]]] === Unused ===
