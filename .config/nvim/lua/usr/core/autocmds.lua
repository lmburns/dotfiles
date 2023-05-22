local shared = require("usr.shared")
local utils = shared.utils
local A = shared.utils.async
local tbl = shared.tbl
local xprequire = shared.utils.mod.xprequire

local Job = require("plenary.job")

local lib = require("usr.lib")
local log = lib.log
local debounce = lib.debounce

local mpi = require("usr.api")
local B = mpi.buf
local W = mpi.win
local map = mpi.map
local autocmd = mpi.autocmd

local cmd = vim.cmd
local api = vim.api
local fn = vim.fn
local env = vim.env
local g = vim.g

local exclude_ft = BLACKLIST_FT:filter(utils.lambda("x -> x ~= ''"))
local include_bt = _t({"", "acwrite"})

---
---@param bufnr number
---@param winid number
---@return boolean
local function should_exclude(bufnr, winid)
    local bufpath = api.nvim_buf_get_name(bufnr)
    local bufname = fn.bufname(bufnr)
    if
        bufpath == ""
        or not fn.filereadable(bufpath)
        or bufname == "[No Name]"
        or exclude_ft:contains(vim.bo[bufnr].ft)
        or not include_bt:contains(vim.bo[bufnr].bt)
        or not vim.bo[bufnr].buflisted
        or W.win_is_float(winid)
    then
        return true
    end
    return false
end

--  <cword>    word under the cursor
--  <cWORD>    WORD under the cursor
--  <cexpr>    word under the cursor, including more to form a C expression
--  <cfile>    path name under the cursor (like what |gf| uses)
--  <afile>    autocmds, fname of buf being manipulated, or file for a read or write
--  <abuf>     autocmds, current effective bufnr, file being read is not in a buffer
--  <amatch>   autocmds, match for which this autocommand was executed
--  <sfile>    `:source`, file name of the sourced file
--  <stack>    call stack, using "function {function-name}[{lnum}]"
--  <script>   `:source`, file name of the sourced file. func, fname
--  <slnum>    `:source`, line number
--  <sflnum>   script, line number.

nvim.autocmd.lmb__GitEnv = {
    event = {"BufEnter"},
    pattern = "*",
    desc = "Set git environment variables for dotfiles bare repo",
    command = (function()
        local has_sourced
        local bufs = {}
        return function(a)
            local bufnr = a.buf
            if not bufs[bufnr] then
                local winid = fn.bufwinid(bufnr)
                if should_exclude(bufnr, winid) then
                    return
                end

                local curfile = api.nvim_buf_get_name(bufnr)
                local _, ret = Job:new({
                    command = "dotbare",
                    args = {"ls-files", "--error-unmatch", curfile},
                    on_exit = function(_, ret)
                        return ret
                    end,
                }):sync()

                if ret == 0 then
                    if not has_sourced then
                        has_sourced = debounce(function()
                            env.GIT_WORK_TREE = os.getenv("DOTBARE_TREE")
                            env.GIT_DIR = os.getenv("DOTBARE_DIR")
                        end, 10)
                    end
                    has_sourced()
                end

                bufs[bufnr] = true
            end
        end
    end)(),
}

