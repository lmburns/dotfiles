---@module 'plugs.dap'
local M = {}

local F = Rc.F
local cmd = vim.cmd
cmd.packadd("nvim-dap")
local dap = F.npcall(require, "dap")
if not dap then
    return
end
cmd.packadd("nvim-dap-ui")
local dapui = F.npcall(require, "dapui")
if not dapui then
    return
end
cmd.packadd("one-small-step-for-vimkind")
local osv = F.npcall(require, "osv")
if not osv then
    return
end

local lazy = require("usr.lazy")
local telescope = lazy.require_on.call_rec("telescope")
local widgets = require("dap.ui.widgets")
local wk = require("which-key")

-- local log = Rc.lib.log
local I = Rc.style.plugins.dap
local command = Rc.api.command

local fn = vim.fn
local uv = vim.loop
local env = vim.env
local it = F.ithunk

local nvim_server
local nvim_chanID

function M.setup()
    -- command("BreakpointToggle", ithunk(dap.toggle_breakpoint), {desc = "[dap]: Toggle breakpoint"})
    command("Debug", it(dap.continue), {desc = "[dap]: Continue"})
    command("DapREPL", it(dap.repl.open), {desc = "[dap]: Open REPL"})
    command("DapLaunch", it(osv.launch), {desc = "[osv]: Launch"})
    command("DapRun", it(osv.run_this), {desc = "[osv]: Run this"})
    command("DapUIOpen", it(dapui.open), {desc = "[dapui]: Open"})
    command("DapUIClose", it(dapui.close), {desc = "[dapui]: Close"})
    command("DapUIToggle", it(dapui.toggle), {desc = "[dapui]: Toggle"})

    -- Inspect all scope properties
    local function inspect_scope()
        widgets.centered_float(widgets.scopes).open()
    end
    local function dapui_eval_input()
        dapui.eval(fn.input("[Expression] > "))
    end
    local function dap_breakpoint_input()
        dap.set_breakpoint(nil, nil, fn.input("[Breakpoint condition] > "))
    end

    wk.register({
        d = {
            name = "+debugger",
            S = {dap.restart, "dap: restart execution"},
            X = {dap.terminate, "dap: terminate session"},
            D = {dap.disconnect, "dap: disconnect session"},
            x = {dap.close, "dap: close session"},
            g = {dap.session, "dap: get session"},
            z = {dap.pause, "dap: pause execution"},
            c = {dap.continue, "dap: continue / start"},
            b = {dap.toggle_breakpoint, "dap: toggle breakpoint"},
            B = {dap.set_breakpoint, "dap: set breakpoint"},
            ["<C-b>"] = {dap.clear_breakpoints, "dap: clear breakpoints"},
            -- B = {dap_breakpoint_input, "dap: input breakpoint"},
            k = {dap.up, "dap: up in callstack"},
            j = {dap.down, "dap: down in callstack"},
            i = {dap.step_into, "dap: step into"},
            l = {dap.step_out, "dap: step out"},
            o = {dap.step_over, "dap: step over"},
            I = {dap.step_back, "dap: step back"},
            L = {dap.run_last, "dap REPL: run last"},
            r = {dap.run_to_cursor, "dap: run to cursor"},
            F = {dap.restart_frame, "dap: restart frame"},
            f = {dap.focus_frame, "dap: focus frame"},

            R = {osv.run_this, "dap OSV: run this"},
            -- R = {osv.start_trace, "dap OSV: start trace"},
            -- R = {osv.stop_trace, "dap OSV: stop trace"},
            d = {osv.launch, "dap OSV: start"},

            -- T = {it(dap.repl.open), "dap REPL: open"},
            t = {it(dap.repl.toggle, nil, "bo sp"), "dap REPL: toggle"},
            -- L = {dap.repl.run_last, "dap REPL: run last"},

            U = {it(dapui.toggle, {reset = true}), "dap UI: open"},
            v = {dapui.eval, "dap UI: eval"},
            m = {dapui.float_element, "dap UI: float element (query)"},
            P = {it(dapui.float_element, "scopes"), "dap UI: float scopes"},
            E = {it(dapui.float_element, "repl"), "dap UI: float repl"},
            W = {it(dapui.float_element, "watches"), "dap UI: float watches"},
            s = {it(widgets.centered_float, widgets.scopes), "dap widgets: center scope"},
            A = {it(widgets.centered_float, widgets.frames), "dap widgets: center frames"},
            h = {widgets.hover, "dap widgets: hover vars"},
            p = {widgets.preview, "dap widgets: preview"},
            -- w = {dapui.elements.watches.add, "dap UI: add watch"},
            -- s = {inspect_scope, "dap widgets: inspect scope"},
            -- E = {dapui_eval_input, "dap UI: eval input"},
        },
    }, {prefix = "<LocalLeader>"})

    wk.register({
        d = {
            name = "+debugger",
            h = {widgets.hover, "dap widgets: hover"},
            p = {widgets.preview, "dap widgets: preview"},
            v = {dapui.eval, "dap UI: eval"},
        },
    }, {prefix = "<LocalLeader>", mode = "x"})

    wk.register({
        ["<F25>"] = {osv.run_this, "dap OSV: run this"},
        ["<F26>"] = {dap.continue, "dap: continue / start"},
        ["<F31>"] = {dap.step_into, "dap: step into"},
        ["<F32>"] = {dap.step_out, "dap: step out"},
        ["<F33>"] = {dap.step_over, "dap: step over"},
        ["<F35>"] = {dap.step_back, "dap: step back"},
        ["<F30>"] = {dap.close, "dap: close session"},
        ["<F34>"] = {dap.toggle_breakpoint, "dap: toggle breakpoint"},
        ["<F28>"] = {dap.terminate, "dap: terminate session"},
    })

    wk.register({
        d = {
            name = "+telescope",
            m = {telescope.extensions.dap.commands, "dap: commands"},
            o = {telescope.extensions.dap.configurations, "dap: configurations"},
            b = {telescope.extensions.dap.list_breakpoints, "dap: list breakpoints"},
            v = {telescope.extensions.dap.variables, "dap: variables"},
            F = {telescope.extensions.dap.frames, "dap: frames"},
        },
    }, {prefix = "<Leader>"})
