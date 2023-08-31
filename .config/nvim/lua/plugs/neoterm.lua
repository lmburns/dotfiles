---@module 'plugs.neoterm'
local M = {}

local F = Rc.F
local toggleterm = F.npcall(require, "toggleterm")
if not toggleterm then
    return
end

local term = require("toggleterm.terminal")
local Terminal = term.Terminal

local utils = Rc.shared.utils
local hl = Rc.shared.hl
local map = Rc.api.map
local command = Rc.api.command
-- local op = Rc.lib.op

local wk = require("which-key")

local cmd = vim.cmd
local fn = vim.fn
local g = vim.g
local api = vim.api
local env = vim.env

local terms, open_key

--  ╭──────────────────────────────────────────────────────────╮
--  │                         Flatten                          │
--  ╰──────────────────────────────────────────────────────────╯

---Setup `flatten.nvim`
function M.flatten()
    local flatten = F.npcall(require, "flatten")
    if not flatten then
        return
    end

    flatten.setup({
        callbacks = {
            ---Called to determine if a nested session should wait for the host to close the file.
            should_block = flatten.default_should_block,
            ---If this returns true, the nested session will be opened.
            ---If false, default behavior is used, and
            ---config.nest_if_no_args is respected.
            ---@type fun(host: channel):boolean
            should_nest = flatten.default_should_nest,
            -- Called when a request to edit file(s) is received
            pre_open = function()
                -- Close toggleterm when an external open request is received
                -- local term = require("toggleterm.terminal")
                -- local termid = term.get_focused_id()
                -- saved_term = term.get(termid)
                toggleterm.toggle(0)
            end,
            ---Called after a nested session is opened.
            post_open = function(bufnr, winnr, ft, isblocking, _isdiff)
                if ft == "gitcommit" or ft == "gitrebase" then
                    api.nvim_create_autocmd("BufWritePost", {
                        buffer = bufnr,
                        once = true,
                        callback = vim.schedule_wrap(function()
                            api.nvim_buf_delete(bufnr, {})
                        end),
                    })
                else
                    -- If it's a normal file, then reopen the terminal, then switch back to the newly opened window
                    -- This gives the appearance of the window opening independently of the terminal
                    toggleterm.toggle(0)
                    api.nvim_set_current_win(winnr)
                end

                -- if isblocking and saved_term then
                --     -- Hide the terminal while it's blocking
                --     saved_term:close()
                -- else
                --     -- If it's a normal file, just switch to its window
                --     api.nvim_set_current_win(winnr)
                -- end
            end,
            ---Called when a nested session is done waiting for the host.
            block_end = function()
                -- After blocking ends (for a git commit, etc), reopen the terminal
                toggleterm.toggle(0)
                -- vim.schedule(function()
                --     if saved_term then
                --         saved_term:open()
                --         saved_term = nil
                --     end
                -- end)
            end,
        },
        -- <String, Bool> dictionary of filetypes that should be blocking
        block_for = {
            gitcommit = true,
        },
        -- Command passthrough
        allow_cmd_passthrough = true,
        -- Allow a nested session to open if Neovim is opened without arguments
        nest_if_no_args = false,
        -- Window options
        window = {
            -- open = "current",
            open = "alternate",
            diff = "tab_vsplit",
            focus = "first",
        },
        -- Override this function to use a different socket to connect to the host
        -- On the host side this can return nil or the socket address.
        -- On the guest side this should return the socket address
        -- or a non-zero channel id from `sockconnect`
        -- flatten.nvim will detect if the address refers to this instance of nvim, to determine if this is a host or a guest
        pipe_path = require("flatten").default_pipe_path,
        -- The `default_pipe_path` will treat the first nvim instance within a single kitty/wezterm session as the host
        -- You can configure this behaviour using the following:
        one_per = {
            kitty = true,   -- Flatten all instance in the current Kitty session
            wezterm = true, -- Flatten all instance in the current Wezterm session
        },
    })
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                         Floaterm                         │
-- ╰──────────────────────────────────────────────────────────╯
---Setup `floaterm`
function M.floaterm()
    g.fzf_floaterm_newentries = {
        ["+lazygit"] = {
            title = "lazygit",
            height = 0.9,
            width = 0.9,
            cmd = "lazygit",
        },
        ["+gitui"] = {title = "gitui", height = 0.9, width = 0.9, cmd = "gitui"},
        ["+taskwarrior-tui"] = {
            title = "taskwarrior-tui",
            height = 0.99,
            width = 0.99,
            cmd = "taskwarrior-tui",
        },
        ["+flf"] = {
            title = "full screen lf",
            height = 0.9,
            width = 0.9,
            cmd = "lf",
        },
        ["+slf"] = {
            title = "split screen lf",
            wintype = "split",
            height = 0.5,
            cmd = "lf",
        },
        ["+xplr"] = {title = "xplr", cmd = "xplr"},
        ["+gpg-tui"] = {
            title = "gpg-tui",
            height = 0.9,
            width = 0.9,
            cmd = "gpg-tui",
        },
        ["+tokei"] = {title = "tokei", height = 0.9, width = 0.9, cmd = "tokei"},
        ["+dust"] = {title = "dust", height = 0.9, width = 0.9, cmd = "dust"},
        ["+zsh"] = {title = "zsh", height = 0.9, width = 0.9, cmd = "zsh"},
    }

    g.floaterm_shell = "zsh"
    g.floaterm_wintype = "float"
    g.floaterm_height = 0.85
    g.floaterm_width = 0.9
    g.floaterm_borderchars = "─│─│╭╮╯╰"

    hl.plugin("Floaterm", {FloatermBorder = {fg = "#A06469", gui = "none"}})

    -- map("n", "<Leader>fll", "<Cmd>Floaterms<CR>", {desc = "Floaterm: list"})
    map("n", ";fl", "<Cmd>FloatermToggle<CR>", {desc = "Floaterm: toggle"})
    map("n", "<Leader>so", ":FloatermNew --autoclose=0 so<space>", {desc = "StackOverflow helper"})
