---@module 'usr.lib.fn'
---@description Functions that perform one task
local M = {}

local shared = require("usr.shared")
local utils = shared.utils ---@module 'usr.shared.utils'
local F = shared.F ---@module 'usr.shared.functional'

local lazy = require("usr.lazy")
local log = lazy.require("usr.lib.log") ---@module 'usr.lib.log'
local Path = lazy.require("plenary.path") ---@module 'plenary.path'

local uv = vim.loop
local cmd = vim.cmd
local fn = vim.fn
local api = vim.api

---Generic open function used with other functions
---@param path string
function M.open(path)
    fn.jobstart({"handlr", "open", path}, {detach = true})
    log.info(("Opening %s"):format(path))
end

---Open a directory or a link
function M.open_link()
    local file = fn.expand("<cfile>")
    if fn.isdirectory(file) > 0 then
        cmd.edit(file)
    else
        M.open(file)
    end
end

---Open a file or a link
---Supports plugin names commonly found in `zinit`, `packer`, `Plug`, etc.
---Will open something like 'lmburns/lf.nvim' and if that fails will open an actual url
---@return nil
function M.open_path()
    local path = fn.expand("<cfile>")
    if path:match("http[s]?://") then
        return cmd.norm({"gx", bang = true})
    end

    -- Check whether it is a file
    -- Need to switch directories before doing this to guarantee the relativity is correct
    local full = fn.expand("%:p:h")
    if uv.cwd() ~= full then
        cmd.lcd(full)
    end

    -- Expand relative links, e.g., ../lua/abbr.lua
    local abs = Path:new(path):absolute()
    if uv.fs_stat(abs) then
        return cmd.norm({"gf", bang = true})
    end

    -- Any URI with a protocol segment
    local protocol_uri_regex = "%a*:%/%/[%a%d%#%[%]%-%%+:;!$@/?&=_.,~*()]*"
    if path:match(protocol_uri_regex) then
        return cmd.norm({"gf", bang = true})
    end

    -- string/string = github link
    local plugin_url_regex = "[%a%d%-%.%_]*%/[%a%d%-%.%_]*"
    local link = path:match(plugin_url_regex)
    -- Check to make sure a path doesn't accidentally get picked up
    local num_slashes = #(path:split("/")) - 1
    if link and num_slashes == 1 then
        return M.open(("https://www.github.com/%s"):format(link))
    end
    return cmd.norm({"gf", bang = true})
end

---Open a file at a specific line + column.
---Example location: `foo/bar/baz:128:17`
---@param location string
function M.open_file_location(location)
    local bufnr = fn.expand("<abuf>") --[[@as number]]
    if bufnr == "" then
        return
    end

    bufnr = tonumber(bufnr)
    local l = vim.trim(location)
    local file = utils.str_match(l, {"(.*):%d+:%d+:?$", "(.*):%d+:?$", "(.*):$"})
    local line = tonumber(utils.str_match(l, {".*:(%d+):%d+:?$", ".*:(%d+):?$"}))
    local col = tonumber(l:match(".*:%d+:(%d+):?$")) or 1

    if utils.pl:readable(file) then
        cmd("keepalt edit " .. fn.fnameescape(file))
        if line then
            api.nvim_exec_autocmds("BufRead", {})
            mpi.set_cursor(0, line, col - 1)
            pcall(api.nvim_buf_delete, bufnr, {})
            pcall(cmd, ("argd %s"):format(fn.fnameescape(l)))
            -- pcall(api.nvim_exec, ("argd "):format(fn.fnameescape(l)), false)
        end
    end
end

---Open the current filetype's ftplugin file
function M.open_file_ftplugin()
    local files = api.nvim_get_runtime_file(("ftplugin/%s.{lua,vim}"):format(vim.bo.ft), true)
    for _, file in ipairs(files) do
        if file:match(lb.dirs.config) then
            cmd("keepalt edit " .. fn.fnameescape(file))
            break
        end
    end
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                      Line Delimiter                      │
-- ╰──────────────────────────────────────────────────────────╯

