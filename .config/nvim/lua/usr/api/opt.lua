---@module 'usr.api.opt'
local M = {}

local lazy = require("usr.lazy")
local log = lazy.require("usr.lib.log") ---@module 'usr.lib.log'
local shared = require("usr.shared")
local utils = shared.utils
local F = shared.F

local api = vim.api

---Cache to track all information about all options
---@class OptionCache
M.option = {cache = {}}

---Setup the option cache
---@return OptionCache
function M.option:set()
    setmetatable({}, self)
    self.__index = self
    if vim.tbl_isempty(self.cache) then
        local info = api.nvim_get_all_options_info()
        for opt, _ in pairs(info) do
            info[opt].value = M.get(opt, nil, {})
        end
        self.cache = info
    end
    return self
end

---Get an option value
---@param opt string
---@return GetOptionInfo|Dict<GetOptionInfo>
function M.option:get(opt)
    if opt then
        return self.cache[opt]
    end
    return self.cache
end

--  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

---Get a Vim option. Will return in the order of: local > global > default
---@param option string option to get
---@param default? Option_t fallback option
---@param opts? GetOptionOpts
---@return Option_t
M.get = function(option, default, opts)
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
M.get_info = function(option, opts)
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

---Toggle a boolean option
---@param option string
---@param values? Option_t[] values to toggle between (default: booleans)
---@param opts? GetOptionOpts
---@param title? string
M.toggle_option = function(option, values, opts, title)
    M.option:set()
    local value
    if opts == nil then
        value = M.option:get(option).value
    else
        value = M.get(option, nil, opts)
    end

    if type(values) == "table" and #values >= 2 then
        local v1, v2 = values[1], values[2]
        if type(v1) == type(v2) and type(v1) == type(value) then
            value = F.if_expr(value == v1, v2, v1)
            vim.opt[option] = value
            log.info(("state: %s"):format(value), {title = F.unwrap_or(title, option)})
            M.option.cache[option].value = value
        end
    elseif value ~= nil then
        vim.opt[option] = not value
        log.info(("state: %s"):format(not value), {title = F.unwrap_or(title, option)})
        M.option.cache[option].value = not value
    end
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
    if type(winids) ~= "table" then
        winids = {winids}
    end

    opt = vim.tbl_extend("keep", opt or {}, {method = "set"}) --[[@as table]]

    for _, id in ipairs(winids) do
        api.nvim_win_call(id, function()
            for option, value in pairs(option_map) do
                local o = opt
                local fullname = api.nvim_get_option_info(option).name
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
        M.option:set()
    end, 500)
end

init()

---@class mpi.setl.Opt
---@field method '"set"'|'"remove"'|'"append"'|'"prepend"' Assignment method. (default: "set")

---@class mpi.setl.ListSpec : string[]
---@field opt mpi.setl.Opt

return M
