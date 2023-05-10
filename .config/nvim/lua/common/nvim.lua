---@module 'common.nvim'
local M = {}

local D = require("dev")
local utils = require("common.utils")
local mpi = require("common.api")
local log = require("common.log")

local api = vim.api
local F = vim.F
local fn = vim.fn

---Get an augroup
---@param name_id string|number
---@return Autocmd_t
local function get_augroup(name_id)
    vim.validate({
        name_id = {name_id, {"s", "n"}, "Augroup name string or id number"},
    })
    return mpi.get_autocmd({group = name_id})
end

---Return augroup ID
---@param name string|number
---@return number
local function get_augroup_id(name)
    local groups = get_augroup(name)
    if #groups > 0 then
        return groups[1].group
    end
    return -1
end

---Add an augroup
---@param name string Augroup name
---@param clear? boolean Clear the augroup
---@return number
local function add_augroup(name, clear)
    vim.validate({
        name = {name, "string"},
        clear = {clear, "boolean", true},
    })

    local groups = get_augroup(name)
    if #groups == 0 or clear then
        return mpi.create_augroup(name, clear == true)
    end
    return groups[1].group
end

---Clear an `augroup`
---@param name string
local function clear_augroup(name)
    vim.validate{name = {name, "string"}}
    mpi.create_augroup(name, true)
end

---Access to plugins
---@type Nvim.Plugins
nvim.plugins = setmetatable({}, {
    __index = function(self, k)
        local mt = getmetatable(self)
        local x = rawget(mt, k)

        if x ~= nil then
            return x
        end

        local ok, plugs = pcall(api.nvim_get_var, "plugs")
        if plugs[k] then
            rawset(mt, k, plugs[k])
            return plugs[k]
        end

        if not ok and _G.packer_plugins then
            plugs = _G.packer_plugins
            if plugs[k] and plugs[k].loaded then
                return plugs[k]
            end
        end

        return nil
    end,
    __call = function(_, _)
        return _G.packer_plugins
    end,
})

---Access to special-escaped keycodes
---@type Dict<string>
nvim.termcodes = utils.termcodes

---Use `nvim.command[...]` or `nvim.command.get()` to list all
---@type Nvim.Command
nvim.command = setmetatable(
    {
        set = mpi.command,
        del = mpi.del_command,
        get = function(_, k)
            local cmds = api.nvim_get_commands({})
            if k == nil then
                return cmds
            end

            return F.if_nil(cmds[k], {})
        end,
    },
    {
        __index = function(self, k)
            local mt = getmetatable(self)
            local x = rawget(mt, k)
            if x ~= nil then
                return x
            end

            return self.get(k)
        end,
    }
)

---Allow this to be callable without explicitly calling `.add`
---@type Nvim.Keymap
nvim.keymap = setmetatable(
    {
        add = mpi.map,
        get = mpi.get_keymap,
        del = mpi.del_keymap,
    },
    {
        __index = function(self, mode)
            vim.validate{mode = {mode, "s"}}
            local modes = _t({"n", "i", "v", "o", "s", "x", "t", "c"})

            if not modes:contains(mode) then
                error(("'%s' is an invalid mode"):format(F.if_nil(mode, "")))
            end
            return self.get(mode)
        end,
        __call = function(self, modes, lhs, rhs, opts)
            self.add(modes, lhs, rhs, opts)
        end,
    }
)

-- These are all still accessible as something like nvim.buf_get_current_commands(...)

---Access to `api.nvim_ui_.*`
---@type Nvim.Ui
nvim.ui = setmetatable(
    {},
    {
        __index = function(self, k)
            local mt = getmetatable(self)
            local x = rawget(mt, k)
            if x ~= nil then
                return x
            end
            local f = api["nvim_ui_" .. k]
            rawset(mt, k, f)
            return f
        end,
    }
)

