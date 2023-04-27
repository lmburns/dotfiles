---@meta

---@class SaveWinPositionsReturn
---@field restore function

---@alias RenderType
---| "'default'"
---| "'minimal'"
---| "'simple'"
---| "'compact'"

---@class NotifyOpts
---@field icon? string Icon to add to notification
---@field title? string|string[][2] Title to add
---@field timeout? string|boolean Time to show notification. (`false` = disable)
---@field message? string Notification message
---@field level? LogLevels Notification level
---@field once? boolean Only send notification one time
---@field on_open? fun(winnr: number): nil Callback for when window opens
---@field on_close? fun(winnr: number): nil Callback for when window closes
---@field keep? fun(): boolean Keep window open after timeout
---@field render? RenderType|fun(buf: number, notif: notify.Record, hl: notify.Highlights, config) Render a notification buffer
---@field replace? integer|notify.Record Notification record or record `id` field
---@field hide_from_history? boolean Hide this notification from history
---@field animate? boolean If false, window will jump to the timed stage
---@field style? RenderType [Custom]: Alias for render
---@field print boolean [Custom]: Print message instead of notify
---@field hl string [Custom]: Highlight group
---@field debug boolean [Custom]: Display function name and line number
---@field dprint boolean [Custom]: Combination of debug and print
