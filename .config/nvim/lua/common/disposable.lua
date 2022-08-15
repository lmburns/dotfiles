---@class Disposable
---@field func fun()
local Disposable = {}

---Dispose of all items
---@param disposables Disposable[]
function Disposable.dispose_all(disposables)
    for _, item in ipairs(disposables) do
        item:dispose()
    end
end

---Create a new `Disposable` instance
---@param func fun()
---@param tbl? table items that can be added to the `metatable`
---@return Disposable
function Disposable:new(func, tbl)
    local o = setmetatable(tbl or {}, self)
    self.__index = self
    o.func = func
    return o
end

---Alias for `Disposable:new`
---@param func fun()
---@param tbl? table items that can be added to the `metatable`
---@return Disposable
function Disposable:create(func, tbl)
    return self:new(func, tbl)
end

---Call the function on the disposer
function Disposable:dispose()
    self.func()
end

return Disposable