---Modify `augroup`s
---@type Nvim.Augroup
nvim.augroup = setmetatable(
    {
        add = add_augroup,
        del = mpi.del_augroup,
        get = get_augroup,
        get_id = get_augroup_id,
        clear = clear_augroup,
    },
    {
        __index = function(self, k)
            local mt = getmetatable(self)
            local x = rawget(mt, k)
            if x ~= nil then
                return x
            end
            local cmds = self.get(k)
            return #cmds > 0 and cmds or nil
        end,
        __newindex = function(self, k, v)
            if type(k) == "string" and k ~= "" then
                if v == nil then
                    self.del(k)
                elseif type(v) == "table" then
                    local autocmds = F.if_expr(vim.tbl_islist(v), vim.deepcopy(v), {v})
                    for _, aucmd in ipairs(autocmds) do
                        if aucmd.group then
                            local group = aucmd.group
                            aucmd.group = nil
                            mpi.augroup(group, aucmd)
                        else
                            mpi.autocmd(aucmd)
                        end
                    end
                end
            end
        end,
    }
)

---Modify `autocmd`s
---@type Nvim.Autocmd
nvim.autocmd = setmetatable(
    {
        add = mpi.autocmd,
        get = mpi.get_autocmd,
        del = function(id)
            vim.validate{id = {id, "number"}}
            pcall(api.nvim_del_autocmd, id)
        end,
    },
    -- Can do nvim.autocmd["User"] to list User autocmds
    {
        __index = function(self, k)
            local mt = getmetatable(self)
            local x = rawget(mt, k)
            if x ~= nil then
                return x
            end
            local cmds = self.get({event = k})
            return #cmds > 0 and cmds or nil
        end,
        __newindex = function(_, k, v)
            if type(k) == "string" and k ~= "" and type(v) == "table" then
                local autocmds = F.if_expr(vim.tbl_islist(v), vim.deepcopy(v), {v})
                mpi.augroup(k, unpack(autocmds))
            end
        end,
    }
)

