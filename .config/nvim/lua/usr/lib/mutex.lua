---@module 'usr.lib.mutex'
---@class MutexL : SemaphoreL
local Mutex = {}

local Semaphore = require('usr.lib.semaphore')

---Create a new Mutex
---@param use_queue? boolean
---@return MutexL
function Mutex:new(use_queue)
    local sem = Semaphore:new(1, use_queue) --[[@as MutexL]]
    sem.__type = "mutex"

    -- FIX: Works with :__tostring() but not tostring()
    -- sem.__tostring = self.__tostring

    return sem
end

return Mutex
