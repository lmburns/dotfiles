local uv = vim.loop
local Debounce = {}

--- Debounces a function on the trailing edge. Automatically
--- `schedule_wrap()`s.
---
-- @param fn (function) Function to debounce
-- @param timeout (number) Timeout in ms
-- @param first (boolean, optional) Whether to use the arguments of the first
---call to `fn` within the timeframe. Default: Use arguments of the last call.
-- @returns (function, timer) Debounced function and timer. Remember to call
---`timer:close()` at the end or you will leak memory!
function Debounce.trailing(fn, ms, first)
    local timer = uv.new_timer()
    local wrapped_fn

    if not first then
        function wrapped_fn(...)
            local argv = {...}
            local argc = select("#", ...)

            timer:start(
                ms,
                0,
                function()
                    pcall(vim.schedule_wrap(fn), unpack(argv, 1, argc))
                end
            )
        end
    else
        local argv, argc
        function wrapped_fn(...)
            argv = argv or {...}
            argc = argc or select("#", ...)

            timer:start(
                ms,
                0,
                function()
                    pcall(vim.schedule_wrap(fn), unpack(argv, 1, argc))
                end
            )
        end
    end
    return wrapped_fn, timer
end

function Debounce:call()
    local timer = self.timer
    if not timer then
        timer = uv.new_timer()
        self.timer = timer
        local wait = self.wait
        timer:start(
            wait,
            wait,
            function()
                self:flush()
            end
        )
    else
        timer:again()
    end
end

function Debounce:clear()
    local timer = self.timer
    if timer then
        if timer:has_ref() then
            timer:stop()
            if not timer:is_closing() then
                timer:close()
            end
        end
        self.timer = nil
    end
end

function Debounce:flush()
    self:clear()
    self.fn()
end

Debounce.__index = Debounce
Debounce.__call = Debounce.call

return setmetatable(
    {},
    {
        __call = function(_, fn, wait)
            vim.validate({fn = {fn, "function"}, wait = {wait, "number"}})
            local obj = {}
            setmetatable(obj, Debounce)
            obj.timer = nil
            obj.fn = vim.schedule_wrap(fn)
            obj.wait = wait
            return obj
        end
    }
)
