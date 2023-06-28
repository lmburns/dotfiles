---@module 'usr.api.opt'
---@description Option manipulation
---@class Api.Opt
local M = {}

local lazy = require("usr.lazy")
-- local W = lazy.require("usr.api.win") ---@module 'usr.api.win'
local B = lazy.require("usr.api.buf") ---@module 'usr.api.buf'
local log = lazy.require("usr.lib.log") ---@module 'usr.lib.log'
local shared = require("usr.shared")
local utils = shared.utils
local F = shared.F

local api = vim.api

---Cache to track all information about all options
---@class OptionCache
---@field cache table<bufnr, GetOptionInfo>
---@field buffers bufnr[]
---@field name_map table<string, string>
---@field __cache table<bufnr, GetOptionInfo>
---@field __buffers bufnr[]
M.store = {}

---Create a new `OptionCache`
---@return self
function M.store:new()
    if not M.store.cache then
        local o = setmetatable(M.store, self)
        self.__index = self
        o.__cache = {}
        o.__buffers = {}
        o.cache = {}
        o.buffers = {}
        o.name_map = {}
        setmetatable(o.cache, {
            __index = function(self, bufnr)
                local listed = vim.bo[bufnr].buflisted

                -- local data = rawget(o.__cache, bufnr)
                -- if not listed then
                --     rawset(o.__cache, bufnr, nil)
                --     rawset(o.__buffers, bufnr, nil)
                --     return {}
                -- end
                -- return data

                local data = rawget(self, bufnr)
                if not listed then
                    rawset(self, bufnr, nil)
                    rawset(o.buffers, bufnr, nil)
                    return {}
                end
                return data
            end,
            __newindex = function(self, bufnr, opts)
                if B.buf_is_valid(bufnr) then
                    -- rawset(o.__cache, bufnr, opts)
                    -- rawset(o.__buffers, bufnr, true)

                    rawset(self, bufnr, opts)
                    rawset(o.buffers, bufnr, true)
                end
            end,
            __len = function(self)
                -- return vim.tbl_count(o.__cache)
                return vim.tbl_count(self)
            end,
        })
        setmetatable(o.buffers, {
            __index = function(self, bufnr)
                local listed = vim.bo[bufnr].buflisted
                local data = rawget(self, bufnr)
                if not listed then
                    rawset(o.cache, bufnr, nil)
                    rawset(self, bufnr, nil)
                    return {}
                end
                return data
            end,
            __newindex = function(self, bufnr, opts)
                if B.buf_is_valid(bufnr) then
                    rawset(o.cache, bufnr, opts)
                    rawset(self, bufnr, true)
                end
            end,
            __tostring = function(self)
                return vim.inspect(vim.tbl_keys(self))
            end,
            __len = function(self)
                return vim.tbl_count(self)
            end,
        })
        return o
    end
    return self
end

---Setup the option cache
---@param bufnr? bufnr
---@return OptionCache
function M.store:setbuf(bufnr)
    bufnr = bufnr or api.nvim_get_current_buf()
    if vim.tbl_isempty(self.cache[bufnr] or {}) then
        local info = api.nvim_get_all_options_info()
        for opt, _ in pairs(info) do
            info[opt].value = M.get(opt, nil, {})
            if info[opt].shortname then
                self.name_map[info[opt].shortname] = opt
            else
                self.name_map[opt] = opt
            end
        end
        self.cache[bufnr] = info
    end
    return self
end

---Set a single option
---@param opt string
---@param bufnr? bufnr
---@return OptionCache
function M.store:update(opt, bufnr)
    bufnr = bufnr or api.nvim_get_current_buf()
    if vim.tbl_isempty(self.cache[bufnr] or {}) then
        self:setbuf(bufnr)
    end
    if self.cache[bufnr][opt] then
        self.cache[bufnr][opt].value = M.get(opt)
    end
    return self
end

---Get an option value
---@param opt? string
---@param bufnr? bufnr
---@return GetOptionInfo|Dict<GetOptionInfo>
function M.store:get(opt, bufnr)
    bufnr = bufnr or api.nvim_get_current_buf()
    if not self.cache[bufnr] then
        self.cache[bufnr] = {}
    end
    if opt then
        return self.cache[bufnr][opt] or self.cache[bufnr][self.name_map[opt]]
    end
    return self.cache
end

--  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

---Get a Vim option. Will return in the order of: local > global > default
---@param option string option to get
---@param default? Option_t fallback option
---@param opts? GetOptionOpts
---@return Option_t
function M.get(option, default, opts)
    local ok, opt = pcall(api.nvim_get_option_value, option, F.unwrap_or(opts, {}))
    if not ok then
        opt = default
    end
    return opt
end

---Get a Vim option information. If no option given, return all
---@param option? string option to get
---@param opts? GetOptionOpts
---@return GetOptionInfo
function M.get_info(option, opts)
    opts = F.unwrap_or(opts, {})
    local ok, info
    if option then
        ok, info = pcall(api.nvim_get_option_info2, option, opts)
        if not ok then
            return {}
        end
    else
        info = api.nvim_get_all_options_info()
    end
    return info
end

