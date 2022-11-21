---@diagnostic disable:undefined-field

-- local global = require("common.global")
local D = require("dev")
local hl = require("common.color")
local debounce = require("common.debounce")
local log = require("common.log")
local Job = require("plenary.job")
local a = require("plenary.async_lib")

local funcs = require("functions")
local utils = require("common.utils")
-- local funcs = require("functions")
local map = utils.map
local augroup = utils.augroup
local autocmd = utils.autocmd
-- local create_augroup = utils.create_augroup

local cmd = vim.cmd
local api = vim.api
local fn = vim.fn
local env = vim.env
local g = vim.g
local v = vim.v
local b = vim.bo
local o = vim.opt
local ol = vim.opt_local

local debounced
local has_sourced

-- ╭──────────────────────────────────────────────────────────╮
-- │                 Setting git environment                  │
-- ╰──────────────────────────────────────────────────────────╯
-- This version uses a pre-built pattern.
-- This also floods autocmds with an additional 1000+
-- local git_pattern =
--     _t(D.get_system_output("dotbare ls-tree --full-tree -r --name-only HEAD")):map(
--     function(path)
--         return ("%s/%s"):format(global.home, path)
--     end
-- )
--
-- -- The first item contains an error because dotbare uses `stty` for a command
-- local _ = git_pattern:remove(1)
--
-- This version runs a command on every event
-- Wilder doesn't trigger a BufWinEnter when coming back like telescope does
nvim.autocmd.lmb__GitEnv = {
    event = {"BufRead", "BufEnter"},
    pattern = "*",
    desc = "Set git environment variables for dotfiles bare repo",
    command = function()
        -- Has to be deferred otherwise something like a terminal buffer doesn't show
        -- Also, I think the API call instead of vim.bo[bufnr].bt is needed for the deferring to happen
        vim.defer_fn(
            function()
                local curr_file = fn.expand("%")
                -- Can't use the buffer from args passed to this function
                local bufnr = api.nvim_get_current_buf()
                local ft = api.nvim_buf_get_option(bufnr, "filetype")
                if not fn.filereadable(curr_file) or _t(BLACKLIST_FT):contains(ft) then
                    return
                end

                local _, ret =
                    Job:new(
                    {
                        command = "dotbare",
                        args = {"ls-files", "--error-unmatch", curr_file},
                        on_exit = function(_, ret)
                            return ret
                        end
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
                -- else

                -- if env.GIT_WORK_TREE == os.getenv("DOTBARE_TREE") and env.GIT_DIR == os.getenv("DOTBARE_DIR") then
                --             local bt = api.nvim_buf_get_option(bufnr, "buftype")
                --             if bt == "" then
                --                 nvim.p(("bufnr: %d has unset DOTBARE"):format(bufnr), "TSNote")
                --             end
                --
                --             env.GIT_WORK_TREE = nil
                --             env.GIT_DIR = nil
                --         end,
                -- end
                end
            end,
            1
        )
    end
}

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
    if v.hlsearch == 0 or utils.mode() ~= "n" then
        return
    end
    utils.normal("m", "<Plug>(StopHL)")
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
                debounce:new(
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

nvim.autocmd.lmb__VimrcIncSearchHighlight = {
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
                    cmd.redrawstatus()
                end
            )
        end
    },
    {
        event = "RecordingEnter",
        command = function()
            o.hlsearch = false
        end
    },
    {
        event = "RecordingLeave",
        command = function()
            o.hlsearch = true
        end
    }
}
-- === Highlight Disable ===

-- === Macro Recording === [[[
nvim.autocmd.lmb__MacroRecording = {
    {
        event = "RecordingEnter",
        pattern = "*",
        command = function()
            local msg = (" 壘Recording @%s"):format(fn.reg_recording())
            vim.notify(msg, log.levels.INFO, {title = "Macro", icon = ""})
        end
    },
    {
        event = "RecordingLeave",
        pattern = "*",
        command = function()
            local event = vim.v.event
            local msg = ("  Recorded @%s\n%s"):format(event.regname, event.regcontents)
            vim.notify(msg, log.levels.INFO, {title = "Macro", icon = ""})
        end
    }
}
-- ]]] === Macro Recording ===

-- === Restore Cursor Position === [[[
nvim.autocmd.lmb__RestoreCursor = {
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
                    "rebase",
                    "help"
                }
            )

            if fn.expand("%") == "" or types:contains(b.ft) or b.bt == "nofile" or D.is_floating_window(0) then
                return
            end

            local row, col = unpack(nvim.buf.get_mark(0, '"'))
            if {row, col} ~= {0, 0} and row <= nvim.buf.line_count(0) then
                utils.set_cursor(0, row, 0)

                funcs.center_next()
            end
        end
    },
    {
        -- @source: https://vim.fandom.com/wiki/Use_gf_to_open_a_file_via_its_URL
        event = {"BufReadCmd"},
        pattern = {"file:///*"},
        nested = true,
        command = function(args)
            cmd.bdelete({bang = true})
            cmd.edit(vim.uri_to_fname(args.file))
        end
    }
}

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
-- ]]] === Restore cursor ===