end

function M.set_terminal_keymaps(buf)
    local function bmap(...)
        Rc.api.bmap(buf, ...)
    end

    -- if not F.is.falsy(fn.mapcheck("jk", "t")) then
    --     Rc.api.del_keymap("t", "<Esc>", {buffer = buf})
    --     Rc.api.del_keymap("t", "jk", {buffer = buf})
    -- end

    bmap("t", "qQ", "<Cmd>close<CR>", {silent = true})
    bmap("t", "<Esc>", [[<C-\><C-n>]])
    bmap("t", ":", ":")
    bmap("t", ":q!", [[<C-\><C-n>:q!<CR>]])
    bmap("t", "<C-h>", [[<Cmd>wincmd h<CR>]])
    bmap("t", "<C-j>", [[<Cmd>wincmd j<CR>]])
    bmap("t", "<C-k>", [[<Cmd>wincmd k<CR>]])
    bmap("t", "<C-l>", [[<Cmd>wincmd l<CR>]])
    bmap("t", "<C-w>", [[<C-\><C-n><C-w>]])
end

--  ╭──────────────────────────────────────────────────────────╮
--  │                     Custom Terminals                     │
--  ╰──────────────────────────────────────────────────────────╯

local function ft_repl_cmd(ft)
    local repl_map = {
        ["lua"] = {"luap", "rep.lua", "lua"},
        ["ruby"] = {"bundle exec rails console"},
        ["eruby"] = {"bundle exec rails console"},
        ["python"] = {"ipython --no-autoindent", "python"},
        ["javascript"] = {"node"},
        ["java"] = {"jshell"},
        ["elixir"] = {"iex"},
        ["julia"] = {"julia"},
        ["gp"] = {"gp"},
        ["r"] = {"R"},
        ["rmd"] = {"R"},
        ["octave"] = {"octave-cli", "octave"},
        ["matlab"] = {"matlab -nodesktop -nosplash"},
        ["idris"] = {"idris"},
        ["lidris"] = {"idris"},
        ["haskell"] = {"stack ghci", "ghci"},
        ["php"] = {"psysh", "php"},
        ["clojure"] = {"lein repl"},
        ["tcl"] = {"tclsh"},
        ["sml"] = {"rlwrap sml", "sml"},
        ["sbt"] = {"sbt console"},
        ["stata"] = {"stata -q"},
        ["racket"] = {"racket"},
        ["lfe"] = {"lfe"},
        ["rust"] = {"evcxr"},
        ["janet"] = {"janet"},
    }

    local executable = function(t)
        if not t then
            return
        end
        for _, c in ipairs(t) do
            if utils.executable(c:match("[^ ]+")) then
                return c
            end
        end
        return nil
    end

    return executable(repl_map[ft])