-- nvim_get_color_by_name({name})
-- nvim_get_color_map()
-- nvim_get_hl({ns_id}, {
-- nvim_get_hl_id_by_name({name})
-- nvim_set_hl({ns_id}, {name}, {

---Access highlight groups
nvim.colors = setmetatable({}, {
    __index = function(_, k)
        return R("common.color")[k]
    end,
    __newindex = function(_, hlgroup, opts)
        R("common.color")[hlgroup] = opts
    end,
    __call = function(_, k)
        return R("common.color")(k)
    end,
})

do
    ---@param _ nil
    ---@param reg string register to get
    ---@return string?
    local function get(_, reg)
        local ok, value = pcall(fn.getreg, reg)
        return ok and value or nil
    end
    ---@param _ nil
    ---@param reg string register to set
    ---@param val? string value to set
    local function set(_, reg, val)
        if val == nil then
            error("can't clear registers")
        end
        pcall(api.nvim_call_function, "setreg", {reg, val})
    end

    ---Access to registers
    ---@type Nvim.Reg
    nvim.reg = setmetatable(
        {
            get = D.thunk(get, nil),
            set = D.thunk(set, nil),
        },
        {
            __index = D.thunk(get, nil),
            __newindex = D.thunk(set, nil),
        }
    )
end

do
    ---@param _ nil
    ---@param mk string mark to get
    ---@return Nvim.Mark?
    local function get(_, mk)
        local ok, mark
        if mk:match("%a") and mk == mk:upper() then
            -- {row, col, buffer, buffername}
            ok, mark = pcall(api.nvim_get_mark, mk, {})
            if ok then
                local row, col, bufnr, bufname = unpack(mark)
                return {name = mk, row = row, col = col, bufnr = bufnr, bufname = bufname}
            else
                log.err(("failed to get mark '%s': %s"):format(mk, mark), {dprint = true})
            end
        else
            -- {row, col}
            ok, mark = pcall(api.nvim_buf_get_mark, 0, mk)
            if ok then
                local row, col = unpack(mark)
                return {
                    name = mk,
                    row = row,
                    col = col,
                    bufnr = 0,
                    bufname = api.nvim_buf_get_name(0),
                }
            else
                log.err(("failed to get mark '%s': %s"):format(mk, mark), {dprint = true})
            end
        end
    end
    ---@param _ nil
    ---@param mk string mark to set
    ---@param val {[1]: integer, [2]: integer}|Nvim.Mark mark value
    local function set(_, mk, val)
        if type(mk) ~= "string" or #mk ~= 1 then
            error("mark must be a single letter")
        end
        if type(val) ~= "table" and (#val ~= 2 or #val ~= 5) then
            error(("must pass table {row, col} or Nvim.Mark. Got: %s"):format(val))
        end
        local row = val.row or val[1]
        local col = val.col or val[2]
        local ok, msg = pcall(api.nvim_buf_set_mark, 0, mk, row, col, {})
        if not ok then
            log.err(("failed to set mark: %s"):format(msg), {dprint = true})
        end
    end

    ---Access to marks
    ---@type Nvim.Mark
    nvim.mark = setmetatable(
        {
            get = D.thunk(get, nil),
            set = D.thunk(set, nil),
        },
        {
            __index = D.thunk(get, nil),
            __newindex = D.thunk(set, nil),
        }
    )
end

--  ╭──────────────────────────────────────────────────────────╮
--  │                        Utiltities                        │
--  ╰──────────────────────────────────────────────────────────╯

---@type Nvim.Exists
local exists_tbl = {
    cmd = function(cmd)
        return fn.exists(":" .. cmd) == 2
    end,
    event = function(event)
        return fn.exists("##" .. event) == 2
    end,
    augroup = function(augroup)
        return fn.exists("#" .. augroup) == 1
    end,
    option = function(option)
        return fn.exists("+" .. option) == 1
    end,
    func = function(func)
        return fn.exists("*" .. func) == 1
    end,
}

---Shortcut for `fn.has()`
---@type Nvim.Exists
nvim.has = setmetatable(exists_tbl, {
    __call = function(_, feature)
        return fn.has(feature) > 0
    end,
})

---Shortcut for `fn.exists()`
---@type Nvim.Exists
nvim.exists = setmetatable(exists_tbl, {
    __call = function(_, feature)
        return fn.exists(feature) > 0
    end,
})

---Global access to check whether something is executable
nvim.executable = utils.executable
---@type Nvim.Command
nvim.cmd = nvim.command
---Equivalent to `api.nvim_win_get_cursor`
nvim.cursor = api.nvim_win_get_cursor
---Equivalent to `api.nvim_get_mode`
nvim.mode = api.nvim_get_mode

---Equivalent to `api.nvim_echo`. Allows multiple commands
---@param chunks { [string]: string }[]
---@param history? boolean
nvim.echo = function(chunks, history)
    vim.validate({
        chunks = {chunks, "t"},
        history = {history, "b", true},
    })
    api.nvim_echo(chunks, history or true, {})
end

---Echo a single colored message
---@type Nvim.p
nvim.p = setmetatable({}, {
    __index = function(super, group)
        group = F.unwrap_or(rawget(super, group), group)

        -- This provides something cool that allows one to do something like:
        -- `nvim.p.MoreMsg('this is colored with MoreMsg')`
        return setmetatable(
            {},
            {
                ---@param _ nil
                ---@param msg string message to echo
                ---@param history? boolean add message to history
                ---@param wait? number amount of time to wait
                __call = function(_, msg, history, wait)
                    -- utils.cecho(msg, group, history, wait)
                    super(msg, group, history, wait)
                end,
            }
        )
    end,
    ---@param _ nil
    ---@param ... any
    __call = function(_, ...)
        utils.cecho(...)
    end,
})

_G.pc = nvim.p

-- ╭──────────────────────────────────────────────────────────╮
-- │                        Variables                         │
-- ╰──────────────────────────────────────────────────────────╯

---Access environment variables
nvim.env = setmetatable({}, {
    __index = function(_, k)
        local ok, value = pcall(api.nvim_call_function, "getenv", {k})
        if not ok then
            value = api.nvim_call_function("expand", {"$" .. k})
            value = value == k and nil or value
        end
        if not value then
            value = os.getenv(k)
        end
        return value or nil
    end,
    __newindex = function(_, k, v)
        local ok, _ = pcall(api.nvim_call_function, "setenv", {k, v})
        if not ok then
            v = type(v) == "string" and ('"%s"'):format(v) or v
            local _ = api.nvim_eval(("let $%s = %s"):format(k, v))
        end
    end,
})

---@param del fun(_: nil, var: string)
---@param set fun(_: nil, var: string, val: any)
---@return fun(_: nil, idx: string, newidx: any)
local function new_idx(del, set)
    return function(_, idx, newidx)
        if newidx == nil then
            del(_, idx)
        else
            set(_, idx, newidx)
        end
    end
end

--  ╭────────╮
--  │ Global │
--  ╰────────╯
do
    ---@param _ nil
    ---@param var string variable to get
    ---@return NvimOptRet
    local function get(_, var)
        local ok, value = pcall(api.nvim_get_var, var)
        return ok and value or nil
    end
    ---@param _ nil
    ---@param var string variable to set
    ---@param val any variable value
    ---@return NvimOptRet
    local function set(_, var, val)
        local ok, value = pcall(api.nvim_set_var, var, val)
        return ok and value or nil
    end
    ---@param _ nil
    ---@param var string variable to delete
    ---@return NvimOptRet
    local function del(_, var)
        local ok, value = pcall(api.nvim_del_var, var)
        return ok and value or nil
    end

    ---Global variables (`g:var`)
    ---@type Nvim.g
    nvim.g = setmetatable(
        {
            get = D.thunk(get, nil),
            set = D.thunk(set, nil),
            del = D.thunk(del, nil),
        },
        {
            __index = D.thunk(get, nil),
            __newindex = new_idx(del, set),
        }
    )
end

--  ╭────────╮
--  │ Buffer │
--  ╰────────╯
do
    ---@param _ nil
    ---@param var string variable to get
    ---@param bufnr? integer
    ---@return NvimOptRet
    local function get(_, var, bufnr)
        local ok, value = pcall(api.nvim_buf_get_var, bufnr or 0, var)
        return ok and value or nil
    end
    ---@param _ nil
    ---@param var string variable to set
    ---@param val any variable value
    ---@param bufnr? integer
    ---@return NvimOptRet
    local function set(_, var, val, bufnr)
        local ok, value = pcall(api.nvim_buf_set_var, bufnr or 0, var, val)
        return ok and value or nil
    end
    ---@param _ nil
    ---@param var string variable to delete
    ---@param bufnr? integer
    ---@return NvimOptRet
    local function del(_, var, bufnr)
        local ok, value = pcall(api.nvim_buf_del_var, bufnr or 0, var)
        return ok and value or nil
    end

    ---Buffer local variables (`b:var`)
    ---@type Nvim.b
    nvim.b = setmetatable(
        {
            get = D.thunk(get, nil),
            set = D.thunk(set, nil),
            del = D.thunk(del, nil),
        },
        {
            __index = D.thunk(get, nil),
            __newindex = new_idx(del, set),
        }
    )

    ---Access to `api.nvim_buf_.*`
    ---@type Nvim.Buf
    nvim.buf = setmetatable(
        {
            line = api.nvim_get_current_line,
            lines = D.ithunk(api.nvim_buf_line_count, 0),
            nr = api.nvim_get_current_buf,
            set = api.nvim_set_current_buf,
            create = api.nvim_create_buf,
            list = api.nvim_list_bufs,
        },
        {
            __index = function(self, k)
                local mt = getmetatable(self)
                local x = rawget(mt, k)
                if x ~= nil then
                    return x
                end
                local f = api["nvim_buf_" .. k]
                rawset(mt, k, f)
                return f
            end,
            ---Call a function with buf as temporary current buf
            ---Alias `api.nvim_buf_call`
            ---@generic R
            ---@param _ Nvim.Buf
            ---@param func fun(): R
            ---@param bufnr integer current buffer number
            ---@return R?
            __call = function(_, func, bufnr)
                bufnr = F.unwrap_or(bufnr, 0)
                if not vim.is_callable(func) then
                    error("param `func` must be callable")
                end
                return api.nvim_buf_call(bufnr, func)
            end,
        }
    )
end

--  ╭────────╮
--  │ Window │
--  ╰────────╯
do
    ---@param _ nil
    ---@param var string variable to get
    ---@param winnr? integer
    ---@return NvimOptRet
    local function get(_, var, winnr)
        local ok, value = pcall(api.nvim_win_get_var, winnr or 0, var)
        return ok and value or nil
    end
    ---@param _ nil
    ---@param var string variable to set
    ---@param val any variable value
    ---@param winnr? integer
    ---@return NvimOptRet
    local function set(_, var, val, winnr)
        local ok, value = pcall(api.nvim_win_set_var, winnr or 0, var, val)
        return ok and value or nil
    end
    ---@param _ nil
    ---@param var string variable to delete
    ---@param winnr? integer
    ---@return NvimOptRet
    local function del(_, var, winnr)
        local ok, value = pcall(api.nvim_win_del_var, winnr or 0, var)
        return ok and value or nil
    end

    ---Window local variables (`w:var`)
    ---@type Nvim.w
    nvim.w = setmetatable(
        {
            get = D.thunk(get, nil),
            set = D.thunk(set, nil),
            del = D.thunk(del, nil),
        },
        {
            __index = D.thunk(get, nil),
            __newindex = new_idx(del, set),
        }
    )

    ---Access to `api.nvim_win_.*`
    ---@type Nvim.Win
    nvim.win = setmetatable(
        {
            nr = api.nvim_get_current_win,
        },
        {
            __index = function(self, k)
                local mt = getmetatable(self)
                local x = rawget(mt, k)
                if x ~= nil then
                    return x
                end
                local f = api["nvim_win_" .. k]
                rawset(mt, k, f)
                return f
            end,
            ---Calls a function with window as temporary current window
            ---Alias `api.nvim_win_call`
            ---@generic R
            ---@param _ Nvim.w
            ---@param func fun(): R function to call inside the window
            ---@param winnr integer window id
            ---@return R?
            __call = function(_, func, winnr)
                winnr = F.unwrap_or(winnr, 0)
                if not vim.is_callable(func) then
                    error("param `func` must be callable")
                end
                return api.nvim_win_call(winnr, func)
            end,
        }
    )
end

--  ╭─────╮
--  │ Tab │
--  ╰─────╯
do
    ---@param _ nil
    ---@param var string variable to get
    ---@param tabpage? integer
    ---@return NvimOptRet
    local function get(_, var, tabpage)
        local ok, value = pcall(api.nvim_tabpage_get_var, tabpage or 0, var)
        return ok and value or nil
    end
    ---@param _ nil
    ---@param var string variable to set
    ---@param val any variable value
    ---@param tabpage? integer
    ---@return NvimOptRet
    local function set(_, var, val, tabpage)
        local ok, value = pcall(api.nvim_tabpage_set_var, tabpage or 0, var, val)
        return ok and value or nil
    end
    ---@param _ nil
    ---@param var string variable to delete
    ---@param tabpage? integer
    ---@return NvimOptRet
    local function del(_, var, tabpage)
        local ok, value = pcall(api.nvim_tabpage_del_var, tabpage or 0, var)
        return ok and value or nil
    end

    ---Tabpage local variables (`t:var`)
    ---@type Nvim.t
    nvim.t = setmetatable(
        {
            get = D.thunk(get, nil),
            set = D.thunk(set, nil),
            del = D.thunk(del, nil),
        },
        {
            __index = D.thunk(get, nil),
            __newindex = new_idx(del, set),
        }
    )

    ---Access to `api.nvim_tabpage_.*`
    ---@type Nvim.Tab
    nvim.tab = setmetatable(
        {
            nr = api.nvim_get_current_tabpage,
        },
        {
            __index = function(self, k)
                local mt = getmetatable(self)
                local x = rawget(mt, k)
                if x ~= nil then
                    return x
                end
                local f = api["nvim_tabpage_" .. k]
                rawset(mt, k, f)
                return f
            end,
            __call = function(_)
                return api.nvim_get_current_tabpage()
            end,
        }
    )
end

--  ╭─────╮
--  │ Vim │
--  ╰─────╯
do
    ---@param _ nil
    ---@param var string variable to get
    ---@return NvimOptRet
    local function get(_, var)
        local ok, value = pcall(api.nvim_get_vvar, var)
        return ok and value or nil
    end
    ---@param _ nil
    ---@param var string variable to set
    ---@param val any variable value
    ---@return NvimOptRet
    local function set(_, var, val)
        local ok, value = pcall(api.nvim_set_vvar, var, val)
        return ok and value or nil
    end

    ---Global predefined vim variables (`v:var`)
    ---@type Nvim.v
    nvim.v = setmetatable(
        {
            get = D.thunk(get, nil),
            set = D.thunk(set, nil),
        },
        {
            __index = D.thunk(get, nil),
            __newindex = new_idx(get, set),
        }
    )
end

nvim.var = setmetatable(
    {
        g = rawget(nvim, "g"),
        b = rawget(nvim, "b"),
        w = rawget(nvim, "w"),
        t = rawget(nvim, "t"),
        v = rawget(nvim, "v"),
    },
    {
        -- __call = function(self)
        -- end,
    }
)

return M