-- -- === Macro Recording === [[[
nvim.autocmd.lmb__MacroRecording = {
    {
        event = "RecordingEnter",
        pattern = "*",
        command = function()
            local msg = ("壘Recording @%s"):format(fn.reg_recording())
            log.info(msg, {title = "Macro", icon = ""})
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
        command = function(a)
            local bufnr = a.buf
            -- if
            --     fn.expand("%") == ""
            --     or exclude_ft:contains(vim.bo[bufnr].ft)
            --     or vim.bo.bt == "nofile"
            --     or W.win_is_float(0)
            -- then
            --     return
            -- end

            local winid = fn.bufwinid(bufnr)
            if should_exclude(bufnr, winid) then
                return
            end

            -- if fn.line([['"]]) > 0 and fn.line([['"]]) <= fn.line("$") then
            local row, col = unpack(api.nvim_buf_get_mark(0, '"'))
            local lcount = api.nvim_buf_line_count(0)
            if row > 0 and row <= lcount then
                -- mpi.set_cursor(0, row, col)
                -- utils.zz([[zv]])
                utils.zz([[g`"zv]])
            end
        end,
    },
}
-- ]]] === Restore cursor ===

-- === Format Options === [[[
-- Whenever set globally these don't seem to work, I'm assuming
-- this is because other plugins overwrite them.
nvim.autocmd.lmb__FormatOptions = {
    event = {"FileType"},
    pattern = "*",
    command = function(_a)
        vim.schedule(
            function()
                -- Bufnr has to be captured in here, not args.buf
                local bufnr = api.nvim_get_current_buf()
                local winid = fn.bufwinid(bufnr)
                if should_exclude(bufnr, winid) then
                    return
                end

                vim.opt_local.formatoptions:append({
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
                    r = lib.fn.set_formatopts, -- continue comments when pressing Enter
                    o = lib.fn.set_formatopts, -- auto insert comment leader after 'o'/'O'
                })
            end
        )
    end,
    desc = "Setup format options",
}
-- ]]] === Format Options ===

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
        command = function(a)
            vim.bo[a.buf].undofile = false
            xprequire("fundo").disable()
        end,
    },
    {
        event = "FileType",
        pattern = {"crontab"},
        command = function(a)
            vim.bo[a.buf].undofile = false
            xprequire("fundo").disable()
        end,
    },
}
-- ]]]

-- === Buffer Stuff === [[[
nvim.autocmd.lmb__BufferStuff = {
    {
        event = {"BufReadCmd"},
        pattern = {"file:///*"},
        nested = true,
        command = function(a)
            cmd.bdelete({bang = true})
            cmd.edit(vim.uri_to_fname(a.file))
        end,
    },
    {
        event = {"BufReadCmd"},
        pattern = {[[*:[0-9]\+]]},
        nested = true,
        command = function(a)
            lib.fn.open_file_location(a.file)
        end,
    },
}
-- ]]]


-- === Remove Empty Buffers === [[[
nvim.autocmd.lmb__FirstBuf = {
    event = "BufHidden",
    command = function()
        require("usr.lib.builtin").wipe_empty_buf()
    end,
    buffer = 0,
    once = true,
    desc = "Remove first empty buffer",
}
-- ]]]

-- -- === MRU === [[[
nvim.autocmd.lmb__MruWin = {
    event = "WinLeave",
    pattern = "*",
    command = function()
        require("usr.plugs.win").record()
    end,
    desc = "Add file to custom MRU list",
}
-- ]]]

-- -- === Select Mode No Yank === [[[
if fn.exists("##ModeChanged") == 1 then
    nvim.autocmd.lmb__SelectModeNoYank = {
        {
            event = "ModeChanged",
            pattern = "*:s",
            command = function()
                vim.o.clipboard = nil
            end,
        },
        {
            event = "ModeChanged",
            pattern = "s:*",
            command = function()
                vim.o.clipboard = "unnamedplus"
            end,
        },
    }
end
-- ]]]

-- === Packer === [[[
nvim.autocmd.lmb__Packer = {
    {
        event = "BufWritePost",
        pattern = {"*/plugins.lua", "*/common/control.lua"},
        command = function()
            cmd.source("<afile>")
            cmd.PackerCompile()
        end,
        desc = "Source plugin file",
    },
}
-- ]]]

-- === Search Wrap === [[[
if fn.exists("##SearchWrapped") then
    nvim.autocmd.lmb__SearchWrappedHighlight = {
        {
            event = "SearchWrapped",
            pattern = "*",
            command = function()
                require("usr.lib.builtin").search_wrap()
            end,
            desc = "Highlight text when wrapping search",
        },
    }
end
-- ]]]

-- -- === Search Wrap === [[[
if fn.exists("##SearchWrapped") then
    nvim.autocmd.lmb__SearchWrappedHighlight = {
        {
            event = "SearchWrapped",
            pattern = "*",
            command = function()
                require("usr.lib.builtin").search_wrap()
            end,
            desc = "Highlight text when wrapping search",
        },
    }
end
-- ]]]

-- === CmdHijack === [[[
nvim.autocmd.lmb__CmdHijack = {
    {
        event = "CmdlineEnter",
        pattern = ":",
        command = function()
            require("usr.plugs.cmdhijack")
        end,
        desc = "Hijack various commands",
    },
}
-- ]]]

-- === Spelling === [[[
nvim.autocmd.lmb__Spellcheck = {
    {
        event = "FileType",
        pattern = {"mail" --[[ "text", "markdown", "vimwiki" ]]},
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
        (cfg and (cfg.external or cfg.relative and #cfg.relative > 0))
        or api.nvim_win_get_height(0) == 1
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
        command = (function()
            local ran = false
            return function(a)
                local bufnr = a.buf
                if not ran and vim.bo[bufnr].bt == "help" then
                    -- pcall needed when opening a TOC inside a help page and returning to help page
                    pcall(cmd.wincmd, "L")
                    cmd("vertical resize 85")
                    ran = true

                    autocmd({
                        event = "BufDelete",
                        once = true,
                        command = function()
                            ran = false
                        end,
                    })
                end
            end
        end)(),
        desc = "Set help split width",
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
        command = function(a)
            local bufnr = a.buf
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
local sclose_ft = _t({
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
})

-- "%[Command Line%]"
local sclose_bt = _t({})
local sclose_bufname = _t({"Luapad"})
local sclose_bufname_bufenter = _t({"option%-window", "__coc_refactor__%d%d?", "Bufferize:"})

nvim.autocmd.lmb__SmartClose = {
    {
        event = "FileType",
        pattern = "*",
        command = function(a)
            local bufnr = a.buf
            local is_unmapped = fn.hasmapto("q", "n") == 0
            local is_eligible = is_unmapped
                or vim.wo.previewwindow
                or sclose_ft:contains(vim.bo[bufnr].ft)
                or sclose_bt:contains(vim.bo[bufnr].bt)
                or sclose_bufname:contains_fn(function(t)
                    return fn.bufname():match(t)
                end)

            if is_eligible then
                -- map("n", "qq", W.win_smart_close, {buffer = bufnr, nowait = true})
                map("n", "qq", "<Cmd>q<CR>", {buffer = bufnr, nowait = true})
            end
        end,
        desc = "Create a smart qq (close) mapping",
    },
    {
        event = "BufEnter",
        pattern = "*",
        command = function(a)
            local bufnr = a.buf
            local is_unmapped = fn.hasmapto("q", "n") == 0
            local is_eligible = is_unmapped
                or sclose_bufname_bufenter:contains_fn(function(t)
                    return fn.bufname():match(t)
                end)

            if is_eligible then
                -- map("n", "qq", W.win_smart_close, {buffer = bufnr, nowait = true})
                map("n", "qq", "<Cmd>q<CR>", {buffer = bufnr, nowait = true})
            end
        end,
        desc = "Create a smart qq (close) mapping",
    },
    {
        event = "BufEnter",
        pattern = "option-window",
        command = function(a)
            local bufnr = a.buf
            vim.bo[bufnr].bufhidden = "wipe"
        end,
        desc = "Delete hidden option-windows",
    },
    {
        event = "BufEnter",
        pattern = "*",
        command = function(a)
            local bufnr = a.buf
            -- fn.winnr("$") == fn.winnr()
            if fn.winnr("$") == 1 and vim.bo[bufnr].buftype == "quickfix" then
                -- api.nvim_buf_delete(bufnr, {force = true})
                cmd("q")
            end

            -- Hide cursorline on popup
            local bufname = api.nvim_buf_get_name(bufnr)
            if bufname == "[No Name]" then
                vim.opt_local.cursorline = false
                -- vim.wo.cursorline = true
            end
        end,
        desc = "Close QuickFix if last window, disable cursorline on [No Name]",
    },
    {
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
--
-- -- === Autoscroll === [[[
local ascroll_ft = _t({"vista"})                  -- 'qf'
local ascroll_from_ft = _t({"aerial", "Trouble"}) -- 'qf'
local ascroll_from_bt = _t({"diff"})
nvim.autocmd.__lmbFixAutoScroll = {
    {
        event = "BufLeave",
        pattern = "*",
        command = function(a)
            -- buffer that was left
            local from_buf = a.buf

            -- curwin could've changed
            local from_win = fn.bufwinid(from_buf)
            local to_win = api.nvim_get_current_win()
            if not W.win_is_float(to_win)
                and not W.win_is_float(from_win)
                and not ascroll_ft:contains(vim.bo[from_buf].ft)
            then
                vim.b.__VIEWSTATE = fn.winsaveview()
            end
        end,
        desc = "Avoid autoscroll when switching buffers",
    },
    {
        event = "BufEnter",
        pattern = "*",
        command = function()
            if vim.b.__VIEWSTATE then
                local win = api.nvim_get_current_win()
                if not W.win_is_float(win) then
                    -- local altbuf = fn.bufnr("#")
                    -- local altid = fn.win_getid(altwin)
                    local altwin = fn.winnr("#")
                    local from_buf = fn.winbufnr(altwin)
                    -- N(("%s = %s"):format(vim.bo[altbuf].ft, vim.bo[from_buf].ft))

                    if not ascroll_from_ft:contains(vim.bo[from_buf].ft)
                        and not ascroll_from_bt:contains(vim.bo[from_buf].bt)
                    then
                        fn.winrestview(vim.b.__VIEWSTATE)
                    end
                end
                vim.b.__VIEWSTATE = nil
            end
        end,
        desc = "Avoid autoscroll when switching buffers",
    },
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
    command = function(a)
        local bufnr = a.buf
        -- local size = fn.getfsize(fn.expand("%"))
        -- if size > 1024 * 1024 * 2 then
        local size = B.buf_get_size(bufnr)
        if size > 1000 then
            local winid = fn.bufwinid(bufnr)
            local hlsearch = vim.go.hlsearch
            local lazyredraw = vim.go.lazyredraw
            local showmatch = vim.go.showmatch

            vim.bo[bufnr].undofile = false
            vim.wo[winid].colorcolumn = ""
            vim.wo[winid].relativenumber = false
            vim.wo[winid].foldmethod = "manual"
            vim.wo[winid].spell = false
            vim.go.hlsearch = false
            vim.go.lazyredraw = true
            vim.go.showmatch = false

            autocmd(
                {
                    event = "BufDelete",
                    buffer = 0,
                    command = function()
                        vim.go.hlsearch = hlsearch
                        vim.go.lazyredraw = lazyredraw
                        vim.go.showmatch = showmatch
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
    -- {
    --     event = {"WinEnter", "FocusGained", "CmdlineLeave"}, -- "InsertLeave"
    --     command = function()
    --         if vim.w.auto_cursorline then
    --             vim.wo.cursorline = true
    --             vim.w.auto_cursorline = nil
    --         end
    --     end,
    --     desc = "Hide cursorline when entering window",
    -- },
    -- {
    --     event = {"WinLeave", "FocusLost", "CmdlineEnter"}, -- "InsertEnter"
    --     command = function()
    --         local cl = vim.wo.cursorline
    --         if cl then
    --             vim.w.auto_cursorline = cl
    --             vim.wo.cursorline = false
    --         end
    --     end,
    --     desc = "Hide cursorline when leaving window",
    -- },
    {
        event = {"WinNew", "WinLeave", "CmdlineEnter"}, -- "InsertEnter"
        command = [[setl winhl=CursorLine:CursorLineNC,CursorLineNr:CursorLineNrNC]],
        desc = "Hide cursorline when leaving window",
    },
    {
        event = {"WinEnter", "CmdlineLeave"}, -- "InsertEnter"
        command = [[setl winhl=]],
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
                    vim.o.titlestring = lib.fn.tmux_title_string()
                elseif vim.bo[bufnr].bt == "terminal" then
                    if vim.bo[bufnr].ft == "toggleterm" then
                        vim.o.titlestring = "ToggleTerm #" .. vim.b.toggle_number
                    else
                        vim.o.titlestring = "Terminal"
                    end
                end
            end,
            desc = "Automatic rename of tmux window",
        },
        {
            event = "VimLeave",
            pattern = "*",
            command = function()
                vim.o.titleold = fn.fnamemodify(lb.vars.shell, ":t")
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
        vim.schedule(function()
            cmd.nohlsearch()
            fn.clearmatches()
        end)
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

-- do
--     local timer
--     local timeout = 6000
--
--     -- Automatically clear command-line messages after a few second delay
--     nvim.autocmd.lmb__ClearCliMsgs = {
--         event = "CmdlineLeave",
--         pattern = ":",
--         command = function()
--             if timer then
--                 timer:stop()
--             end
--             timer = A.setTimeoutv(function()
--                 if utils.mode() == "n" then
--                     utils.clear_prompt()
--                 end
--             end, timeout)
--         end,
--         desc = ("Clear command-line messages after %d seconds"):format(timeout / 1000),
--     }
-- end

-- === Custom file type settings === [[[
nvim.autocmd.lmb__TrimWhitespace = {
    event = "BufWritePre",
    pattern = "*",
    command = function(_a)
        -- Delete trailing spaces
        utils.preserve("%s/\\s\\+$//ge")

        -- Delete trailing blank lines
        utils.preserve([[%s#\($\n\s*\)\+\%$##e]])

        -- Delete trailing blank lines at end of file
        -- utils.preserve([[0;/^\%(\n*.\)\@!/,$d]])

        -- Delete blank lines if more than 2 in a row
        -- utils.squeeze_blank_lines()
    end,
}
-- ]]] === Custom file type ===

-- ========================== Buffer Reload =========================== [[[
nvim.autocmd.lmb__AutoReloadFile = {
    {
        event = {"BufEnter", "CursorHold", "FocusGained"},
        command = function(args)
            local bufnr = args.buf
            local name = api.nvim_buf_get_name(bufnr)
            -- Only check for normal files
            if
                name == ""
                or vim.bo[bufnr].buftype ~= ""
                or not fn.filereadable(name)
            then
                -- To avoid: E211: File "..." no longer available
                return
            end

            -- targets.vim throws an error here
            pcall(function()
                cmd(bufnr .. "checktime")
            end)
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
            require("usr.plugs.rnu").focus(false)
        end,
    },
    {
        -- FIX: Sometimes tmux has to be re-opened for this to work
        --      (has to do with focus events)
        event = {"FocusGained", "InsertLeave"},
        pattern = "*",
        command = function()
            require("usr.plugs.rnu").focus(true)
        end,
    },
    {
        event = {"WinEnter", "BufEnter"},
        pattern = "*",
        command = function()
            require("usr.plugs.rnu").win_enter()
        end,
    },
    {
        event = "CmdlineEnter",
        pattern = [[/,\?]],
        command = function()
            require("usr.plugs.rnu").scmd_enter()
        end,
    },
    {
        event = "CmdlineLeave",
        pattern = [[/,\?]],
        command = function()
            require("usr.plugs.rnu").scmd_leave()
        end,
    },
}
-- ]]] === RNU Column ===

nvim.autocmd.lmb__SetFocus = {
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
    },
}
