-- Create an autocmd with vim commands
function M.autocmd(group, cmds, clear)
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
function M.resize(vertical, margin)
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
