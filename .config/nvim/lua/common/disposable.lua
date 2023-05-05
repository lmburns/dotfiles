---@class Disposable
---@field fn fun()
local Disposable = {}

---Create a new `Disposable` instance
---@generic T: table
---@param fn fun()
---@param tbl? T items that are added to the `metatable`
---@return Disposable|T
function Disposable:new(fn, tbl)
    local o = setmetatable(tbl or {}, self)
    self.__index = self
    o.fn = fn
    return o
end

---Alias for `Disposable:new`
---@generic T: table
---@param fn fun()
---@param tbl? T items that are added to the `metatable`
---@return Disposable|T
function Disposable:create(fn, tbl)
    return self:new(fn, tbl)
end

---Call the function on the disposer
function Disposable:dispose()
    self.fn()
end

---Dispose of all items
---@param disposables Disposable[]
function Disposable.dispose_all(disposables)
    for _, item in ipairs(disposables) do
        item:dispose()
    end
end

return Disposable
