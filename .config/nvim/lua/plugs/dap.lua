local M = {}

local utils = require("common.utils")
local map = utils.map
local command = utils.command
local dap = require("dap")
local dapui = require("dapui")
local widgets = require("dap.ui.widgets")

local telescope = require("telescope")
local wk = require("which-key")

local fn = vim.fn

local nvim_server
local nvim_chanID

function M.setup()
    -- https://alpha2phi.medium.com/neovim-dap-enhanced-ebc730ff498b
    command(
        "BreakpointToggle",
        function()
            require("dap").toggle_breakpoint()
        end
    )
    command(
        "Debug",
        function()
            require("dap").continue()
        end
    )
    command(
        "DapREPL",
        function()
            require("dap").repl.open()
        end
    )
    command(
        "DapLaunch",
        function()
            require("osv").launch()
        end
    )
    command(
        "DapRun",
        function()
            require("osv").run_this()
        end
    )

    local function repl_toggle()
        require("dap").repl.toggle(nil, "botright split")
    end
    local function repl_open()
        require("dap").repl.open()
    end
    -- Start the debug session and continue to next breakpoint
    local function continue()
        require("dap").continue()
    end
    local function step_out()
        require("dap").step_out()
    end
    local function step_into()
        require("dap").step_into()
    end
    local function step_over()
        require("dap").step_over()
    end
    ---Run last again
    local function run_last()
        require("dap").run_last()
    end
    ---Run to cursor position
    local function run_cursor()
        require("dap").run_to_cursor()
    end
    ---Create and remove a breakpoint
    local function toggle_breakpoint()
        require("dap").toggle_breakpoint()
    end
    local function set_breakpoint()
        require("dap").set_breakpoint(fn.input("Breakpoint condition: "))
    end
    ---Close the debug session
    local function close()
        require("dap").close()
    end
    ---Terminate the debug session
    local function terminate()
        require("dap").terminate()
    end
    ---Restart the execution
    local function restart()
        require("dap").restart()
    end
    ---Pause the execution
    local function pause()
        require("dap").pause()
    end
    ---Go up in the call stack
    local function up()
        require("dap").up()
    end
    ---Go down in the call stack
    local function down()
        require("dap").down()
    end

    local function hover()
        widgets.hover()
    end
    -- Inspect all scope properties
    local function inspect_scope()
        widgets.centered_float(widgets.scopes).open()
    end

    local function ui_open()
        require("dapui").toggle()
    end
    local function ui_eval()
        require("dapui").eval()
    end
    local function ui_eval_input()
        require("dapui").eval(fn.input "[Expression] > ")
    end

    local function osv_launch()
        require("osv").launch()
    end

    wk.register(
        {
            d = {
                name = "+debugger",
                -- B = {set_breakpoint, "dap: set breakpoint"},
                E = {ui_eval_input, "dapui: eval input"},
                R = {restart, "dap: restart"},
                T = {repl_open, "dap REPL: open"},
                U = {ui_open, "dap UI: open"},
                X = {terminate, "dap: terminate"},
                b = {toggle_breakpoint, "dap: toggle breakpoint"},
                c = {continue, "dap: continue or start debugging"},
                d = {osv_launch, "dap: start osv"},
                e = {step_out, "dap: step out"},
                h = {hover, "dap widgets: hover"},
                i = {step_into, "dap: step into"},
                l = {run_last, "dap REPL: run last"},
                m = {down, "dap: down"},
                n = {up, "dap: up"},
                o = {step_over, "dap: step over"},
                p = {pause, "dap: pause"},
                r = {run_cursor, "dap: run to cursor"},
                s = {inspect_scope, "dap widgets: inspect scope"},
                t = {repl_toggle, "dap REPL: toggle"},
                v = {ui_eval, "dap UI: eval"},
                x = {close, "dap: close"},
                [","] = {
                    name = "+telescope",
                    c = {telescope.extensions.dap.commands, "dap: commands"},
                    o = {telescope.extensions.dap.configurations, "dap: configurations"},
                    b = {telescope.extensions.dap.list_breakpoints, "dap: list breakpoints"},
                    v = {telescope.extensions.dap.variablesk, "dap: variables"},
                    f = {telescope.extensions.dap.frames, "dap: frames"}
                }
            }
        },
        {
            prefix = "<LocalLeader>"
        }
    )
end

function M.setup_dap_virtual()
    require("nvim-dap-virtual-text").setup {
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
        virt_text_pos = "eol", -- position of virtual text, see `:h nvim_buf_set_extmark()`
        all_frames = false, -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
        virt_lines = false, -- show virtual lines instead of virtual text (will flicker!)
        virt_text_win_col = nil -- position the virtual text at a fixed window column (starting from the first text column) ,
        -- e.g. 80 to position at column 80, see `:h nvim_buf_set_extmark()`
    }
end

