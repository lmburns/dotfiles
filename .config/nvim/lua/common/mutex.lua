local Semaphore = require('common.semaphore')

---@class MutexL: SemaphoreL
---@field new fun(_: MutexL): MutexL
local Mutex = {}

---Create a new Mutex
---@return MutexL
function Mutex:new()
    return Semaphore:new(1)
end

return Mutex