end

function M.setup_dap_python()
    cmd.packadd("nvim-dap-python")
    local dap_python = F.npcall(require, "dap-python")
    if not dap_python then
        return
    end

    dap_python.setup(("%s/shims/python"):format(env.PYENV_ROOT))
    -- nnoremap <silent> <leader>dn :lua require('dap-python').test_method()<CR>
    -- nnoremap <silent> <leader>df :lua require('dap-python').test_class()<CR>
    -- vnoremap <silent> <leader>ds <ESC>:lua require('dap-python').debug_selection()<CR>
end

function M.setup_dap_virtual()
    cmd.packadd("nvim-dap-virtual-text")
    local dap_virtual = F.npcall(require, "nvim-dap-virtual-text")
    if not dap_virtual then
        return
    end

    dap_virtual.setup({
        enabled = true, -- enable this plugin (the default)
        -- DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle,DapVirtualTextForceRefresh
        enabled_commands = true,
        highlight_changed_variables = true,
        -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
        highlight_new_as_changed = false,
        -- show stop reason when stopped for exceptions
        show_stop_reason = true,
        -- prefix virtual text with comment string
        commented = false,
        -- only show virtual text at first definition (if there are multiple)
        only_first_definition = true,
        -- show virtual text on all all references of the variable (not only definitions)
        all_references = false,
        -- filter references (not definitions) pattern when all_references is activated
        filter_references_pattern = "<module",
        -- experimental features:
        virt_text_pos = "eol",   -- position of virtual text, see `:h nvim_buf_set_extmark()`
        all_frames = false,      -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
        virt_lines = false,      -- show virtual lines instead of virtual text (will flicker!)
        virt_text_win_col = nil, -- position the virtual text at a fixed window column (starting from the first text column) ,
        -- e.g. 80 to position at column 80, see `:h nvim_buf_set_extmark()`
    })
end

