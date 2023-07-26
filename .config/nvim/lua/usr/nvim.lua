---@module 'usr.nvim'
local M = {}

local log = Rc.lib.log
local utils = Rc.shared.utils
local F = Rc.F

local api = vim.api
local fn = vim.fn

---Get an augroup
---@param name_id string|number
---@return Autocmd_t
local function get_augroup(name_id)
    vim.validate({
        name_id = {name_id, {"s", "n"}, "Augroup name string or id number"},
    })
    return Rc.api.get_autocmd({group = name_id})
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
---@param clear? {clear?: bool, del?: bool} Clear or delete group
---@return number
local function add_augroup(name, clear)
    vim.validate({
        name = {name, "string"},
        clear = {clear, "boolean", true},
    })

    local groups = get_augroup(name)
    if #groups == 0 or clear then
        return Rc.api.create_augroup(name, clear)
    end
    return groups[1].group
end

---Clear an `augroup`
---@param name string
local function clear_augroup(name)
    vim.validate {name = {name, "string"}}
    Rc.api.create_augroup(name, {clear = true})
end

---Access to plugins
---@class Nvim.Plugins: PackerPlugins
---@operator call(): PackerPlugins
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
---@type Termcodes
nvim.termcodes = utils.termcodes

---Use `nvim.command[...]` or `nvim.command.get()` to list all
---@class Nvim.Command
---@field [string] table?
nvim.command = setmetatable(
    {
        set = Rc.api.command,
        del = Rc.api.del_command,
        ---
        ---@param k string
        ---@return Command_t
        get = function(k)
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

---@class Nvim.Keymap
---@field n Keymap_t[] normal mode
---@field i Keymap_t[] insert mode
---@field v Keymap_t[] visual mode
---@field o Keymap_t[] operator pending mode
---@field s Keymap_t[] select mode
---@field x Keymap_t[] visual and select mode
---@field t Keymap_t[] terminal mode
---@field c Keymap_t[] command mode
---@field __call fun(self: Nvim.Keymap, modes: Keymap.mode|Keymap.mode[], lhs: string|string[], rhs: string|fun(), opts?: Keymap.Builder): Keymap.Disposable?
---@operator call:Keymap.Disposable?
nvim.keymap = setmetatable(
    {
        add = Rc.api.map,
        get = Rc.api.get_keymap,
        del = Rc.api.del_keymap,
    },
    {
        __index = function(self, mode)
            vim.validate {mode = {mode, "s"}}
            local modes = _t({"n", "i", "v", "o", "s", "x", "t", "c"})

            if not modes:contains(mode) then
                error(("'%s' is an invalid mode"):format(F.if_nil(mode, "")))
            end
            return self.get(mode)
        end,
        ---
        ---@param self Nvim.Keymap
        ---@param modes Keymap.mode|Keymap.mode[] modes the keymapping should be bound
        ---@param lhs string|string[]  key(s) that are mapped
        ---@param rhs string|fun(): string? string or Lua function that will be bound
        ---@param opts? Keymap.Builder options given to keybindings
        ---@return Keymap.Disposable?: table with a two keys `dispose` & `map`
        __call = function(self, modes, lhs, rhs, opts)
            return self.add(modes, lhs, rhs, opts)
        end,
    }
)

-- These are all still accessible as something like nvim.buf_get_current_commands(...)

---Access to `api.nvim_ui_.*`
---@class Nvim.Ui : vim.api
---@field [string] fun(...)
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
---@class Nvim.Augroup
---@field [string] Autocmd_t
nvim.augroup = setmetatable(
    {
        add = add_augroup,
        del = Rc.api.del_augroup,
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
                            Rc.api.augroup(group, aucmd)
                        else
                            Rc.api.autocmd(aucmd)
                        end
                    end
                end
            end
        end,
    }
)

---Modify `autocmd`s
---@class Nvim.Autocmd
---@field [string] Autocmd.Builder[]|Autocmd.Builder
nvim.autocmd = setmetatable(
    {
        add = Rc.api.autocmd,
        get = Rc.api.get_autocmd,
        del = Rc.api.del_autocmd,
        clear = Rc.api.clear_autocmd,
        doa = Rc.api.doautocmd,
        noa = Rc.api.noautocmd,
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
                local autocmds = F.ifis_list(v, vim.deepcopy(v), {v})
                Rc.api.augroup(k, unpack(autocmds))
            end
        end,
    }
)

---Access highlight groups
---@class Nvim.Colors: table
---@field [string] CallableTable
---@operator call:table
nvim.colors = setmetatable({}, {
    __index = function(_, k)
        return require("usr.shared.color")[k]
    end,
    __newindex = function(_, hlgroup, opts)
        require("usr.shared.color")[hlgroup] = opts
    end,
    __call = function(_, k)
        return require("usr.shared.color")(k)
    end,
})

do
    ---@alias Nvim.Reg.str string

    ---@param _ Nvim.Reg
    ---@param reg string register to get
    ---@return Nvim.Reg.str?
    local function get(_, reg)
        local ok, value = pcall(fn.getreg, reg)
        return ok and value or nil
    end

    ---@param _ Nvim.Reg
    ---@param reg string register to set
    ---@param val? string value to set
    ---@param opts? SetRegOpts[]|string register type
    local function set(_, reg, val, opts)
        if val == nil then
            val = ""
        end
        if type(val) == "table" then
            val, opts = unpack(val)
        end
        if type(opts) == "table" then
            opts = _j(opts):concat("")
        end
        pcall(fn.setreg, reg, val, opts)
    end

    ---Access to registers
    ---@class Nvim.Reg
    ---@field [string] string
    nvim.reg = setmetatable(
        {
            ---Get register.
            ---@type fun(reg: string): Nvim.Reg.str?
            get = F.thunk(get, {}),
            ---Set register.
            ---Uppercase letter appends to register.
            ---@type fun(reg: string, val: string, opts: table)
            set = F.thunk(set, {}),
        },
        {
            __index = F.thunk(get),
            __newindex = F.thunk(set),
        }
    )
end

do
    ---@param _ self
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
    ---@param _ self
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
    ---@class Nvim.Mark
    ---@field [string] Nvim.Mark?
    nvim.mark = setmetatable(
        {
            get = F.thunk(get, {}),
            set = F.thunk(set, {}),
        },
        {
            __index = F.thunk(get),
            __newindex = F.thunk(set),
        }
    )
end

--  ╭──────────────────────────────────────────────────────────╮
--  │                        Utiltities                        │
--  ╰──────────────────────────────────────────────────────────╯

---@class Nvim.Exists
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
---@operator call:boolean
nvim.has = setmetatable(exists_tbl, {
    __call = function(_, feature)
        return fn.has(feature) > 0
    end,
})

---Shortcut for `fn.exists()`
---@type Nvim.Exists
---@operator call:boolean
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
---@class Nvim.p
---@field [string] CallableTable
---@operator call:nil
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
---@class Nvim.Env : vim.env
---@field [string] string|number
nvim.env = setmetatable({}, {
    __index = function(_, k)
        local ok, value = pcall(fn.getenv, k)
        if not ok or value == vim.NIL then
            value = fn.expand("$" .. k)
            value = value == k and nil or value
        end
        if not value then
            value = os.getenv(k)
        end
        return value or nil
    end,
    __newindex = function(_, k, v)
        local ok, _ = pcall(fn.setenv, k, v)
        if not ok then
            v = F.ifis_str(v, ('"%s"'):format(v), v)
            local _ = api.nvim_eval(("let $%s = %s"):format(k, v))
        end
    end,
})

---@param del fun(var: string)
---@param set fun(var: string, val: any)
---@return fun(_this: self, idx: string, newidx: any)
local function new_idx(del, set)
    return F.partial(function(_this, idx, newidx)
        if newidx == nil then
            del(idx)
        else
            set(idx, newidx)
        end
    end)
end

--  ╭────────╮
--  │ Global │
--  ╰────────╯
do
    ---@param _ Nvim.g
    ---@param var string variable to get
    ---@return NvimOptRet
    local function get(_, var)
        local ok, value = pcall(api.nvim_get_var, var)
        return ok and value or nil
    end
    ---@param _ Nvim.g
    ---@param var string variable to set
    ---@param val any variable value
    ---@return NvimOptRet
    local function set(_, var, val)
        local ok, value = pcall(api.nvim_set_var, var, val)
        return ok and value or nil
    end
    ---@param _ Nvim.g
    ---@param var string variable to delete
    ---@return NvimOptRet
    local function del(_, var)
        local ok, value = pcall(api.nvim_del_var, var)
        return ok and value or nil
    end

    ---Global variables (`g:var`)
    ---@class Nvim.g : vim.g
    ---@field [string] any
    nvim.g = setmetatable(
        {
            ---@type fun(var: string): NvimOptRet
            get = F.thunk(get, {}),
            ---@type fun(var: string, val: any): NvimOptRet
            set = F.thunk(set, {}),
            ---@type fun(var: string): NvimOptRet
            del = F.thunk(del, {}),
        },
        {
            __index = F.thunk(get),
            __newindex = new_idx(del, set),
        }
    )
end

--  ╭────────╮
--  │ Buffer │
--  ╰────────╯
do
    ---@param _ Nvim.b
    ---@param var string variable to get
    ---@param bufnr? bufnr
    ---@return NvimOptRet
    local function get(_, var, bufnr)
        local ok, value = pcall(api.nvim_buf_get_var, bufnr or 0, var)
        return ok and value or nil
    end
    ---@param _ Nvim.b
    ---@param var string variable to set
    ---@param val any variable value
    ---@param bufnr? bufnr
    ---@return NvimOptRet
    local function set(_, var, val, bufnr)
        local ok, value = pcall(api.nvim_buf_set_var, bufnr or 0, var, val)
        return ok and value or nil
    end
    ---@param _ Nvim.b
    ---@param var string variable to delete
    ---@param bufnr? bufnr
    ---@return NvimOptRet
    local function del(_, var, bufnr)
        local ok, value = pcall(api.nvim_buf_del_var, bufnr or 0, var)
        return ok and value or nil
    end

    ---Buffer local variables (`b:var`)
    ---@class Nvim.b : vim.b
    ---@field [string] any
    nvim.b = setmetatable(
        {
            ---@type fun(var: string, bufnr?: integer): NvimOptRet
            get = F.thunk(get, {}),
            ---@type fun(var: string, val: any, bufnr?: integer): NvimOptRet
            set = F.thunk(set, {}),
            ---@type fun(var: string, bufnr?: integer): NvimOptRet
            del = F.thunk(del, {}),
        },
        {
            __index = F.thunk(get),
            __newindex = new_idx(del, set),
        }
    )

    local buf_errmsg = "failed to %s option '%s' for bufnr '%d'. %s"
    local function buf_validate(typ, opt, bufnr)
        local ok, valid = pcall(Rc.api.opt.validate, opt, "buf")
        if not ok then
            local buf = bufnr == 0 and api.nvim_get_current_buf() or bufnr
            log.err(buf_errmsg:format(typ, opt, buf, "\n- " .. valid))
            return false
        end
        return true
    end

    local function buf_wrap(typ, func, opt, bufnr, ...)
        if not buf_validate(typ, opt, bufnr) then
            return
        end
        local args = {...}
        local ok, value
        local a = {typ, func, opt, bufnr, ...}
        N(a)
        if #args then
            ok, value = pcall(func, opt, unpack(args), {buf = bufnr})
        else
            ok, value = pcall(func, opt, {buf = bufnr})
        end
        if not ok then
            log.err(buf_errmsg:format(typ, opt, bufnr, F.unwrap_or("\n- " .. value, "")))
            return
        end
        return value
    end

    -- TODO: Finish last

    ---@param _ Nvim.bo
    ---@param opt string opt to get
    ---@param bufnr? bufnr
    ---@return GetOptionInfo_t
    local function optinfo_get(_, opt, bufnr)
        local value = buf_wrap("get", Rc.api.opt.get_info, opt, bufnr or 0)
        if value == nil then
            return {}
        end
        return value
    end

    ---@param _ Nvim.bo
    ---@param opt string opt to get
    ---@param bufnr? bufnr
    ---@return Option_t?
    local function opt_get(_, opt, bufnr)
        return buf_wrap("get", api.nvim_get_option_value, opt, bufnr or 0)
    end

    ---@param _ Nvim.bo
    ---@param opt string opt to set
    ---@param val any option value
    ---@param bufnr? bufnr
    ---@return Option_t?
    local function opt_set(_, opt, val, bufnr)
        return buf_wrap("set", api.nvim_set_option_value, opt, bufnr or 0, val)
    end

    ---@param _ Nvim.bo
    ---@param opt string opt to toggle
    ---@param val? Option_t[]? possible option values
    ---@param bufnr? bufnr
    ---@return Option_t?
    local function opt_toggle(_, opt, val, bufnr)
        return buf_wrap("toggle", Rc.api.opt.toggle_option, opt, bufnr or 0, val)
    end

    ---Access to `api.nvim_buf_.*`
    ---@class Nvim.bo : vim.bo
    ---@field [string] fun(...): any
    ---@operator call(...): any?
    nvim.bo = setmetatable(
        {
            ---@type fun(opt: string, bufnr?: bufnr): GetOptionInfo_t?
            iget = F.thunk(optinfo_get, {}),
            ---@type fun(opt: string, bufnr?: bufnr): NvimOptRet
            get = F.thunk(opt_get, {}),
            ---@type fun(opt: string, val: any, bufnr?: bufnr): NvimOptRet
            set = F.thunk(opt_set, {}),
            ---@type fun(opt: string, vals: Option_t[]?, bufnr?: bufnr): NvimOptRet
            toggle = F.thunk(opt_toggle, {}),
        },
        {
            __index = F.thunk(opt_get),
            __newindex = F.thunk(opt_set),
        }
    )

    ---Access to `api.nvim_buf_.*`
    ---@class Nvim.Buf : vim.api
    ---@field [string] fun(...): any
    ---@operator call(...): any?
    nvim.buf = setmetatable(
        {
            line = api.nvim_get_current_line,
            lines = F.ithunk(api.nvim_buf_line_count, 0),
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
    ---@param _ Nvim.w
    ---@param var string variable to get
    ---@param winnr? winnr
    ---@return NvimOptRet
    local function get(_, var, winnr)
        local ok, value = pcall(api.nvim_win_get_var, winnr or 0, var)
        return ok and value or nil
    end
    ---@param _ Nvim.w
    ---@param var string variable to set
    ---@param val any variable value
    ---@param winnr? winnr
    ---@return NvimOptRet
    local function set(_, var, val, winnr)
        local ok, value = pcall(api.nvim_win_set_var, winnr or 0, var, val)
        return ok and value or nil
    end
    ---@param _ Nvim.w
    ---@param var string variable to delete
    ---@param winnr? winnr
    ---@return NvimOptRet
    local function del(_, var, winnr)
        local ok, value = pcall(api.nvim_win_del_var, winnr or 0, var)
        return ok and value or nil
    end

    ---Window local variables (`w:var`)
    ---@class Nvim.w : vim.w
    ---@field [string] any
    nvim.w = setmetatable(
        {
            ---@type fun(var: string, winnr?: winnr): NvimOptRet
            get = F.thunk(get, {}),
            ---@type fun(var: string, val: any, winnr?: winnr): NvimOptRet
            set = F.thunk(set, {}),
            ---@type fun(var: string, winnr?: winnr): NvimOptRet
            del = F.thunk(del, {}),
        },
        {
            __index = F.thunk(get),
            __newindex = new_idx(del, set),
        }
    )

    ---Access to `api.nvim_win_.*`
    ---@class Nvim.Win : vim.api
    ---@field [string] fun(...): any
    ---@operator call(...): any?
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
    ---@param _ Nvim.t
    ---@param var string variable to get
    ---@param tabpage? tabnr
    ---@return NvimOptRet
    local function get(_, var, tabpage)
        local ok, value = pcall(api.nvim_tabpage_get_var, tabpage or 0, var)
        return ok and value or nil
    end
    ---@param _ Nvim.t
    ---@param var string variable to set
    ---@param val any variable value
    ---@param tabpage? tabnr
    ---@return NvimOptRet
    local function set(_, var, val, tabpage)
        local ok, value = pcall(api.nvim_tabpage_set_var, tabpage or 0, var, val)
        return ok and value or nil
    end
    ---@param _ Nvim.t
    ---@param var string variable to delete
    ---@param tabpage? tabnr
    ---@return NvimOptRet
    local function del(_, var, tabpage)
        local ok, value = pcall(api.nvim_tabpage_del_var, tabpage or 0, var)
        return ok and value or nil
    end

    ---Tabpage local variables (`t:var`)
    ---@class Nvim.t : vim.t
    ---@field [string] any
    nvim.t = setmetatable(
        {
            ---@type fun(var: string, tabpage?: tabnr): NvimOptRet
            get = F.thunk(get, {}),
            ---@type fun(var: string, val: any, tabpage?: tabnr): NvimOptRet
            set = F.thunk(set, {}),
            ---@type fun(var: string, tabpage?: tabnr): NvimOptRet
            del = F.thunk(del, {}),
        },
        {
            __index = F.thunk(get),
            __newindex = new_idx(del, set),
        }
    )

    ---Access to `api.nvim_tabpage_.*`
    ---@class Nvim.Tab : vim.api
    ---@field [string] fun(...): any
    ---@operator call(...): any?
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
    ---@param _ Nvim.v
    ---@param var string variable to get
    ---@return NvimOptRet
    local function get(_, var)
        local ok, value = pcall(api.nvim_get_vvar, var)
        return ok and value or nil
    end
    ---@param _ Nvim.v
    ---@param var string variable to set
    ---@param val any variable value
    ---@return NvimOptRet
    local function set(_, var, val)
        local ok, value = pcall(api.nvim_set_vvar, var, val)
        return ok and value or nil
    end

    ---Global predefined vim variables (`v:var`)
    ---@class Nvim.v : vim.v
    ---@field [string] any
    nvim.v = setmetatable(
        {
            ---@type fun(var: string): NvimOptRet
            get = F.thunk(get, {}),
            ---@type fun(var: string, val: any): NvimOptRet
            set = F.thunk(set, {}),
        },
        {
            __index = F.thunk(get),
            __newindex = new_idx(get, set),
        }
    )
end

---@class Nvim.Var
---@field g Nvim.g
---@field b Nvim.b
---@field w Nvim.w
---@field t Nvim.t
---@field v Nvim.v
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
