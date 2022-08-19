local M = {}

-- https://editorconfig-specification.readthedocs.io/
-- https://github.com/editorconfig/editorconfig/wiki/EditorConfig-Properties

local cmd = vim.cmd
local api = vim.api
local fn = vim.fn
local g = vim.g

local indentLine_loaded

function M.hook(config)
    if tonumber(config.indent_size) == 2 then
        local bufnr = api.nvim_get_current_buf()
        vim.defer_fn(
            function()
                local bt = vim.bo[bufnr].bt
                if bt == "" then
                    if not indentLine_loaded then
                        cmd.PackerLoad("indent-blankline.nvim")
                        indentLine_loaded = true
                    end
                    api.nvim_buf_call(
                        bufnr,
                        function()
                            cmd.IndentBlanklineEnable()
                        end
                    )
                end
            end,
            100
        )
    end
end

local function init()
    indentLine_loaded = false
    g.EditorConfig_exclude_patterns = {"fugitive://.*", "scp://.*", "gitsigns://.*"}
    g.EditorConfig_max_line_indicator = "none"
    g.EditorConfig_preserve_formatoptions = 1
    fn["editorconfig#AddNewHook"](M.hook)

    vim.defer_fn(
        function()
            cmd.EditorConfigReload()
        end,
        100
    )
end

init()

return M
