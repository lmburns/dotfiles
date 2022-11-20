---Credit: lewis6991

local hl = require("common.color")
local style = require("style")
local utils = require("common.utils")
-- local augroup = utils.augroup
local autocmd = utils.autocmd
local map = utils.map

local api = vim.api
local fn = vim.fn
local uv = vim.loop
local F = vim.F

local WIN_TIMEOUT = 2000
local KEY_TIMEOUT = 2000
local CONTEXT = 10

local ns
local win_timer
local key_timer
local win
local buf
local show = false

-- Autocmd ID for cursor moved
local cmoved_au

local function enable_cmoved_au()
    cmoved_au =
        autocmd(
        {
            event = {"CursorMoved", "CursorMovedI"},
            once = true,
            command = function()
                if win then
                    api.nvim_win_close(win, true)
                    win = nil
                end
                cmoved_au = nil
            end
        }
    )
end

local function disable_cmoved_au()
    if cmoved_au then
        cmoved_au:dispose()
        cmoved_au = nil
    end
end

local function refresh_win(height, width)
    if win then
        api.nvim_win_set_config(
            win,
            {
                width = width,
                height = height
            }
        )
    else
        win =
            api.nvim_open_win(
            buf,
            false,
            {
                relative = "win",
                anchor = "ne",
                col = api.nvim_win_get_width(0),
                row = 0,
                zindex = 200,
                width = width,
                height = height,
                style = "minimal",
                border = style.current.border
            }
        )

        api.nvim_win_call(
            win,
            function()
                vim.wo[win].winblend = 15
                vim.wo[win].winhighlight = "FloatBorder:JumpFloatBorder"
            end
        )
    end
end

local function refresh_win_timer()
    if not win_timer then
        win_timer = uv.new_timer()
    end

    win_timer:start(
        WIN_TIMEOUT,
        0,
        function()
            win_timer:close()
            win_timer = nil
            if win then
                vim.schedule(
                    function()
                        api.nvim_win_close(win, true)
                        win = nil
                    end
                )
            end
        end
    )
end

local function render_buf(lines, current_line)
    api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    for i, l in ipairs(lines) do
        api.nvim_buf_set_extmark(
            buf,
            ns,
            i - 1,
            0,
            {
                virt_text = l,
                hl_mode = "combine",
                line_hl_group = F.tern(i == current_line, "Visual", nil)
            }
        )
    end
end

local function get_text(jumplist, current)
    local width = 0
    local lines = {}
    local current_line
    for i = current - 3, current + 10 do
        local j = jumplist[i]
        if j then
            --If there is no bufnr field then it is a changelist and not jumplist
            local bufname = fn.fnamemodify(api.nvim_buf_get_name(j.bufnr or 0), ":~:.")
            local line = ("%s:%d:%d"):format(bufname, j.lnum, j.col)
            local len = api.nvim_strwidth(line)
            if len > width then
                width = len + 1
            end
            table.insert(
                lines,
                {
                    {bufname},
                    {(":%d:%d"):format(j.lnum, j.col), "Directory"}
                }
            )
            if current == i then
                current_line = #lines
            end
            if #lines > CONTEXT then
                break
            end
        end
    end
    return lines, current_line, width
end

local function do_show()
    -- Only show on second succesive jump within KEY_TIMEOUT
    if not key_timer then
        key_timer = uv.new_timer()
    end
    key_timer:start(
        KEY_TIMEOUT,
        0,
        function()
            key_timer:close()
            key_timer = nil
            show = false
        end
    )

    if show then
        return true
    end

    show = true
end

---Display the list in a window
---@param changelist boolean whether to show changelist or jumplist
---@param forward boolean
local function show_list(changelist, forward)
    if not do_show() then
        return
    end

    disable_cmoved_au()

    local list, last_pos = unpack(F.tern(changelist, fn.getchangelist(), fn.getjumplist()))

    local current = last_pos + 1 + (F.tern(forward, 1, -1))
    if current == 0 then
        current = 1
    end

    if current > #list then
        current = #list
    end

    local lines, current_line, width = get_text(list, current)
    render_buf(lines, current_line)

    vim.schedule(
        function()
            refresh_win(#lines, width + 2)
            refresh_win_timer()
            enable_cmoved_au()
        end
    )
end

local function init()
    ns = api.nvim_create_namespace("jumper")
    buf = api.nvim_create_buf(false, true)

    -- Clear lines in the buffer
    do
        local blank = {}
        for i = 1, 100 do
            blank[i] = ""
        end
        api.nvim_buf_set_lines(buf, 0, -1, false, blank)
    end

    vim.defer_fn(
        function()
            local colors = require("kimbox.colors")
            hl.set("JumpFloatBorder", {fg = colors.blue})

            map(
                "n",
                "<C-o>",
                function()
                    show_list(false)
                    return "<C-o>"
                end,
                {expr = true, desc = "Show jumps (prev)"}
            )

            map(
                "n",
                "<C-i>",
                function()
                    show_list(false, true)
                    return "<C-i>"
                end,
                {expr = true, desc = "Show jumps (next)"}
            )

            map(
                "n",
                "g;",
                function()
                    show_list(true, false)
                    return "g;"
                end,
                {expr = true, desc = "Show jumps (prev)"}
            )

            map(
                "n",
                "g,",
                function()
                    show_list(true, true)
                    return "g,"
                end,
                {expr = true, desc = "Show jumps (next)"}
            )
        end,
        100
    )
end

init()
