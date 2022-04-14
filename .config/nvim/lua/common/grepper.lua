local M = {}

-- This is mean to be used in concert with `vim-grepper`
-- Vim-grepper searches the current directory, this searches the current buffer

local utils = require("common.utils")
local map = utils.map

function M.vimgrep_qf(mode)
    local regions = M.get_regions(mode)
    local text = table.concat(M.get_text(regions), "\n")
    -- Vimgrep doesn't respect smartcase
    cmd(([[:vimgrep '\C%s' %% | copen]]):format(text))
end

function M.vg_motion(options)
    options = options or {}
    vim.o.operatorfunc = "v:lua.require'common.grepper'.vimgrep_qf"
    api.nvim_feedkeys("g@" .. (options.motion or ""), "i", false)
end

-- Credit: gbprod/substitute.nvim
---Turn region markers into text
---@param regions table
---@return table
function M.get_text(regions)
    local all_lines = {}
    for _, region in ipairs(regions) do
        local lines = api.nvim_buf_get_lines(0, region.start_row - 1, region.end_row, true)
        lines[vim.tbl_count(lines)] = string.sub(lines[vim.tbl_count(lines)], 0, region.end_col + 1)
        lines[1] = string.sub(lines[1], region.start_col + 1)

        for _, line in ipairs(lines) do
            table.insert(all_lines, line)
        end
    end

    return all_lines
end

-- Credit: gbprod/substitute.nvim
---Get motion region
---@param vmode string
---@return table
function M.get_regions(vmode)
    if vmode == api.nvim_replace_termcodes("<c-v>", true, false, true) then
        local start = api.nvim_buf_get_mark(0, "<")
        local finish = api.nvim_buf_get_mark(0, ">")

        local regions = {}

        for row = start[1], finish[1], 1 do
            local current_row_len = fn.getline(row):len() - 1

            table.insert(
                regions,
                {
                    start_row = row,
                    start_col = start[2],
                    end_row = row,
                    end_col = current_row_len >= finish[2] and finish[2] or current_row_len
                }
            )
        end

        return regions
    end

    local start_mark, end_mark = "[", "]"
    if vmode:match("[vV]") then
        start_mark, end_mark = "<", ">"
    end

    local start = api.nvim_buf_get_mark(0, start_mark)
    local finish = api.nvim_buf_get_mark(0, end_mark)
    local end_row_len = fn.getline(finish[1]):len() - 1

    return {
        {
            start_row = start[1],
            start_col = vmode ~= "line" and start[2] or 0,
            end_row = finish[1],
            end_col = (end_row_len >= finish[2] and vmode ~= "line") and finish[2] or end_row_len
        }
    }
end

map("n", "go", ":lua R('common.grepper').vg_motion()<CR>")

return M