end

local function term_exec(cmd, id)
    if not id or id < 1 then
        id = 1
    end
    local terms = term.get_all()
    local term_init = false
    for i = #terms, 1, -1 do
        local term = terms[i]
        if term.id == id then
            term_init = true
            break
        end
    end
    if not term_init then
        local repl_cmd = ft_repl_cmd(vim.bo.filetype)
        if repl_cmd then
            toggleterm.exec(repl_cmd, id)
        end
    end
    return toggleterm.exec(cmd, id)
end

-- Sample on how a command can be ran
-- require'toggleterm'.exec("git push", <count>, 12)

---
---@param cmd string Command to be ran
---@param id? number Terminal ID
---@param dir? string directory
---@param direction? "'float'"|"'horizontal'"|"'vertical'"
function M.neoterm(cmd, id, dir, direction)
    if not id or id < 1 then
        id = 1
    end
    toggleterm.exec(cmd, id, nil, dir, direction)
end

function M.terms()
    -- :spawn()   -- cmd runs in background
    -- :toggle()  -- cmd runs when terminal opens

    local float_open = function(term)
        cmd("startinsert!")
        vim.wo.sidescrolloff = 0

        if not F.is.falsy(fn.mapcheck("jk", "t")) then
            Rc.api.del_keymap("t", "<Esc>", {buffer = term.bufnr})
            Rc.api.del_keymap("t", "jk", {buffer = term.bufnr})
        end
    end

    -- terms.dust =
    --     Terminal:new({
    --         cmd = "dust",
    --         direction = "float",
    --         hidden = true,
    --         float_opts = {border = "rounded"},
    --         close_on_exit = false,
    --         on_open = function(term)
    --             float_open(term)
    --             Rc.api.bmap(term.bufnr, "t", "q", "q", {nowait = true})
    --         end,
    --     })
    -- terms.tokei =
    --     Terminal:new({
    --         cmd = "tokei",
    --         direction = "float",
    --         hidden = true,
    --         float_opts = {border = "rounded"},
    --         close_on_exit = false,
    --         on_open = function(term)
    --             float_open(term)
    --             Rc.api.bmap(term.bufnr, "t", "q", "q", {nowait = true})
    --         end,
    --     })
    terms.gpgtui =
        Terminal:new({
            cmd = "gpg-tui",
            direction = "float",
            hidden = true,
            float_opts = {border = "rounded"},
            on_open = function(term)
                float_open(term)
                Rc.api.bmap(term.bufnr, "t", "q", "q", {nowait = true})
            end,
        })
    terms.gitui =
        Terminal:new({
            cmd = "gitui",
            dir = "git_dir",
            direction = "float",
            hidden = true,
            float_opts = {border = "rounded"},
            on_open = float_open,
        })
    terms.lazygit =
        Terminal:new({
            cmd = "lazygit",
            dir = "git_dir",
            direction = "float",
            hidden = true,
            float_opts = {border = "double"},
            on_open = function(term)
                float_open(term)
                Rc.api.bmap(term.bufnr, "t", "q", "q", {nowait = true})
            end,
        })
    terms.tig =
        Terminal:new({
            cmd = "tig",
            dir = "git_dir",
            direction = "tab",
            hidden = true,
            on_open = function(term)
                float_open(term)
                Rc.api.bmap(term.bufnr, "t", "q", "q", {nowait = true})

                vim.opt_local.number = false
                vim.opt_local.relativenumber = false
                vim.opt_local.signcolumn = "no"
                vim.bo.ft = "tig"
            end,
        })
    terms.taskwarrior =
        Terminal:new({
            cmd = "taskwarrior-tui",
            hidden = true,
            direction = "float",
            highlights = {FloatBorder = {link = "Statement"}},
            on_open = function(term)
                float_open(term)
                Rc.api.bmap(term.bufnr, "t", "q", "q", {nowait = true})
            end,
        })
    terms.htop =
        Terminal:new({
            cmd = "htop",
            hidden = true,
            direction = "float",
            highlights = {FloatBorder = {link = "MoreMsg"}},
            on_open = function(term)
                float_open(term)
                Rc.api.bmap(term.bufnr, "t", "q", "q", {nowait = true})
            end,
        })

    local function gpgtui()
        terms.gpgtui:toggle()
    end
    local function gitui()
        terms.gitui:toggle()
    end
    local function lazygit()
        terms.lazygit:toggle()
    end
    local function tig()
        terms.tig:toggle()
    end
    local function taskwarrior()
        terms.taskwarrior:toggle()
    end
    local function htop()
        terms.htop:toggle()
    end

    -- local function tokei()
    --     terms.tokei:toggle()
    -- end
    -- local function dust()
    --     terms.dust:toggle()
    -- end

    Rc.api.commands(
        {"Gitui", F.ithunk(gitui), {nargs = 0, desc = "Git: gitui"}},
        {"LazyGit", F.ithunk(lazygit), {nargs = 0, desc = "Git: lazygit"}},
        {"Tig", F.ithunk(tig), {nargs = 0, desc = "Git: tig"}},
        {"TaskwarriorTUI", F.ithunk(taskwarrior), {nargs = 0, desc = "Term: TaskwarriorTUI"}},
        {"Htop", F.ithunk(htop), {nargs = 0, desc = "Term: htop"}},
        {"GpgTUI", F.ithunk(gpgtui), {nargs = 0, desc = "Term: gpg-tui"}}
    -- {"Dust", F.ithunk(dust), {nargs = 0, desc = "Term: dust"}},
    -- {"Tokei", F.ithunk(tokei), {nargs = 0, desc = "Term: tokei"}}
    )

    map("n", "<Leader>lg", "LazyGit", {desc = "Git: LazyGit", cmd = true})
    map("n", "<Leader>g'", "Tig", {desc = "Git: Tig", cmd = true})
    map("n", "<Leader>tw", "TaskwarriorTUI", {desc = "TaskwarriorTUI", cmd = true})
    map("n", "<Leader>th", "Htop", {desc = "Term: Htop", cmd = true})

    --  ══════════════════════════════════════════════════════════════════════

    -- local function termdir(c, dir)
    --     local opts = {direction = dir, on_open = float_open}
    --     if c ~= nil and not F.is.empty(c) then
    --         opts.cmd = c
    --         -- allows for commands like 'TH ls'
    --         opts.close_on_exit = false
    --     end
    --     local t = Terminal:new(opts)
    --     return t:toggle()
    -- end
    --
    -- command(
    --     "TH",
    --     function(args)
    --         termdir(args.args, "horizontal")
    --     end,
    --     {nargs = "*", desc = "Term: horiz (1 shot w/ args)"}
    -- )
    -- command(
    --     "TV",
    --     function(args)
    --         termdir(args.args, "vertical")
    --     end,
    --     {nargs = "*", desc = "Term: vert (1 shot w/ args)"}
    -- )