-- === Format Options === [[[
-- Whenever set globally these don't seem to work, I'm assuming
-- this is because other plugins overwrite them.
nvim.autocmd.lmb__FormatOptions = {
    event = {"BufEnter", "FileType"},
    pattern = "*",
    command = function()
        ol.formatoptions = {
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

        vim.schedule(
            function()
                -- Bufnr has to be captured in here, not args.buf
                local bufnr = api.nvim_get_current_buf()
                local ft = api.nvim_buf_get_option(bufnr, "filetype")

                -- o.conceallevel = 2
                -- o.concealcursor = "vc"

                -- Allows a shared statusline
                if ft ~= "fzf" then
                    ol.laststatus = 3
                end
            end
        )
    end,
    desc = "Setup format options"
}
-- ]]] === Format Options ===

-- ╭──────────────────────────────────────────────────────────╮
-- │                Colorscheme Modifications                 │
-- ╰──────────────────────────────────────────────────────────╯
nvim.autocmd.lmb__ColorschemeSetup = {
    event = "ColorScheme",
    pattern = "*",
    command = function()
        vim.defer_fn(
            function()
                hl.all(
                    {
                        TSVariableBuiltin = {default = true, gui = "none"},
                        TSTypeBuiltin = {default = true, gui = "none"},
                        TSProperty = {default = true, gui = "none"},
                        TSVariable = {default = true, gui = "none"},
                        TSKeyword = {default = true, gui = "none"},
                        TSConditional = {default = true, gui = "none"},
                        TSString = {default = true, gui = "none"},
                        TSKeywordFunction = {default = true, gui = "none"},
                        Function = {default = true, gui = "bold"},
                        Todo = {default = true, bg = "none"},
                        QuickFixLine = {default = true, fg = "none"}
                        -- TSConstBuiltin = {default = true, gui = "none"},
                        -- TSMethod = {default = true, gui = "bold"},
                        -- Hlargs = {link = "TSParameter"} -- This overrides TSParameter
                    }
                )

                if g.colors_name ~= "kimbox" then
                    hl.all(
                        {
                            Hlargs = {link = "TSParameter"}
                        }
                    )
                else
                    hl.all(
                        {
                            Function = {default = true, bold = true},
                            TSFunction = {default = true, bold = true},
                            TSFuncBuiltin = {link = "TSFunction", bold = true}
                        }
                    )
                end
            end,
            1
        )
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
    {
        event = "BufWritePre",
        pattern = {"COMMIT_EDITMSG", "MERGE_MSG", "gitcommit", "*.tmp", "*.log"},
        command = function(args)
            vim.bo[args.buf].undofile = false
        end
    },
    {
        event = "FileType",
        pattern = {"crontab"},
        command = function(args)
            vim.bo[args.buf].undofile = false
        end
    }
}
-- ]]]

