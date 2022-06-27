local M = {}

-- ╭──────────────────────────────────────────────────────────╮
-- │                      Notifications                       │
-- ╰──────────────────────────────────────────────────────────╯
-- https://github.com/rcarriga/nvim-notify/wiki/Usage-Recipes
local status_record = {}
local diag_record = {}

---Use nvim-notify to send an alert for Coc
---@param msg string
---@param level string
function M.coc_status_notify(msg, level)
    local notify_opts = {
        title = "LSP Status",
        timeout = 500,
        hide_from_history = true,
        on_close = M.reset_status_record
    }
    -- if status_record is not {} then add it to notify_opts to key called "replace"
    if status_record ~= {} then
        notify_opts["replace"] = status_record.id
    end
    status_record = vim.notify(msg, level, notify_opts)
end

---Reset the status record
---@param window number
function M.reset_status_record(window)
    status_record = {}
end

---Set a notification to be sent for CocDiagnostics
---@param msg string
---@param level string
function coc_diag_notify(msg, level)
    local notify_opts = {title = "LSP Diagnostics", timeout = 500, on_close = reset_diag_record}
    -- if diag_record is not {} then add it to notify_opts to key called "replace"
    if diag_record ~= {} then
        notify_opts["replace"] = diag_record.id
    end
    diag_record = vim.notify(msg, level, notify_opts)
end

function reset_diag_record(window)
    diag_record = {}
end

vim.cmd [[
function! CocDiagnosticNotify() abort
  let l:info = get(b:, 'coc_diagnostic_info', {})
  if empty(l:info) | return '' | endif
  let l:msgs = []
  let l:level = 'info'
   if get(l:info, 'warning', 0)
    let l:level = 'warn'
  endif
  if get(l:info, 'error', 0)
    let l:level = 'error'
  endif

  if get(l:info, 'error', 0)
    call add(l:msgs, ' Errors: ' . l:info['error'])
  endif
  if get(l:info, 'warning', 0)
    call add(l:msgs, ' Warnings: ' . l:info['warning'])
  endif
  if get(l:info, 'information', 0)
    call add(l:msgs, ' Infos: ' . l:info['information'])
  endif
  if get(l:info, 'hint', 0)
    call add(l:msgs, ' Hints: ' . l:info['hint'])
  endif
  let l:msg = join(l:msgs, "\n")
  if empty(l:msg) | let l:msg = ' All OK' | endif
  call v:lua.coc_diag_notify(l:msg, l:level)
endfunction
]]

---Send a notification for the value of `vim.g.coc_status`
function M.coc_status_notification()
    local status = vim.trim(vim.g.coc_status or "")
    if status == "" then
        return ""
    end
    M.coc_status_notify(status, "info")
end

return M
