---@module 'plugs.neotest'
local M = {}

local F = Rc.F
local neotest = F.npcall(require, "neotest")
if not neotest then
    return
end

local hl = Rc.shared.hl
local map = Rc.api.map
local command = Rc.api.command
-- local op = Rc.lib.op
local it = F.ithunk

local wk = require("which-key")

local cmd = vim.cmd
local fn = vim.fn

function M.setup()
    local python_adapter = F.npcall(require, "neotest-python")
    if not python_adapter then
        return
    end
    local go_adapter = F.npcall(require, "neotest-go")
    if not go_adapter then
        return
    end
    local plenary_adapter = F.npcall(require, "neotest-plenary")
    if not plenary_adapter then
        return
    end
    local vim_adapter = F.npcall(require, "neotest-vim-test")
    if not vim_adapter then
        return
    end

    neotest.setup({
        icons = {
            non_collapsible = "─",
            collapsed = "─",
            expanded = "╮",
            child_indent = "│",
            child_prefix = "├",
            final_child_prefix = "╰",
            final_child_indent = " ",
            skipped = " ",
            passed = " ", -- ✔
            running = " ", -- ↻
            failed = " ", -- ✖
            unknown = " ", -- ?
            -- running_animated = { "←", "↖", "↑", "↗", "→", "↘", "↓", "↙" },
            running_animated = vim.tbl_map(
                function(s)
                    return s .. " "
                end,
                {"⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"}
            ),
        },
        summary = {
            enabled = true,
            expand_errors = true,
            follow = true,
            mappings = {
                attach = "a",
                expand = {"l", "<CR>", "<2-LeftMouse>"},
                expand_all = "L",
                jumpto = "gf",
                output = "o",
                run = "r",
                short = "O",
                stop = {"<Space>", "u"},
            },
        },
        highlights = {
            adapter_name = "NeotestAdapterName",
            border = "NeotestBorder",
            dir = "NeotestDir",
            expand_marker = "NeotestExpandMarker",
            failed = "NeotestFailed",
            file = "NeotestFile",
            focused = "NeotestFocused",
            indent = "NeotestIndent",
            namespace = "NeotestNamespace",
            passed = "NeotestPassed",
            running = "NeotestRunning",
            skipped = "NeotestSkipped",
            test = "NeotestTest",
        },
        strategies = {
            integrated = {height = 40, width = 180},
        },
        consumers = {overseer = require("neotest.consumers.overseer")},
        discovery = {enabled = false},
        diagnostic = {enabled = true},
        run = {enabled = true},
        quickfix = {enabled = false},
        status = {
            enabled = true,
            virtual_text = true,
            signs = true,
        },
        output = {
            enabled = true,
            open_on_run = false,
            -- open_on_run = "short",
        },
        adapters = {
            python_adapter({
                dap = {justMyCode = false, console = "integratedTerminal"},
                args = {"--log-level", "DEBUG"},
                runner = "pytest",
            }),
            go_adapter,
            plenary_adapter,
            vim_adapter({
                allow_file_types = {"ruby", "typescript"},
                -- ignore_file_types = { "python", "vim", "lua" },
            }),
        },
    })
end

local function init()
    cmd.packadd("neotest")
    cmd.packadd("neotest-python")
    cmd.packadd("neotest-plenary")
    cmd.packadd("neotest-go")
    cmd.packadd("neotest-vim-test")
    -- cmd.packadd("overseer")

    M.setup()

    hl.plugin("Neotest", {
        NeotestPassed = {default = true, link = "Type"},
        NeotestRunning = {default = true, link = "@text.hint"},
        NeotestFailed = {default = true, link = "@text.error"},
        NeotestSkipped = {default = true, link = "@text.warning"},
        NeotestUnknown = {link = "@text.info"},
        NeotestTest = {default = true, link = "Title"},
        NeotestNamespace = {default = true, link = "@namespace"},
        NeotestFocused = {default = true, link = "QuickFixLine"},
        NeotestFile = {default = true, link = "@text.uri"}, -- @text.strong, @bold
        NeotestDir = {default = true, link = "Function"},
        NeotestIndent = {default = true, link = "Conceal"},
        NeotestExpandMarker = {default = true, link = "Conceal"},
        NeotestAdapterName = {default = true, link = "@constructor"},
    })

    local function run_file()
        neotest.run.run(fn.expand("%"))
    end

    local function run_cwd()
        neotest.run.run(fn.expand("%:p:h"))
    end
    local function run_all()
        for _, adaptid in ipairs(neotest.run.adapters()) do
            neotest.run.run({suite = true, adapter = adaptid})
        end
    end

    command("TestNear", neotest.run.run, {desc = "neotest: Nearest"})
    command("TestCurrent", run_file, {desc = "neotest: Run file"})
    command("TestSummary", neotest.summary.toggle, {desc = "neotest: Summary"})
    command("TestOutput", it(neotest.output.open, {enter = true}), {desc = "neotest: Output"})
    command("TestStop", neotest.run.stop, {desc = "neotest: Stop"})
    command("TestAttach", neotest.run.attach, {desc = "neotest: Attach"})
    command(
        "TestStrat",
        function(args)
            if _t({"dap", "integrated"}):contains(args.args) then
                neotest.run.run({strategy = args.args})
            else
                neotest.run.run({strategy = "integrated"})
            end
        end,
        {force = true, nargs = 1, desc = "neotest: Strategy"}
    )

    map("n", "[.", neotest.jump.prev, {desc = "Previous test"})
    map("n", "].", neotest.jump.next, {desc = "Next test"})
    map("n", "[Y", it(neotest.jump.prev, {status = "failed"}), {desc = "Prev failed Test"})
    map("n", "]Y", it(neotest.jump.next, {status = "failed"}), {desc = "Next failed Test"})

    wk.register(
        {
            u = {neotest.summary.toggle, "neotest: Summary"},
            o = {it(neotest.output.open, {enter = true}), "neotest: Output"},
            O = {
                it(neotest.output.open, {enter = true, short = true}),
                "neotest: Output (short)",
            },
            A = {it(neotest.run.attach), "neotest: Run attach"},
            l = {it(neotest.run.run_last), "neotest: Run last"},
            -- strategy = integrated
            D = {it(neotest.run.run_last, {strategy = "dap"}), "neotest: Run last (dap)"},
            d = {it(neotest.run.run, {strategy = "dap"}), "neotest: Run nearest (dap)"},
            n = {it(neotest.run.run), "neotest: Run nearest"},
            a = {run_all, "neotest: Run all"},
            f = {run_file, "neotest: Run file"},
            c = {run_cwd, "neotest: Run cwd"},
            s = {it(neotest.run.stop), "neotest: Stop"},
        },
        {prefix = "<Leader>t", mode = "n"}
    )
end

init()

return M
