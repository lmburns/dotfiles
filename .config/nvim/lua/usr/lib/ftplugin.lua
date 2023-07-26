---@module 'usr.lib.ftplugin'
---@class Usr.Lib.Ftplugin
local M = {}

-- local utils = Rc.shared.utils
local F = Rc.F
local log = Rc.lib.log
local Abbr = Rc.api.abbr
local bmap = Rc.api.bmap

local api = vim.api

local did_setup = false

local function validate_bindings(bindings)
    if not bindings then
        return
    end
    vim.validate({bindings = {bindings, "t"}})
    vim.iter(bindings):each(function(v)
        if not F.is.tbl(v) then
            error("ftplugin bindings must be an array of arrays")
        end
    end)
end

---@type Dict<Filetype.Config>
local configs = {}

---@type Dict<any>
local _default_win_opts = {}

---@param winid integer
---@param opt string
---@return any
local function get_default_opt(winid, opt)
    local ret = _default_win_opts[opt]
    if type(ret) == "function" then
        return ret(winid)
    else
        return ret
    end
end

---Set the config for a filetype
---@param name string
---@param config Filetype.Config
function M.set(name, config)
    validate_bindings(config.bindings)
    configs[name] = config
end

---Get a filetype config
---@param name string
---@return Filetype.Config?
function M.get(name)
    return configs[name]
end

local function merge_callbacks(fn1, fn2)
    if not fn1 and not fn2 then
        return nil
    end
    if fn1 then
        if fn2 then
            return function(...)
                fn1(...)
                fn2(...)
            end
        else
            return fn1
        end
    else
        return fn2
    end
end

local function merge_bindings(b1, b2)
    if not b1 then
        return b2
    elseif not b2 then
        return b1
    end
    local ret = vim.list_extend({}, b1)
    return vim.list_extend(ret, b2)
end

local function coalesce(v1, v2)
    if v1 == nil then
        return v2
    else
        return v1
    end
end

function M.reapply_all_bufs()
    for _, bufnr in ipairs(api.nvim_list_bufs()) do
        M.apply(vim.bo[bufnr].filetype, bufnr)
    end
end

---Extend the configuration for a filetype, overriding values that conflict
---@param name string
---@param new_config Filetype.Config
function M.extend(name, new_config)
    validate_bindings(new_config.bindings)
    local conf = configs[name] or {}
    conf.abbr = vim.tbl_deep_extend("force", conf.abbr or {}, new_config.abbr or {})
    conf.opt = vim.tbl_deep_extend("force", conf.opt or {}, new_config.opt or {})
    conf.bufvar = vim.tbl_deep_extend("force", conf.bufvar or {}, new_config.bufvar or {})
    conf.winvar = vim.tbl_deep_extend("force", conf.winvar or {}, new_config.winvar or {})
    conf.callback = merge_callbacks(conf.callback, new_config.callback)
    conf.bindings = merge_bindings(conf.bindings, new_config.bindings)
    conf.ignore_win_opts = coalesce(new_config.ignore_win_opts, conf.ignore_win_opts)
    configs[name] = conf
    if did_setup then
        M.reapply_all_bufs()
    end
end

---Set many configs all at once
---@param confs Dict<Filetype.Config>
function M.set_all(confs)
    for k, v in pairs(confs) do
        M.set(k, v)
    end
end

---Extend many configs all at once
---@param confs table<string, Filetype.Config>
function M.extend_all(confs)
    for k, v in pairs(confs) do
        M.extend(k, v)
    end
end

---@param name string
---@param winid integer
---@return Dict<boolean>
local function _apply_win(name, winid)
    local conf = configs[name]
    if not conf or not conf.opt then
        return {}
    end
    local ret = {}
    if conf.opt then
        for k, v in pairs(conf.opt) do
            local opt_info = Rc.api.opt.get_info(k)
            if opt_info.scope == "win" then
                local ok, err = pcall(api.nvim_set_option_value, k, v, {win = winid})
                if ok then
                    ret[k] = true
                else
                    log.err(
                        ("Failed setting window option.\n"
                            .. "%s => %s: %s")
                        :format(k, I(v), err),
                        {debug = true}
                    )
                end
            end
        end
    end
    return ret
end

---Apply window options
---@param name string
---@param winid integer
function M.apply_win(name, winid)
    local win_overrides = {}
    local pieces = vim.split(name, ".", {plain = true})
    if #pieces > 1 then
        for _, ft in ipairs(pieces) do
            win_overrides = vim.tbl_extend("force", win_overrides, _apply_win(ft, winid))
        end
    else
        win_overrides = _apply_win(name, winid)
    end

    local conf = configs[name]
    if conf and conf.ignore_win_opts then
        return
    end
    -- Restore other window options to the default value
    local prev_win_opts = vim.w[winid].ftplugin_set_opts
    -- local has_prev, prev_win_opts = pcall(api.nvim_win_get_var, winid, "ftplugin_set_opts")
    if prev_win_opts then
        for _, prev_opt in ipairs(prev_win_opts) do
            if not win_overrides[prev_opt] then
                local ok, err = pcall(
                    api.nvim_win_set_option,
                    winid,
                    prev_opt,
                    get_default_opt(winid, prev_opt)
                )
                if not ok then
                    log.err(
                        ("Failed restoring window option.\n"
                            .. "%s => %s: %s")
                        :format(prev_opt, I(get_default_opt(winid, prev_opt)), err),
                        {debug = true}
                    )
                end
            end
        end
    end
    vim.w[winid].ftplugin_set_opts = vim.tbl_keys(win_overrides)
