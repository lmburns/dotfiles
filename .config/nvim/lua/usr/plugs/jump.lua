---@module 'usr.plugs.jump'
local M = {}

-- TODO: do not open all files in jumplist

local lazy = require("usr.lazy")
local style = require("usr.style")
local shared = require("usr.shared")
local F = shared.F
local hl = shared.color

local mpi = lazy.require("usr.api") ---@module 'usr.api'
local autocmd = mpi.autocmd
local map = mpi.map

local api = vim.api
local fn = vim.fn
local uv = vim.loop

local timer = {}
local show = false

local auid

local function enable_cmoved_au()
    auid = autocmd({
        event = {"CursorMoved", "CursorMovedI"},
        once = true,
        command = function()
            if M.win then
                api.nvim_win_close(M.win, true)
                M.win = nil
            end
            auid = nil
        end,
    })
end

local function disable_cmoved_au()
    if auid then
        auid:dispose()
        auid = nil
    end
end

---
---@param height number
---@param width number
local function refresh_win(height, width)
    if M.win then
        api.nvim_win_set_config(M.win, {
            width = width,
            height = height,
        })
    else
        if height == 0 then
            return
        end

        M.win = api.nvim_open_win(
            M.buf,
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
                border = style.current.border,
                title = "Jumps",
                title_pos = "center",
                noautocmd = true,
            }
        )

        api.nvim_win_call(M.win, function()
            vim.wo[M.win].winbl = 15
            vim.wo[M.win].winhl = "FloatBorder:JumpFloatBorder"
        end)

        api.nvim_buf_call(M.buf, function()
            vim.b[M.buf].bufclean_ignore = true
        end)
    end
end

local function refresh_win_timer()
    if not timer.win then
        timer.win = uv.new_timer()
    end

    timer.win:start(
        M.WIN_TIMEOUT,
        0,
        function()
            timer.win:close()
            timer.win = nil
            if M.win then
                vim.schedule(function()
                    api.nvim_win_close(M.win, true)
                    M.win = nil
                end)
            end
        end
    )
end

local function render_buf(lines, current_line)
    api.nvim_buf_clear_namespace(M.buf, M.ns, 0, -1)
    for i, l in ipairs(lines) do
        api.nvim_buf_set_extmark(
            M.buf,
            M.ns,
            i - 1,
            0,
            {
                virt_text = l,
                hl_mode = "combine",
                line_hl_group = F.if_expr(i == current_line, "Search", nil),
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
            table.insert(lines, {
                {bufname},
                {(":%d:%d"):format(j.lnum, j.col), "Directory"},
            })
            if current == i then
                current_line = #lines
            end
            if #lines > M.CONTEXT then
                break
            end
        end
    end
    return lines, current_line, width
end

local function do_show()
    -- Only show on second succesive jump within KEY_TIMEOUT
    if not timer.key then
        timer.key = uv.new_timer()
    end
    timer.key:start(
        M.KEY_TIMEOUT,
        0,
        function()
            timer.key:close()
            timer.key = nil
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

    local list, last_pos = unpack(F.if_expr(changelist, fn.getchangelist(), fn.getjumplist()))
    local current = last_pos + 1 + (F.if_expr(forward, 1, -1))
    if current == 0 then
        current = 1
    end

    if current > #list then
        current = #list
    end

    local lines, current_line, width = get_text(list, current)
    render_buf(lines, current_line)

    vim.schedule(function()
        refresh_win(#lines, width + 2)
        refresh_win_timer()
        enable_cmoved_au()
    end)
end

local function init()
    timer = {
        win = nil,
        key = nil,
    }
    M = {
        ns = api.nvim_create_namespace("jumper"),
        buf = api.nvim_create_buf(false, true),
        win = nil,
        WIN_TIMEOUT = 2000,
        KEY_TIMEOUT = 2000,
        CONTEXT = 10,
    }

    -- Clear lines in the buffer
    do
        local blank = {}
        for i = 1, 100 do
            blank[i] = ""
        end
        api.nvim_buf_set_lines(M.buf, 0, -1, false, blank)
    end

    vim.defer_fn(function()
        local colors = require("kimbox.colors")
        hl.set("JumpFloatBorder", {fg = colors.blue})

        map(
            "n",
            "<C-o>",
            function()
                show_list(false, false)
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
                -- utils.zz("g;")
                return "g;zv"
            end,
            {expr = true, desc = "Show jumps (prev)"}
        )

        map(
            "n",
            "g,",
            function()
                show_list(true, true)
                -- utils.zz("g,")
                return "g,zv"
            end,
            {expr = true, desc = "Show jumps (next)"}
        )
    end, 100)
end

init()