function M.setup_dapui()
    dapui.setup(
        {
            icons = {expanded = "-", collapsed = "$"},
            mappings = {
                expand = "<CR>",
                open = "o",
                remove = "d",
                edit = "e",
                repl = "r",
                toggle = "t"
            },
            sidebar = {
                elements = {
                    {id = "scopes", size = 0.5},
                    {id = "breakpoints", size = 0.25},
                    {id = "stacks", size = 0.25}
                },
                size = 40,
                position = "right"
            },
            tray = {elements = {"repl", "watches"}, size = 10, position = "bottom"},
            floating = {border = "rounded", mappings = {close = {"q", "<esc>", "<c-o>"}}}
        }
    )

    dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
    end
end

local function dap_server(opts)
    assert(
        dap.adapters.nlua,
        "nvim-dap adapter configuration for nlua not found. " .. "Please refer to the README.md or :help osv.txt"
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
    assert(not mode.blocking, "Neovim is waiting for input at startup. Aborting.")

    -- make sure OSV is loaded
    fn.rpcrequest(nvim_chanID, "nvim_command", "packadd one-small-step-for-vimkind")

    nvim_server = fn.rpcrequest(nvim_chanID, "nvim_exec_lua", [[return require"osv".launch(...)]], {opts})

    vim.wait(100)

    -- print(("Server started on port %d, channel-id %d"):format(nvim_server.port, nvim_chanID))
    return nvim_server
end

local function init()
    M.setup()
    M.setup_dapui()
    M.setup_dap_virtual()

    fn.sign_define("DapStopped", {text = "=>", texthl = "DiagnosticWarn"})
    fn.sign_define("DapBreakpoint", {text = "<>", texthl = "DiagnosticInfo"})
    fn.sign_define("DapBreakpointRejected", {text = "!>", texthl = "DiagnosticError"})
    fn.sign_define("DapBreakpointCondition", {text = "?>", texthl = "DiagnosticInfo"})
    fn.sign_define("DapLogPoint", {text = ".>", texthl = "DiagnosticInfo"})

    -- Debugpy
    dap.adapters.python = {
        type = "executable",
        command = "python",
        args = {"-m", "debugpy.adapter"}
    }

    dap.configurations.python = {
        {
            type = "python",
            request = "launch",
            name = "Launch file",
            program = "${file}",
            pythonPath = function()
                return ("%s/shims/python"):format(env.PYENV_ROOT)
            end
        }
    }

    -- Neovim Lua
    -- dap.adapters.nlua = function(callback, config)
    --     callback {type = "server", host = config.host, port = config.port}
    -- end

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
            type = "nlua",
            name = "Debug current file",
            request = "attach",
            -- we acquire host/port in the adapters function above
            -- host = function() end,
            -- port = function() end,
            post = function()
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
            end
        },
        {
            type = "nlua",
            request = "attach",
            name = "Attach to running Neovim instance",
            host = function()
                local value = fn.input("Host [127.0.0.1]: ")
                if value ~= "" then
                    return value
                end
                return "127.0.0.1"
            end,
            port = function()
                local val = tonumber(fn.input("Port: ") or 37837)
                assert(val, "Please provide a port number")
                return val
            end
        }
    }

    -- lldb
    dap.adapters.lldb = {
        type = "executable",
        command = "/usr/bin/lldb-vscode",
        name = "lldb"
    }

    dap.configurations.cpp = {
        {
            name = "Launch",
            type = "lldb",
            request = "launch",
            program = function()
                return fn.input("Path to executable: ", fn.getcwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
            args = {},
            runInTerminal = false
        }
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
            detached = true
        }
        handle, pid_or_err =
            uv.spawn(
            "dlv",
            opts,
            function(code)
                stdout:close()
                handle:close()
                if code ~= 0 then
                    print("dlv exited with code", code)
                end
            end
        )
        assert(handle, "Error running dlv: " .. tostring(pid_or_err))
        stdout:read_start(
            function(err, chunk)
                assert(not err, err)
                if chunk then
                    vim.schedule(
                        function()
                            require("dap.repl").append(chunk)
                        end
                    )
                end
            end
        )
        -- Wait for delve to start
        vim.defer_fn(
            function()
                callback({type = "server", host = "127.0.0.1", port = port})
            end,
            100
        )
    end

    dap.configurations.go = {
        {
            type = "go",
            name = "Debug",
            request = "launch",
            program = "${file}"
        },
        {
            type = "go",
            name = "Debug Package",
            request = "launch",
            program = "${fileDirname}"
        },
        {
            type = "go",
            name = "Attach",
            mode = "local",
            request = "attach",
            processId = require("dap.utils").pick_process
        },
        {
            type = "go",
            name = "Debug test",
            request = "launch",
            mode = "test",
            program = "${file}"
        },
        {
            type = "go",
            name = "Debug test (go.mod)",
            request = "launch",
            mode = "test",
            program = "./${relativeFileDirname}"
        }
    }

    dap.adapters.ruby = {
        type = 'executable',
        command = 'bundle',
        args = {'exec', 'readapt', 'stdio'}
    }

    dap.configurations.ruby = {{
        type = 'ruby',
        request = 'launch',
        name = 'Rails',
        program = 'bundle',
        programArgs = {'exec', 'rails', 's'},
        useBundler = true
    }}
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
