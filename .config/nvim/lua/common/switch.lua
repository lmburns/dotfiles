--- ## Usage
---
---<code>
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
---</code>
---
---Credit: kitsunies/switch.lua
local switch = {}

switch.__index = switch

switch.__call = function(self, v)
    local c = self._callbacks[v] or self._default
    assert(c, "No case statement defined for variable, and :default is not defined")
    c()
end

function switch:case(v, f)
    self._callbacks[v] = f
    return self
end

function switch:default(f)
    self._default = f
    return self
end

return function()
    return setmetatable({_callbacks = {}}, switch)
end
