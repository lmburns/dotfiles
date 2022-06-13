_G.myluafunc =
    setmetatable(
    {},
    {
        __call = function(self, idx, args, count)
            return self[idx](args, count)
        end
    }
)

local func2str = function(func, args)
    local idx = #_G.myluafunc + 1
    _G.myluafunc[idx] = func
    if not args then
        return ("lua myluafunc(%s)"):format(idx)
    else
        -- return ("lua myluafunc(%s, <q-args>)"):format(idx)
        return ("lua myluafunc(%s, <q-args>, <count>)"):format(idx)
    end
end

---Remap keys (create a Vim function with Lua)
M.remap = function(modes, lhs, rhs, opts)
    modes = type(modes) == "string" and {modes} or modes
    opts = opts or {}
    opts = type(opts) == "string" and {opts} or opts

    local fallback = function()
        return api.nvim_feedkeys(M.t(lhs), "n", true)
    end

    local _rhs =
        (function()
        if type(rhs) == "function" then
            opts.noremap = true
            opts.cmd = true
            return func2str(
                function()
                    rhs(fallback)
                end
            )
        else
            if rhs:lower():sub(1, #"<plug>") == "<plug>" then
                opts.noremap = false
            end
            return rhs
        end
    end)()

    for key, opt in ipairs(opts) do
        opts[opt] = true
        opts[key] = nil
    end

    local buffer = (function()
        if opts.buffer then
            opts.buffer = nil
            return true
        end
    end)()

    _rhs = (function()
        if opts.cmd then
            opts.cmd = nil
            return ("<cmd>%s<cr>"):format(_rhs)
        else
            return _rhs
        end
    end)()

    for _, mode in ipairs(modes) do
        if buffer then
            api.nvim_buf_set_keymap(0, mode, lhs, _rhs, opts)
        else
            api.nvim_set_keymap(mode, lhs, _rhs, opts)
        end
    end
end
---Create an autocmd with vim commands
---
---This allows very easy transition from vim commands
M.autocmd = function(group, cmds, clear)
    clear = clear == nil and false or clear
    if type(cmds) == "string" then
        cmds = {cmds}
    end
    cmd("augroup " .. group)
    if clear then
        cmd [[au!]]
    end
    for _, c in ipairs(cmds) do
        cmd("autocmd " .. c)
    end
    cmd [[augroup END]]
end

-- Modify vim options
function M.opt(o, v, scopes)
    scopes = scopes or {vim.o}
    v = v == nil and true or v

    if type(v) == "table" then
        v = table.concat(v, ",")
    end

    for _, s in ipairs(scopes) do
        s[o] = v
    end
end

-- Another command function
function M.cmd(name, action, flags)
    local flag_pairs = {}

    if flags then
        for flag, value in pairs(flags) do
            if value == true then
                table.insert(flag_pairs, "-" .. flag)
            else
                table.insert(flag_pairs, "-" .. flag .. "=" .. value)
            end
        end
    end

    action = action:gsub("\n%s*", " ")

    local def = table.concat({"command!", table.concat(flag_pairs, " "), name, action}, " ")

    vim.cmd(def)
end

-- Expand or minimize current buffer in a more natural direction (tmux-like)
M.resize = function(vertical, margin)
    local cur_win = api.nvim_get_current_win()
    -- go (possibly) right
    vim.cmd(string.format("wincmd %s", vertical and "l" or "j"))
    local new_win = api.nvim_get_current_win()

    -- determine direction cond on increase and existing right-hand buffer
    local not_last = not (cur_win == new_win)
    local sign = margin > 0
    -- go to previous window if required otherwise flip sign
    if not_last == true then
        vim.cmd [[wincmd p]]
    else
        sign = not sign
    end

    sign = sign and "+" or "-"
    local dir = vertical and "vertical " or ""
    local cmd = dir .. "resize " .. sign .. math.abs(margin) .. "<CR>"
    vim.cmd(cmd)
end

M.sudo_exec = function(cmd, print_output)
    local password = vim.fn.inputsecret("Password: ")
    if not password or #password == 0 then
        M.warn("Invalid password, sudo aborted")
        return false
    end
    local out = vim.fn.system(string.format("sudo -p '' -S %s", cmd), password)
    if vim.v.shell_error ~= 0 then
        print("\r\n")
        M.err(out)
        return false
    end
    if print_output then
        print("\r\n", out)
    end
    return true
end

M.sudo_write = function(tmpfile, filepath)
    if not tmpfile then
        tmpfile = vim.fn.tempname()
    end
    if not filepath then
        filepath = vim.fn.expand("%")
    end
    if not filepath or #filepath == 0 then
        M.err("E32: No file name")
        return
    end
    -- `bs=1048576` is equivalent to `bs=1M` for GNU dd or `bs=1m` for BSD dd
    -- Both `bs=1M` and `bs=1m` are non-POSIX
    local cmd = string.format("dd if=%s of=%s bs=1048576", vim.fn.shellescape(tmpfile), vim.fn.shellescape(filepath))
    -- no need to check error as this fails the entire function
    vim.api.nvim_exec(string.format("write! %s", tmpfile), true)
    if M.sudo_exec(cmd) then
        M.info(string.format('\r\n"%s" written', filepath))
        vim.cmd("e!")
    end
    vim.fn.delete(tmpfile)
end

---API for command mappings
-- Supports lua function args
---@param args string|table
function M.cmd(args)
    if type(args) == "table" then
        for i = 2, #args do
            if fn.exists(":" .. args[2]) == 2 then
                cmd("delcommand " .. args[2])
            end
            if type(args[i]) == "function" then
                args[i] = func2str(args[i], true)
            end
        end
        args = table.concat(args, " ")
    end
    cmd("command! " .. args)
end

cmd [[
    function! IsPluginInstalled(name) abort
      return luaeval("_G.packer_plugins['" .. a:name .. "'] ~= nil")
    endfunction
]]

my_packer.is_plugin_installed = function(name)
    return _G.packer_plugins[name] ~= nil
end

function AutocmdLazyConfig(plugin_name)
    local timer = loop.new_timer()
    timer:start(
        1000,
        0,
        schedule_wrap(
            function()
                if _G.packer_plugins[plugin_name].loaded then
                    timer:close() -- Always close handles to avoid leaks.
                    cmd(string.format("doautocmd User %s", "packer-" .. plugin_name))
                end
            end
        )
    )
end