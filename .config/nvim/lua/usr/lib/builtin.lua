---@module 'usr.lib.builtin'
---@class Usr.Lib.Builtin
local M = {}

local B = Rc.api.buf
local hl = Rc.shared.hl ---@module 'usr.shared.utils'
local utils = Rc.shared.utils ---@module 'usr.shared.utils'

local api = vim.api
local fn = vim.fn
local cmd = vim.cmd

---Set a timeout for a character-prefix in keybindings
---@param prefix string a prefix for other mappings
---@return string
function M.prefix_timeout(prefix)
    local char = fn.getcharstr(0)
    return char == "" and utils.termcodes["<Ignore>"] or prefix .. char
end

---Return string allowing jumping from column 0 to first character on the line
---These could be the same if there is no whitespace prefix
---@return string jump position in a mapping
function M.jump0()
    -- map("n", "0", "getline('.')[0 : col('.') - 2] =~# '^\\s\\+$' ? '0' : '^'", {expr = true})
    local lnum, col = unpack(api.nvim_win_get_cursor(0))
    local line = api.nvim_buf_get_lines(0, lnum - 1, lnum, true)[1]
    local expr
    if line:sub(1, col):match("^%s+$") then
        -- expr = "0"
        expr = "g0" -- screen-line
    else
        nvim.mark["`"] = {lnum, col}
        -- expr = "^"
        expr = "g^" -- screen-line
    end
    return expr
end

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
            local text = api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1]
            text = text and text:match("%C*") or "......"
            table.insert(
                items,
                {
                    bufnr = bufnr,
                    lnum = lnum,
                    col = col,
                    text = text,
                }
            )
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

function M.spellcheck()
    cmd.SpellCheck()
    if #fn.getqflist() > 0 then
        cmd.copen()
    end
end

---TODO: Finish this
---Translate spelling mistakes to quickfix
function M.spell2qf()
    vim.wo.spell = true
    cmd.norm({"gg", bang = true})

    local bufnr = api.nvim_get_current_buf()
    local mistakes = {}

    local line = 0
    -- Why is this nil?
    while Rc.api.get_cursor_row(0) or 1 > line do
        cmd.norm({"]syw", bang = true})
        local ilnum, icol = unpack(api.nvim_win_get_cursor(0))
        -- p(("line: %d lnum: %d icol %d"):format(line, ilnum, icol))
        line = ilnum
        table.insert(
            mistakes,
            {
                bufnr = bufnr,
                lnum = ilnum,
                col = icol,
                text = nvim.reg['"'],
            }
        )
    end

    p(mistakes)
end

---Set location list to changes
function M.changes2qf()
    local store_text
    local locs, pos = unpack(fn.getchangelist())
    local items, idx = {}, 1
    local bufnr = api.nvim_get_current_buf()
    for i = #locs, 1, -1 do
        local loc = locs[i]

        -- coladd
        local col, _, lnum = loc.col + 1, loc.coladd, loc.lnum
        local text = api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1]

        -- Remove consecutive duplicates
        if text ~= store_text then
            text = text and text:match("%C*") or "......"
            table.insert(
                items,
                {
                    bufnr = bufnr,
                    lnum = lnum,
                    col = col,
                    text = text,
                }
            )

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

-- TODO: Add a count operator to this
---Move to last buffer
function M.switch_lastbuf()
    local alter_bufnr = fn.bufnr("#")
    local cur_bufnr = api.nvim_get_current_buf()

    if alter_bufnr ~= -1 and alter_bufnr ~= cur_bufnr then
        -- With nvim-fundo, the check for '%' within the file name is required
        local alt_bufname = api.nvim_buf_get_name(alter_bufnr)
        if not alt_bufname:match("%%") then
            cmd.b("#")
            -- If a buffer was closed with 'bq', then reopened
            local new_bufnr = api.nvim_get_current_buf()
            if not vim.bo[new_bufnr].buflisted then
                vim.bo.buflisted = true
            end
        end
    else
        local mru_list = require("usr.plugs.mru").list()
        local cur_bufname = api.nvim_buf_get_name(cur_bufnr)
        for _, f in ipairs(mru_list) do
            if cur_bufname ~= f then
                cmd.e(fn.fnameescape(f))
                -- Cursor position when last exiting
                pcall(cmd.norm, {'`"', bang = true, mods = {silent = true}})
                break
            end
        end
    end
end

---Split the screen of the last buffer
---@param vertical boolean vertical splitting if true, else horizontal
function M.split_lastbuf(vertical)
    local sp = vertical and "vert" or ""
    local binfo =
        _j(fn.getbufinfo({buflisted = 1})):map(
            function(b)
                return {bufnr = b.bufnr, lastused = b.lastused}
            end
        )
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

---Highlight the line once the search results wrap back around to the top of the file
function M.search_wrap()
    if utils.mode() ~= "n" then
        return
    end
    hl.set("SearchWrapReverse", {bg = "#5e452b"})
    -- hl.set("SearchWrapReverse", {bg = require("kimbox.colors").bg_red})
    local bufnr = api.nvim_get_current_buf()
    local topline = fn.line("w0")
    vim.schedule(function()
        if bufnr == api.nvim_get_current_buf() and topline ~= fn.line("w0") then
            local lnum = fn.line(".") - 1
            utils.highlight(
                bufnr,
                "SearchWrapReverse",
                {lnum},
                {lnum + 1},
                {hl_eol = true},
                350
            )
        end
    end)
end

---Wipe empty buffers on startup (only meant to be ran *one* time)
function M.wipe_empty_buf()
    local bufnr = api.nvim_get_current_buf()
    vim.schedule(function()
        M.wipe_empty_buf = nil
        if B.buf_is_valid(bufnr) and api.nvim_buf_get_name(bufnr) == ""
            and not vim.bo[bufnr].modified and api.nvim_buf_get_offset(bufnr, 1) <= 0 then
            pcall(api.nvim_buf_delete, bufnr, {})
        end
    end)
end

return M
