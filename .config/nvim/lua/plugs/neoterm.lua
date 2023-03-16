local M = {}

local D = require("dev")
local terminal = D.npcall(require, "toggleterm")
if not terminal then
    return
end

local utils = require("common.utils")
local map = utils.map
local command = utils.command

local fn = vim.fn
local api = vim.api

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
        ["janet"] = {"janet"}
    }

    local executable = function(t)
        if not t then
            return
        end
        for _, c in ipairs(t) do
            if fn.executable(c:match("[^ ]+")) == 1 then
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
    local terms = require("toggleterm.terminal").get_all()
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
            terminal.exec(repl_cmd, id)
        end
    end
    return terminal.exec(cmd, id)
end

-- ========================= Custom Terminals =========================
-- ====================================================================

local function bmap(...)
    utils.bmap(0, ...)
end

function M.set_terminal_keymaps()
    bmap("t", ":", ":")
    bmap("t", "<Esc>", [[<C-\><C-n>]])
    bmap("t", ":q!", [[<C-\><C-n>:q!<CR>]])
    bmap("t", "<C-h>", [[<cmd>wincmd h<CR>]])
    bmap("t", "<C-j>", [[<cmd>wincmd j<CR>]])
    bmap("t", "<C-k>", [[<cmd>wincmd k<CR>]])
    bmap("t", "<C-l>", [[<cmd>wincmd l<CR>]])
end

-- Sample on how a command can be ran
-- require'toggleterm'.exec("git push", <count>, 12)

function M.neoterm(cmd, id)
    if not id or id < 1 then
        id = 1
    end
    local terms = require("toggleterm.terminal").get_all()
    for i = #terms, 1, -1 do
        local term = terms[i]
        if term.id == id then
            break
        end
    end
    return terminal.exec(cmd, id)
end

---Setup `flatten.nvim`
function M.flatten()
    local flatten = D.npcall(require, "flatten")
    if not flatten then
        return
    end

    flatten.setup(
        {
            callbacks = {
                -- Called when a request to edit file(s) is received
                pre_open = function()
                    -- Close toggleterm when an external open request is received
                    terminal.toggle(0)
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
                                end
                            }
                        )
                    else
                        -- If it's a normal file, then reopen the terminal, then switch back to the newly opened window
                        -- This gives the appearance of the window opening independently of the terminal
                        terminal.toggle(0)
                        api.nvim_set_current_win(winnr)
                    end
                end,
                -- Called when a file is open in blocking mode, after it's done blocking
                -- (after bufdelete, bufunload, or quitpre for the blocking buffer)
                block_end = function()
                    -- After blocking ends (for a git commit, etc), reopen the terminal
                    terminal.toggle(0)
                end
            },
            -- <String, Bool> dictionary of filetypes that should be blocking
            block_for = {
                gitcommit = true
            }
        }
    )
end

local function init()
    terminal.setup(
        {
            size = function(term)
                if term.direction == "horizontal" then
                    return vim.o.lines * 0.4
                elseif term.direction == "vertical" then
                    return vim.o.columns * 0.5
                end
            end,
            open_mapping = [[<c-\>]],
            hide_numbers = true,
            shade_filetypes = {},
            shade_terminals = true,
            shading_factor = "1", -- the degree by which to darken to terminal colour, default: 1 for dark
            start_in_insert = true,
            insert_mappings = true, -- whether or not the open mapping applies in insert mode
            terminal_mappings = true, -- whether or not the open mapping applies in the opened terminals
            persist_size = true,
            shell = vim.o.shell,
            direction = "float",
            -- direction = "horizontal",
            close_on_exit = true,
            float_opts = {
                border = "rounded",
                width = math.floor(vim.o.columns * 0.85),
                height = math.floor(vim.o.lines * 0.8),
                winblend = 4
            }
        }
    )

    map(
        "n",
        "gzz",
        function()
            return term_exec(fn.getline("."))
        end,
        {desc = "REPL current line"}
    )

    map(
        "v",
        "gz",
        function()
            local mode = utils.mode()
            if mode == "v" or mode == "V" or mode == "" then
                local text = utils.get_visual_selection()
                term_exec(text)
            end
        end,
        {desc = "REPL current selection"}
    )

    -- Terminal repl
    command("TP", [[botright sp | resize 20 | term <args>]], {nargs = "*", desc = "Terminal split"})
    command("VT", [[vsp | term <args>]], {nargs = "*", desc = "Terminal vertical split"})

    command(
        "TR",
        function(args)
            term_exec(args.args, args.count)
        end,
        {nargs = "*", count = 1, desc = "Terminal REPL"}
    )

    -- Equivalent to neoterms `T`
    command(
        "T",
        function(args)
            M.neoterm(args.args, args.count)
        end,
        {nargs = "*", count = 1, desc = "Neoterm"}
    )

    map("n", "gzo", "<Cmd>T<CR>", {desc = "Open terminal"})

    local Terminal = require("toggleterm.terminal").Terminal

    -- local lazygit =
    --     Terminal:new(
    --     {
    --         cmd = "lazygit",
    --         dir = "git_dir",
    --         hidden = true,
    --         direction = "float",
    --         on_open = float_handler
    --     }
    -- )

    -- TaskWarrior TUI
    local tw_tui =
        Terminal:new(
        {
            cmd = "taskwarrior-tui",
            hidden = true,
            direction = "float",
            on_open = M.set_terminal_keymaps,
            highlights = {
                FloatBorder = {link = "FloatBorder"},
                NormalFloat = {link = "NormalFloat"}
            }
        }
    )

    command(
        "TaskwarriorTUI",
        function()
            tw_tui:toggle()
        end,
        {nargs = "*", count = 1, desc = "Term: TaskwarriorTUI"}
    )

    map("n", "<Leader>tw", "<Cmd>TaskwarriorTUI<CR>", {desc = "Term: Taskwarrior TUI"})
end

init()

return M
