local M = {}

require("common.utils")
local utils = require("common.kutils")

---Set a timeout for a character-prefix in keybindings
---@param prefix string
---@return string
function M.prefix_timeout(prefix)
    local char = fn.getcharstr(0)
    return char == "" and utils.termcodes["<Ignore>"] or prefix .. char
end

-- once
function M.wipe_empty_buf()
    local bufnr = api.nvim_get_current_buf()
    vim.schedule(
        function()
            M.wipe_empty_buf = nil
            if
                api.nvim_buf_is_valid(bufnr) and api.nvim_buf_get_name(bufnr) == "" and not vim.bo[bufnr].modified and
                    api.nvim_buf_get_offset(bufnr, 1) <= 0
             then
                pcall(api.nvim_buf_delete, bufnr, {})
            end
        end
    )
end

---Return string allowing jumping from column 0 to first character on the line
---These could be the same if there is no whitespace prefix
---@return string jump position in a mapping
function M.jump0()
    local lnum, col = unpack(api.nvim_win_get_cursor(0))
    local line = nvim.buf.get_lines(0, lnum - 1, lnum, true)[1]
    local expr
    if line:sub(1, col):match("^%s+$") then
        expr = "0"
    else
        nvim.buf.set_mark(0, "`", lnum, col, {})
        expr = "^"
    end
    return expr
end

-- TODO: Oldfiles

-- function M.oldf2qf()
--   local current_buffer = api.nvim_get_current_buf()
--   local current_file = api.nvim_buf_get_name(current_buffer)
--
--   for _, file in ipairs(vim.v.oldfiles) do
--     if uv.fs_stat(file) and file ~= current_file and not sess_map[file] then
--       add_entry(file, co)
--     end
--   end
-- end

---Set location list to jump list
function M.jumps2qf()
    local locs, pos = unpack(fn.getjumplist())
    local items, idx = {}, 1
    for i = #locs, 1, -1 do
        local loc = locs[i]
        local bufnr, lnum, col = loc.bufnr, loc.lnum, loc.col + 1
        if api.nvim_buf_is_valid(bufnr) then
            local text = nvim.buf.get_lines(bufnr, lnum - 1, lnum, false)[1]
            text = text and text:match("%C*") or "......"
            table.insert(items, {bufnr = bufnr, lnum = lnum, col = col, text = text})
        end
        if pos + 1 == i then
            idx = #items
        end
    end

    fn.setloclist(0, {}, " ", {title = "JumpList", items = items, idx = idx})
    local winid = fn.getloclist(0, {winid = 0}).winid
    if winid == 0 then
        cmd("abo lw")
    else
        api.nvim_set_current_win(winid)
    end
end

---Set location list to changes
function M.changes2qf()
    local store_text
    local locs, pos = unpack(fn.getchangelist())
    local items, idx = {}, 1
    local bufnr = nvim.buf.nr()
    for i = #locs, 1, -1 do
        local loc = locs[i]

        -- coladd
        local col, _, lnum = loc.col + 1, loc.coladd, loc.lnum
        local text = nvim.buf.get_lines(bufnr, lnum - 1, lnum, false)[1]

        -- Remove consecutive duplicates
        if text ~= store_text then
            text = text and text:match("%C*") or "......"
            table.insert(items, {bufnr = bufnr, lnum = lnum, col = col, text = text})

            if pos + 1 == i then
                idx = #items
            end
        end

        store_text = text
    end

    fn.setloclist(0, {}, " ", {title = "ChangeList", items = items, idx = idx})
    local winid = fn.getloclist(0, {winid = 0}).winid
    if winid == 0 then
        cmd("abo lw")
    else
        api.nvim_set_current_win(winid)
    end
end

-- TODO: Add a count to this
---Move to last buffer
function M.switch_lastbuf()
    local alter_bufnr = fn.bufnr("#")
    local cur_bufnr = api.nvim_get_current_buf()
    if alter_bufnr ~= -1 and alter_bufnr ~= cur_bufnr then
        ex.b("#")
    else
        local mru_list = require("common.mru").list()
        local cur_bufname = api.nvim_buf_get_name(cur_bufnr)
        for _, f in ipairs(mru_list) do
            if cur_bufname ~= f then
                ex.e(fn.fnameescape(f))
                cmd('sil! norm! `"')
                break
            end
        end
    end
end

---Split the screen of the last buffer
---@param vertical boolean vertical splitting if true, else horizontal
function M.split_lastbuf(vertical)
    local sp = vertical and "vert" or ""
    -- local binfo = nvim.eval([[map(getbufinfo({'buflisted':1}),'{"bufnr": v:val.bufnr, "lastused": v:val.lastused}')]])
    local binfo = fn.map(fn.getbufinfo({buflisted = 1}), '{"bufnr": v:val.bufnr, "lastused": v:val.lastused}')
    local last_buf_info
    for _, bi in ipairs(binfo) do
        if fn.bufwinnr(bi.bufnr) == -1 then
            if not last_buf_info or last_buf_info.lastused < bi.lastused then
                last_buf_info = bi
            end
        end
    end
    cmd(sp .. " sb " .. (last_buf_info and last_buf_info.bufnr or ""))
end

function M.search_wrap()
    if api.nvim_get_mode().mode ~= "n" then
        return
    end
    local bufnr = nvim.get_current_buf()
    local topline = fn.line("w0")
    vim.schedule(
        function()
            if bufnr == nvim.buf.nr() and topline ~= fn.line("w0") then
                local lnum = fn.line(".") - 1
                utils.highlight(bufnr, "Reverse", {lnum}, {lnum + 1}, {hl_eol = true}, 350)
            end
        end
    )
end

-- https://github.com/neovim/neovim/issues/11440
function M.fix_quit()
    local ok, msg = pcall(cmd, "q")
    if not ok and msg:match(":E5601:") then
        cmd("1only | q")
    end
end

return M
