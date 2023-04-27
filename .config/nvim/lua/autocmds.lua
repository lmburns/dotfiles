local D = require("dev")
local debounce = require("common.debounce")
local log = require("common.log")
local Job = require("plenary.job")
local a = require("plenary.async_lib")

local funcs = require("functions")
local utils = require("common.utils")

local W = require("common.api.win")
local mpi = require("common.api")
local map = mpi.map
local augroup = mpi.augroup
local autocmd = mpi.autocmd

local cmd = vim.cmd
local api = vim.api
local fn = vim.fn
local env = vim.env
local g = vim.g
local o = vim.opt
local ol = vim.opt_local

local has_sourced
local exclude_ft = _t(BLACKLIST_FT):filter(utils.lambda("x -> x ~= ''"))
local exclude_bt = _t({"nofile"})

---
---@param bufnr number
---@return boolean
local function should_exclude(bufnr)
    if
        fn.expand("%") == "" or exclude_ft:contains(vim.bo[bufnr].ft) or
        exclude_bt:contains(vim.bo[bufnr].bt) or
        W.win_is_float()
    then
        return true
    end
    return false
end

nvim.autocmd.lmb__GitEnv = {
    event = {"BufEnter"},
    pattern = "*",
    desc = "Set git environment variables for dotfiles bare repo",
    command = function()
        -- Has to be deferred otherwise something like a terminal buffer doesn't show
        vim.defer_fn(
            function()
                local curr_file = fn.expand("%")
                local bufnr = api.nvim_get_current_buf()
                -- Can't use the buffer from args passed to this function
                local ft = api.nvim_buf_get_option(bufnr, "filetype")
                if not fn.filereadable(curr_file) or exclude_ft:contains(ft) then
                    return
                end

                -- if not fn.filereadable(curr_file) or should_exclude(bufnr) == true then
                --     return
                -- end

                local _, ret =
                    Job:new(
                        {
                            command = "dotbare",
                            args = {"ls-files", "--error-unmatch", curr_file},
                            on_exit = function(_, ret)
                                return ret
                            end,
                        }
                    ):sync()

                if ret == 0 then
                    if not has_sourced then
                        has_sourced =
                            debounce(
                                function()
                                    env.GIT_WORK_TREE = os.getenv("DOTBARE_TREE")
                                    env.GIT_DIR = os.getenv("DOTBARE_DIR")
                                end,
                                10
                            )
                    end

                    -- nvim.p(("bufnr: %d is using DOTBARE"):format(bufnr), "TSConstructor")
                    has_sourced()
                end
            end,
            1
        )
    end,
}

-- === Macro Recording === [[[
nvim.autocmd.lmb__MacroRecording = {
    {
        event = "RecordingEnter",
        pattern = "*",
        command = function()
            local msg = ("壘Recording @%s"):format(fn.reg_recording())
            vim.notify(msg, vim.log.levels.INFO, {title = "Macro", icon = ""})
        end,
    },
    {
        event = "RecordingLeave",
        pattern = "*",
        command = function()
            local event = vim.v.event
            local msg = (" Recorded @%s\n%s"):format(event.regname, event.regcontents)
            log.info(msg, {title = "Macro", icon = ""})
        end,
    },
}
-- ]]] === Macro Recording ===

