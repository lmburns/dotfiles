---@type Promise
local promise = require("promise")

---@class SemaphoreL
---@field new fun(_: SemaphoreL, c: number): SemaphoreL
---@field acquire fun(_: SemaphoreL): Promise
---@field use fun(_: SemaphoreL, f: fun(): Promise): Promise
---@field count number
---@field queue fun()[]
local Semaphore = {}
Semaphore.__index = Semaphore

---
---@param count number
---@return SemaphoreL
function Semaphore:new(count)
    assert(type(count) == "number" and count > 0, "expected number > 0")
    local o = self == Semaphore and setmetatable({}, self) or self
    o.count = count
    o.queue = {}
    return o
end

---Blocks until a Semaphore can be acquired
---@return Promise
function Semaphore:acquire()
    return promise(function(resolve)
        local function task()
            self.count = self.count - 1
            local released = false
            local function release_oneshot()
                if released then
                    return
                end
                released = true
                self.count = self.count + 1
                self:_notify()
            end

            resolve(release_oneshot)
        end

        if self.count > 0 then
            task()
        else
            table.insert(self.queue, task)
        end
    end)
end

---@private
function Semaphore:_notify()
    if self.count > 0 then
        local task = table.remove(self.queue, 1)
        if task then
            task()
        end
    end
end

---
---@param f fun(): Promise
---@return Promise
function Semaphore:use(f)
    return self:acquire():thenCall(function(release)
        return f():thenCall(
            function(res)
                release()
                return res
            end,
            function(reason)
                release()
                return promise.reject(reason)
            end)
    end)
end

return Semaphore
