local M = {}

local utils = require("common.utils")
local color = require("common.color")

---Get an autocmd
---@param opts table
---@return table
local function get_autocmd(opts)
    vim.validate {
        opts = {opts, "table", true}
    }
    opts = opts or {}

    local ok, autocmds = pcall(api.nvim_get_autocmds, opts)
    if not ok then
        autocmds = {}
    end
    return autocmds
end

---Get an augroup
---@param name_id string|number
---@return table
local function get_augroup(name_id)
    vim.validate {
        name_id = {
            name_id,
            {"s", "n"},
            "Augroup name string or id number"
        }
    }
    return get_autocmd {group = name_id}
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
    vim.validate {
        name = {name, "string"},
        clear = {clear, "boolean", true}
    }

    local groups = get_augroup(name)
    if #groups == 0 or clear then
        return api.nvim_create_augroup(name, {clear = clear == true})
    end
    return groups[1].group
end

---Clear an augroup
---@param name string
local function clear_augroup(name)
    vim.validate {
        name = {name, "string"}
    }
    api.nvim_create_augroup(name, {clear = true})
end

---Delete an augroup
---@param name_id string|number
local function del_augroup(name_id)
    vim.validate {
        name_id = {
            name_id,
            {"s", "n"},
            "Augroup name string or id number"
        }
    }

    local api_call = type(name_id) == "string" and api.nvim_del_augroup_by_name or api.nvim_del_augroup_by_id
    pcall(api_call, name_id)
end

-- Mike325/nvim
nvim.plugins =
    setmetatable(
    {},
    {
        __index = function(self, k)
            local mt = getmetatable(self)
            local x = mt[k]

            if x ~= nil then
                return x
            end

            local ok, plugs = pcall(api.nvim_get_var, "plugs")
            if plugs[k] then
                mt[k] = plugs[k]
                return plugs[k]
            end

            if not ok and _G.packer_plugins then
                plugs = _G.packer_plugins
                if plugs[k] and plugs[k].loaded then
                    return plugs[k]
                else
                    -- [...]
                    return _G.packer_plugins
                end
            end

            return nil
        end
    }
)

nvim.has =
    setmetatable(
    {
        cmd = function(cmd)
            return api.nvim_call_function("exists", {":" .. cmd}) == 2
        end,
        event = function(command)
            return api.nvim_call_function("exists", {"##" .. command}) == 2
        end,
        augroup = function(augroup)
            return api.nvim_call_function("exists", {"#" .. augroup}) == 1
        end,
        option = function(option)
            return api.nvim_call_function("exists", {"+" .. option}) == 1
        end,
        func = function(func)
            return api.nvim_call_function("exists", {"*" .. func}) == 1
        end
    },
    {
        __call = function(_, feature)
            return api.nvim_call_function("has", {feature}) == 1
        end
    }
)

nvim.exists =
    setmetatable(
    {
        cmd = function(cmd)
            return api.nvim_call_function("exists", {":" .. cmd}) == 2
        end,
        event = function(command)
            return api.nvim_call_function("exists", {"##" .. command}) == 2
        end,
        augroup = function(augroup)
            return api.nvim_call_function("exists", {"#" .. augroup}) == 1
        end,
        option = function(option)
            return api.nvim_call_function("exists", {"+" .. option}) == 1
        end,
        func = function(func)
            return api.nvim_call_function("exists", {"*" .. func}) == 1
        end
    },
    {
        __call = function(_, feature)
            return api.nvim_call_function("exists", {feature}) == 1
        end
    }
)

---Has access to `line` and `nr`
nvim.buffer = nvim.buf
nvim.cmd = nvim.command

-- These are all still accessible as something like nvim.buf_get_current_commands(...)

nvim.buf =
    setmetatable(
    {
        nr = nvim.buffer.nr,
        line = nvim.buffer.line
    },
    {
        __index = function(self, k)
            local mt = getmetatable(self)
            local x = mt[k]
            if x ~= nil then
                return x
            end
            local f = api["nvim_buf_" .. k]
            mt[k] = f
            return f
        end
    }
)

nvim.win =
    setmetatable(
    {},
    {
        __index = function(self, k)
            local mt = getmetatable(self)
            local x = mt[k]
            if x ~= nil then
                return x
            end
            local f = api["nvim_win_" .. k]
            mt[k] = f
            return f
        end
    }
)