---Execute a function with an option temporarily changed
---@generic A, R
---@param opt {opt: string, val: string|number|table}
---@param func string|fun(...: A): R
---@param ... A
---@return R?
function M.tmp_call(opt, func, ...)
    local old = vim.o[opt.opt]
    if utils.is.tbl(opt.val) then
        vim.opt[opt.opt] = opt.val
    else
        vim.o[opt.opt] = opt.val
    end
    -- local res = F.wrap(func, utils.wrap_fn_call)(...)
    local res = utils.wrap_fn_call(func, ...)
    vim.o[opt.opt] = old
    return res
end

---Toggle a boolean option
---@param option string
---@param values? Option_t[] values to toggle between (default: booleans)
---@param opts? GetOptionOpts
---@param title? string
function M.toggle_option(option, values, opts, title)
    -- :set cursorcolumn! cursorcolumn?
    -- :exec "set fo"..(stridx(&fo, 'r') == -1 ? "+=ro" : "-=ro").." fo?"
    -- :exec "set stal="..(&stal == 2 ? "0" : "2").." stal?"
    -- :let &mouse=(empty(&mouse) ? 'a' : '')
    local value
    -- if opts == nil then
    --     value = M.store:get(option).value
    -- else
    value = M.get(option, nil, opts)
    -- end

    if type(values) == "table" and #values >= 2 then
        local v1, v2 = values[1], values[2]
        if type(v1) == type(v2) and type(v1) == type(value) then
            value = F.if_expr(value == v1, v2, v1)
            vim.opt[option] = value
            -- log.info(("state: %s"):format(value), {title = F.unwrap_or(title, option)})
            -- M.store:update(option)
        end
    elseif value ~= nil then
        vim.opt[option] = not value
        -- log.info(("state: %s"):format(not value), {title = F.unwrap_or(title, option)})
        -- M.store:update(option)
    end
    cmd(("set %s?"):format(option))
end

--  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

---Map of options that accept comma separated, list-like values, but don't work
---correctly with Option:set(), Option:append(), Option:prepend(), and
---Option:remove() (seemingly for legacy reasons).
local list_like_options = {
    winhighlight = true,
    listchars = true,
    fillchars = true,
}

---@param winids number[]|number Either a list of winids, or a single winid (0 for current window).
---@param option_map WindowOptions
---@param opt? mpi.setl.Opt
function M.set_local(winids, option_map, opt)
    winids = F.unwrap_or(winids, {0})
    winids = F.if_expr(not utils.is.tbl(winids), {winids}, winids)

    opt = vim.tbl_extend("keep", opt or {}, {method = "set"}) --[[@as table]]

    for _, id in ipairs(winids) do
        api.nvim_win_call(id, function()
            for option, value in pairs(option_map) do
                local o = opt
                local fullname = api.nvim_get_option_info2(option).name
                local is_list_like = list_like_options[fullname]
                local cur_value = vim.o[fullname]

                if type(value) == "table" then
                    if value.opt then
                        o = vim.tbl_extend("force", opt, value.opt) --[[@as table ]]
                    end

                    if is_list_like then
                        value = table.concat(value, ",")
                    end
                end

                if o.method == "set" then
                    vim.opt_local[option] = value
                else
                    if o.method == "remove" then
                        if is_list_like then
                            vim.opt_local[fullname] = cur_value:gsub(",?" .. vim.pesc(value), "")
                        else
                            vim.opt_local[fullname]:remove(value)
                        end
                    elseif o.method == "append" then
                        if is_list_like then
                            vim.opt_local[fullname] = ("%s%s"):format(
                                cur_value ~= "" and cur_value .. ",", value)
                        else
                            vim.opt_local[fullname]:append(value)
                        end
                    elseif o.method == "prepend" then
                        if is_list_like then
                            vim.opt_local[fullname] = ("%s%s%s"):format(
                                value,
                                cur_value ~= "" and "," or "",
                                cur_value
                            )
                        else
                            vim.opt_local[fullname]:prepend(value)
                        end
                    end
                end
            end
        end)
    end
end

---@param winids number[]|number Either a list of winids, or a single winid (0 for current window).
---@param option string
function M.unset_local(winids, option)
    winids = utils.is.tbl(winids) and winids or {winids}
    for _, id in ipairs(winids) do
        api.nvim_win_call(id, function()
            vim.opt_local[option] = nil
        end)
    end
end

local function init()
    vim.defer_fn(function()
        M.store:new():setbuf()

        nvim.autocmd.lmb__OptionWrap = {
            {
                event = "OptionSet",
                pattern = "*",
                command = function(a)
                    -- local typ = vim.v.option_type        -- "local" | "global"
                    -- local command = vim.v.option_command -- "set"|"setlocal"|"setglobal"
                    -- local new = vim.v.option_new
                    -- local old = vim.v.option_old
                    -- local oldlocal = vim.v.option_oldlocal
                    -- local oldglobal = vim.v.option_oldglobal

                    if not vim.tbl_isempty(M.store.cache) then
                        M.store:update(a.match)
                    end
                end,
            },
            {
                event = "BufEnter",
                pattern = "*",
                command = function(a)
                    local bufnr = a.buf
                    if B.buf_should_exclude(bufnr) then
                        return
                    end

                    M.store:setbuf(bufnr)
                end,
            },
        }
    end, 500)
end

-- init()

---@class mpi.setl.Opt
---@field method '"set"'|'"remove"'|'"append"'|'"prepend"' Assignment method. (default: "set")

---@class mpi.setl.ListSpec : string[]
---@field opt mpi.setl.Opt

return M
