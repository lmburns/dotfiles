local M = {}

local diagnostic_icons = require("style").icons.lsp

---Get the diagnostic icon and highlight group based on severity
---@param severity number
---@return string, string
M.diagnostic_icon_by_severity = function(severity)
    local icon, highlight
    if severity == 1 then
        icon = diagnostic_icons.error
        highlight = "DiagnosticError"
    elseif severity == 2 then
        icon = diagnostic_icons.warn
        highlight = "DiagnosticWarn"
    elseif severity == 3 then
        icon = diagnostic_icons.info
        highlight = "DiagnosticInfo"
    elseif severity == 4 then
        icon = diagnostic_icons.hint
        highlight = "DiagnosticHint"
    end
    return icon, highlight
end

---Returns the name of the struct, method or function.
---@return string
M.get_current_node_name = function()
    local ts_utils = require("nvim-treesitter.ts_utils")
    local cur_node = ts_utils.get_node_at_cursor()
    local type_patterns = {
        method_declaration = 2,
        function_declaration = 1,
        type_spec = 0
    }
    local stop = false
    local index = 1
    while cur_node do
        for rgx, k in pairs(type_patterns) do
            if cur_node:type() == rgx then
                stop = true
                index = k
                break
            end
        end
        if stop then
            break
        end
        cur_node = cur_node:parent()
    end

    if not cur_node then
        vim.notify(
            "Test not found",
            vim.lsp.log_levels.WARN,
            {
                title = "User Command",
                timeout = 1000
            }
        )
        return ""
    end
    return (vim.treesitter.query.get_node_text(cur_node:child(index)))[1]
end

local windows = {}

local function set_auto_close()
  vim.cmd([[ au CursorMoved * ++once lua require('plugs.lsp.utils').remove_wins() ]])
end

local function fit_to_node(window)
    local node = require("nvim-treesitter.ts_utils").get_node_at_cursor()
    if node:type() == "identifier" then
        node = node:parent()
    end
    local start_row, _, end_row, _ = node:range()
    local new_height = math.min(math.max(end_row - start_row + 6, 15), 30)
    vim.api.nvim_win_set_height(window, new_height)
end

local open_preview_win = function(target, position)
    local buffer = vim.uri_to_bufnr(target)
    local win_opts = {
        relative = "cursor",
        row = 4,
        col = 4,
        width = 120,
        height = 15,
        border = vim.g.border_chars
    }
    -- Don't jump immediately, we need the windows list to contain ID before autocmd
    windows[#windows + 1] = vim.api.nvim_open_win(buffer, false, win_opts)
    vim.api.nvim_set_current_win(windows[#windows])
    vim.api.nvim_buf_set_option(buffer, "bufhidden", "wipe")
    set_auto_close()
    vim.api.nvim_win_set_cursor(windows[#windows], position)
    fit_to_node(windows[#windows])
end

function M.preview(request)
    local params = vim.lsp.util.make_position_params()
    pcall(
        vim.lsp.buf_request,
        0,
        request,
        params,
        function(_, result, _)
            if not result then
                return
            end
            local data = vim.tbl_islist(result) and result[1] or result
            local target = data.targetUri or data.uri
            local range = data.targetRange or data.range
            open_preview_win(target, {range.start.line + 1, range.start.character})
        end
    )
end

function M.peek_definition()
    local params = vim.lsp.util.make_position_params()
    return vim.lsp.buf_request(
        0,
        "textDocument/definition",
        params,
        function(_, result)
            if result == nil or vim.tbl_isempty(result) then
                return nil
            end
            vim.lsp.util.preview_location(result[1])
        end
    )
end

return M