end

local function init()
    terms = {}
    open_key = [[<C-\>]]

    toggleterm.setup({
        shell = Rc.meta.shell,
        direction = "float", -- 'vertical' | 'horizontal' | 'tab' | 'float'
        open_mapping = open_key,
        start_in_insert = true,
        insert_mappings = false,  -- whether or not the open mapping applies in insert mode
        terminal_mappings = true, -- whether or not the open mapping applies in the opened terminals
        shade_filetypes = {},
        -- shade_filetypes = {"none", "fzf"},
        shade_terminals = false,
        shading_factor = "1", -- the degree by which to darken to terminal colour, default: 1 for dark
        hide_numbers = true,  -- hide the number column in toggleterm buffers
        persist_size = true,
        persist_mode = true,  -- if set to true previous terminal mode will be remembered
        close_on_exit = true, -- -- close the terminal window when the process exits
        auto_scroll = true,   -- auto scroll to the bottom on terminal output
        autochdir = false,    -- when nvim changes dir, term will change it's own when opened
        -- on_create = fun(t: Terminal),
        -- on_open   = fun(t: Terminal),
        -- on_close  = fun(t: Terminal),
        -- on_stdout = fun(t: Terminal, job: number, data: string[], name: string)
        -- on_stderr = fun(t: Terminal, job: number, data: string[], name: string)
        -- on_exit   = fun(t: Terminal, job: number, exit_code: number, name: string)
        ---@param t Terminal
        on_open = function(t)
            if not env.TERM_NOFOCUS then
                vim.defer_fn(
                    function()
                        if t.direction == "horizontal" then
                            cmd.wincmd("j")
                        elseif t.direction == "vertical" then
                            cmd.wincmd("l")
                        end
                        cmd("startinsert!")
                    end,
                    20
                )
            end
        end,
        size = function(term)
            if term.direction == "horizontal" then
                return vim.o.lines * 0.4
            elseif term.direction == "vertical" then
                return vim.o.columns * 0.5
            end
        end,
        float_opts = {
            border = Rc.style.border,
            width = math.floor(vim.o.columns * 0.85),
            height = math.floor(vim.o.lines * 0.8),
            winblend = 4,
            zindex = 100,
        },
        highlights = {
            Normal = {link = "Normal"},
            NormalFloat = {link = "NormalFloat"},
            FloatBorder = {guifg = "#ea6962"},
        },
        -- winbar = {
        --     enabled = true,
        --     name_formatter = function(term)
        --         return term.name
        --     end,
        -- },
    })

    map(
        "n",
        "<Leader>tX",
        function()
            return term_exec(fn.getline("."))
        end,
        {desc = "REPL current line"}
    )

    -- map(
    --     "v",
    --     "<Leader>tx",
    --     function()
    --         -- N(op.get_visual_selection())
    --         term_exec(utils.get_visual_selection())
    --     end,
    --     {desc = "REPL current selection"}
    -- )

    -- map("n", "", "<Cmd>ToggleTermSendCurrentLine <T_ID><CR>", {desc = "REPL: whole line"})
    -- map("x", "", "<Cmd>ToggleTermSendVisualLines <T_ID><CR>", {desc = "REPL: whole line visual sel"})
    -- map("x", "", "<Cmd>ToggleTermSendVisualSelection <T_ID><CR>", {desc = "REPL: visual sel"})

    command(
        "TR",
        function(args)
            term_exec(args.args, args.count)
        end,
        {nargs = "*", count = 1, desc = "Terminal: REPL"}
    )

    -- FIX: Two lines are opened in the terminal
    -- Equivalent to neoterms `T`
    command(
        "T",
        function(args)
            M.neoterm(args.args, args.count, nil, "float")
        end,
        {nargs = "*", count = 1, desc = "Terminal: open"}
    )
    command(
        "TH",
        function(args)
            M.neoterm(args.args, args.count, nil, "horizontal")
        end,
        {nargs = "*", count = 1, desc = "Term: horiz"}
    )
    command(
        "TV",
        function(args)
            M.neoterm(args.args, args.count, nil, "vertical")
        end,
        {nargs = "*", count = 1, desc = "Term: vert"}
    )

    wk.register({
        [open_key] = "Open ToggleTerm",
        ["<Leader>tx"] = {"<Cmd>T<CT>", "Term: open"},
    }, {mode = "n"})

    -- M.term_autocmds()
    M.terms()
end

init()

return M