nvim.tab =
    setmetatable(
    {},
    {
        __index = function(self, k)
            local mt = getmetatable(self)
            local x = mt[k]
            if x ~= nil then
                return x
            end
            local f = api["nvim_tabpage_" .. k]
            mt[k] = f
            return f
        end
    }
)

nvim.ui =
    setmetatable(
    {},
    {
        __index = function(self, k)
            local mt = getmetatable(self)
            local x = mt[k]
            if x ~= nil then
                return x
            end
            local f = api["nvim_ui_" .. k]
            mt[k] = f
            return f
        end
    }
)

nvim.reg =
    setmetatable(
    {},
    {
        __index = function(_, k)
            local ok, value = pcall(api.nvim_call_function, "getreg", {k})
            return ok and value or nil
        end,
        __newindex = function(_, k, v)
            if v == nil then
                error("Can't clear registers")
            end
            pcall(api.nvim_call_function, "setreg", {k, v})
        end
    }
)

---Use nvim.command[...] to list all
nvim.command =
    setmetatable(
    {
        set = utils.command,
        del = utils.del_command
    },
    {
        __index = function(self, k)
            local mt = getmetatable(self)
            local x = mt[k]
            if x ~= nil then
                return x
            end

            local cmds = api.nvim_get_commands({})
            return k and cmds[k] or cmds
        end
    }
)

-- Allow this to be callable without explicitly calling `.add`
nvim.keymap =
    setmetatable(
    {
        add = utils.map,
        get = api.nvim_get_keymap,
        del = vim.keymap.del
    },
    {
        __index = function(self, mode)
            vim.validate {
                mode = {mode, "s"}
            }

            local modes =
                _t(
                {
                    "n",
                    "i",
                    "v",
                    "o",
                    "s",
                    "x",
                    "t",
                    "c"
                }
            )

            if not modes:contains(mode) then
                error("Invalid mode")
            end
            return self.get(mode)
        end,
        __call = function(self, bufnr, modes, lhs, rhs, opts)
            self.add(bufnr, modes, lhs, rhs, opts)
        end
    }
)

nvim.augroup =
    setmetatable(
    {
        add = add_augroup,
        del = del_augroup,
        get = get_augroup,
        get_id = get_augroup_id,
        clear = clear_augroup
    },
    {
        __index = function(self, k)
            local mt = getmetatable(self)
            local x = mt[k]
            if x ~= nil then
                return x
            end
            local cmds = get_augroup(k)
            return #cmds > 0 and cmds or nil
        end,
        __newindex = function(_, k, v)
            if type(k) == type "" and k ~= "" then
                if v == nil then
                    del_augroup(k)
                elseif type(v) == type {} then
                    local autocmds
                    if vim.tbl_islist(v) then
                        autocmds = vim.deepcopy(v)
                    else
                        autocmds = {v}
                    end

                    for _, aucmd in ipairs(autocmds) do
                        if aucmd.group then
                            local group = aucmd.group
                            aucmd.group = nil
                            utils.augroup(group, aucmd)
                        else
                            utils.autocmd(aucmd)
                        end
                    end
                end
            end
        end
    }
)

nvim.autocmd =
    setmetatable(
    {
        add = utils.autocmd,
        get = get_autocmd,
        del = function(id)
            vim.validate {
                id = {id, "number"}
            }
            pcall(api.nvim_del_autocmd, id)
        end
    },
    -- Can do nvim.autocmd["User"] to list User autocmds
    {
        __index = function(self, k)
            local mt = getmetatable(self)
            local x = mt[k]
            if x ~= nil then
                return x
            end
            local cmds = get_autocmd {event = k}
            return #cmds > 0 and cmds or nil
        end,
        __newindex = function(_, k, v)
            if type(k) == "string" and k ~= "" and type(v) == "table" then
                local autocmds = F.tern(vim.tbl_islist(v), vim.deepcopy(v), {v})
                utils.augroup(k, unpack(autocmds))
            end
        end
    }
)

nvim.executable = function(exec)
    return utils.executable(exec)
end

nvim.colors =
    setmetatable(
    {},
    {
        __index = function(_, k)
            color.colors(k)
        end
    }
)

return M