end

---Apply all filetype configs for a buffer
---@param name string
---@param bufnr integer
---@param after? bool
function M.apply(name, bufnr, after)
    local pieces = vim.split(name, ".", {plain = true})
    if #pieces > 1 then
        for _, ft in ipairs(pieces) do
            M.apply(ft, bufnr)
        end
        return
    end
    local conf = configs[name]
    if not conf then
        return
    end

    -- TODO: get this to work
    if conf.after and not after then
        vim.defer_fn(function()
            M.apply(name, bufnr, true)
        end, 400)
        return
    end

    if conf.abbr then
        api.nvim_buf_call(bufnr, function()
            for k, v in pairs(conf.abbr) do
                Abbr:new("i", k, v, {buffer = bufnr})
            end
        end)
    end
    if conf.opt then
        for k, v in pairs(conf.opt) do
            local opt_info = Rc.api.opt.get_info(k)
            if opt_info.scope == "buf" then
                local ok, err = pcall(api.nvim_set_option_value, k, v, {buf = bufnr})
                if not ok then
                    log.err(
                        ("Failed setting buffer option.\n"
                            .. "%s => %s: %s")
                        :format(k, I(v), err),
                        {debug = true}
                    )
                end
            end
        end
        local winids = vim.tbl_filter(function(win)
            return api.nvim_win_get_buf(win) == bufnr
        end, api.nvim_list_wins())
        for _, winid in ipairs(winids) do
            M.apply_win(name, winid)
        end
    end
    if conf.bufvar then
        for k, v in pairs(conf.bufvar) do
            vim.b[bufnr][k] = v
        end
    end
    if conf.winvar then
        for k, v in pairs(conf.winvar) do
            vim.w[bufnr][k] = v
        end
    end
    if conf.bindings then
        for _, defn in ipairs(conf.bindings) do
            bmap(bufnr, unpack(defn))
        end
    end
    if conf.callback then
        conf.callback(bufnr)
    end
end

---Create autocommands that will apply the configs
---@param opts? Filetype.Opts
function M.setup(opts)
    local conf = vim.tbl_deep_extend("keep", opts or {}, {
        augroup = nil,
        default_win_opts = {
            scroll = 0, -- We won't get a good default value for this otherwise (will be 1/2 of current win height)
        },
    })
    if not conf.augroup then
        conf.augroup = "lmb__FiletypePlugin"
    end

    -- Pick up the existing option values
    for opt, opt_info in pairs(Rc.api.opt.get_info()) do
        if opt_info.scope == "win" and conf.default_win_opts[opt] == nil then
            if opt_info.global_local then
                conf.default_win_opts[opt] = vim.go[opt]
            else
                conf.default_win_opts[opt] = vim.o[opt]
            end
        end
    end
    _default_win_opts = conf.default_win_opts

    nvim.autocmd[conf.augroup] = {
        {
            event = "FileType",
            pattern = "*",
            desc = "Set filetype-specific options",
            command = function(a)
                M.apply(a.match, a.buf)
            end,
        },
        {
            event = "BufWinEnter",
            pattern = "*",
            desc = "Set filetype-specific window options",
            command = function(_a)
                local winid = api.nvim_get_current_win()
                local bufnr = api.nvim_win_get_buf(winid)
                local filetype = vim.bo[bufnr].ft
                if vim.bo[bufnr].bt == "terminal" then
                    filetype = "terminal"
                end
                M.apply_win(filetype, winid)
            end,
        },
        {
            event = "TermEnter",
            desc = "Set terminal-specific options",
            pattern = "*",
            command = function(_a)
                -- local bufnr = a.buf
                local winid = api.nvim_get_current_win()
                local bufnr = api.nvim_win_get_buf(winid)
                if vim.bo[bufnr].bt ~= "terminal" then
                    return
                end
                M.apply("terminal", bufnr)
                M.apply_win("terminal", winid)
            end,
        },
    }

    did_setup = true
end

---@class Filetype.Config
---@field abbr? Dict<string>        insert-mode abbreviations
---@field bindings? Keymap.Prototype[]  buffer-local keymaps
---@field bufvar? Dict<any>         buffer-local variables
---@field winvar? Dict<any>         buffer-local variables
---@field opt? vim.bo|vim.wo        buffer-local or window-local options
---@field ignore_win_opts? boolean  don't manage the window-local options for this filetype
---@field callback? fun(bufnr: bufnr)
---@field after? boolean             run filetype like it was in after directory

---@class Filetype.Opts
---@field augroup? string|Augroup.id augroup to use when creating the autocmds
---@field default_win_opts? Dict<vim.wo|vim.go> default window-local option values to revert to when leaving a window

return M