function M.setup_dapui()
    dapui.setup({
        icons = {expanded = "▾", collapsed = "▸", current_frame = "▸"},
        mappings = {
            expand = {"<CR>", "<2-LeftMouse>"},
            open = "o",
            remove = "d",
            edit = "e",
            repl = "r",
            toggle = "t",
            -- close = {"q", "<Esc>"},
        },
        layouts = {
            {
                elements = {
                    {id = "scopes", size = 0.5},
                    {id = "breakpoints", size = 0.25},
                    {id = "stacks", size = 0.25},
                    -- { id = "watches", size = 00.25 },
                },
                size = 40,
                position = "left",
            },
            {
                elements = {
                    {id = "repl", size = 0.5},
                    {id = "console", size = 0.5},
                },
                size = 0.25,
                position = "bottom",
            },
        },
        scopes = {
            edit = "l",
        },
        render = {
            indent = 1,
            max_value_lines = 100,
        },
        windows = {indent = 1},
        floating = {
            max_height = 0.5,
            max_width = 0.9,
            border = Rc.style.border,
            mappings = {close = {"q", "<Esc>", "<c-o>"}},
        },
        controls = {
            element = "repl",
            enabled = true,
            icons = {
                disconnect = "",
                pause = "",
                play = "",
                run_last = "",
                step_back = "",
                step_into = "",
                step_out = "",
                step_over = "",
                terminate = "",
            },
        },
        expand_lines = true,
        force_buffers = true,
    })

    -- dap.listeners.after.event_initialized["dapui_config"] = function()
    --     log.info("Debugger connected", {title = "dap"})
    --     dapui.open()
    -- end
    -- dap.listeners.before.event_terminated["dapui_config"] = dapui.close
    -- dap.listeners.before.event_exited["dapui_config"] = dapui.close
end

local function dap_server(opts)
    assert(
        dap.adapters.nlua,
        "nvim-dap adapter configuration for nlua not found. " ..
        "Please refer to the README.md or :help osv.txt"
    )

    -- server already started?
    if nvim_chanID then
        local pid = fn.jobpid(nvim_chanID)
        fn.rpcnotify(nvim_chanID, "nvim_exec_lua", [[return require"osv".stop()]])
        fn.jobstop(nvim_chanID)
        if type(uv.os_getpriority(pid)) == "number" then
            uv.kill(pid, 9)
        end
        nvim_chanID = nil
    end

    nvim_chanID = fn.jobstart({vim.v.progpath, "--embed", "--headless"}, {rpc = true})
    assert(nvim_chanID, "Could not create neovim instance with jobstart!")

    local mode = fn.rpcrequest(nvim_chanID, "nvim_get_mode")
    assert(mode and not mode.blocking, "Neovim is waiting for input at startup. Aborting.")

    -- make sure OSV is loaded
    fn.rpcrequest(nvim_chanID, "nvim_command", "packadd one-small-step-for-vimkind")

    nvim_server = fn.rpcrequest(
        nvim_chanID,
        "nvim_exec_lua",
        [[return require"osv".launch(...)]],
        {opts}
    )

    vim.wait(100)

    -- print(("Server started on port %d, channel-id %d"):format(nvim_server.port, nvim_chanID))
    return nvim_server
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                      Notifications                       │
-- ╰──────────────────────────────────────────────────────────╯

local client_notifs = {}
local spinner_frames = {"⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷"}

local function get_notif_data(client_id, token)
    if not client_notifs[client_id] then
        client_notifs[client_id] = {}
    end

    if not client_notifs[client_id][token] then
        client_notifs[client_id][token] = {}
    end

    return client_notifs[client_id][token]
end

local function update_spinner(client_id, token)
    local notif_data = get_notif_data(client_id, token)

    if notif_data.spinner then
        local new_spinner = (notif_data.spinner + 1) % #spinner_frames
        notif_data.spinner = new_spinner

        notif_data.notification = vim.notify(nil, nil, {
            hide_from_history = true,
            icon = spinner_frames[new_spinner],
            replace = notif_data.notification,
        })

        vim.defer_fn(function()
            update_spinner(client_id, token)
        end, 100)
    end
end

