---@module 'ftplugin'
local M = {}

local Abbr = require("abbr")
local utils = require("common.utils")
local log = require("common.log")
local mpi = require("common.api")
local map = mpi.map

local api = vim.api

local did_setup = false

local function validate_bindings(bindings)
    if not bindings then
        return
    end
    vim.validate({bindings = {bindings, "t"}})
    vim.iter(bindings):each(function(v)
        if not utils.is.table(v) then
            error("ftplugin bindings must be an array of arrays")
        end
    end)
end

---@type Dict<FiletypeConfig>
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
---@param config FiletypeConfig
M.set = function(name, config)
    validate_bindings(config.bindings)
    configs[name] = config
end

---Get a filetype config
---@param name string
---@return FiletypeConfig?
M.get = function(name)
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

M.reapply_all_bufs = function()
    for _, bufnr in ipairs(api.nvim_list_bufs()) do
        M.apply(vim.bo[bufnr].filetype, bufnr)
    end
end

---Extend the configuration for a filetype, overriding values that conflict
---@param name string
---@param new_config FiletypeConfig
M.extend = function(name, new_config)
    validate_bindings(new_config.bindings)
    local conf = configs[name] or {}
    conf.abbr = vim.tbl_deep_extend("force", conf.abbr or {}, new_config.abbr or {})
    conf.opt = vim.tbl_deep_extend("force", conf.opt or {}, new_config.opt or {})
    conf.bufvar = vim.tbl_deep_extend("force", conf.bufvar or {}, new_config.bufvar or {})
    conf.callback = merge_callbacks(conf.callback, new_config.callback)
    conf.bindings = merge_bindings(conf.bindings, new_config.bindings)
    conf.ignore_win_opts = coalesce(new_config.ignore_win_opts, conf.ignore_win_opts)
    configs[name] = conf
    if did_setup then
        M.reapply_all_bufs()
    end
end

---Set many configs all at once
---@param confs table<string, FiletypeConfig>
M.set_all = function(confs)
    for k, v in pairs(confs) do
        M.set(k, v)
    end
end

---Extend many configs all at once
---@param confs table<string, FiletypeConfig>
M.extend_all = function(confs)
    for k, v in pairs(confs) do
        M.extend(k, v)
    end
end

---@param name string
---@param winid integer
---@return table<string, boolean>
local function _apply_win(name, winid)
    local conf = configs[name]
    if not conf then
        return {}
    end
    local ret = {}
    if conf.opt then
        for k, v in pairs(conf.opt) do
            local opt_info = mpi.get_option_info(k)
            if opt_info.scope == "win" then
                local ok, err = pcall(api.nvim_win_set_option, winid, k, v)
                if ok then
                    ret[k] = true
                else
                    log.err(
                        ("Failed setting winopt\n%s = %s: %s"):format(k, vim.inspect(v), err),
                        {title = "ftplugin"}
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
M.apply_win = function(name, winid)
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
    if prev_win_opts ~= nil then
        for _, prev_opt in ipairs(prev_win_opts) do
            if not win_overrides[prev_opt] then
                local ok, err = pcall(
                    api.nvim_win_set_option,
                    winid,
                    prev_opt,
                    get_default_opt(winid, prev_opt)
                )
                if not ok then
                    log.err(("Failed restoring winopt\n%s = %s: %s"):format(
                        prev_opt,
                        get_default_opt(winid, prev_opt),
                        err
                    ), {title = "ftplugin"})
                end
            end
        end
    end
    vim.w[winid].ftplugin_set_opts = vim.tbl_keys(win_overrides)
end

---Apply all filetype configs for a buffer
---@param name string
---@param bufnr integer
M.apply = function(name, bufnr)
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
    if conf.abbr then
        api.nvim_buf_call(bufnr, function()
            for k, v in pairs(conf.abbr) do
                Abbr:new("i", k, v, {buffer = bufnr})
            end
        end)
    end
    if conf.opt then
        for k, v in pairs(conf.opt) do
            local opt_info = mpi.get_option_info(k)
            if opt_info.scope == "buf" then
                local ok, err = pcall(api.nvim_buf_set_option, bufnr, k, v)
                if not ok then
                    log.err(
                        ("Failed setting bufopt\n%s = %s: %s"):format(k, vim.inspect(v), err),
                        {title = "ftplugin"}
                    )
                end
            end
        end
        local winids = vim.tbl_filter(
            function(win)
                return api.nvim_win_get_buf(win) == bufnr
            end,
            api.nvim_list_wins()
        )
        for _, winid in ipairs(winids) do
            M.apply_win(name, winid)
        end
    end
    if conf.bufvar then
        for k, v in pairs(conf.bufvar) do
            vim.b[bufnr][k] = v
        end
    end
    if conf.bindings then
        for _, defn in ipairs(conf.bindings) do
            local mode, lhs, rhs, opts = unpack(defn)
            opts = vim.tbl_deep_extend("error", opts or {}, {
                buffer = bufnr,
            })
            map(mode, lhs, rhs, opts)
        end
    end
    if conf.callback then
        conf.callback(bufnr)
    end
end

---Create autocommands that will apply the configs
---@param opts? FiletypeOpts
M.setup = function(opts)
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
    for opt, opt_info in pairs(mpi.get_option_info()) do
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
            desc = "Set filetype-specific options",
            pattern = "*",
            command = function(a)
                M.apply(a.match, a.buf)
            end,
        },
        {
            event = "BufWinEnter",
            desc = "Set filetype-specific window options",
            pattern = "*",
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

---@class FiletypeConfig
---@field abbr? Dict<string> Insert-mode abbreviations
---@field bindings? table Buffer-local keymaps
---@field bufvar? Dict<any> Buffer-local variables
---@field callback? fun(bufnr: integer)
---@field opt? Dict<any> Buffer-local or window-local options
---@field ignore_win_opts? boolean Don't manage the window-local options for this filetype

---@class FiletypeOpts
---@field augroup? string|integer Augroup to use when creating the autocmds
---@field default_win_opts? table<string, any> Default window-local option values to revert to when leaving a window

return M
