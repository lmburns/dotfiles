---@module 'usr.lib.event'
---Wrapper around autocmds
---```lua
--- [{ "InsertEnter", "Custom" }] = { <function 2> },
---
--- -- These are equivalent indexes
--- InsertEnter = { <function 1> },
--- [{ "InsertEnter" }] = { <function 1> },
---```
---@class Event
local Event      = {
    _collection = {},
}

local disposable = Rc.lib.disposable
local log        = Rc.lib.log
local logger     = log.file_config("event")

setmetatable(Event._collection, {
    __index = function(self, k)
        if type(k) == "table" then
            local ev, scope = unpack(k)
            if scope then
                local scope_tbl = rawget(self, scope)
                if scope_tbl then
                    return rawget(scope_tbl, ev)
                end
                return scope_tbl
            end
            return rawget(self, ev)
        end
        return rawget(self, k)
    end,
})

---@param name Nvim.Event|{[1]: Nvim.Event, [2]: string}
---@param listener function
function Event:off(name, listener)
    local listeners = self._collection[name]
    if not listeners then
        return
    end

    for i = 1, #listeners do
        if listeners[i] == listener then
            table.remove(listeners, i)
            break
        end
    end
    if #listeners == 0 then
        self._collection[name] = nil
    end
end

---Subscribe to a given event
---@param name Nvim.Event|{[1]: Nvim.Event, [2]: string}
---@param listener fun(...)
---@param disposables? Disposable[]
---@return Disposable
function Event:on(name, listener, disposables)
    if not self._collection[name] then
        self._collection[name] = {}
    end

    table.insert(self._collection[name], listener)
    local d = disposable:create(function()
        self:off(name, listener)
    end)
    if type(disposables) == "table" then
        table.insert(disposables, d)
    end
    return d
end

---@param name Nvim.Event|{[1]: Nvim.Event, [2]: string}
---@param ... any
function Event:emit(name, ...)
    local listeners = self._collection[name]
    -- N({"event:", name, "listeners:", listeners or {}, "args:", ...})
    if not listeners then
        return
    end
    logger.trace("event:", name, "listeners:", listeners, "args:", ...)
    for _, listener in ipairs(listeners) do
        listener(...)
    end
end

return Event