local function format_title(title, client_name)
    return ("%s %s"):format(client_name, #title > 0 and ": " .. title or "")
end

local function format_message(message, percentage)
    return ("%s %s"):format(percentage and percentage .. "%\t" or "", F.if_nil(message, ""))
end

function M.setup_notify()
    -- DAP integration
    -- Make sure to also have the snippet with the common helper functions in your config!

    dap.listeners.before["event_progressStart"]["progress-notifications"] = function(session, body)
        local notif_data = get_notif_data("dap", body.progressId)

        local message = format_message(body.message, body.percentage)
        notif_data.notification =
            vim.notify(
                message,
                "info",
                {
                    title = format_title(body.title, session.config.type),
                    icon = spinner_frames[1],
                    timeout = false,
                    hide_from_history = false,
                }
            )

        notif_data.notification.spinner = 1
        update_spinner("dap", body.progressId)
    end

    ---@diagnostic disable-next-line:unused-local
    dap.listeners.before["event_progressUpdate"]["progress-notifications"] = function(session, body)
        local notif_data = get_notif_data("dap", body.progressId)
        notif_data.notification =
            vim.notify(
                format_message(body.message, body.percentage),
                "info",
                {
                    replace = notif_data.notification,
                    hide_from_history = false,
                }
            )
    end

    ---@diagnostic disable-next-line:unused-local
    dap.listeners.before["event_progressEnd"]["progress-notifications"] = function(session, body)
        local notif_data = client_notifs["dap"][body.progressId]
        notif_data.notification =
            vim.notify(
                body.message and format_message(body.message) or "Complete",
                "info",
                {
                    icon = "",
                    replace = notif_data.notification,
                    timeout = 3000,
                }
            )
        notif_data.spinner = nil
    end
end

local function init()
    M.setup()
    M.setup_dapui()
    M.setup_dap_virtual()
    M.setup_dap_python()
    require("dap.ext.vscode").load_launchjs(nil, {node = {"typescript", "javascript"}})

    local dap_signs = {
        {{"Stopped", "Stop"}, icon = I.stopped},
        {{"Breakpoint", "BreakpointsLine"}, icon = I.breakpoint},
        {{"BreakpointRejected", "Error"}, icon = I.rejected},
        {{"BreakpointCondition", "BreakpointsInfo"}, icon = I.condition},
        {{"LogPoint", "BreakpointsPath"}, icon = I.log_point},
    }

    fn.sign_define(
        vim.tbl_map(
            function(t)
                local name, hl = unpack(t[1])
                name = ("Dap%s"):format(name)
                return {
                    name = name,
                    text = t.icon,
                    texthl = ("DapUI%s"):format(hl),
                    numhl = hl == "Stop" and "Error" or nil,
                    linehl = hl == "Stop" and "DiagnosticUnderlineError" or nil,
                }
            end,
            dap_signs
        )
    )

    dap.set_log_level("TRACE") --TRACE DEBUG INFO WARN ERROR

    -- Debugpy
    dap.adapters.python = {
        type = "executable",
        command = "python",
        args = {"-m", "debugpy.adapter"},
    }
    dap.configurations.python = {
        {
            name = "Launch file",
            type = "python",
            request = "launch",
            program = "${file}",
            justMyCode = false,
            pythonPath = ("%s/shims/python"):format(env.PYENV_ROOT),
            console = "integratedTerminal",
        },
        {
            name = "Launch Module",
            type = "python",
            request = "launch",
            justMyCode = false,
            module = function()
                return fn.expand("%:.:r"):gsub("/", ".")
            end,
            pythonPath = ("%s/shims/python"):format(env.PYENV_ROOT),
            console = "integratedTerminal",
        },
        {
            type = "python",
            request = "attach",
            name = "Attach remote",
            justMyCode = false,
            pythonPath = ("%s/shims/python"):format(env.PYENV_ROOT),
            host = function()
                local value = fn.input("Host [127.0.0.1]: ")
                if value ~= "" then
                    return value
                end
                return "127.0.0.1"
            end,
            port = function()
                return tonumber(fn.input("Port [5678]: ")) or 5678
            end,
        },
    }

    local firefox_exec = "/usr/bin/firefox"
    dap.adapters.firefox = {
        type = "executable",
        command = "node",
        args = {
            ("%s/%s"):format(
                Rc.dirs.home,
                "/.vscode/extensions/firefox-devtools.vscode-firefox-debug-2.9.6/dist/adapter.bundle.js"
            ),
        },
    }

    dap.configurations.typescript = {
        -- {
        --     name = "node attach",
        --     type = "node2",
        --     request = "attach",
        --     program = "${file}",
        --     cwd = fn.expand("%:p:h"),
        --     sourceMaps = true,
        --     protocol = "inspector",
        -- },
        {
            name = "Launch",
            type = "node2",
            request = "launch",
            program = "${file}",
            args = {"--stdio"},
            cwd = uv.cwd(),
            -- cwd = it(uv.cwd),
            env = {ELECTRON_RUN_AS_NODE = "true"},
            sourceMaps = true,
            protocol = "inspector",
            console = "integratedTerminal",
        },
        {
            -- For this to work you need to make sure the node process is started with the `--inspect` flag.
            name = "Attach to process",
            type = "node2",
            request = "attach",
            processId = require("dap.utils").pick_process,
        },
        {
            name = "chrome",
            type = "chrome",
            request = "attach",
            program = "${file}",
            -- cwd = "${workspaceFolder}",
            -- protocol = "inspector",
            port = 9222,
            webRoot = "${workspaceFolder}",
            -- sourceMaps = true,
            sourceMapPathOverrides = {
                -- Sourcemap override for nextjs
                ["webpack://_N_E/./*"] = "${webRoot}/*",
                ["webpack:///./*"] = "${webRoot}/*",
            },
        },
        {
            name = "Debug with Firefox",
            type = "firefox",
            request = "launch",
            reAttach = true,
            sourceMaps = true,
            url = "http://localhost:6969",
            webRoot = "${workspaceFolder}",
            firefoxExecutable = firefox_exec,
        },
    }

    dap.configurations.typescriptreact = dap.configurations.typescript
    dap.configurations.javascript = dap.configurations.typescript
    dap.configurations.javascriptreact = dap.configurations.typescript

    dap.adapters.nlua = function(callback, config)
        if not config.port then
            local server = dap_server()
            config.host = server.host
            config.port = server.port
        end
        callback({type = "server", host = config.host, port = config.port or 37837})
        if type(config.post) == "function" then
            config.post()
        end
    end

    dap.configurations.lua = {
        {
            name = "Debug current file",
            type = "nlua",
            request = "attach",
            -- we acquire host/port in the adapters function above
            -- host = function() end,
            -- port = function() end,
            post = function()
                ---@diagnostic disable-next-line:unused-local
                dap.listeners.after["setBreakpoints"]["osv"] = function(session, body)
                    assert(nvim_chanID, "Fatal: neovim RPC channel is nil!")
                    fn.rpcnotify(nvim_chanID, "nvim_command", "luafile " .. fn.expand("%:p"))
                    -- clear the lisener or we get called in any dap-config run
                    dap.listeners.after["setBreakpoints"]["osv"] = nil
                end
                -- for k, v in pairs(dap.listeners.after) do
                --   v["test"] = function()
                --     print(k, "called")
                --   end
                -- end
            end,
        },
        {
            name = "Attach to running Neovim instance",
            type = "nlua",
            request = "attach",
            host = function()
                local value = fn.input("Host [127.0.0.1]: ")
                if value ~= "" then
                    return value
                end
                return "127.0.0.1"
            end,
            port = function()
                return tonumber(fn.input("Port [37837]: ")) or 37837
            end,
        },
    }

    -- lldb
    dap.adapters.lldb = {
        name = "lldb",
        type = "executable",
        command = "/usr/bin/lldb-vscode",
    }

    dap.adapters.cppdbg = {
        id = "cppdbg",
        type = "executable",
        command =
        "/home/lucas/projects/clang/tools/cpptools/extension/debugAdapters/bin/OpenDebugAD7",

        -- type = "server",
        -- host = "127.0.0.1",
        -- port = "4711",
        -- executable = {
        --     command = "/home/lucas/projects/clang/tools/cpptools/extension/debugAdapters/bin/OpenDebugAD7",
        --     args = {"--server", "${port}"},
        -- },
    }

    dap.adapters.codelldb = {
        name = "codelldb",
        id = "codelldb",
        type = "server",
        host = "127.0.0.1",
        port = "${port}",
        executable = {
            -- command = "/usr/bin/lldb-vscode",
            command = "/usr/lib/codelldb/adapter/codelldb",
            args = {"--port", "${port}"},
        },
    }

    local action_state = require("telescope.actions.state")
    local actions = require("telescope.actions")
    local conf = require("telescope.config").values
    local finders = require("telescope.finders")
    local pickers = require("telescope.pickers")

    -- https://github.com/mfussenegger/nvim-dap/wiki/C-C---Rust-(gdb-via--vscode-cpptools)
    -- https://old.reddit.com/r/neovim/comments/12xfolf/nvimdap_connecting_to_a_gdbserver/
    dap.configurations.cpp = {
        {
            name = "Launch lldb",
            type = "lldb",
            request = "launch",
            program = function()
                return fn.input("Path to executable: ", uv.cwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
            args = {},
            -- runInTerminal = false,
        },
        -- {
        --     -- If you get an "Operation not permitted" error using this, try disabling YAMA:
        --     --  echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
        --     name = "Attach to process",
        --     type = "cpp", -- Adjust this to match your adapter name (`dap.adapters.<name>`)
        --     request = "attach",
        --     pid = require("dap.utils").pick_process,
        --     args = {},
        -- },
        {
            name = "Launch cpptools + telescope",
            type = "cppdbg",
            request = "launch",
            cwd = "${workspaceFolder}",
            stopAtEntry = true,
            program = function()
                return coroutine.create(function(coro)
                    local opts = {}
                    pickers
                        .new(opts, {
                            prompt_title = "Path to executable",
                            finder = finders.new_oneshot_job(
                                {"fd", "--absolute-path", "--hidden", "--no-ignore", "--type", "x"},
                                {}),
                            sorter = conf.generic_sorter(opts),
                            attach_mappings = function(buffer_number)
                                actions.select_default:replace(function()
                                    actions.close(buffer_number)
                                    coroutine.resume(coro, action_state.get_selected_entry()[1])
                                end)
                                return true
                            end,
                        })
                        :find()
                end)
            end,
        },
        {
            name = "Attach to gdbserver :1234",
            type = "cppdbg",
            request = "launch",
            MIMode = "gdb",
            -- miDebuggerServerAddress = "localhost:1234",
            miDebuggerPath = "/usr/bin/gdb",
            cwd = "${workspaceFolder}",
            program = function()
                return fn.input("Path to executable: ", uv.cwd() .. "/", "file")
            end,
            setupCommands = {
                {
                    text = "-enable-pretty-printing",
                    description = "enable pretty printing",
                    ignoreFailures = false,
                },
            },
        },
        {
            name = "Launch codelldb",
            type = "codelldb",
            request = "launch",
            program = function()
                return fn.input("Path to executable: ", uv.cwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
        },
    }


    dap.configurations.c = dap.configurations.cpp
    dap.configurations.rust = dap.configurations.cpp

    dap.adapters.go = function(callback, config)
        local stdout = uv.new_pipe(false)
        local handle
        local pid_or_err
        local host = config.host or "127.0.0.1"
        local port = config.port or "38697"
        local addr = string.format("%s:%s", host, port)
        local opts = {
            stdio = {nil, stdout},
            args = {"dap", "-l", addr},
            detached = true,
        }
        handle, pid_or_err = uv.spawn("dlv", opts, function(code)
            stdout:close()
            handle:close()
            if code ~= 0 then
                print("dlv exited with code", code)
            end
        end)
        assert(handle, "Error running dlv: " .. tostring(pid_or_err))
        stdout:read_start(function(err, chunk)
            assert(not err, err)
            if chunk then
                vim.schedule(function()
                    require("dap.repl").append(chunk)
                end)
            end
        end)
        -- Wait for delve to start
        vim.defer_fn(function()
            callback({type = "server", host = "127.0.0.1", port = port})
        end, 100)
    end

    dap.configurations.go = {
        {
            type = "go",
            name = "Debug",
            request = "launch",
            program = "${file}",
        },
        {
            type = "go",
            name = "Debug Package",
            request = "launch",
            program = "${fileDirname}",
        },
        {
            type = "go",
            name = "Attach",
            mode = "local",
            request = "attach",
            processId = require("dap.utils").pick_process,
        },
        {
            type = "go",
            name = "Debug test",
            request = "launch",
            mode = "test",
            program = "${file}",
        },
        {
            type = "go",
            name = "Debug test (go.mod)",
            request = "launch",
            mode = "test",
            program = "./${relativeFileDirname}",
        },
    }

    dap.adapters.ruby = {
        type = "executable",
        command = "bundle",
        args = {"exec", "readapt", "stdio"},
    }

    dap.configurations.ruby = {
        {
            type = "ruby",
            request = "launch",
            name = "Rails",
            program = "bundle",
            programArgs = {"exec", "rails", "s"},
            useBundler = true,
        },
    }
end

init()

-- local function start_session()
--     -- set session tab
--     dap.session().session_target_tab = fn.tabpagenr()
--
--     setup_maps()
--     dapui.open()
--
--     -- force local statusline
--     require("lib/misc").toggle_global_statusline(true)
--
--     require("notify")(
--         string.format("[prog] %s", dap.session().config.program),
--         "debug",
--         {title = "[dap] session started", timeout = 500}
--     )
-- end
--
-- -- terminate session: remove keymaps, close dapui, close dap repl,
-- -- close internal_servers, set last output buffer active
-- local function terminate_session()
--     remove_maps()
--     dapui.close()
--     dap.repl.close()
--
--     close_internal_servers() -- close servers launched within neovim
--     get_output_windows(true) -- set last output window active
--
--     require("notify")(
--         string.format("[prog] %s", dap.session().config.program),
--         "debug",
--         {title = "[dap] session terminated", timeout = 500}
--     )
-- end
--
-- -- dap events
-- dap.listeners.after.event_initialized["dapui"] = start_session
-- dap.listeners.before.event_terminated["dapui"] = terminate_session

return M