-- === Restore Cursor Position === [[[
nvim.autocmd.lmb__RestoreCursor = {
    {
        event = "BufReadPost",
        pattern = "*",
        command = function(args)
            -- local bufnr = args.buf
            -- if should_exclude(bufnr) == true then
            --     return
            -- end

            -- local types =
            --     _t(
            --     {
            --         "nofile",
            --         "fugitive",
            --         "gitcommit",
            --         "gitrebase",
            --         "commit",
            --         "rebase",
            --         "help"
            --     }
            -- )

            if
                fn.expand("%") == "" or exclude_ft:contains(vim.bo.ft) or vim.bo.bt == "nofile" or
                W.win_is_float(0)
            then
                return
            end

            local mark = nvim.mark['"']
            local row, col = mark.row, mark.col
            if {row, col} ~= {0, 0} and row <= nvim.buf.line_count(0) then
                mpi.set_cursor(0, row, 0)
                funcs.center_next([[g`"zv']])
            end
        end,
    },
    {
        -- @source: https://vim.fandom.com/wiki/Use_gf_to_open_a_file_via_its_URL
        event = {"BufReadCmd"},
        pattern = {"file:///*"},
        nested = true,
        command = function(args)
            cmd.bdelete({bang = true})
            cmd.edit(vim.uri_to_fname(args.file))
        end,
    },
}
-- ]]] === Restore cursor ===

-- === Folds === [[[
-- nvim.autocmd.lmb__RememberFolds = {
--     {
--         event = {"BufWritePre", "BufWinLeave"},
--         pattern = "?*",
--         command = function()
--             if funcs.makeview() then
--                 cmd.silent({"mkview", bang = true})
--             end
--         end,
--         desc = "Save folds"
--     },
--     {
--         event = "BufWinEnter",
--         pattern = "?*",
--         command = function()
--             if funcs.makeview() then
--                 cmd.silent({"loadview", bang = true})
--             end
--         end,
--         desc = "Restore folds from previous session"
--     }
-- }
-- ]]] === Folds ===

-- === Format Options === [[[
-- Whenever set globally these don't seem to work, I'm assuming
-- this is because other plugins overwrite them.
nvim.autocmd.lmb__FormatOptions = {
    event = {"FileType"},
    pattern = "*",
    command = function(_args)
        vim.schedule(
            function()
                ol.formatoptions:append(
                    {
                        ["1"] = true, -- don't break a line after a one-letter word; break before
                        -- ["2"] = false, -- use indent from 2nd line of a paragraph
                        q = true,     -- format comments with gq"
                        n = true,     -- recognize numbered lists. Indent past formatlistpat not under
                        M = true,     -- when joining lines, don't insert a space before or after a multibyte char
                        j = true,     -- remove a comment leader when joining lines.
                        -- Only break if the line was not longer than 'textwidth' when the insert
                        -- started and only at a white character that has been entered during the
                        -- current insert command.
                        l = true,
                        v = false,                -- only break line at blank line I've entered
                        c = false,                -- auto-wrap comments using textwidth
                        t = false,                -- autowrap lines using text width value
                        p = true,                 -- don't break lines at single spaces that follow periods
                        ["/"] = true,             -- when 'o' included: don't insert comment leader for // comment after statement
                        r = funcs.set_formatopts, -- continue comments when pressing Enter
                        o = funcs.set_formatopts, -- auto insert comment leader after 'o'/'O'
                    }
                )

                -- Allow
                -- * in comments
                -- * * to autoformat
                -- ol.comments:prepend(
                --     {
                --         "nb:/// *",
                --         "nb://! *",
                --         "nb:// *",
                --         "nb:--- *",
                --         "nb:-- *",
                --         "nb:# *",
                --         "nb:*",
                --         "nb:/// -",
                --         "nb://! -",
                --         "nb:// -",
                --         "nb:--- -",
                --         "nb:-- -",
                --         "nb:# -",
                --         "nb:-",
                --         "nb:/// +",
                --         "nb://! +",
                --         "nb:// +",
                --         "nb:--- +",
                --         "nb:-- +",
                --         "nb:# +",
                --         "nb:+",
                --     }
                -- )

                -- Bufnr has to be captured in here, not args.buf
                local bufnr = api.nvim_get_current_buf()
                local ft = vim.bo[bufnr].ft

                vim.wo.conceallevel = 2
                vim.wo.concealcursor = "c"

                if ft == "jsonc" or ft == "json" then
                    vim.wo.conceallevel = 0
                end

                -- Allows a shared statusline
                if ft ~= "fzf" then
                    ol.laststatus = 3
                end
            end
        )
    end,
    desc = "Setup format options",
}
-- ]]] === Format Options ===

-- === Remove Empty Buffers === [[[
nvim.autocmd.lmb__FirstBuf = {
    event = "BufHidden",
    command = function()
        require("common.builtin").wipe_empty_buf()
    end,
    buffer = 0,
    once = true,
    desc = "Remove first empty buffer",
}
-- ]]]

-- === Disable Undofile === [[[
nvim.autocmd.lmb__DisableUndofile = {
    {
        event = "BufWritePre",
        pattern = {
            "COMMIT_EDITMSG",
            "MERGE_MSG",
            "gitcommit",
            "*.tmp",
            "*.log",
            "/dev/shm/*",
        },
        command = function(args)
            vim.bo[args.buf].undofile = false

            if utils.mod.plugin_loaded("fundo") then
                require("fundo").disable()
            end
        end,
    },
    {
        event = "FileType",
        pattern = {"crontab"},
        command = function(args)
            vim.bo[args.buf].undofile = false

            if utils.mod.plugin_loaded("fundo") then
                require("fundo").disable()
            end
        end,
    },
}
-- ]]]

-- === MRU === [[[
nvim.autocmd.lmb__MruWin = {
    event = "WinLeave",
    pattern = "*",
    command = function()
        require("common.win").record()
    end,
    desc = "Add file to custom MRU list",
}
-- ]]]

-- === Spelling === [[[
nvim.autocmd.lmb__Spellcheck = {
    {
        event = "FileType",
        pattern = {"markdown", "text", "mail", "vimwiki"},
        command = "setlocal spell",
        desc = "Automatically enable spelling",
    },
    {
        event = {"BufRead", "BufNewFile"},
        pattern = "neomutt-archbox*",
        command = "setlocal spell",
        desc = "Automatically enable spelling",
    },
}
-- ]]] === Spelling ===

-- === Help/Man pages in vertical ===
local split_should_return = function()
    -- do nothing for floating windows
    local cfg = api.nvim_win_get_config(0)
    if
        (cfg and (cfg.external or cfg.relative and #cfg.relative > 0)) or
        api.nvim_win_get_height(0) == 1
    then
        return true
    end
    -- do not run if Diffview is open
    if g.diffview_nvim_loaded and require("diffview.lib").get_current_view() then
        return true
    end

    return false
end

local debounced
nvim.autocmd.lmb__Help = {
    {
        event = "BufEnter",
        pattern = "*.txt",
        command = function(args)
            local bufnr = args.buf
            if vim.bo[bufnr].bt == "help" then
                -- Shouldn't have to check for explicit truth
                if split_should_return() == true then
                    return
                end

                -- map("n", "qq", "helpclose", {cmd = true, buffer = bufnr})
                map("n", "qq", "q", {cmd = true, buffer = bufnr})
            end
        end,
        desc = "Create mapping for help pages",
    },
    {
        event = "BufEnter",
        pattern = "*.txt",
        once = false,
        command = function(args)
            local bufnr = args.buf
            if vim.bo[bufnr].bt == "help" then
                if not debounced then
                    debounced =
                        debounce:new(
                            function()
                                -- pcall needed when opening a TOC inside a help page and returning to help page
                                pcall(cmd.wincmd, "L")
                                -- local width = math.floor(vim.o.columns * 0.75)
                                -- cmd("vertical resize " .. width)
                                cmd("vertical resize 85")
                            end,
                            0
                        )
                end
                debounced()
            end
        end,
        desc = "Set help split width",
    },
    {
        event = "BufLeave",
        pattern = "*.txt",
        command = function(args)
            -- Prevents resize from happening when going from Help buffer => Other buffer
            local bufnr = args.buf
            if vim.bo[bufnr].bt == "help" then
                debounced = function()
                end
            end
        end,
        desc = "Set help split width (set debounce to empty)",
    },
    {
        event = "BufWinLeave",
        pattern = "*.txt",
        command = function(args)
            -- Allows resize to happen when closing Help buffer & opening it again
            local bufnr = args.buf
            if vim.bo[bufnr].bt == "help" then
                debounced = nil
            end
        end,
        desc = "Set help split width (reset debounce)",
    },
    {
        event = "FileType",
        pattern = {"man"},
        once = false,
        command = function(args)
            local bufnr = args.buf
            if split_should_return() == true then
                return
            end

            pcall(cmd.wincmd, "L")
            local width = math.floor(vim.o.columns * 0.75)
            cmd("vertical resize " .. width)
            -- cmd("vertical resize 82")
            map("n", "qq", "q", {cmd = true, buffer = bufnr})
        end,
        desc = "Equalize and create mapping for manpages",
    },
    {
        event = "BufHidden",
        pattern = "man://*",
        command = function(args)
            local bufnr = args.buf
            if vim.bo[bufnr].ft == "man" then
                vim.defer_fn(
                    function()
                        if api.nvim_buf_is_valid(bufnr) then
                            api.nvim_buf_delete(bufnr, {force = true})
                        end
                    end,
                    0
                )
            end
        end,
        desc = "Delete hidden man buffers",
    },
}
-- ]]] === Help ===

-- === Smart Close === [[[
local sc_filetypes =
    _t(
        {
            -- 'help',
            -- 'qf',
            "LuaTree",
            "Outline",
            "aerial", -- has its own mapping but is slow
            "bufferize",
            "dbui",
            "floggraph",
            "fugitive",
            "fugitiveblame",
            "git",
            "git-log",
            "git-status",
            "gitcommit",
            "godoc",
            "log",
            "lspinfo",
            "neotest-summary",
            "scratchpad",
            "startuptime",
            "tsplayground",
            "vista",
        }
    )

local sc_buftypes = _t({})
local sc_titles = _t({"option-window", "%[Command Line%]", "Luapad"})
local sc_title_bufenter = _t({"__coc_refactor__%d%d?"})

local function smart_close()
    if fn.winnr("$") ~= 1 then
        api.nvim_win_close(0, true)
    end

    -- For floggraph
    -- if fn.tabpagewinnr("$") ~= 1 then
    --     cmd.tabc()
    -- end
end

nvim.autocmd.lmb__SmartClose = {
    {
        event = "FileType",
        pattern = "*",
        command = function(args)
            local bufnr = args.buf
            local is_unmapped = fn.hasmapto("q", "n") == 0
            local is_eligible =
                is_unmapped or vim.wo.previewwindow or sc_filetypes:contains(vim.bo[bufnr].ft) or
                sc_buftypes:contains(vim.bo[bufnr].bt) or
                sc_titles:contains_fn(
                    function(t)
                        return fn.bufname():match(t)
                    end
                )

            if is_eligible then
                map("n", "qq", smart_close, {buffer = bufnr, nowait = true})
            end
        end,
        desc = "Create a smart qq (close) mapping",
    },
    {
        event = "BufEnter",
        pattern = "*",
        command = function(args)
            local bufnr = args.buf
            local is_unmapped = fn.hasmapto("q", "n") == 0
            local is_eligible =
                is_unmapped or
                sc_title_bufenter:contains_fn(
                    function(t)
                        return fn.bufname():match(t)
                    end
                )

            if is_eligible then
                map("n", "qq", smart_close, {buffer = bufnr, nowait = true})
            end
        end,
        desc = "Create a smart qq (close) mapping",
    },
    {
        event = "BufEnter",
        pattern = "option-window",
        command = function(args)
            local bufnr = args.buf
            vim.bo[bufnr].bufhidden = "wipe"
        end,
        desc = "Delete hidden option-windows",
    },
    {
        -- Close quick fix window if the file containing it was closed
        event = "BufEnter",
        pattern = "*",
        command = function(args)
            -- local bufnr = args.buf
            -- fn.winnr("$") == 1
            local bufnr = api.nvim_get_current_buf()
            -- N(("passed: %s - new: %s"):format(args.buf, bufnr))
            if fn.winnr("$") == fn.winnr() and vim.bo[bufnr].buftype == "quickfix" then
                -- N("hit")
                -- api.nvim_buf_delete(bufnr, {force = true})
                cmd("q")
            end

            -- Hide cursorline on popup
            local bufname = api.nvim_buf_get_name(bufnr)
            if bufname == "[No Name]" then
                ol.cursorline = false
                -- vim.wo.cursorline = true
            end

            -- if bufname:match("%[Wilder Float %d%]") then
            --     ol.buflisted = false
            -- end
        end,
        desc = "Close QuickFix if last window, disable cursorline on [No Name]",
    },
    -- {
    --     -- Close quick fix window if the file containing it was closed
    --     event = "WinEnter",
    --     pattern = "*",
    --     command = function(args)
    --         local bufnr = args.buf
    --         if fn.winnr("$") == fn.winnr() and vim.bo.buftype == "quickfix" then
    --             -- api.nvim_buf_delete(bufnr, {force = true})
    --             cmd("q")
    --         end
    --     end,
    --     desc = "Close QuickFix if last window, disable cursorline on [No Name]"
    -- },
    {
        -- Automatically close corresponding loclist when quitting a window
        event = "QuitPre",
        pattern = "*",
        nested = true,
        command = function(args)
            local bufnr = args.buf
            if vim.bo[bufnr].filetype ~= "qf" then
                cmd.lcl({mods = {silent = true}})
            end
        end,
        desc = "Close loclist when quitting window",
    },
}
-- ]]]

-- === Autoscroll === [[[
-- TODO: Works but breaks aerial
-- nvim.autocmd.__lmbFixAutoScroll = {
--     {
--         event = "BufLeave",
--         pattern = "*",
--         command = function()
--             -- current buf is the buffer we've left
--             -- but current window already changed,
--             -- verify neither source nor destination are floating windows
--             local from_buf = api.nvim_get_current_buf()
--             local from_win = fn.bufwinid(from_buf)
--             local to_win = api.nvim_get_current_win()
--             if not W.win_is_float(to_win) and not W.win_is_float(from_win) then
--                 -- vim.b.__VIEWSTATE = W.win_save_positions(from_buf)
--                 vim.b.__VIEWSTATE = fn.winsaveview()
--             end
--         end,
--         desc = "Avoid autoscroll when switching buffers",
--     },
--     {
--         event = "BufEnter",
--         pattern = "*",
--         command = function()
--             if vim.b.__VIEWSTATE then
--                 local to_win = api.nvim_get_current_win()
--                 if not W.win_is_float(to_win) then
--                     -- vim.b.__VIEWSTATE.restore()
--                     fn.winrestview(vim.b.__VIEWSTATE)
--                 end
--                 vim.b.__VIEWSTATE = nil
--             end
--         end,
--         desc = "Avoid autoscroll when switching buffers",
--     },
-- }
-- ]]]

-- === Filetype Detection === [[[
-- Used for something like a file named 'x' and then #!/usr/bin/env zsh is written as a shebang
nvim.autocmd.lmb__FiletypeDetect = {
    event = {"BufWritePost"},
    pattern = {"*"},
    nested = true,
    command = function(args)
        local bufnr = args.buf
        if utils.is.empty(vim.bo[bufnr].filetype) or fn.exists("b:ftdetect") == 1 then
            vim.b.ftdetect = nil
            cmd.filetype("detect")
            utils.cecho(("Filetype set to %s"):format(vim.bo[bufnr].ft), "Macro")
        end
    end,
    desc = "Set filetype after modification",
}
-- ]]]

-- === File Enhancements === [[[
nvim.autocmd.lmb__LargeFileEnhancement = {
    event = "BufRead",
    desc = "Optimize the viewing of larger files",
    command = function(args)
        local bufnr = args.buf
        local size = fn.getfsize(fn.expand("%"))
        if size > 1024 * 1024 * 2 then
            local winid = fn.bufwinid(bufnr)
            local hlsearch = vim.opt.hlsearch
            local lazyredraw = vim.opt.lazyredraw
            local showmatch = vim.opt.showmatch

            vim.bo[bufnr].undofile = false
            vim.wo[winid].colorcolumn = ""
            vim.wo[winid].relativenumber = false
            vim.wo[winid].foldmethod = "manual"
            vim.wo[winid].spell = false
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
                    desc = "Restore settings from optimizing large files",
                }
            )
        end
    end,
}
-- ]]]

-- ======================= CursorLine Control ========================= [[[
nvim.autocmd.lmb__CursorLineCurrWin = {
    {
        event = {"WinEnter", "FocusGained", "CmdlineLeave"}, -- "InsertLeave"
        command = function()
            if vim.w.auto_cursorline then
                vim.wo.cursorline = true
                vim.w.auto_cursorline = nil
            end
        end,
        desc = "Hide cursorline when entering window",
    },
    {
        event = {"WinLeave", "FocusLost", "CmdlineEnter"}, -- "InsertEnter"
        command = function()
            local cl = vim.wo.cursorline
            if cl then
                vim.w.auto_cursorline = cl
                vim.wo.cursorline = false
            end
        end,
        desc = "Hide cursorline when leaving window",
    },
}
-- ]]]

-- === Tmux === [[[
if env.TMUX ~= nil and env.NORENAME == nil then
    nvim.autocmd.lmb__RenameTmux = {
        {
            event = {"TermEnter", "BufEnter"},
            pattern = "*",
            once = false,
            command = function(args)
                local bufnr = args.buf
                if vim.bo[bufnr].bt == "" then
                    o.titlestring = funcs.title_string()
                elseif vim.bo[bufnr].bt == "terminal" then
                    if vim.bo[bufnr].ft == "toggleterm" then
                        o.titlestring = "ToggleTerm #" .. vim.b.toggle_number
                    else
                        o.titlestring = "Terminal"
                    end
                end
            end,
            desc = "Automatic rename of tmux window",
        },
        {
            event = "VimLeave",
            pattern = "*",
            command = function()
                -- o.titleold = ("%s %s"):format(fn.fnamemodify(os.getenv("SHELL"), ":t"), global.name)
                o.titleold = fn.fnamemodify(os.getenv("SHELL"), ":t")
                pcall(os.execute, "tmux set-window automatic-rename on")
            end,
            desc = "Turn back on Tmux auto-rename",
        },
    }
end
-- ]]] === Tmux ===

-- === Terminal === [[[
nvim.autocmd.lmb__TermFix = {
    event = "TermEnter",
    pattern = "*",
    command = function()
        vim.schedule(
            function()
                cmd.nohlsearch()
                fn.clearmatches()
            end
        )
    end,
    desc = "Clear matches & highlights when entering a terminal",
}

nvim.autocmd.lmb__TermMappings = {
    -- pattern = "term://*toggleterm#*",
    event = "TermOpen",
    pattern = "term://*",
    command = function(args)
        -- vim.wo.statusline = "%{b:term_title}"
        require("plugs.neoterm").set_terminal_keymaps()
        vim.wo.number = false
        vim.wo.relativenumber = false
        vim.bo.bufhidden = "hide"

        if vim.bo[args.buf].bt == "terminal" then
            cmd("startinsert!")
        end
    end,
    desc = "Set terminal mappings",
}

do
    local timer
    local timeout = 6000

    -- Automatically clear command-line messages after a few second delay
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
                        if utils.mode() == "n" then
                            api.nvim_echo({}, false, {})
                        end
                    end,
                    timeout
                )
        end,
        desc = ("Clear command-line messages after %d seconds"):format(timeout / 1000),
    }
end

-- === Custom file type settings === [[[
-- nvim.autocmd.lmb__CustomFileType = {
--     {
--         event = "BufWritePre",
--         pattern = {"*.odt", "*.rtf"},
--         command = [[silent set ro]]
--     },
--     {
--         event = "BufWritePre",
--         pattern = "*.odt",
--         command = [[%!pandoc --columns=78 -f odt -t markdown "%"]]
--     },
--     {
--         event = "BufWritePre",
--         pattern = "*.rt",
--         command = [[silent %!unrtf --text]]
--     }
-- }

a.async_void(
    vim.schedule_wrap(
        function()
            augroup(
                "lmb__TrimWhitespace",
                {
                    event = "BufWritePre",
                    pattern = "*",
                    command = function(args)
                        -- Delete trailing spaces
                        utils.preserve("keepj keepp %s/\\s\\+$//ge")

                        -- Delete trailing blank lines
                        utils.preserve([[keepj keepp %s#\($\n\s*\)\+\%$##e]])

                        -- Delete trailing blank lines at end of file
                        -- utils.preserve([[keepj keepp 0;/^\%(\n*.\)\@!/,$d]])

                        -- Delete blank lines if more than 2 in a row
                        -- utils.squeeze_blank_lines()
                    end,
                }
            )
        end
    )
)()
-- ]]] === Custom file type ===

-- ========================== Buffer Reload =========================== [[[
nvim.autocmd.lmb__AutoReloadFile = {
    {
        event = {"BufEnter", "CursorHold", "FocusGained"},
        command = function(args)
            local bufnr = args.buf
            local name = api.nvim_buf_get_name(bufnr)
            if
                name == "" or vim.bo[bufnr].buftype ~= "" or -- Only check for normal files
                not fn.filereadable(name)
            then                                             -- To avoid: E211: File "..." no longer available
                return
            end

            -- targets.vim throws an error here
            pcall(
                function()
                    cmd(bufnr .. "checktime")
                end
            )
        end,
        desc = "Reload file when modified outside of the instance",
    },
    {
        event = "FileChangedShellPost",
        pattern = "*",
        command = function()
            nvim.p.WarningMsg("File changed on disk. Buffer reloaded!")
        end,
        desc = "Display a message if the buffer is changed outside of instance",
    },
}
-- ]]] === Buffer Reload ===

-- =========================== RNU Column ============================= [[[
---Toggle relative/non-relative nubmers:
---  - Only in the active window
---  - Ignore quickfix window
---  - Only when searching in cmdline or in insert mode
nvim.autocmd.RnuColumn = {
    {
        event = {"FocusLost", "InsertEnter"},
        pattern = "*",
        command = function()
            require("common.rnu").focus(false)
        end,
    },
    {
        -- FIX: This works sometimes
        event = {"FocusGained", "InsertLeave"},
        pattern = "*",
        command = function()
            require("common.rnu").focus(true)
        end,
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
        end,
    },
    {
        event = "CmdlineEnter",
        pattern = [[/,\?]],
        command = function()
            require("common.rnu").scmd_enter()
        end,
    },
    {
        event = "CmdlineLeave",
        pattern = [[/,\?]],
        command = function()
            require("common.rnu").scmd_leave()
        end,
    },
}
-- ]]] === RNU Column ===

augroup(
    "lmb__SetFocus",
    {
        event = "FocusGained",
        desc = "Set `nvim_focused` to true",
        command = function()
            g.nvim_focused = true
        end,
    },
    {
        event = "FocusLost",
        desc = "Set `nvim_focused` to false",
        command = function()
            g.nvim_focused = false
        end,
    }
)
