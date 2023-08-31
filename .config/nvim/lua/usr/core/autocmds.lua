local xprequire = Rc.shared.utils.mod.xprequire

local lazy = require("usr.lazy")
local lib = lazy.require("usr.lib") ---@module 'usr.lib'
local log = lazy.require("usr.lib.log") ---@module 'usr.lib.log'
local debounce = require("usr.lib.debounce")
local Job = require("plenary.job")

local B = Rc.api.buf
local W = Rc.api.win
local map = Rc.api.map
local autocmd = Rc.api.autocmd

local cmd = vim.cmd
local api = vim.api
local fn = vim.fn
local env = vim.env
local g = vim.g

nvim.autocmd.lmb__GitEnv = {
    event = {"BufNewFile", "BufRead"},
    pattern = "*",
    desc = "Set git environment variables for dotfiles bare repo",
    command = (function()
        local has_sourced
        local bufs = {}
        return function(a)
            local bufnr = a.buf
            if not bufs[bufnr] then
                if B.buf_should_exclude(bufnr) then
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
                            env.GIT_WORK_TREE = env.DOTBARE_TREE
                            env.GIT_DIR = env.DOTBARE_DIR
                        end, 10)
                    end
                    has_sourced()
                end

                bufs[bufnr] = true
            end
        end
    end)(),
}

-- === Macro Recording ==================================================== [[[
nvim.autocmd.lmb__MacroRecording = {
    {
        event = "RecordingEnter",
        pattern = "*",
        desc = "Display message when starting to record a macro",
        command = function()
            local msg = ("壘Recording @%s"):format(fn.reg_recording())
            log.info(msg, {title = "Macro", icon = ""})
        end,
    },
    {
        event = "RecordingLeave",
        pattern = "*",
        desc = "Display message after recording a macro",
        command = function()
            local event = vim.v.event
            local msg = (" Recorded @%s\n%s"):format(event.regname, event.regcontents)
            log.info(msg, {title = "Macro", icon = ""})
        end,
    },
}
-- ]]]

