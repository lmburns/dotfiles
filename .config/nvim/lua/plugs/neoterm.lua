local M = {}

local D = require("dev")
local terminal = D.npcall(require, "toggleterm")
if not terminal then
    return
end

local utils = require("common.utils")
local bmap = utils.bmap
local map = utils.map
local command = utils.command

local fn = vim.fn

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

function M.set_terminal_keymaps()
    map("t", "<Esc>", [[<C-\><C-n>]], {buffer = true})
    -- Why does this need to be remapped to work?
    map("t", ":", ":", {buffer = true})
    map("t", ":q!", [[<C-\><C-n>:q!<CR>]], {buffer = true})

    -- bmap(0, "t", "jk", [[<C-\><C-n>]])
    -- bmap(0, "t", "kj", [[<C-\><C-n>]])
    -- bmap(0, "t", "<C-h>", [[<C-\><C-n><C-W>h]])
    -- bmap(0, "t", "<C-j>", [[<C-\><C-n><C-W>j]])
    -- bmap(0, "t", "<C-k>", [[<C-\><C-n><C-W>k]])
    -- bmap(0, "t", "<C-l>", [[<C-\><C-n><C-W>l]])
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
            close_on_exit = false,
            float_opts = {
                border = "rounded",
                width = math.floor(vim.o.columns * 0.85),
                height = math.floor(vim.o.lines * 0.8),
                winblend = 4,
                highlights = {
                    -- border = "Normal",
                    -- background = "Normal",
                    border = "TSNote"
                }
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
            local mode = vim.fn.mode()
            if mode == "v" or mode == "V" or mode == "" then
                local text = utils.get_visual_selection()
                term_exec(text)
            end
        end,
        {desc = "REPL current selection"}
    )

    -- Terminal repl
    command(
        "TR",
        function(tbl)
            term_exec(tbl.args, tbl.count)
        end,
        {nargs = "*", count = 1, desc = "Terminal REPL"}
    )

    command("TP", [[botright sp | resize 20 | term <args>]], {nargs = "*", desc = "Terminal split"})
    command("VT", [[vsp | term <args>]], {nargs = "*", desc = "Terminal vertical split"})

    -- Equivalent to neoterms `T`
    command(
        "T",
        function(tbl)
            M.neoterm(tbl.args, tbl.count)
        end,
        {nargs = "*", count = 1, desc = "Neoterm"}
    )

    map("n", "gzo", "<Cmd>T<CR>", {desc = "Open terminal"})
end

init()

return M
