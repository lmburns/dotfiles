---@module 'usr.lib.semaphore'
---@class SemaphoreL
---@field count number number of Semaphores that can currently be acquired
---@field queue fun()[] queued tasks
---@field protected _allowed number total number of Semaphores that can be acquired
---@field private __use_queue boolean should tasks which occur when the semaphore is busy be scheduled in a queue?
---@field private __id integer the id of the Semaphore
---@field protected __type string
local Semaphore = {}
Semaphore.__index = Semaphore

---@type Promise
local promise = require("promise")
local F = Rc.F

local id = 1

---Create a new Semaphore
---@param count number
---@param use_queue? boolean
---@return SemaphoreL
function Semaphore:new(count, use_queue)
    assert(type(count) == "number" and count > 0, "expected number > 0")
    local o = self == Semaphore and setmetatable({}, self) or self
    o.__id = id
    o.__type = "semaphore"
    o.__use_queue = F.if_nil(use_queue, true)
    o._allowed = count
    o.count = count
    o.queue = {}
    id = id + 1
    return o
end

---@private
---@param force? boolean
function Semaphore:_schedule(force)
    self:release(force)
    self:flush(force)
end

---Execute the first item in the queue (if any)
---Note that the number of locks remains
---@param force? boolean
function Semaphore:flush(force)
    if not force and self:busy() then
        return
    end
    if self:has_tasks() then
        local task = table.remove(self.queue, 1)
        if task then
            task()
        end
    end
end

---Release a lock only if current number of locks is allowed
---@param force? boolean
function Semaphore:release(force)
    if force or self:can_acquire() then
        self:unlock()
    end
end

---Check whether a lock is available to acquire
---@return boolean
function Semaphore:can_acquire()
    return self.count < self._allowed
end

---Check whether the Semaphore has a lock available
---@return boolean
function Semaphore:busy()
    -- Shouldn't go below 0 unless done manually
    return self.count <= 0
end

---Add a lock, subtracting `1` from the available count
function Semaphore:lock()
    self:mod(-1)
end

---Release a lock, adding `1` to the available count
function Semaphore:unlock()
    self:mod(1)
end

---Reset the queue and acquire all locks
function Semaphore:reset()
    self.count = self._allowed
    self.queue = {}
end

--NOTE: Maybe delete
---Acquire all locks and return the number acquired
---@return integer
function Semaphore:drain()
    if not self:busy() then
        local acq = self.count
        self.count = 0
        return acq
    end
    return 0
end

---Return the Semaphore's id
---@return integer
function Semaphore:id()
    return self.__id
end

---Get the number of currently locked locks
---@return number
function Semaphore:locks()
    return self._allowed - self.count
end

---Get the number of available locks
---@return number
function Semaphore:available()
    return self.count
end

---Get the maximum allowed locks
---@return number
function Semaphore:max()
    return self._allowed
end

---Check whether there are tasks in the queue
---@return boolean
function Semaphore:has_tasks()
    return #self.queue > 0
end

---Blocks until a Semaphore can be acquired
---@return Promise
function Semaphore:acquire()
    return promise(function(resolve)
        local function task()
            self:lock()
            local released = false
            local function release_oneshot()
                if released then
                    return
                end
                released = true
                self:_schedule()
            end

            resolve(release_oneshot)
        end

        if not self:busy() then
            task()
        elseif self.__use_queue then
            table.insert(self.queue, task)
        end
    end)
end

---Acquire the Semaphore to execute a function
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

---Set the number of locks held on the Semaphore by modifying the current number of locks
---
---```lua
---  self:mod(1)  -- self.count = self.count + 1
---  self:mod(-1) -- self.count = self.count - 1
---```
---@param count number
function Semaphore:mod(count)
    self.count = self.count + count
end

---Set the number of locks held on the Semaphore
---@param count number
function Semaphore:__set_locks(count)
    self.count = count
end

--NOTE: Maybe delete
---Toggle the state of preserving tasks in a queue
function Semaphore:toggle_use_queue()
    self.__use_queue = not self.__use_queue
end

---Convert a Semaphore to a string
---@return string
function Semaphore:__tostring()
    local state
    if self.__type == "mutex" then
        if self.count <= 0 then
            state = "LOCKED"
        elseif self.count == self._allowed then
            state = "UNLOCKED"
        else
            state = "OVERFLOWED"
        end
        return ("Mutex { <%s> %d/%d }"):format(state, self.count, self._allowed)
    end

    if self.count <= 0 then
        state = "BUSY"
    elseif self.count > 0 and self.count < self._allowed then
        state = "PARTIAL"
    elseif self.count == self._allowed then
        state = "EMPTY"
    else
        state = "OVERFLOWED"
    end
    return ("Semaphore { <%s> %d/%d }"):format(state, self.count, self._allowed)
end

return Semaphore