---Add a delimiter to the end of the line if the delimiter isn't already present
---If the delimiter is present, remove it
---@param character "','"|"';'"
---@return fun()
function M.modify_line_end_delimiter(character)
    local delimiters = {",", ";"}
    return function()
        local line = nvim.buf.line()
        local last_char = line:sub(-1)
        if last_char == character then
            nvim.set_current_line(line:sub(1, #line - 1))
        elseif vim.tbl_contains(delimiters, last_char) then
            nvim.set_current_line(line:sub(1, #line - 1) .. character)
        else
            nvim.set_current_line(line .. character)
        end
    end
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                    Insert empty lines                    │
-- ╰──────────────────────────────────────────────────────────╯

---Insert an empty line `count` lines above the cursor
---@param add number direction to add/subtract (neg=above, pos=below)
---@param count? number
function M.insert_empty_lines(add, count) --{{{2
    -- ["oo"] = {"printf('m`%so<ESC>``', v:count1)", "Insert line below cursor"},
    -- ["OO"] = {"printf('m`%sO<ESC>``', v:count1)", "Insert line above cursor"}
    -- ["oo"] = {[[<cmd>put =repeat(nr2char(10), v:count1)<cr>]], "Insert line below cursor"},
    -- ["OO"] = {[[<cmd>put! =repeat(nr2char(10), v:count1)<cr>]], "Insert line below cursor"},
    local lines = {}
    for i = 1, count or vim.v.count1 do
        lines[i] = ""
    end

    local row = mpi.get_cursor_row()
    local new = row + add
    api.nvim_buf_set_lines(0, new, new, false, lines)
end

---Add an empty line above the cursor
function M.empty_line_above()
    M.insert_empty_lines(-1)
end

---Add an empty line below the cursor
function M.empty_line_below()
    M.insert_empty_lines(0)
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                          Syntax                          │
-- ╰──────────────────────────────────────────────────────────╯

---Display the syntax stack at current cursor position
---@return table?
function M.name_syn_stack()
    local stack = fn.synstack(fn.line("."), fn.col("."))
    stack = vim.tbl_map(
        function(v)
            return fn.synIDattr(v, "name")
        end,
        stack
    ) --[[@as table]]
    return stack
end

---Display the syntax group at current cursor position
function M.print_syn_group()
    local id = fn.synID(fn.line("."), fn.col("."), 1)
    nvim.echo({{"Synstack: ", "WarningMsg"}, {vim.inspect(M.name_syn_stack())}})
    nvim.echo({
        {fn.synIDattr(id, "name"), "WarningMsg"},
        {" => "},
        {fn.synIDattr(fn.synIDtrans(id), "name")},
    })
end

---Print syntax highlight group (e.g., 'luaFuncId      xxx links to Function')
function M.print_hi_group()
    for _, id in pairs(M.name_syn_stack()) do
        cmd.hi(id)
    end
end

--  ╭──────────────────────────────────────────────────────────╮
--  │                           Tmux                           │
--  ╰──────────────────────────────────────────────────────────╯

---Return the filetype icon and color
---@return string?, string?
local function fileicon()
    local name = fn.bufname()
    local icon, hl

    local devicons = F.npcall(require, "nvim-web-devicons")
    if devicons then
        icon, hl = devicons.get_icon_color(name, nil, {default = true})
    end
    return icon, hl
end

---Change tmux title string or return filename
---@return string
function M.tmux_title_string()
    -- %(%m%)%(%{expand(\"%:t\")}%)
    local fname = fn.expand("%:t")
    local icon, hl = fileicon()
    local mod_hl = require("kimbox.colors").green
    if not hl then
        return (icon or "") .. " "
    end

    if vim.env.TMUX ~= nil then
        -- return ("#[fg=%s]%s #[fg=%s]%s %s #[fg=%s]"):format(mod_hl, "%(%m%)", hl, fname, icon, "#EF1D55")
        return ("#[fg=%s]%s#[fg=%s]%s %s#[fg=%s]"):format(mod_hl, "%(%M%)", hl,
            "%(%{expand(\"%:t\")}%)", icon, "#EF1D55")
    end

    return ("%s %s"):format(fname, icon)
end

---Hide number & sign columns to do tmux copy
function M.tmux_copy_mode_toggle()
    -- cmd[[setl number! rnu!]]
    vim.wo.nu = not vim.wo.nu
    vim.wo.rnu = not vim.wo.rnu

    if vim.wo.signcolumn == "no" then
        vim.wo.scl = "yes:1"
        vim.wo.fdc = "1"
    else
        vim.wo.scl = "no"
        vim.wo.fdc = "0"
    end
end

--  ╭──────────────────────────────────────────────────────────╮
--  │                          Other                           │
--  ╰──────────────────────────────────────────────────────────╯

M.set_formatopts = true

---Toggle 'r' in 'formatoptions'.
---This is the continuation of a comment on the next line
function M.toggle_formatopts_r()
    ---@diagnostic disable-next-line:undefined-field
    if vim.opt_local.formatoptions:get().r then
        vim.opt_local.formatoptions:append({r = false, o = false})
        M.set_formatopts = false
        log.info(("state: %s"):format(M.set_formatopts), {title = "Comment Continuation"})
    else
        vim.opt_local.formatoptions:append({r = true, o = true})
        M.set_formatopts = true
        log.warn(("state: %s"):format(M.set_formatopts), {title = "Comment Continuation"})
    end
end

---Execute a macro over a given selection
function M.macro_visual()
    print("@" .. fn.getcmdline())
    fn.execute(":'<,'>normal @" .. fn.nr2char(fn.getchar()))

    -- local regions = op.get_region(fn.visualmode())
    -- local start, finish = regions.start, regions.finish
    -- cmd.norm({("@%s"):format(reg or fn.nr2char(fn.getchar())), bang = true, addr = "lines", range = {start.row, finish.row}})
    -- cmd.norm({"@q", bang = true, addr = "lines", range = {"'<", "'>"}})
end

---Show changes since last save
function M.diffsaved()
    local ft = api.nvim_buf_get_option(0, "filetype")
    -- cmd("tab split")
    cmd.split({mods = {tab = 1}})
    cmd.diffthis()
    cmd.vnew({mods = {split = "aboveleft"}})
    cmd.r("#")
    cmd.norm({"1Gdd", bang = true})
    cmd.diffthis()
    cmd(("setl bt=nofile bh=wipe nobl noswf ro ft=%s"):format(ft))
    cmd.wincmd("l")
end

-- TODO: Write visual selection to temporary file
--       Give an interval update so it isn't running every second
--       Use this result as a statusbar item

---Display tokei output similar to
---@param path? string
---@param full? boolean whether to display full tokei output
---@return table|number
function M.tokei(path, full)
    local bufnr = api.nvim_get_current_buf()
    local ft = vim.bo[bufnr].ft
    if ft == nil or #ft == 0 then
        ft = fn.expand("%:p:e") or nil
    end

    if ft == nil then
        vim.notify("Unable to determine filetype")
        return api.nvim_buf_line_count(bufnr)
    end

    if full then
        local stdout =
            fn.system(
                ([==[
            tokei --type=%s --output=json %s \
            | jq -r '[to_entries[] | [.key, .value.code, .value.comments, .value.blanks]][0] | @csv'
            ]==]):format(
                    ft,
                    path or fn.expand("%:p")
                )
            )

        local lang, code, comment, blanks = unpack(vim.split(stdout:gsub('[\r\n"]+', ""), ","))
        return {lang = lang, code = code, comment = comment, blanks = blanks}
    else
        local stdout =
            fn.system(
                ([==[
            tokei --type=%s --output=json %s  \
            | jq -r '[to_entries[] | [.key, .value.code]][0] | @csv'
            ]==]):format(
                    ft,
                    path or fn.expand("%:p")
                )
            )

        local lang, code = unpack(vim.split(stdout:gsub('[\r\n"]+', ""), ","))
        return {lang = lang, code = code}
    end
end

---Remove duplicate blank lines
function M.squeeze_blank_lines()
    if vim.bo.binary == false and vim.o.ft ~= "diff" then
        local old_query = nvim.reg["/"]
        -- set current search count number
        -- utils.preserve([[1,.s/^\n\{2,}/\r/gn]])
        local result = fn.searchcount({maxcount = 1000, timeout = 500}).current
        local line, col = unpack(api.nvim_win_get_cursor(0))
        utils.preserve([[%s/^\n\{2,}/\r/ge]])
        utils.preserve([[%s/\v($\n\s*)+%$/\r/e]])
        -- utils.preserve([[0;/^\%(\n*.\)\@!/,$d]])
        if result > 0 then
            mpi.set_cursor(0, (line - result), col)
        end
        nvim.reg["/"] = old_query
    end
end

---Execute a command and resore change marks
---@generic A, R
---@param func string|fun(...: A): R
---@param ... A
---@return R?
function M.save_change_marks(func, ...)
    local s, e = nvim.mark["["], nvim.mark["]"]
    utils.wrap_fn_call(func, ...)
    local lastline = fn.line("$")
    if e.row < lastline then
        nvim.mark["["] = s
        nvim.mark["]"] = e
    end
end

---Record a macro with same keypress
---@param register string
---@return string
function M.record_macro(register)
    return F.if_expr(fn.reg_recording() == "", "q" .. register, "q")
end

return M
