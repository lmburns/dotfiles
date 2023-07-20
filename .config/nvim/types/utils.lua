---@meta
---@description Types for some of my utility/lib functions

---@alias Render_t
---| "'default'"
---| "'minimal'"
---| "'simple'"
---| "'compact'"

---@class Notify.Opts : notify.Options
---@field icon? string Icon to add to notification
---@field title? string|{[1]: string, [2]: string} Title to add
---@field timeout? string|bool Time to show notification. (`false` = disable)
---@field message? string Notification message
---@field level? Log.Level Notification level
---@field once? bool Only send notification one time
---@field on_open? fun(winnr: winid) Callback for when window opens
---@field on_close? fun(winnr: winid) Callback for when window closes
---@field keep? fun(): bool Keep window open after timeout
---@field render? Render_t|fun(buf: number, notif: notify.Record, hl: notify.Highlights, config) Render a notification buffer
---@field replace? integer|notify.Record Notification record or record `id` field
---@field hide_from_history? bool Hide this notification from history
---@field animate? bool If false, window will jump to the timed stage
---@field style? Render_t [Custom]: Alias for render
---@field debug bool [Custom]: Display function name and line number
---@field dprint bool [Custom]: Combination of debug and print
---@field print bool [Custom]: Print message instead of notify
---@field expand bool [Custom]: Should text be expanded?
---@field syntax string|bool [Custom]: Syntax to set the notification to
---@field hl string [Custom]: Highlight group (used for printing)

---@alias MarkPos {row: integer, col: integer}
---@alias MarkPosTable {start: MarkPos, finish: MarkPos}

---@class Usr.Operator.Opts
---@field cb string operator function as a string (no need for `v:lua`)
---@field motion string motion to feed to operator
---@field reg string register to use
---@field count integer count to use (default: vim.v.count or 1)

---@class Utils.Input.Spec
---@field default string
---@field completion string|function
---@field cancelreturn string
---@field callback fun(response: string?)

---@class Utils.InputChar.Spec
---@field clear_prompt boolean (default: true)
---@field allow_non_ascii boolean (default: false)
---@field filter string A lua pattern that the input must match in order to be valid. (default: nil)
---@field loop boolean Loop the input prompt until a valid char is given. (default: false)
---@field prompt_hl string Prompt highlight group

---@class Utils.Confirm.Opts
---@field default boolean
---@field callback fun(choice: boolean)
---@field prompt_hl string (default: nil)

---@class Utils.StrQuote.Spec
---@field esc_fmt string Format string for escaping quotes. Passed to `string.format()`.
---@field prefer_single boolean Prefer single quotes.
---@field only_if_whitespace boolean Only quote the string if it contains whitespace.
