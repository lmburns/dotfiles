local M = {}

local D = require("dev")
local dap = D.npcall(require, "dap")
if not dap then
    return
end

local dapui = D.npcall(require, "dapui")
if not dapui then
    return
end

local osv = D.npcall(require, "osv")
if not osv then
    return
end

local widgets = require("dap.ui.widgets")
local telescope = require("telescope")
local wk = require("which-key")

local icons = require("style").plugins.dap
local mpi = require("common.api")
local command = mpi.command

local fn = vim.fn
local uv = vim.loop
local F = vim.F
local env = vim.env
local ithunk = D.ithunk

local nvim_server
local nvim_chanID

function M.setup()
    -- https://alpha2phi.medium.com/neovim-dap-enhanced-ebc730ff498b
    command("BreakpointToggle", ithunk(dap.toggle_breakpoint), {desc = "[dap]: Toggle breakpoint"})
    command("Debug", ithunk(dap.continue), {desc = "[dap]: Continue"})
    command("DapREPL", ithunk(dap.repl.open), {desc = "[dap]: Open REPL"})
    command("DapLaunch", ithunk(osv.launch), {desc = "[osv]: Launch"})
    command("DapRun", ithunk(osv.run_this), {desc = "[osv]: Run this"})

    -- Inspect all scope properties
    local function inspect_scope()
        widgets.centered_float(widgets.scopes).open()
    end
    local function dap_eval()
        dapui.eval(fn.input("[Expression] > "))
    end

    wk.register(
        {
            d = {
                name = "+debugger",
                -- B = {ithunk(dap.set_breakpoint, fn.input("Breakpoint condition: ")), "dap: set breakpoint"},
                E = {dap_eval, "dapui: eval input"},
                R = {ithunk(dap.restart), "dap: restart execution"},
                T = {ithunk(dap.repl.open), "dap REPL: open"},
                U = {ithunk(dapui.toggle), "dap UI: open"},
                X = {ithunk(dap.terminate), "dap: terminate session"},
                b = {ithunk(dap.toggle_breakpoint), "dap: toggle breakpoint"},
                c = {ithunk(dap.continue), "dap: continue or start debugging"},
                d = {ithunk(osv.launch), "dap: start osv"},
                e = {ithunk(dap.step_out), "dap: step out"},
                h = {ithunk(widgets.hover), "dap widgets: hover"},
                i = {ithunk(dap.step_into), "dap: step into"},
                l = {ithunk(dap.run_last), "dap REPL: run last"},
                m = {ithunk(dap.down), "dap: down in callstack"},
                n = {ithunk(dap.up), "dap: up in callstack"},
                o = {ithunk(dap.step_over), "dap: step over"},
                p = {ithunk(dap.pause), "dap: pause execution"},
                r = {ithunk(dap.run_to_cursor), "dap: run to cursor"},
                s = {inspect_scope, "dap widgets: inspect scope"},
                t = {ithunk(dap.repl.toggle, nil, "botright split"), "dap REPL: toggle"},
                v = {ithunk(dapui.eval), "dap UI: eval"},
                x = {ithunk(dap.close), "dap: close session"}
            }
        },
        {prefix = "<LocalLeader>"}
    )

    wk.register(
        {
            d = {
                name = "+telescope",
                c = {telescope.extensions.dap.commands, "dap: commands"},
                o = {telescope.extensions.dap.configurations, "dap: configurations"},
                b = {telescope.extensions.dap.list_breakpoints, "dap: list breakpoints"},
                v = {telescope.extensions.dap.variablesk, "dap: variables"},
                f = {telescope.extensions.dap.frames, "dap: frames"}
            }
        },
        {prefix = ";"}
    )
end

function M.setup_dap_python()
    local dap_python = D.npcall(require, "dap-python")
    if not dap_python then
        return
    end

    dap_python.setup(("%s/shims/python"):format(env.PYENV_ROOT))
end

function M.setup_dap_virtual()
    local dap_virtual = D.npcall(require, "nvim-dap-virtual-text")
    if not dap_virtual then
        return
    end

    dap_virtual.setup {
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
            icons = {expanded = "▾", collapsed = "▸"},
            mappings = {
                expand = {"<CR>", "<2-LeftMouse>"},
                open = "o",
                remove = "d",
                edit = "e",
                repl = "r",
                toggle = "t"
            },
            layouts = {
                {
                    elements = {
                        {id = "scopes", size = 0.5},
                        {id = "breakpoints", size = 0.25},
                        {id = "stacks", size = 0.25}
                        -- { id = "watches", size = 00.25 },
                    },
                    size = 40,
                    position = "left"
                },
                {
                    elements = {"repl", "console"},
                    size = 10,
                    position = "bottom"
                }
            },
            floating = {
                max_height = nil,
                max_width = nil,
                border = "rounded",
                mappings = {close = {"q", "<Esc>", "<c-o>"}}
            }
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

        notif_data.notification =
            vim.notify(
            nil,
            nil,
            {
                hide_from_history = true,
                icon = spinner_frames[new_spinner],
                replace = notif_data.notification
            }
        )

        vim.defer_fn(
            function()
                update_spinner(client_id, token)
            end,
            100
        )
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
                hide_from_history = false
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
                hide_from_history = false
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
                timeout = 3000
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

    fn.sign_define(
        "DapStopped",
        {text = icons.stopped, texthl = "DiagnosticWarn", numhl = "String", linehl = "DiagnosticUnderlineError"}
    )
    fn.sign_define("DapBreakpoint", {text = icons.breakpoint, texthl = "DiagnosticInfo"})
    fn.sign_define("DapBreakpointRejected", {text = icons.rejected, texthl = "DiagnosticError"})
    fn.sign_define("DapBreakpointCondition", {text = icons.condition, texthl = "DiagnosticInfo"})
    fn.sign_define("DapLogPoint", {text = icons.log_point, texthl = "DiagnosticInfo"})

    dap.set_log_level("TRACE") --TRACE DEBUG INFO WARN ERROR

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

    local firefox_exec = "/usr/bin/firefox"
    dap.adapters.firefox = {
        type = "executable",
        command = "node",
        args = {
            ("%s/%s"):format(
                lb.dirs.home,
                "/.vscode/extensions/firefox-devtools.vscode-firefox-debug-2.9.6/dist/adapter.bundle.js"
            )
        }
    }

    dap.configurations.typescript = {
        {
            type = "node2",
            name = "node attach",
            request = "attach",
            program = "${file}",
            cwd = fn.expand("%:p:h"),
            sourceMaps = true,
            protocol = "inspector"
        },
        {
            type = "chrome",
            name = "chrome",
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
                ["webpack:///./*"] = "${webRoot}/*"
            }
        },
        {
            name = "Debug with Firefox",
            type = "firefox",
            request = "launch",
            reAttach = true,
            sourceMaps = true,
            url = "http://localhost:6969",
            webRoot = "${workspaceFolder}",
            firefoxExecutable = firefox_exec
        }
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
            type = "nlua",
            name = "Debug current file",
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
        type = "executable",
        command = "bundle",
        args = {"exec", "readapt", "stdio"}
    }

    dap.configurations.ruby = {
        {
            type = "ruby",
            request = "launch",
            name = "Rails",
            program = "bundle",
            programArgs = {"exec", "rails", "s"},
            useBundler = true
        }
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
