local M = {}

-- local t = require("common.utils").t
local utils = require("common.utils")
local map = utils.map

local ex = nvim.ex
local fn = vim.fn
local api = vim.api

-- This is meant to be used in concert with `vim-grepper`
-- Vim-grepper searches the current directory, this searches the current buffer
--
-- There was an issue with some operators
--      got| => works all the time
--      gof| => works some of the time
-- Fix the text that is grabbed when the operator is hit

---Execute `vimgrep`
---@param mode string
function M.vimgrep_qf(mode)
    local regions = M.get_regions(mode)
    -- Multiline in unsupported, so concatenate with a space
    local text = table.concat(M.get_text(regions), " ")
    -- Vimgrep doesn't respect smartcase
    ex.vimgrep(([['\C%s' %% | copen]]):format(text))
end

---'Operator function' function
---@param motion string text motion
function M.vg_motion(motion)
    vim.o.operatorfunc = "v:lua.require'common.grepper'.vimgrep_qf"
    api.nvim_feedkeys("g@" .. (motion or ""), "i", false)
end

map("n", "go", [[:lua R('common.grepper').vg_motion()<CR>]], {desc = "Grep current file"})
map("x", "go", [[:lua R('common.grepper').vimgrep_qf(vim.fn.visualmode())<CR>]], {desc = "Grep current file"})

-- Credit: gbprod/substitute.nvim
---Turn region markers into text
---@param regions table
---@return table
function M.get_text(regions)
    local all_lines = {}
    for _, region in ipairs(regions) do
        local lines = nvim.buf.get_lines(0, region.start_row - 1, region.end_row, true)
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
    if vmode == utils.termcodes["<c-v>"] then
        local start = nvim.buf.get_mark(0, "<")
        local finish = nvim.buf.get_mark(0, ">")
        -- local start = api.nvim_buf_get_mark(0, "<")
        -- local finish = api.nvim_buf_get_mark(0, ">")

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

    local start = nvim.buf.get_mark(0, start_mark)
    local finish = nvim.buf.get_mark(0, end_mark)
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

-- ╭──────────────────────────────────────────────────────────╮
-- │                      Telescope Grep                      │
-- ╰──────────────────────────────────────────────────────────╯

---Show grep results in telescope
---@param type string
---@param only_curr boolean grep only current buffer
M.telescope_grep = function(type, only_curr)
    local select_save = vim.o.selection
    vim.o.selection = 'inclusive'
    local reg_save = nvim.reg['@']

    if type:match("v") then
        ex.normal_('`<v`>y')
    elseif type:match("char") then
        ex.normal_('`[v`]y')
    else
        return
    end

    local curr = fn.expand("%:p")
    local cwd = fn.expand("%:p:h")
    local root = require("common.gittool").root(cwd)
    ex.lcd(cwd)

    local opts = {
        layout_strategy = "vertical",
        layout_config = {prompt_position = "top"},
        sorting_strategy = "ascending",
        search_dirs = {only_curr and curr or (#root == 0 and cwd or root)},
        search = nvim.reg["@"]
    }

    require("telescope.builtin").grep_string(opts)

    -- This sets the register to what is queried
    vim.o.selection = select_save
    nvim.reg['@'] = reg_save
end

---Show grep results of the current buffer in telescope
---@param type string
M.telescope_grep_current_buffer = function(type)
    M.telescope_grep(type, true)
end

map("n", "gt", [[:silent! set operatorfunc=v:lua.R'common.grepper'.telescope_grep<cr>g@]])
map("x", "gt", [[:call v:lua.R'common.grepper'.telescope_grep(visualmode())<cr>]])

map("n", "gT", [[:silent! set operatorfunc=v:lua.R'common.grepper'.telescope_grep_current_buffer<cr>g@]])
map("x", "gT", [[:call v:lua.R'common.grepper'.telescope_grep_current_buffer(visualmode())<cr>]])

-- ╭──────────────────────────────────────────────────────────╮
-- │                     Alternative Grep                     │
-- ╰──────────────────────────────────────────────────────────╯

---An alternative to the above functions
---@param type string
function M.grep_operator(type)
    -- local saved_unnamed_register = fn.getreg("@@")
    if type:match("v") then
        vim.cmd([[normal! `<v`>y]])
    elseif type:match("char") then
        vim.cmd([[normal! `[v`]y']])
    else
        return
    end

    -- Use Winnr to check if the cursor has moved it if has restore it
    -- local winnr = fn.winnr()
    --
    -- For grep across multiple files
    -- if fn.winnr() ~= winnr then
    --    cmd("wincmd p")
    -- end

    -- local row, col = unpack(api.nvim_win_get_cursor(0))
    local escaped = require("dev").shellescape(fn.getreg("@@"))

    -- cmd(("vimgrep! %s %s"):format(escaped, fn.expand("%")))
    ex.vimgrep(("%s %s"):format(escaped, fn.expand("%")))
    -- vim.cmd([[silent execute 'grep! ' . shellescape(@@) . ' %%']])

    -- fn.setreg("@@", saved_unnamed_register)
    -- api.nvim_win_set_cursor(0, {row, col})

    -- p(("%s %s"):format(winnr, fn.winnr()))

    ex.copen()
end

-- map("n", "gt", [[:silent! set operatorfunc=v:lua.R'common.grepper'.grep_operator<cr>g@]])
-- map("x", "gt", [[:call v:lua.R'common.grepper'.grep_operator(visualmode())<cr>]])

return M