-- === MRU === [[[
nvim.autocmd.lmb__MruWin = {
    event = "WinLeave",
    pattern = "*",
    command = function()
        require("common.win").record()
    end,
    desc = "Add file to custom MRU list"
}
-- ]]]

-- === Spelling === [[[
nvim.autocmd.lmb__Spellcheck = {
    {
        event = "FileType",
        pattern = {"markdown", "text", "mail", "vimwiki"},
        command = "setlocal spell",
        desc = "Automatically enable spelling"
    },
    {
        event = {"BufRead", "BufNewFile"},
        pattern = "neomutt-archbox*",
        command = "setlocal spell",
        desc = "Automatically enable spelling"
    }
}
-- ]]] === Spelling ===

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
        vim.bo.bufhidden = "hide"
        cmd.startinsert()
    end,
    desc = "Set terminal mappings"
}

-- nvim.autocmd.lmb__TermClose = {
--     event = {"TermClose"},
--     pattern = "*",
--     command = function()
--         if v.event.status == 0 then
--             local info = api.nvim_get_chan_info(vim.opt.channel._value)
--             if not info or not info.argv then
--                 return
--             end
--             if info.argv[1] == env.SHELL then
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
    if cfg and (cfg.external or cfg.relative and #cfg.relative > 0) or api.nvim_win_get_height(0) == 1 then
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
        command = function(args)
            local bufnr = args.buf
            if b[bufnr].bt == "help" then
                if split_should_return() then
                    return
                end

                -- Fix, somwhere this is not allowing me to resize window
                local width = math.floor(vim.o.columns * 0.75)
                -- pcall needed when opening a TOC inside a help page and returning to help page
                pcall(cmd.wincmd, "L")
                cmd("vertical resize " .. width)
                map("n", "qq", "helpclose", {cmd = true, buffer = bufnr})
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
        command = function(args)
            local bufnr = args.buf
            if split_should_return() then
                return
            end

            local width = math.floor(vim.o.columns * 0.75)
            pcall(cmd.wincmd, "L")
            cmd("vertical resize " .. width)
            map("n", "qq", "q", {cmd = true, buffer = bufnr})
        end,
        desc = "Equalize and create mapping for manpages"
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
        desc = "Delete hidden man buffers"
    }
}
-- ]]] === Help ===

-- === Smart Close === [[[
local smart_close_filetypes = {
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
    "vista"
}

local smart_close_buftypes = {}

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
                is_unmapped or vim.wo.previewwindow or _t(smart_close_filetypes):contains(vim.bo[bufnr].ft) or
                _t(smart_close_buftypes):contains(vim.bo[bufnr].bt)

            if is_eligible then
                map("n", "qq", smart_close, {buffer = bufnr, nowait = true})
            end
        end,
        desc = "Create a smart qq (close) mapping"
    },
    {
        -- Close quick fix window if the file containing it was closed
        event = "BufEnter",
        pattern = "*",
        command = function(args)
            local bufnr = args.buf
            if fn.winnr("$") == 1 and vim.bo[bufnr].buftype == "quickfix" then
                api.nvim_buf_delete(bufnr, {force = true})
            end

            -- Hide cursorline on popup
            local bufname = api.nvim_buf_get_name(bufnr)
            if bufname == "[No Name]" then
                ol.cursorline = false
            end

            -- if bufname:match("%[Wilder Float %d%]") then
            --     ol.buflisted = false
            -- end
        end,
        desc = "Close QuickFix if last window, disable cursorline on [No Name]"
    },
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
    command = function(args)
        local bufnr = args.buf
        if utils.empty(vim.bo[bufnr].filetype) or fn.exists("b:ftdetect") == 1 then
            vim.b.ftdetect = nil
            cmd.filetype("detect")
            utils.cecho(("Filetype set to %s"):format(vim.bo[bufnr].ft), "Macro")
        end
    end,
    desc = "Set filetype after modification"
}
-- ]]]

