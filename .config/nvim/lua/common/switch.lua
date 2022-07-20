--- ## Usage
---
---```
---local numbercase = switch()
---    :case(10, function()
---        print("Hello Ten")
---    end)
--
---    :case(20, function()
---        print("Hello Twenty")
---    end)
--
---    :default(function()
---        print("Unrecognized")
---    end)
--
---numbercase(15 + 5)
---```
---
-- local switch = {}
--
-- switch.__index = switch
--
-- switch.__call = function(self, v)
--     local c = self._callbacks[v] or self._default
--     assert(c, "No case statement defined for variable, and :default is not defined")
--     c()
-- end
--
-- function switch:case(v, f)
--     self._callbacks[v] = f
--     return self
-- end
--
-- function switch:default(f)
--     self._default = f
--     return self
-- end
--
-- return function()
--     return setmetatable({_callbacks = {}}, switch)
-- end

-- ╭──────────────────────────────────────────────────────────╮
-- │                          Switch                          │
-- ╰──────────────────────────────────────────────────────────╯

---# Usage
---
---```lua
--- local s = switch()
---  :case('matchAgainst')
---  :call(function(val) print(('matched: %s'):format(val)) end)
---  :default(function(val) print(('no match: %s'):format(val)) end)
---```
---@class Switch
---@field cachedCases string[]
---@field map table<string, function>
---@field _default fun(...):...
local Switch = {}
Switch.__index = Switch

---@param name string
---@return Switch
function Switch:case(name)
    self.cachedCases[#self.cachedCases + 1] = name
    return self
end

---@param callback async fun(...):...
---@return Switch
function Switch:call(callback)
    for i = 1, #self.cachedCases do
        local name = self.cachedCases[i]
        self.cachedCases[i] = nil
        if self.map[name] then
            error("Repeated fields:" .. tostring(name))
        end
        self.map[name] = callback
    end
    return self
end

---@param callback fun(...):...
---@return Switch
function Switch:default(callback)
    self._default = callback
    return self
end

function Switch:getMap()
    return self.map
end

---@param name string
---@return boolean
function Switch:has(name)
    return self.map[name] ~= nil
end

---@param name string
---@return ...
function Switch:__call(name, ...)
    local callback = self.map[name] or self._default
    if not callback then
        return
    end
    return callback(...)
end

---@return Switch
return function()
    return setmetatable(
        {
            map = {},
            cachedCases = {}
        },
        Switch
    )
end