-- === Restore Cursor Position ============================================ [[[
nvim.autocmd.lmb__RestoreCursor = {
    event = "BufReadPost",
    pattern = "*",
    desc = "Restore cursor position when opening a buffer",
    command = function(a)
        local bufnr = a.buf
        if B.buf_should_exclude(bufnr) then
            return
        end

        -- if fn.line([['"]]) > 0 and fn.line([['"]]) <= fn.line("$") then
        local row, _col = unpack(api.nvim_buf_get_mark(0, '"'))
        local lcount = api.nvim_buf_line_count(0)
        if row > 0 and row <= lcount then
            -- Rc.api.set_cursor(0, row, col)
            -- utils.zz([[zv]])
            utils.zz([[g`"zv]])
        end
    end,
}
-- ]]]

-- === Format Options ===================================================== [[[
-- Whenever set globally these don't seem to work, I'm assuming
-- this is because other plugins overwrite them.
nvim.autocmd.lmb__FormatOptions = {
    event = {"FileType"},
    pattern = "*",
    desc = "Overwrite formatoptions for each file type",
    command = function(_a)
        vim.schedule(function()
            -- Bufnr has to be captured in here, not args.buf
            local bufnr = api.nvim_get_current_buf()
            if B.buf_should_exclude(bufnr) then
                return
            end

            require("usr.core.options").formatoptions()
        end)
    end,
}
-- ]]]

-- === Remove Empty Buffers =============================================== [[[
nvim.autocmd.lmb__FirstBuf = {
    event = "BufHidden",
    buffer = 0,
    once = true,
    desc = "Remove first empty buffer",
    command = function()
        Rc.lib.builtin.wipe_empty_buf()
    end,
}
-- ]]]

-- === MRU ================================================================ [[[
nvim.autocmd.lmb__MruWin = {
    event = "WinLeave",
    pattern = "*",
    desc = "Add file to custom MRU list when leaving window",
    command = function()
        require("usr.plugs.win").record()
    end,
}
-- ]]]

-- === Select Mode ======================================================== [[[
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

-- === Search Wrap ======================================================== [[[
if fn.exists("##SearchWrapped") then
    nvim.autocmd.lmb__SearchWrappedHighlight = {
        {
            event = "SearchWrapped",
            pattern = "*",
            desc = "Highlight text when wrapping search",
            command = function()
                Rc.lib.builtin.search_wrap()
            end,
        },
    }
end
-- ]]]

-- === Packer ============================================================= [[[
nvim.autocmd.lmb__Packer = {
    event = "BufWritePost",
    pattern = {Rc.dirs.my.lua .. "/plugins.lua", Rc.dirs.my.lua .. "/usr/control.lua"},
    desc = "Source packer plugin file",
    command = function()
        cmd.source("<afile>")
        cmd.PackerCompile()
    end,
}
-- ]]]

-- === Command Hijack ===================================================== [[[
nvim.autocmd.lmb__CmdHijack = {
    event = "CmdlineEnter",
    pattern = ":",
    desc = "Hijack various commands",
    command = function()
        require("usr.plugs.cmdhijack")
    end,
}
-- ]]]

-- === Spell Checking ===================================================== [[[
nvim.autocmd.lmb__Spellcheck = {
    {
        event = "FileType",
        pattern = {"mail" --[[ "text", "markdown", "vimwiki" ]]},
        desc = "Automatically enable spelling",
        command = "setlocal spell",
    },
    {
        event = {"BufRead", "BufNewFile"},
        pattern = "neomutt-archbox*",
        desc = "Automatically enable spelling",
        command = "setlocal spell",
    },
}
-- ]]]

-- === Help / Man pages =================================================== [[[
local function split_should_return()
    if
        W.win_is_float()
        or api.nvim_win_get_height(0) == 1
        or (g.diffview_nvim_loaded and require("diffview.lib").get_current_view())
    then
        return true
    end
    return false
end

local debounced
nvim.autocmd.lmb__Help = {
    {
        event = "BufEnter",
        pattern = "*.txt",
        desc = "Create mapping for help pages",
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
    },
    {
        event = "BufEnter",
        pattern = "*.txt",
        once = false,
        desc = "Set help split width",
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
    },
    {
        event = "BufEnter",
        pattern = "*.txt",
        once = false,
        desc = "Set help split width",
        command = function(args)
            local bufnr = args.buf
            if vim.bo[bufnr].bt == "help" then
                if not debounced then
                    debounced =
                        debounce:new(function()
                            -- pcall needed when opening a TOC inside a help page and returning to help page
                            pcall(cmd.wincmd, "L")
                            -- local width = math.floor(vim.o.columns * 0.75)
                            -- cmd("vertical resize " .. width)
                            cmd("vertical resize 85")
                            -- local longest = utils.longest_line(bufnr) + 2
                            -- cmd("vertical resize " .. longest)
                        end, 0)
                end
                debounced()
            end
        end,
    },
    {
        event = "BufLeave",
        pattern = "*.txt",
        desc = "Set help split width (set debounce to empty)",
        command = function(args)
            -- Prevents resize from happening when going from Help buffer => Other buffer
            local bufnr = args.buf
            if vim.bo[bufnr].bt == "help" then
                debounced = function()
                end
            end
        end,
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
        desc = "Equalize and create mapping for manpages",
        command = function(_args)
            -- local bufnr = args.buf
            if split_should_return() == true then
                return
            end

            pcall(cmd.wincmd, "L")
            local width = math.floor(vim.o.columns * 0.75)
            cmd("vertical resize " .. width)

            -- local longest = utils.longest_line(bufnr) + 2
            -- cmd("vertical resize " .. longest)

            -- Set below
            -- map("n", "qq", "q", {cmd = true, buffer = bufnr})
        end,
    },
    {
        event = "BufHidden",
        pattern = "man://*",
        desc = "Delete hidden man buffers",
        command = function(a)
            local bufnr = a.buf
            if vim.bo[bufnr].ft == "man" then
                vim.defer_fn(function()
                    if api.nvim_buf_is_valid(bufnr) then
                        api.nvim_buf_delete(bufnr, {force = true})
                    end
                end, 0)
            end
        end,
    },
}
-- ]]]

-- === Smart Close ======================================================== [[[
local sclose_ft = _t({
    -- 'help',
    -- 'qf',
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
    -- "oil",
    "scratchpad",
    "startuptime",
    "tsplayground",
    "vista",
    "vista_kind",
    "DiffviewFileHistory",
    "DiffviewFileStatus",
    "dirdiff",
})

local sclose_bt = _t({})
local sclose_bufname = _t({"Luapad"})
local sclose_bufname_bufenter = _t({
    "option%-window",
    "__coc_refactor__%d%d?",
    "Bufferize:",
    "NetrwMessage",
    "fugitive://*",
    "gitsigns://*",
    "man://*",
    "info://*",
    "health://*",
    -- "zipfile://*",
    "://*",
})

nvim.autocmd.lmb__SmartClose = {
    {
        event = "FileType",
        pattern = "*",
        desc = "Create a smart 'qq' (close) mapping (FileType)",
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
                -- map("n", "q,", close, {buffer = bufnr, nowait = true})
                map("n", "qq", "<Cmd>q<CR>", {buffer = bufnr, nowait = true})
            end
        end,
    },
    {
        event = "BufEnter",
        pattern = "*",
        desc = "Create a smart 'qq' (close) mapping (BufEnter)",
        command = function(a)
            local bufnr = a.buf
            local is_unmapped = fn.hasmapto("q", "n") == 0
            local is_eligible = is_unmapped
                or sclose_bufname_bufenter:contains_fn(function(t)
                    return fn.bufname():match(t)
                end)

            if is_eligible then
                -- map("n", "qq", W.win_smart_close, {buffer = bufnr, nowait = true})
                -- map("n", "q,", close, {buffer = bufnr, nowait = true})
                map("n", "qq", "<Cmd>q<CR>", {buffer = bufnr, nowait = true})
            end
        end,
    },
    {
        event = "CmdwinEnter",
        pattern = "*",
        command = "nnoremap <silent><buffer><nowait> qq <C-w>c",
        desc = "Create smart 'qq' mapping for command-line window",
    },
    {
        event = "QuitPre",
        pattern = "*",
        nested = true,
        desc = "Close loclist when quitting window",
        command = function(args)
            local bufnr = args.buf
            if vim.bo[bufnr].ft ~= "qf" then
                cmd.lcl({mods = {silent = true}})
            end
        end,
    },
    -- {
    --     -- TODO: Check this out
    --     event = "BufEnter",
    --     pattern = "[No Name]",
    --     desc = "Close QuickFix if last window",
    --     command = function(a)
    --         local bufnr = a.buf -- fn.winnr("$") == fn.winnr()
    --         if fn.winnr("$") == 1 and vim.bo[bufnr].buftype == "quickfix" then
    --             -- api.nvim_buf_delete(bufnr, {force = true})
    --             cmd("q")
    --         end
    --     end,
    -- },
}
-- ]]]

-- === Autoscroll ========================================================= [[[
local ascroll_ft = _t({"vista", "tsplayground"})  -- 'qf'
local ascroll_from_ft = _t({"aerial", "Trouble"}) -- 'qf'
local ascroll_from_bt = _t({"diff"})
nvim.autocmd.lmb__FixAutoScroll = {
    {
        event = "BufLeave",
        pattern = "*",
        desc = "Avoid autoscroll when switching buffers",
        command = function(a)
            -- buffer that was left
            local from_buf = a.buf

            -- curwin could've changed
            local from_win = fn.bufwinid(from_buf)
            local to_win = api.nvim_get_current_win()
            if not W.win_is_float(to_win)
                and not W.win_is_float(from_win)
                and not ascroll_ft:contains(vim.bo[from_buf].ft)
                and not vim.wo[from_win].diff
            then
                vim.b.__VIEWSTATE = fn.winsaveview()
            end
        end,
    },
    {
        event = "BufEnter",
        pattern = "*",
        desc = "Avoid autoscroll when switching buffers",
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
    },
}
-- ]]]

-- === Tmux =============================================================== [[[
if env.TMUX and env.NORENAME == nil then
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
                vim.o.titleold = fn.fnamemodify(Rc.meta.shell, ":t")
                pcall(os.execute, "tmux set-window automatic-rename on")
            end,
            desc = "Turn back on Tmux auto-rename",
        },
    }
end
-- ]]]

-- === Terminal =========================================================== [[[
nvim.autocmd.lmb__TermFix = {
    event = "TermEnter",
    pattern = "*",
    desc = "Clear matches/highlights; set mappings for terminal",
    command = function()
        vim.schedule(function()
            cmd.nohlsearch()
            fn.clearmatches()
        end)
    end,
}

nvim.autocmd.lmb__TermMappings = {
    -- pattern = "term://*toggleterm#*",
    event = "TermOpen",
    pattern = "term://*",
    desc = "Set terminal mappings",
    command = function(a)
        local bufnr = a.buf
        require("plugs.neoterm").set_terminal_keymaps(bufnr)
        local winid = fn.bufwinid(bufnr)

        -- vim.wo[winid].statusline = "%{b:term_title}"
        vim.wo[winid].list = false
        vim.wo[winid].number = false
        vim.wo[winid].relativenumber = false
        vim.wo[winid].cursorline = false
        vim.wo[winid].cursorcolumn = false
        vim.wo[winid].foldcolumn = "0"
        vim.wo[winid].signcolumn = "no"
        vim.wo[winid].colorcolumn = ""
        vim.wo[winid].sidescrolloff = 0
        vim.wo[winid].scrolloff = 0
        vim.wo[winid].scrollbind = false
        vim.wo[winid].spell = false
        vim.wo[winid].showbreak = "NONE"

        vim.bo[bufnr].swapfile = false
        vim.bo[bufnr].undofile = false
        vim.bo[bufnr].undolevels = -1
        vim.bo[bufnr].bufhidden = "hide"
        -- vim.bo[bufnr].buflisted = false
        vim.opt_local.backup = false
        vim.opt_local.writebackup = false

        -- if vim.bo[bufnr].bt == "terminal" then
        --     cmd("startinsert!")
        -- end
    end,
}
-- ]]]

-- === File Enhancements ================================================== [[[
nvim.autocmd.lmb__LargeFileEnhancement = {
    event = "BufRead",
    desc = "Optimize the viewing of larger files",
    command = function(a)
        -- local size = fn.getfsize(a.file)
        -- if size > 1024 * 1024 * 2 then

        local bufnr = a.buf
        local size = B.buf_get_size(bufnr)
        if size > 1000 then
            local incsearch = vim.go.incsearch
            local inccommand = vim.go.inccommand
            local showmatch = vim.go.showmatch
            vim.go.showmatch = false
            vim.go.incsearch = false
            vim.go.inccommand = "nosplit"

            if size > 1500 then
                local winid = fn.bufwinid(bufnr)
                local hlsearch = vim.go.hlsearch
                local lazyredraw = vim.go.lazyredraw
                local backup = vim.go.backup
                local writebackup = vim.go.writebackup

                vim.go.hlsearch = false
                vim.go.lazyredraw = true
                vim.go.backup = false
                vim.go.writebackup = false

                vim.wo[winid].list = false
                vim.wo[winid].relativenumber = false
                -- vim.wo[winid].cursorline = false
                vim.wo[winid].cursorcolumn = false
                -- vim.wo[winid].foldcolumn = "0"
                vim.wo[winid].signcolumn = "no"
                vim.wo[winid].colorcolumn = ""
                vim.wo[winid].foldenable = false
                vim.wo[winid].foldmethod = "manual"
                vim.wo[winid].showbreak = "NONE"
                vim.wo[winid].conceallevel = 0
                vim.wo[winid].concealcursor = ""
                vim.wo[winid].smoothscroll = false
                vim.wo[winid].spell = false
                vim.bo[bufnr].swapfile = false

                vim.b[bufnr].matchup_matchparen_enabled = 0
                vim.b[bufnr].matchup_matchparen_fallback = 0

                -- vim.g.indent_blankline_enabled = 0
                if size > 2200 then
                    vim.bo[bufnr].undofile = false
                    vim.bo[bufnr].undolevels = -1

                    vim.g.gutentags_dont_load = 1
                    vim.g.loaded_vista = 1
                end

                vim.defer_fn(function()
                    -- require("usr.plugs.bufclean").disable()
                    cmd.IndentBlanklineDisable()
                    cmd.GutentagsToggleEnabled()
                    -- cmd.CocDisable()
                    -- xprequire("gitsigns").detach()
                    -- xprequire("ufo").disable() -- detach
                    xprequire("paint.highlight").disable() -- detach
                    xprequire("colorizer").detach_from_buffer(bufnr)
                    xprequire("todo-comments").disable()
                    xprequire("incline").disable()
                    -- xprequire("hlslens").disable()
                    -- xprequire("wilder").disable()
                    -- xprequire("fundo").disable() -- FundoDisable()
                    -- xprequire("nvim-autopairs").disable()
                    -- xprequire('lualine').hide()
                    xprequire("scrollbar.utils").hide() -- ScrollbarHide()
                    xprequire("specs").clear_autocmds()

                    -- xprequire("ufo").hasAttached()  .detach()
                    -- xprequire("colorizer").is_buffer_attached(0)
                    -- xprequire("todo-comments").attach(win)
                    -- xprequire("incline").is_enabled()
                    -- xprequire("hlslens").isEnabled()
                end, 100)

                autocmd({
                    event = "BufDelete",
                    buffer = 0,
                    desc = "Restore settings from optimizing large files",
                    command = function(a)
                        -- require("usr.plugs.bufclean").enable()
                        vim.b[a.buf].matchup_matchparen_enabled = 1
                        vim.b[a.buf].matchup_matchparen_fallback = 1

                        cmd.IndentBlanklineEnable()
                        cmd.GutentagsToggleEnabled()
                        -- cmd.CocEnable()
                        -- xprequire("gitsigns").detach()
                        -- xprequire("ufo").enable() -- attach
                        xprequire("paint.highlight").enable() -- attach(a.buf)
                        xprequire("colorizer").attach_to_buffer(a.buf)
                        xprequire("todo-comments").enable()
                        xprequire("incline").enable()
                        -- xprequire("hlslens").enable()
                        -- xprequire("wilder").enable()
                        -- xprequire("fundo").enable()
                        -- xprequire("nvim-autopairs").enable()
                        -- xprequire('lualine').hide({unhide = true})
                        xprequire("scrollbar.utils").show()
                        xprequire("specs").create_autocmds()

                        vim.go.lazyredraw = lazyredraw
                        vim.go.backup = backup
                        vim.go.writebackup = writebackup
                        vim.go.showmatch = showmatch
                        vim.go.hlsearch = hlsearch
                        vim.go.incsearch = incsearch
                        vim.go.inccommand = inccommand
                    end,
                })
            end
        end
    end,
}
-- ]]]

-- === Disable Undofile =================================================== [[[
nvim.autocmd.lmb__DisableUndofile = {
    {
        event = {--[["BufWritePre",]] "BufNewFile", "BufRead"},
        pattern = {
            "*~",
            "*.tmp",
            "*.log",
            "crontab.*",
            "COMMIT_EDITMSG",
            "MERGE_MSG",
            "gitcommit",
            "rterm://",
            "roil://",
            "rfugitive://",
            "rgitsigns://",
            "rman://",
            "rhealth://",
            "rzipfile://",
            "*.prs-secret-*",
            "/dev/shm/*",
            "/run/user/*",
            "/private/*",
            "/mnt/*",
            "/tmp/*",
            Rc.dirs.tmp .. "/pass.?*/?*.txt",
            Rc.dirs.xdg.config .. "/*/massren/temp/*",
            Rc.dirs.xdg.config .. "/*/task/task.*",
        },
        desc = "Disable undofile for various filetypes",
        command = function(a)
            local buf = a.buf
            local backup = vim.go.backup
            local writebackup = vim.go.writebackup

            vim.go.backup = false
            vim.go.writebackup = false

            vim.bo[buf].undofile = false
            vim.bo[buf].swapfile = false
            xprequire("fundo").disable()

            autocmd({
                event = "BufDelete",
                buffer = 0,
                desc = "Restore settings after disabling undofile",
                command = function()
                    vim.go.backup = backup
                    vim.go.writebackup = writebackup
                end,
            })
        end,
    },
}
-- ]]]

-- === Buffer Stuff ======================================================= [[[
-- CHECK: and make sure works
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
    {
        event = "BufEnter",
        pattern = "option-window",
        desc = "Delete hidden option-windows",
        command = function(a)
            local bufnr = a.buf
            vim.bo[bufnr].bufhidden = "wipe"
        end,
    },
}
-- ]]]

-- === Buffer Reloading =================================================== [[[
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
-- ]]]

-- === Filetype Detection ================================================= [[[
-- Used for something like a file named 'x' and then #!/usr/bin/env zsh is written as a shebang
nvim.autocmd.lmb__FiletypeDetect = {
    event = {"BufWritePost"},
    pattern = {"*"},
    nested = true,
    desc = "Set filetype after modification",
    command = function(args)
        local bufnr = args.buf
        if F.is.empty(vim.bo[bufnr].filetype) or fn.exists("b:ftdetect") == 1 then
            vim.b.ftdetect = nil
            cmd.filetype("detect")
            utils.cecho(("Filetype set to %s"):format(vim.bo[bufnr].ft), "Macro")
        end
    end,
}
-- ]]]

-- === Trim Whitespace ==================================================== [[[
nvim.autocmd.lmb__TrimWhitespace = {
    event = "BufWritePre",
    pattern = "*",
    command = function()
        utils.preserve([[%s/\s\+$//ge]])         -- Delete trailing spaces
        utils.preserve([[0;/^\%(\n*.\)\@!/,$d]]) -- Delete trailing blank lines
        -- utils.preserve([[%s#\($\n\s*\)\+\%$##e]]) -- Delete trailing blank lines
        -- utils.squeeze_blank_lines() -- Delete blank lines if more than 2 in a row
    end,
}
-- ]]]

-- === VimResized things ================================================== [[[
nvim.autocmd.lmb__VimResize = {
    {
        event = {"VimEnter", "VimResized"},
        desc = "Update previewheight as per the new Vim size",
        command = function()
            vim.o.previewheight = math.floor(vim.o.lines / 3)
        end,
    },
}
-- ]]]

-- === Cursorline Control ================================================= [[[
nvim.autocmd.lmb__CursorlineControl = {
    {
        event = {"WinNew", "WinLeave", "CmdlineEnter"}, -- "InsertEnter"
        desc = "Hide cursorline when leaving window",
        command = [[setl winhl=CursorLine:CursorLineNC,CursorLineNr:CursorLineNrNC]],
    },
    {
        event = {"WinEnter", "CmdlineLeave"}, -- "InsertEnter"
        desc = "Hide cursorline when leaving window",
        command = [[setl winhl=]],
    },
    {
        event = "BufEnter",
        pattern = "[No Name]",
        desc = "Disable cursorline on [No Name]",
        command = function(a)
            local bufnr = a.buf
            local winid = fn.bufwinid(bufnr)
            vim.wo[winid].cursorline = false
        end,
    },
}
-- ]]]

-- === RNU Column ========================================================= [[[
---Toggle relative/non-relative nubmers:
---  - Only in the active window
---  - Ignore quickfix window
---  - Only when searching in cmdline or in insert mode

nvim.autocmd.RnuColumn = {
    {
        event = {"FocusLost"},
        pattern = "*",
        command = function()
            require("usr.plugs.rnu").focus(false)
        end,
    },
    {
        -- FIX: Sometimes tmux has to be re-opened for this to work
        --      (has to do with focus events)
        event = {"FocusGained"},
        pattern = "*",
        command = function()
            require("usr.plugs.rnu").focus(true)
        end,
    },
    {
        event = {"InsertEnter"},
        pattern = "*",
        command = function()
            require("usr.plugs.rnu").focus(false)
        end,
    },
    {
        event = {"InsertLeave"},
        pattern = "*",
        command = function()
            require("usr.plugs.rnu").focus(true)
        end,
    },
    {
        -- PERF: checking to see if this increases performance
        event = {"BufEnter"},
        pattern = "*",
        command = function(a)
            if api.nvim_buf_line_count(a.buf) > 1500 then
                vim.o.relativenumber = false
            end
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
-- ]]]

-- === Set Focused ======================================================== [[[
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
-- ]]]

-- === Global Buffer Variables ============================================ [[[
nvim.autocmd.lmb__SetFocus = {
    event = "BufEnter",
    desc = "Globalize buffer variables",
    command = function(a)
        vim.b[a.buf].man_default_sects = "1:1p:n:l:8:3:3p:0:0p:2:3type:5:4:7:9:p:o:6:3X11:3Xt:3x:3X:3am"
    end,
}

env.MANSECT = "1:1p:n:l:8:3:3p:0:0p:2:3type:5:4:7:9:p:o:6:3X11:3Xt:3x:3X"
-- ]]]

-- === Clear Command-line ================================================= [[[
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
--             timer = A.set_timeoutv(function()
--                 if utils.mode() == "n" then
--                     utils.clear_prompt()
--                 end
--             end, timeout)
--         end,
--         desc = ("Clear command-line messages after %d seconds"):format(timeout / 1000),
--     }
-- end
-- ]]]
