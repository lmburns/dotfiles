local M = {}

local map = require("common.utils").map
local dap = require("dap")
local dapui = require("dapui")

local nvim_server
local nvim_chanID

function M.setup()
    -- https://alpha2phi.medium.com/neovim-dap-enhanced-ebc730ff498b
    cmd [[com! BreakpointToggle lua require('dap').toggle_breakpoint()]]
    cmd [[com! Debug lua require('dap').continue()]]
    cmd [[com! DapREPL lua require('dap').repl.open()]]
    cmd [[com! DapLaunch lua require('osv').launch()]]
    cmd [[com! DapRun lua require('osv').run_this()]]

    map("n", "<Leader>dct", [[<cmd>lua require'dap'.continue()<CR>]])
    map("n", "<Leader>dsv", [[<cmd>lua require'dap'.step_over()<CR>]])
    map("n", "<Leader>dsi", [[<cmd>lua require'dap'.step_into()<CR>]])
    map("n", "<Leader>dso", [[<cmd>lua require'dap'.step_out()<CR>]])

    map("n", "<Leader>dt", [[<cmd>lua require('dap').toggle_breakpoint()<CR>]])
    map("n", "<Leader>dro", [[<cmd>lua require('dap').repl.open()<CR>]])
    map("n", "<Leader>drl", [[<cmd>lua require("dap").run_last()<CR>]])

    map("n", "<Leader>dui", [[<cmd>lua require('dapui').toggle()<CR>]])
    map("n", "<Leader>due", [[<cmd>lua require('dapui').eval()<CR>]])

    map("n", "<Leader>dsc", [[<cmd>lua require('dap.ui.variables').scopes()<CR>]])
    map("n", "<Leader>dhh", [[<cmd>lua require('dap.ui.variables').hover()<CR>]])
    map("v", "<Leader>dhv", [[<cmd>lua require('dap.ui.variables').visual_hover()<CR>]])

    map("n", "<Leader>duh", [[<cmd>lua require'dap.ui.widgets'.hover()<CR>]])
    map(
        "n",
        "<Leader>duf",
        [[<cmd>lua local widgets=require'dap.ui.widgets';widgets.centered_float(widgets.scopes)<CR>]]
    )
    map("n", "<Leader>dsbr", [[<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>]])
    map(
        "n",
        "<Leader>dsbm",
        [[<cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>]]
    )

    -- telescope-dap
    map("n", "<Leader>dcc", [[<cmd>lua require'telescope'.extensions.dap.commands{}<CR>]])
    map("n", "<Leader>dco", [[<cmd>lua require'etelescope'.extensions.dap.configurations{}<CR>]])
    map("n", "<Leader>dlb", [[<cmd>lua require'telescope'.extensions.dap.list_breakpoints{}<CR>]])
    map("n", "<Leader>dv", [[<cmd>lua require'telescope'.extensions.dap.variables{}<CR>]])
    -- map("n", "<Leader>df", [[<cmd>lua require'telescope'.extensions.dap.frames{}<CR>]])
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
end

local function dap_server(opts)
    assert(
        dap.adapters.nlua,
        "nvim-dap adapter configuration for nlua not found. " .. "Please refer to the README.md or :help osv.txt"
    )

    -- server already started?
    if nvim_chanID then
        local pid = vim.fn.jobpid(nvim_chanID)
        vim.fn.rpcnotify(nvim_chanID, "nvim_exec_lua", [[return require"osv".stop()]])
        vim.fn.jobstop(nvim_chanID)
        if type(uv.os_getpriority(pid)) == "number" then
            uv.kill(pid, 9)
        end
        nvim_chanID = nil
    end

    nvim_chanID = vim.fn.jobstart({vim.v.progpath, "--embed", "--headless"}, {rpc = true})
    assert(nvim_chanID, "Could not create neovim instance with jobstart!")

    local mode = vim.fn.rpcrequest(nvim_chanID, "nvim_get_mode")
    assert(not mode.blocking, "Neovim is waiting for input at startup. Aborting.")

    -- make sure OSV is loaded
    vim.fn.rpcrequest(nvim_chanID, "nvim_command", "packadd one-small-step-for-vimkind")

    nvim_server = vim.fn.rpcrequest(nvim_chanID, "nvim_exec_lua", [[return require"osv".launch(...)]], {opts})

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
                    vim.fn.rpcnotify(nvim_chanID, "nvim_command", "luafile " .. vim.fn.expand("%:p"))
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
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
            args = {},
            runInTerminal = false
        }
    }

    dap.configurations.c = dap.configurations.cpp
    dap.configurations.rust = dap.configurations.cpp
end

init()

-- local function start_session()
--     -- set session tab
--     dap.session().session_target_tab = vim.fn.tabpagenr()
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
