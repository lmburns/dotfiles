local M = {}

local style = require("style")
local icons = style.icons.lsp
local fn = vim.fn

M.setup_config = function()
vim.diagnostic.config(
    {
        virtual_text = {
            -- prefix = "« ",
            severity = {min = vim.diagnostic.severity.W},
            source = "if_many"
        },
        signs = true,
        underline = false,
        update_in_insert = false,
        severity_sort = true,
        float = {
            focusable = true,
            source = "always",
            border = style.current.border,
            header = {"", "DiagnosticHeader"}
        }
    }
)

-- »« ‣

local diagnostic_types = {
    {"Error", icon = icons.error},
    {"Warn", icon = icons.warn},
    {"Info", icon = icons.info},
    {"Hint", icon = icons.hint}
}

fn.sign_define(
    vim.tbl_map(
        function(t)
            local hl = "DiagnosticSign" .. t[1]
            return {
                name = hl,
                text = t.icon,
                texthl = hl,
                numhl = ("%sNr"):format(hl),
                linehl = ("%sLine"):format(hl)
            }
        end,
        diagnostic_types
    )
)
end

local function init()
    M.setup_config()
end

init()

return M