-- === File Enhancements === [[[
nvim.autocmd.lmb__LargeFileEnhancement = {
    event = "BufRead",
    desc = "Optimize the viewing of larger files",
    command = function(args)
        local bufnr = args.buf
        if vim.bo[bufnr].ft == "help" then
            return
        end

        local size = fn.getfsize(fn.expand("%"))
        if size > 1024 * 1024 * 5 then
            local hlsearch = vim.opt.hlsearch
            local lazyredraw = vim.opt.lazyredraw
            local showmatch = vim.opt.showmatch

            vim.bo[bufnr].undofile = false
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

-- ======================= CursorLine Control ========================= [[[
nvim.autocmd.lmb__CursorLineControl = {
    {
        event = {"BufWinEnter", "WinEnter", "FocusGained", "CmdlineLeave"},
        pattern = "*",
        command = function()
            local winid = api.nvim_get_current_win()
            vim.wo[winid].cursorline = not vim.w[winid].nocursorline
        end,
        desc = "Control cursorline when re-focusing"
    },
    {
        event = {"WinLeave", "FocusLost", "CmdlineEnter"},
        pattern = "*",
        command = function(args)
            local bufnr = args.buf
            local bufs = D.list_bufs({loaded = true, buftype = {"", "terminal"}})
            if _t(bufs):contains(bufnr) and not vim.b[bufnr].keep_cursor_on_leave then
                local winid = fn.bufwinid(bufnr)
                vim.wo[winid].cursorline = false
            end
        end,
        desc = "Control cursorline when un-focusing"
    }
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
                    -- o.titlestring = fn.expand("%:t")
                    o.titlestring = funcs.title_string()
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
                -- o.titleold = ("%s %s"):format(fn.fnamemodify(os.getenv("SHELL"), ":t"), global.name)
                o.titleold = fn.fnamemodify(os.getenv("SHELL"), ":t")
                pcall(os.execute, "tmux set-window automatic-rename on")
            end,
            desc = "Turn back on Tmux auto-rename"
        }
    }
end
-- ]]] === Tmux ===

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
        desc = ("Clear command-line messages after %d seconds"):format(timeout / 1000)
    }
end

-- === Auto Resize on Resize Event === [[[
do
    local o = vim.o

    nvim.autocmd.lmb__VimResize = {
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
nvim.autocmd.lmb__CustomFileType = {
    {
        event = "BufWritePre",
        pattern = {"*.odt", "*.rtf"},
        command = [[silent set ro]]
    },
    {
        event = "BufWritePre",
        pattern = "*.odt",
        command = [[%!pandoc --columns=78 -f odt -t markdown "%"]]
    },
    {
        event = "BufWritePre",
        pattern = "*.rt",
        command = [[silent %!unrtf --text]]
    }
}

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
                        utils.preserve("keepj keepp %s/\\s\\+$//ge")

                        -- Delete trailing blank lines
                        utils.preserve([[keepj keepp %s#\($\n\s*\)\+\%$##e]])

                        -- Delete trailing blank lines at end of file
                        -- utils.preserve([[keepj keepp 0;/^\%(\n*.\)\@!/,$d]])

                        -- Delete blank lines if more than 2 in a row
                        -- utils.squeeze_blank_lines()
                    end
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

augroup(
    "lmb__SetFocus",
    {
        event = "FocusGained",
        desc = "Set `nvim_focused` to true",
        command = function()
            g.nvim_focused = true
        end
    },
    {
        event = "FocusLost",
        desc = "Set `nvim_focused` to false",
        command = function()
            g.nvim_focused = false
        end
    }
)

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
