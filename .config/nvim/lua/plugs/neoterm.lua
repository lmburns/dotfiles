---@module 'plugs.neoterm'
local M = {}

local shared = require("usr.shared")
local F = shared.F
local toggleterm = F.npcall(require, "toggleterm")
if not toggleterm then
    return
end

local term = require("toggleterm.terminal")
local Terminal = term.Terminal

local utils = shared.utils
local hl = shared.color
local mpi = require("usr.api")
local map = mpi.map
local command = mpi.command
local style = require("usr.style")
-- local op = require("usr.lib.op")

local wk = require("which-key")

local cmd = vim.cmd
local fn = vim.fn
local g = vim.g
local api = vim.api
local env = vim.env

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
            -- Called when a request to edit file(s) is received
            pre_open = function()
                -- Close toggleterm when an external open request is received
                toggleterm.toggle(0)
            end,
            -- Called after a file is opened
            -- Passed the buf id, win id, and filetype of the new window
            post_open = function(bufnr, winnr, ft)
                if ft == "gitcommit" then
                    -- If the file is a git commit, create one-shot autocmd to delete it on write
                    -- If you just want the toggleable terminal integration, ignore this bit and only use the
                    -- code in the else block
                    api.nvim_create_autocmd(
                        "BufWritePost",
                        {
                            buffer = bufnr,
                            once = true,
                            callback = function()
                                -- This is a bit of a hack, but if you run bufdelete immediately
                                -- the shell can occasionally freeze
                                vim.defer_fn(
                                    function()
                                        api.nvim_buf_delete(bufnr, {})
                                    end,
                                    50
                                )
                            end,
                        }
                    )
                else
                    -- If it's a normal file, then reopen the terminal, then switch back to the newly opened window
                    -- This gives the appearance of the window opening independently of the terminal
                    toggleterm.toggle(0)
                    api.nvim_set_current_win(winnr)
                end
            end,
            -- Called when a file is open in blocking mode, after it's done blocking
            -- (after bufdelete, bufunload, or quitpre for the blocking buffer)
            block_end = function()
                -- After blocking ends (for a git commit, etc), reopen the terminal
                toggleterm.toggle(0)
            end,
        },
        -- <String, Bool> dictionary of filetypes that should be blocking
        block_for = {
            gitcommit = true,
        },
    })
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                         Floaterm                         │
-- ╰──────────────────────────────────────────────────────────╯
---Setup `flatten.nvim`
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

    map("n", "<Leader>fll", ":Floaterms<CR>", {desc = "List floaterms"})
    map("n", ";fl", ":FloatermToggle<CR>", {desc = "Toggle Floaterm"})
    map("n", "<Leader>so", ":FloatermNew --autoclose=0 so<space>", {desc = "StackOverflow helper"})
end

--  ╭──────────────────────────────────────────────────────────╮
--  │                         Autocmds                         │
--  ╰──────────────────────────────────────────────────────────╯
function M.term_autocmds()
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
        command = function()
            -- vim.wo.statusline = "%{b:term_title}"
            M.set_terminal_keymaps()
            vim.wo.number = false
            vim.wo.relativenumber = false
            vim.bo.bufhidden = "hide"
            cmd.startinsert()
        end,
        desc = "Set terminal mappings",
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
end

function M.set_terminal_keymaps()
    local function bmap(...)
        mpi.bmap(0, ...)
    end

    bmap("t", ":", ":")
    bmap("t", "<Esc>", [[<C-\><C-n>]])
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
---@param direction? 'float'|'horizontal'|'vertical'
function M.neoterm(cmd, id, dir, direction)
    if not id or id < 1 then
        id = 1
    end
    toggleterm.exec(cmd, id, nil, dir, direction)
end

function M.terms()
    -- Terminal:new {
    --   cmd = string                -- cmd to exe when creating term
    --   direction = string          -- layout for the term, same as the main config
    --   dir = string                -- the directory for the term
    --   close_on_exit = bool        -- close the term window when process exits
    --   highlights = table          -- table with highlights
    --   env = table                 -- key:value table with env vars passed to jobstart()
    --   clear_env = bool            -- use only env vars from `env`, passed to jobstart()
    --   on_open = fun(t: Terminal)  -- func to run when the term opens
    --   on_close = fun(t: Terminal) -- func to run when the term closes
    --   auto_scroll = boolean       -- auto scroll to bottom on term output
    --   on_stdout = fun(t: Terminal, job: number, data: string[], name: string)
    --   on_stderr = fun(t: Terminal, job: number, data: string[], name: string)
    --   on_exit = fun(t: Terminal, job: number, exit_code: number, name: string)
    -- }
    --
    -- :spawn()   -- cmd runs in background
    -- :toggle()  -- cmd runs when terminal opens

    local float_open = function(term)
        cmd("startinsert!")
        vim.wo.sidescrolloff = 0
        -- mpi.bmap(term.bufnr, "n", "qq", "<Cmd>close<CR>", {silent = true})

        if not utils.is.falsy(fn.mapcheck("jk", "t")) then
            mpi.del_keymap("t", "<esc>", {buffer = term.bufnr})
            mpi.del_keymap("t", "jk", {buffer = term.bufnr})
        end
    end

    local lazygit =
        Terminal:new({
            cmd = "lazygit",
            dir = "git_dir",
            direction = "float",
            -- hidden = true,
            float_opts = {border = "double"},
            on_open = float_open,
        })

    local function lg()
        lazygit:toggle()
    end

    map("n", "<leader>lg", F.ithunk(lg), {desc = "LazyGit"})

    --  ══════════════════════════════════════════════════════════════════════

    -- TaskWarrior TUI
    local taskwarrior =
        Terminal:new({
            cmd = "taskwarrior-tui",
            -- hidden = true,
            direction = "float",
            on_open = float_open,
            highlights = {FloatBorder = {link = "Statement"}},
        })

    command(
        "TaskwarriorTUI",
        function()
            taskwarrior:toggle()
        end,
        {nargs = 0, desc = "Term: TaskwarriorTUI"}
    )

    --  ══════════════════════════════════════════════════════════════════════

    -- Htop
    local htop =
        Terminal:new(
            {
                cmd = "htop",
                -- hidden = true,
                direction = "float",
                on_open = float_open,
                highlights = {FloatBorder = {link = "MoreMsg"}},
            }
        )

    command(
        "Htop",
        function()
            htop:toggle()
        end,
        {nargs = 0, desc = "Term: htop"}
    )

    map("n", "<Leader>flh", "Htop", {desc = "Term: htop", cmd = true})
    map("n", "<Leader>hT", "Htop", {desc = "Term: htop", cmd = true})

    --  ══════════════════════════════════════════════════════════════════════

    -- local function termdir(c, dir)
    --     local opts = {direction = dir, on_open = float_open}
    --     if c ~= nil and not utils.is.empty(c) then
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
    local open_key = [[<C-\>]]

    toggleterm.setup(
        {
            shell = lb.vars.shell,
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
                border = style.current.border,
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
        }
    )

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

    wk.register(
        {
            [open_key] = "Open ToggleTerm",
            ["<Leader>tw"] = {"<Cmd>TaskwarriorTUI<CR>", "Term: Taskwarrior TUI"},
            ["<Leader>tx"] = {"<Cmd>T<CT>", "Term: open"},
        },
        {mode = "n"}
    )

    -- M.term_autocmds()
    M.terms()
end

init()

return M
