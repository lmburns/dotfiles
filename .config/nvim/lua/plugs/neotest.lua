local M = {}

local D = require("dev")
local neotest = D.npcall(require, "neotest")
if not neotest then
    return
end

local wk = require("which-key")
local utils = require("common.utils")
local map = utils.map
local command = utils.command

local ex = vim.cmd
local fn = vim.fn

function M.setup()
    local python_adapter = D.npcall(require, "neotest-python")
    if not python_adapter then
        return
    end

    local go_adapter = D.npcall(require, "neotest-go")
    if not go_adapter then
        return
    end

    local plenary_adapter = D.npcall(require, "neotest-plenary")
    if not plenary_adapter then
        return
    end

    local vim_adapter = D.npcall(require, "neotest-vim-test")
    if not vim_adapter then
        return
    end

    neotest.setup(
        {
            icons = {
                child_indent = "│",
                child_prefix = "├",
                collapsed = "─",
                expanded = "╮",
                failed = "✖",
                final_child_indent = " ",
                final_child_prefix = "╰",
                non_collapsible = "─",
                passed = "✔",
                running = "↻",
                skipped = "ﰸ",
                unknown = "?"
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
                    stop = "<Space>" -- u
                }
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
                test = "NeotestTest"
            },
            strategies = {
                integrated = {
                    height = 40,
                    width = 180
                }
            },
            discovery = {
                enabled = false
            },
            diagnostic = {
                enabled = true
            },
            run = {
                enabled = true
            },
            status = {
                enabled = true
            },
            output = {
                enabled = true,
                open_on_run = false
                -- open_on_run = "short",
            },
            adapters = {
                python_adapter(
                    {
                        -- Extra arguments for nvim-dap configuration
                        dap = {justMyCode = false, console = "integratedTerminal"},
                        args = {"--log-level", "DEBUG"},
                        runner = "pytest"
                    }
                ),
                go_adapter,
                plenary_adapter,
                vim_adapter(
                    {
                        allow_file_types = {"ruby", "typescript"}
                        -- ignore_file_types = { "python", "vim", "lua" },
                    }
                )
            }
        }
    )
end

local function init()
    ex.packadd("neotest-python")
    ex.packadd("neotest-plenary")
    ex.packadd("neotest-vim-test")
    ex.packadd("neotest-go")

    M.setup()

    vim.cmd(
        [[
            hi! link NeotestPassed String
            hi! link NeotestFailed DiagnosticError
            hi! link NeotestRunning Constant
            hi! link NeotestSkipped DiagnosticInfo
            hi! link NeotestTest Normal
            hi! link NeotestNamespace TSKeyword
            hi! link NeotestFocused QuickFixLine
            hi! link NeotestFile Keyword
            hi! link NeotestDir Keyword
            hi! link NeotestIndent Conceal
            hi! link NeotestExpandMarker Conceal
            hi! link NeotestAdapterName TSConstructor
        ]]
    )

    local function run_file()
        neotest.run.run(fn.expand("%"))
    end

    local function run_cwd()
        neotest.run.run(fn.expand("%:p:h"))
    end

    command("TestNear", D.ithunk(neotest.run.run), {desc = "neotest: Nearest"})
    command("TestCurrent", D.ithunk(run_file), {desc = "neotest: Run file"})
    command("TestSummary", D.ithunk(neotest.summary.toggle), {desc = "neotest: Summary"})
    command("TestOutput", D.ithunk(neotest.output.open, {enter = true}), {desc = "neotest: Output"})
    command("TestStop", D.ithunk(neotest.run.stop), {desc = "neotest: Stop"})
    command("TestAttach", D.ithunk(neotest.run.attach), {desc = "neotest: Attach"})
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

    map("n", "[k", D.ithunk(neotest.jump.prev), {desc = "Previous Test"})
    map("n", "]k", D.ithunk(neotest.jump.next), {desc = "Next Test"})
    map("n", "[K", D.ithunk(neotest.jump.prev, {status = "failed"}), {desc = "Previous Failed Test"})
    map("n", "]K", D.ithunk(neotest.jump.next, {status = "failed"}), {desc = "Next Failed Test"})

    wk.register(
        {
            u = {D.ithunk(neotest.summary.toggle), "neotest: Summary"},
            o = {D.ithunk(neotest.output.open, {enter = true}), "neotest: Output"},
            O = {D.ithunk(neotest.output.open, {enter = true, short = true}), "neotest: Output (short)"},
            a = {D.ithunk(neotest.run.attach), "neotest: Run attach"},
            l = {D.ithunk(neotest.run.run_last), "neotest: Run last"},
            D = {D.ithunk(neotest.run.run_last, {strategy = "dap"}), "neotest: Run last (dap)"}, -- strategy = integrated
            n = {D.ithunk(neotest.run.run), "neotest: Run nearest"},
            d = {D.ithunk(neotest.run.run, {strategy = "dap"}), "neotest: Run nearest (dap)"},
            -- f = {D.ithunk(neotest.run.run, fn.expand("%")), "neotest: Run file"},
            f = {run_file, "neotest: Run file"},
            c = {run_cwd, "neotest: Run cwd"},
            s = {D.ithunk(neotest.run.stop), "neotest: Stop"}
        },
        {prefix = "<Leader>t", mode = "n"}
    )
end

init()

return M
