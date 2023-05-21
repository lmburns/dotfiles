local Semaphore = require('common.semaphore')

---@class MutexL : SemaphoreL
local Mutex = {}
-- Mutex.__index = Mutex

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

-- ---Convert a Mutex to a string
-- ---@return string
-- function Mutex:__tostring()
--     local state
--     if self.count <= 0 then
--         state = "LOCKED"
--     elseif self.count == self._allowed then
--         state = "UNLOCKED"
--     else
--         state = "OVERFLOWED"
--     end
--     return ("Mutex { <%s> %d/%d }"):format(state, self.count, self._allowed)
-- end

return Mutex
