---@module 'plugs.coc'
local M = {}

local utils = Rc.shared.utils
local A = Rc.shared.utils.async
local F = Rc.F
local hl = Rc.shared.hl
local it = F.ithunk

local lazy = require("usr.lazy")
local log = Rc.lib.log
local B = Rc.api.buf
local W = Rc.api.win
local map = Rc.api.map

-- local wk = require("which-key")
---@type Promise
local promise = require("promise")
local async = require("async")

local fn = vim.fn
local api = vim.api
local g = vim.g
local cmd = vim.cmd
local uv = vim.loop

local opts = {
    diag_qfid = nil,
    -- Highlight fallback blacklist filetype
    hlfb_bl_ft = {},
}

---@type Coc.Fn
M.fn = {}
M.fn.ready = vim.funcref("coc#rpc#ready")
M.fn.refresh = vim.funcref("coc#refresh")
M.fn.on_enter = vim.funcref("coc#on_enter")
M.fn.select_confirm = vim.funcref("coc#_select_confirm")
M.fn.expandable = vim.funcref("coc#expandable")
M.fn.jumpable = vim.funcref("coc#jumpable")
M.fn.expandableOrJumpable = vim.funcref("coc#expandableOrJumpable")
M.fn.status = vim.funcref("coc#status")
M.fn.add_command = vim.funcref("coc#add_command")
M.fn.has_provider = fn.CocHasProvider

---@type Coc.Snippet
M.snippet = {}
M.snippet.next = vim.funcref("coc#snippet#next")
M.snippet.prev = vim.funcref("coc#snippet#prev")

---@type Coc.Config
M.config = {}
M.config.get = vim.funcref("coc#util#get_config")
M.config.set = vim.funcref("coc#config")

---@type Coc.Float
M.float = {}
M.float.has_float = vim.funcref("coc#float#has_float")
M.float.close_all = vim.funcref("coc#float#close_all")
M.float.close = vim.funcref("coc#float#close")
M.float.has_scroll = vim.funcref("coc#float#has_scroll")
M.float.scroll = vim.funcref("coc#float#scroll")
M.float.get_float_win_list = vim.funcref("coc#float#get_float_win_list")

---@type Coc.Pum
M.pum = {}
M.pum.visible = vim.funcref("coc#pum#visible")
M.pum.next = vim.funcref("coc#pum#next")
M.pum.prev = vim.funcref("coc#pum#prev")
M.pum.stop = vim.funcref("coc#pum#stop")
M.pum.cancel = vim.funcref("coc#pum#cancel")
M.pum.insert = vim.funcref("coc#pum#insert")
M.pum.confirm = vim.funcref("coc#pum#confirm")
M.pum.info = vim.funcref("coc#pum#info")
M.pum.select = vim.funcref("coc#pum#select")
M.pum.one_more = vim.funcref("coc#pum#one_more")
M.pum.scroll = vim.funcref("coc#pum#scroll")

---@type Coc.Notify
M.notify = {}
M.notify.close_all = vim.funcref("coc#notify#close_all")
M.notify.do_action = vim.funcref("coc#notify#do_action")
M.notify.copy = vim.funcref("coc#notify#copy")
M.notify.show_sources = vim.funcref("coc#notify#show_sources")
M.notify.keep = vim.funcref("coc#notify#keep")

---Check whether Coc has been initialized
---@param echo? boolean
---@return boolean
function M.did_init(echo)
    if g.coc_service_initialized == 0 then
        if echo then
            log.warn("coc.nvim hasn't initialized")
        end
        return false
    end
    return true
end

---CocActionAsync using Coc's async
---@param action string CocAction to run
---@param args? any[] Arguments to pass to that CocAction
---@param timeout? integer Time to wait for action to be performed
---@return boolean Error
---@return string result
function M.a2sync(action, args, timeout)
    local done, err, res = false, false, ""
    args = _t(args or {})
    args:insert(function(e, r)
        if e ~= vim.NIL then
            err = true
        end
        if r ~= vim.NIL then
            res = r
        end
        done = true
    end)
    fn.CocActionAsync(action, unpack(args))
    local wait_ret = vim.wait(
        timeout or 1000,
        function()
            return done
        end
    )
    err = err or not wait_ret
    if not wait_ret then
        res = "timeout"
    end
    return err, res
end

---Run an asynchronous CocAction using 'promise-async'
---@param action string CocAction to run
---@param args? any[] Arguments to pass to that CocAction
---@param timeout? integer Time to wait for action to be performed
---@return Promise
function M.action(action, args, timeout)
    args = vim.deepcopy(args) or {}
    return promise:new(function(resolve, reject)
        table.insert(args, function(err, res)
            if err ~= vim.NIL then
                reject(err)
            else
                if res == vim.NIL then
                    res = nil
                end
                resolve(res)
            end
        end)
        fn.CocActionAsync(action, unpack(args))
    end)
end

---Run a Coc command using Promises
---@param name string Command to run
---@param ... any
---@return Promise
function M.runCommand(name, ...)
    return M.action("runCommand", {name, ...})
end

---Run a Coc command
---@param name string Command to run
---@param args? table Arguments to the command
---@param cb? function
---@return string[]
function M.run_command(name, args, cb)
    local action_fn
    args = args or {}
    if type(cb) == "function" then
        action_fn = fn.CocActionAsync
        table.insert(args, cb)
    else
        action_fn = fn.CocAction
    end
    return action_fn("runCommand", name, unpack(args))
end

---Show documentation differently depending on filetype
function M.show_documentation()
    ---@type Ufo
    local ufo = require("ufo")
    local winid = ufo.peekFoldedLinesUnderCursor()

    if winid then
        local bufnr = api.nvim_win_get_buf(winid)
        local keys = {"a", "i", "o", "A", "I", "O", "gd", "gr",
            "gD", "gy", "gi", "gR", "gs", "go", "gt",}
        for _, k in ipairs(keys) do
            Rc.api.bmap(bufnr, "n", k, "<CR>" .. k, {noremap = false})
        end
    end

    if not winid then
        local ft = vim.bo.ft
        local cword = fn.expand("<cword>")
        if _t({"help"}):contains(ft) then
            cmd.help({cword, mods = {emsg_silent = true}})
        elseif ft == "man" then
            cmd.Man(("%s"):format(cword))
        elseif fn.bufname() == "Cargo.toml" then
            require("crates").show_popup()
        elseif M.fn.ready() then
            M.action("definitionHover"):thenCall(function(hover)
                if not hover then
                    if ft == "vim" then
                        -- NOTE: something here causes noice to disable for one notification after switching
                        --       to another filetype.
                        cword = Rc.api.opt.tmp_call(
                            {opt = "iskeyword", val = ("%s,.,-"):format(vim.bo.iskeyword)},
                            F.ithunk(fn.expand, "<cword>")
                        ) or cword

                        local hl_group = fn.synIDattr(
                            fn.synID(fn.line("."), fn.col("."), 1),
                            "name"
                        )
                        local groups = _t({"vimOption"})
                        if groups:contains(hl_group) then
                            cmd.help({("'%s'"):format(cword), mods = {emsg_silent = true}})
                        else
                            cmd.help({cword, mods = {emsg_silent = true}})
                        end
                    else
                        utils.normal("n", "K")
                    end
                end
            end)
        else
            cmd(("!%s %s"):format(vim.o.keywordprg, cword))
        end
    end
end

---Get the nearest symbol in reference to the location of the cursor
---@param notify boolean
---@return string?
function M.getsymbol(notify)
    local ret
    local ok, gps = pcall(require, "nvim-gps")
    if not ok then
        local symbol = fn.CocAction("getCurrentFunctionSymbol")
        if #symbol == 0 then
            ret = "N/A"
        else
            ret = symbol
        end
    end

    ret = gps.get_location()
    if notify then
        log.info(ret, {title = "Location"})
    end
    return ret
end

---Go to symbol definition
function M.go2def()
    local cur_bufnr = api.nvim_get_current_buf()
    local by
    if vim.bo.ft == "help" then
        utils.normal("n", "<C-]>")
        by = "tag"
    else
        local err, res = M.a2sync("jumpDefinition", {"drop"})
        if not err then
            by = "coc"
        elseif res == "timeout" then
            log.warn("Go to reference timeout")
        else
            local cword = fn.expand("<cword>")
            if not pcall(function()
                    local wv = W.win_save_positions()
                    cmd.ltag(cword)
                    local def_size = fn.getloclist(0, {size = 0}).size
                    by = "ltag"
                    if def_size > 1 then
                        api.nvim_set_current_buf(cur_bufnr)
                        wv.restore()
                        cmd("bel lw")
                    elseif def_size == 1 then
                        cmd.lcl()
                        fn.search(cword, "cs")
                    end
                end)
            then
                fn.searchdecl(cword)
                by = "search"
            end
        end
    end
    if api.nvim_get_current_buf() ~= cur_bufnr then
        utils.zz()
    end

    if by then
        utils.cecho("go2def: " .. by, "Special")
    end
end

---Organize file imports
function M.organize_import()
    M.action("organizeImport"):thenCall(function(has)
        if not has then
            log.warn("No action for organizeImport")
        end
    end)
end

---CocAction('codeLensAction')
---CocAction('codeAction')
---CocAction('codeActions')
---CocAction('organizeImport')
---CocAction('fixAll')
---CocAction('quickfixes')

---Code actions
---@param mode Coc.CodeAction.Mode|Coc.CodeAction.Mode[]
---@param only? Coc.CodeAction_t
function M.code_action(mode, only)
    async(function()
        mode = type(mode) == "string" and {mode} or mode
        local no_actions = true

        for _, m in ipairs(mode) do
            local ret = await(M.action("codeActions", {m, only}))
            if ret == false then
                log.warn("codeAction timeout")
                break
            end
            if type(ret) == "table" and #ret > 0 then
                fn.CocActionAsync("codeAction", m, only)
                no_actions = false
                break
            end
        end
        if no_actions then
            log.warn("No code Action available")
        end
    end)
end

---Jump to location list. Ran on `CocLocationsChange`
---@param locs? Coc.Locations
---@param skip? boolean
function M.jump2loc(locs, skip)
    locs = locs or g.coc_jump_locations
    fn.setloclist(0, {}, " ", {title = "CocLocationList", items = locs})
    if not skip then
        local winid = fn.getloclist(0, {winid = 0}).winid
        if winid == 0 then
            cmd("abo lw")
        else
            api.nvim_set_current_win(winid)
        end
    end
end

---Coc rename
function M.rename()
    g.coc_jump_locations = nil
    M.action("rename"):thenCall(function(res)
        if res then
            local loc = g.coc_jump_locations
            if loc then
                local uri = vim.uri_from_bufnr(0)
                local dont_open = true
                for _, lo in ipairs(loc) do
                    if lo.uri ~= uri then
                        dont_open = false
                        break
                    end
                end
                M.jump2loc(loc, dont_open)
            end
        end
    end)
end

---Function to run on `CocDiagnosticChange`
function M.diagnostic_change()
    if vim.v.exiting == vim.NIL then
        local info = fn.getqflist({id = opts.diag_qfid, winid = 0, nr = 0})
        if info.id == opts.diag_qfid and info.winid ~= 0 then
            M.diagnostic(info.winid, info.nr, true)
        end
    end
end

-- FIX: Diagnostic are not refreshing properly
--      When using ]g or [g to navigate there aren't any
--      However vim.b.coc_diagnostic_info still shows errors

---The current document diagnostics
M.document = {}
---The current workspace diagnostics
M.workspace = {}

---Get the diagnostics for Coc
M.diagnostics_tracker = function()
    -- Clear these on each run
    local curr_bufname
    M.document = {}
    M.workspace = {}

    M.action("diagnosticList"):thenCall(function(res)
        for _, d in ipairs(res) do
            if d.file == curr_bufname then
                table.insert(M.document, d)
            end
            table.insert(M.workspace, d)
            curr_bufname = d.file
        end
    end)
end

---Fill quickfix with CocDiagnostics
---@param winid number
---@param nr number
---@param keep boolean
function M.diagnostic(winid, nr, keep)
    M.action("diagnosticList"):thenCall(function(res)
        local items = {}
        for _, d in ipairs(res) do
            local text = ("[%s%s] %s"):format(
                (d.source == "" and "coc.nvim" or d.source),
                ((d.code == vim.NIL or d.code == nil) and "" or " " .. d.code),
                d.message:match("([^\n]+)\n*")
            )
            local item = {
                filename = d.file,
                lnum = d.lnum,
                end_lnum = d.end_lnum,
                col = d.col,
                end_col = d.end_col,
                text = text,
                type = d.severity,
            }
            table.insert(items, item)
        end
        local id
        if winid and nr then
            id = opts.diag_qfid
        else
            local info = fn.getqflist({id = opts.diag_qfid, winid = 0, nr = 0})
            id, winid, nr = info.id, info.winid, info.nr
        end
        local action = id == 0 and " " or "r"
        fn.setqflist({}, action, {
            id = id ~= 0 and id or nil,
            title = "CocDiagnosticList",
            items = items,
        })

        if id == 0 then
            local info = fn.getqflist({id = id, nr = 0})
            opts.diag_qfid, nr = info.id, info.nr
        end

        if not keep then
            if winid == 0 then
                cmd("bo cope")
            else
                api.nvim_set_current_win(winid)
            end
            cmd(("sil %dchi"):format(nr))
        end
    end)
end

---Provide a highlighting fallback on cursor hold
---This will not highlight keywords, (.e.g., won't highlight `local` in Lua)
---@return fun()
M.hl_fallback = (function()
    local hl_fb_tbl = {}
    local re_s, re_e = vim.regex([[\k*$]]), vim.regex([[^\k*]])

    local function cur_word_pat()
        ---@diagnostic disable:need-check-nil
        local lnum, col = unpack(api.nvim_win_get_cursor(0))
        local line = api.nvim_buf_get_lines(0, lnum - 1, lnum, true)[1]:match("%C*")
        local _, e_off = re_e:match_str(line:sub(col + 1, -1))
        local pat = ""
        if e_off ~= 0 then
            local s, e = re_s:match_str(line:sub(1, col + 1))
            local word = line:sub(s + 1, e + e_off - 1)
            pat = ([[\<%s\>]]):format(word:gsub("[\\/~]", [[\%1]]))
        end
        return pat
    end

    return function()
        local ft = vim.bo.ft
        if vim.tbl_contains(opts.hlfb_bl_ft, ft) or utils.mode() == "t" then
            return
        end

        local m_id, winid = unpack(hl_fb_tbl)
        pcall(fn.matchdelete, m_id, winid)

        winid = api.nvim_get_current_win()
        m_id = fn.matchadd("CocHighlightText", cur_word_pat(), -1, -1, {window = winid})
        hl_fb_tbl = {m_id, winid}
    end
end)()

---Change the diagnostic target
---Can get hard to read sometimes if there are many errors
function M.toggle_diag_target()
    if M.config.get("diagnostic").messageTarget == "float" then
        if M.config.set("diagnostic", {messageTarget = "echo"}) == 0 then
            log.info("messageTarget: echo", {title = "coc"})
        end
    else
        if M.config.set("diagnostic", {messageTarget = "float"}) == 0 then
            log.info("messageTarget: float", {title = "coc"})
        end
    end
end

---Toggle `:CocOutline`
function M.toggle_outline()
    local winid = fn["coc#window#find"]("cocViewId", "OUTLINE")
    if winid == -1 then
        M.action("showOutline", {1}):thenCall(function(_)
            cmd.wincmd("l")
        end)
    else
        fn["coc#window#close"](winid)
    end
end

--  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

---Used with popup completions
---@return boolean
function _G.check_backspace()
    local col = Rc.api.get_cursor_col()
    return (col == 0 or api.nvim_get_current_line():sub(col, col):match("%s")) and true
end

---Used to map <CR> with both autopairs and coc
function _G.map_cr()
    if M.pum.visible() ~= 0 then
        return M.pum.confirm()
    end
    return require("nvim-autopairs").autopairs_cr()
end

--  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

function M.skip_snippet()
    fn.CocActionAsync("snippetNext")
    return utils.termcodes["<BS>"]
end

---Function that is ran on `CocOpenFloat`
function M.post_open_float()
    local winid = g.coc_last_float_win
    if winid and api.nvim_win_is_valid(winid) then
        local bufnr = api.nvim_win_get_buf(winid)
        api.nvim_buf_call(
            bufnr,
            function()
                vim.wo[winid].showbreak = "NONE"
            end
        )
    end
end

function M.scroll(down)
    if #M.float.get_float_win_list() > 0 then
        return M.float.scroll(down)
    end
    return down and utils.termcodes["<C-f>"] or utils.termcodes["<C-b>"]
end

function M.scroll_insert(right)
    if #M.float.get_float_win_list() > 0
        and M.pum.visible() == 0
        and api.nvim_get_current_win() ~= g.coc_last_float_win
    then
        return M.float.scroll(right)
    end

    return right and utils.termcodes["<Right>"] or utils.termcodes["<Left>"]
end

--  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

---If this is ran in `init.lua` the command is not overwritten
-- function M.tag_cmd()
--     nvim.autocmd.lmb__CocDef = {
--         event = "FileType",
--         pattern = {"sh", "zsh", "tmux"},
--         command = function(a)
--             map("n", "<C-]>", "<Plug>(coc-definition)", {buffer = a.buf})
--         end,
--     }
-- end

function M.map(modes, lhs, rhs, opts)
    return async(function()
        if vim.in_fast_event() then
            await(A.scheduler())
        end
        if opts.cocc then
            rhs = ("<Cmd>CocCommand %s<CR>"):format(rhs)
            opts.cocc = nil
            opts.act = nil
            opts.cmd = nil
            opts.lcmd = nil
            opts.ccmd = nil
            opts.vlua = nil
            opts.vluar = nil
            opts.ncmd = nil
            opts.nncmd = nil
            goto down_there
        end
        if opts.act or opts.acta then
            rhs = _t(rhs:split(","))
                :map(function(v) return ([['%s']]):format(v:trim()) end)
                :concat(",")
            rhs = ("<Cmd>call CocAction%s(%s)<CR>"):format(F.tern(opts.acta, "Async", ""), rhs)
            opts.act = nil
            opts.acta = nil
            opts.cmd = nil
            opts.lcmd = nil
            opts.ccmd = nil
            opts.vlua = nil
            opts.vluar = nil
            opts.ncmd = nil
            opts.nncmd = nil
        end

        ::down_there::
        return map(modes, lhs, rhs, opts)
    end)
end

--  ══════════════════════════════════════════════════════════════════════

---Adds all Lua runtime paths to coc
---@return table
M.get_lua_runtime = function()
    local result = {}
    local types_filter = {"neodev.nvim", "promise-async"}

    ---Add a path to the Lua runtime
    ---@param lib string
    ---@param filter string[]
    ---@param types boolean?
    local function add(lib, filter, types)
        -- If it is a colorscheme, skip it. Removes a lot of files
        -- for _, path in ipairs(fn.expand(lib .. "/colors", false, true)) do
        --     path = uv.fs_realpath(path)
        --     if path and not filter[fn.fnamemodify(path, ":h:t")] then
        --         vim.notify(('COLORS: %s'):format(path))
        --         goto continue
        --     end
        -- end

        for _, path in ipairs(fn.expand(lib .. "/lua", false, true)) do
            ---@cast path +?
            path = uv.fs_realpath(path)
            if path then
                local stat = uv.fs_stat(path)
                if stat and stat.type == "directory" then
                    result[path] = true
                end

                -- path = fn.fnamemodify(path, ":h")
                -- result[path] = true
            end
        end

        -- Not sure which is faster: fn.isdirectory() or uv.fs_stat()

        -- Add types for plugins that have them
        if types then
            for _, path in pairs(fn.expand(lib .. "/types", false, true)) do
                if path and not _t(filter):contains(fn.fnamemodify(path, ":h:t")) then
                    path = uv.fs_realpath(path)
                    if path and fn.isdirectory(path) then
                        result[path] = true
                    end
                end
            end

            for _, path in pairs(fn.expand(("%s/lua/*/types"):format(lib), false, true)) do
                path = uv.fs_realpath(path)
                if path then
                    if fn.isdirectory(path) then
                        result[path] = true
                    end
                end
            end
        end

        -- ::continue::
    end

    -- local function add(lib)
    --     for _, path in pairs(fn.expand(lib .. "/lua", false, true)) do
    --         path = uv.fs_realpath(path)
    --         if path and fn.isdirectory(path) then
    --             result[path] = true
    --         end
    --     end
    -- end

    for _, site in pairs(vim.split(vim.o.packpath, ",")) do
        add(site .. "/pack/*/opt/*", types_filter, true)
        add(site .. "/pack/*/start/*", types_filter, true)
    end

    -- add("$VIMRUNTIME")
    -- api.nvim_get_runtime_file("", true)

    -- This adds 400-500+ files
    -- for _, run in pairs(api.nvim_list_runtime_paths()) do
    --     add(run)
    -- end

    return result
end

---Setup the Sumneko-Coc Lua language-server
---Note that the runtime paths here are placed into an array, not a table
function M.sumneko_ls()
    -- Workspace
    ---@type string[]
    -- local library = M.config.get("Lua").workspace.library

    -- local runtime = _t(M.get_lua_runtime()):keys()
    -- library = vim.list_extend(library, runtime)
    --
    -- M.set_config("Lua.workspace", {library = library})

    -- Runtime path
    local path = vim.split(package.path, ";")
    table.insert(path, "?.lua")
    table.insert(path, "?/init.lua")
    M.set_config("Lua.runtime", {path = path})
end

--  ╭──────────────────────────────────────────────────────────╮
--  │                           Init                           │
--  ╰──────────────────────────────────────────────────────────╯

function M.setup_commands()
    local command = Rc.api.command
    command("CocMarket", [[CocFzfList marketplace]], {nargs = 0, desc = "Fzf marketplace"})
    command("Format", [[call CocAction('format')]], {nargs = 0, desc = "Format file with coc"})
    command("OR", M.organize_import, {nargs = 0, desc = "Organize imports"})

    command(
        "Prettier",
        [[call CocActionAsync('runCommand', 'prettier.formatFile')]],
        {nargs = 0, desc = "Format file with prettier"}
    )
    command(
        "CocOutput",
        [[CocCommand workspace.showOutput]],
        {nargs = 0, desc = "Show workspace output"}
    )
    command(
        "CocCodeAction",
        [[call CocActionAsync('codeActionRange', <line1>, <line2>, <f-args>)]],
        {nargs = 0, range = "%", desc = "Coc code action"}
    )
    command(
        "CocQuickfix",
        [[call CocActionAsync('codeActionRange', <line1>, <line2>, 'quickfix')]],
        -- [[call CocAction('quickfixes')]]
        {nargs = "*", range = "%", desc = "Coc code action fix"}
    )
    command(
        "CocFixAll",
        [[call CocActionAsync('fixAll')]],
        {nargs = "*", range = "%", desc = "Coc code action fix all"}
    )
    command(
        "CocDiagnosticsToggleBuf",
        [[call CocActionAsync('diagnosticToggleBuffer')]],
        {nargs = 0, desc = "Toggle diagnostics for buffer"}
    )
    command(
        "CocDiagnosticsToggle",
        [[call CocActionAsync('diagnosticToggle')]],
        {nargs = 0, desc = "Toggle diagnostics globally"}
    )
    command(
        "Tsc",
        [[call CocAction('runCommand', 'tsserver.watchBuild')]],
        {nargs = 0, desc = "Typescript watch build"}
    )
    command(
        "Eslint",
        [[call CocAction('runCommand', 'eslint.lintProject')]],
        {nargs = 0, desc = "Typescript ESLint"}
    )
end

function M.setup_autocmds()
    nvim.autocmd.CocNvimSetup = {
        {
            event = "User",
            pattern = "CocLocationsChange",
            nested = true,
            command = function()
                require("plugs.coc").jump2loc()
            end,
        },
        {
            event = "User",
            pattern = "CocDiagnosticChange",
            nested = true,
            command = function()
                require("plugs.coc").diagnostic_change()
                require("plugs.coc").diagnostics_tracker()
            end,
        },
        {
            event = "BufEnter",
            pattern = "*",
            command = function(a)
                local bufnr = a.buf
                -- require("plugs.coc").diagnostics_tracker()
                -- vim.b[bufnr].coc_trim_trailing_whitespace = 1
                -- vim.b[bufnr].coc_trim_final_newlines = 1

                if vim.bo[bufnr].ft == "coctree" and fn.winnr("$") == 1 then
                    if fn.tabpagenr("$") ~= 1 then
                        cmd.close()
                    else
                        cmd.bdelete()
                    end
                end
            end,
        },
        -- {
        --     event = "CursorHold",
        --     pattern = "*",
        --     command = function()
        --         if M.fn.ready() then
        --             vim.defer_fn(
        --                 function()
        --                     fn.CocActionAsync("diagnosticRefresh")
        --                 end,
        --                 1000
        --             )
        --         end
        --     end,
        -- },
        {
            event = "CursorHold",
            pattern = "*",
            command =
            [[sil! call CocActionAsync('highlight', '', v:lua.require('plugs.coc').hl_fallback)]],
        },
        {
            event = "FileType",
            pattern = {"typescript", "json", "lua"},
            command = [[setl formatexpr=CocActionAsync('formatSelected')]],
        },
        {
            event = "User",
            pattern = "CocJumpPlaceholder",
            command = [[call CocActionAsync('showSignatureHelp')]],
        },
        {
            event = "FileType",
            pattern = "list",
            command = function()
                cmd.packadd("nvim-bqf")
                require("bqf.magicwin.handler").attach()
            end,
        },
        {
            event = "VimLeavePre",
            pattern = "*",
            command = function()
                if g.coc_process_pid and type(uv.os_getpriority(g.coc_process_pid)) == "number" then
                    uv.kill(g.coc_process_pid, 9)
                end
            end,
        },
        {
            event = "BufAdd",
            pattern = "*",
            command = function(a)
                local size = B.buf_get_size(a.buf)
                if size > 1200 then
                    vim.b[a.buf].coc_enabled = 0
                end
            end,
        },
        {
            event = "BufReadPost",
            pattern = "*",
            command = function(a)
                local bufnr = a.buf
                if vim.bo[bufnr].readonly then
                    vim.b[bufnr].coc_diagnostic_disable = 1
                end
            end,
        },
        {
            event = "User",
            pattern = "CocOpenFloat",
            command = function()
                require("plugs.coc").post_open_float()
            end,
        },
    }
end

function M.setup_maps()
    -- map("n", "<Leader><Leader>o", "<Plug>(coc-openlink)", {desc = "Coc: open link"})

    map("n", "<C-A-'>", M.toggle_outline, {desc = "Coc: outline"})
    map("n", "<A-q>", it(M.getsymbol, true), {desc = "Coc: get current symbol"})
    map("n", "<C-w>D", "<Plug>(coc-float-hide)", {desc = "Coc: hide float"})
    map("n", "K", M.show_documentation, {desc = "Coc: show documentation"})

    map("n", "<Leader>jt", M.toggle_diag_target, {desc = "Coc: toggle diagnostic target"})
    map("n", "<Leader>jo", "CocDiagnosticsToggleBuf", {cmd = true, desc = "Coc: tog buf diagnostics"})
    map("n", "<Leader>jD", "CocRestart", {cmd = true, desc = "Coc: restart"})
    map("n", "<Leader>jd", "CocDisable", {cmd = true, desc = "Coc: disable"})
    map("n", ";fs", "<Plug>(coc-fix-current)", {desc = "CocFix: current line"})
    map("n", ";fd", "CocFixAll", {cmd = true, desc = "CocFix: all diagnostics"})
    map("n", ";fi", M.organize_import, {desc = "Coc: organize imports"})
    map("n", ";fc", "<Plug>(coc-codelens-action)", {desc = "Coc: CodeLens action"})

    map("n", "<Leader>j;", M.diagnostic, {desc = "Coc: diagnostic (project)"})
    map("n", "<Leader>j,", "CocDiagnostics", {cmd = true, desc = "Coc: diagnostic (buffer)"})
    map("n", "gd", M.go2def, {desc = "Coc: definitions"})
    M.map("n", "gD", [[jumpDeclaration, drop]], {acta = true, desc = "Coc: declaration"})
    M.map("n", "gy", [[jumpTypeDefinition, drop]], {acta = true, desc = "Coc: typedefs"})
    M.map("n", "gi", [[jumpImplementation, drop]], {acta = true, desc = "Coc: implementations"})
    M.map("n", "gr", [[jumpUsed, drop]], {acta = true, desc = "Coc: used instances"})
    M.map("n", "gR", [[jumpReferences, drop]], {acta = true, desc = "Coc: references"})
    M.map("n", "[g", [[diagnosticPrevious]], {act = true, desc = "Coc: prev diagnostic"})
    M.map("n", "]g", [[diagnosticNext]], {act = true, desc = "Coc: next diagnostic"})
    M.map("n", "[G", [[diagnosticPrevious, error]], {act = true, desc = "Coc: prev error"})
    M.map("n", "]G", [[diagnosticNext, error]], {act = true, desc = "Coc: next error"})
    M.map("n", "[x", [[document.jumpToPrevSymbol]], {cocc = true, desc = "Coc: prev symbol"})
    M.map("n", "]x", [[document.jumpToNextSymbol]], {cocc = true, desc = "Coc: next symbol"})
    map("n", "<Leader>jn", M.rename, {desc = "Coc: rename"})
    map("n", "<Leader>j'", "<Plug>(coc-command-repeat)", {desc = "Coc: repeat command"})
    M.map("n", "<Leader>ja", [[refactor]], {act = true, desc = "Coc: refactor"})
    M.map("n", "<Leader>j?", [[diagnosticInfo]], {act = true, desc = "Coc: diagnostic popup"})
    M.map(
        "n",
        "<Leader>jl",
        [[workspace.diagnosticRelated]],
        {cocc = true, desc = "Coc: related diagnostics"}
    )
    M.map(
        "n",
        "<Leader>jr",
        [[diagnosticRefresh, drop]],
        {acta = true, desc = "Coc: diagnostic refresh"}
    )

    map("n", "<Leader>rn", M.rename, {desc = "Coc: rename"})
    map("n", "<Leader>rp", "<Plug>(coc-command-repeat)", {desc = "Coc: repeat command"})
    M.map("n", "<Leader>rf", [[refactor]], {act = true, desc = "Coc: refactor"})

    -- === CodeActions ===
    local caction = lazy.require("coc_code_action_menu").open_code_action_menu

    -- map("n", "<A-CR>", it(M.code_action, "currline"), {desc = "CodeAction: line"})
    map("n", "<C-CR>", it(M.code_action, {"cursor", "currline"}), {desc = "CodeAction: cursor+line"})
    -- map("n", "<C-A-CR>", it(M.code_action, ""), {desc = "CodeAction: all"})
    map("n", "<C-A-CR>", it(caction, ""), {desc = "CodeAction: all"})
    -- map("n", "<C-CR>", it(caction, "cursor"), {desc = "CodeAction: cursor"})
    map("n", "<A-CR>", it(caction, "currline"), {desc = "CodeAction: line"})
    map("x", "<C-CR>", it(caction, fn.visualmode()), {desc = "CodeAction: visual"})

    map("i", "<C-'>", M.fn.refresh, {expr = true, desc = "Coc: refresh compl"})
    map("i", "<CR>", "map_cr()", {vlua = true, desc = "ignore"})
    map(
        "i",
        "<Tab>",
        ("coc#pum#visible() ? %s : %s"):format(
            [[coc#pum#next(1)]],
            [[v:lua.check_backspace() ? "\<Tab>" : coc#refresh()]]
        ),
        {expr = true, desc = "ignore"}
    )
    map("i", "<S-Tab>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-d>"]], {expr = true})
    map("i", "<Down>", [[coc#pum#visible() ? coc#pum#next(0) : "\<Down>"]], {expr = true})
    map("i", "<Up>", [[coc#pum#visible() ? coc#pum#prev(0) : "\<Up>"]], {expr = true})
    map("i", "<C-j>", [[coc#pum#visible() ? coc#pum#next(0) : "\<C-j>"]], {expr = true})
    map("i", "<C-k>", [[coc#pum#visible() ? coc#pum#prev(0) : "\<C-k>"]], {expr = true})

    -- Snippet
    map(
        "i",
        "<C-]>",
        [[!get(b:, 'coc_snippet_active') ? "\<C-]>" : "\<C-j>"]],
        {expr = true, noremap = false}
    )
    map("s", "<C-]>", [['plugs.coc'.skip_snippet()]], {vluar = true, desc = "Skip snippet"})
    map("s", "<C-o>", "<Nop>")
    map("s", "<C-o>o", "<Esc>a<C-o>o")
    map("s", "<C-h>", '<C-g>"_c')
    map("s", "<C-w>", "<Esc>a")
    map("s", "<BS>", "<C-g>c")
    map("s", "<DEL>", "<C-g>c")
    map("s", "<C-r>", '<C-g>"_c<C-r>')
    -- map("s", "<C-h>", "<C-g>c")

    map("n", "<Leader>se", "CocFzfList snippets", {cmd = true, desc = "CocFzf: snippets"})
    -- M.map("n", "<A-[>", "fzf-preview.BufferTags", {cocc = true, desc = "Coc: list buffer tags"})
    map("n", "<C-x><C-s>", "CocFzfList symbols", {cmd = true, desc = "CocFzf: workspace symbols"})
    map("n", "<C-x><C-o>", "CocFzfList outline", {cmd = true, desc = "CocFzf: workspace outline"})
    map("n", "<C-x><C-l>", "CocFzfList", {cmd = true, desc = "CocFzf: list commands"})
    M.map("n", "<C-x><C-r>", "fzf-preview.CocReferences", {cocc = true, desc = "CocFzf: references"})
    M.map("n", "<C-x><C-]>", "fzf-preview.CocImplementations", {cocc = true, desc = "CocFzf: impls"})
    M.map(
        "n",
        "<C-x><C-d>",
        "fzf-preview.CocTypeDefinition",
        {cocc = true, desc = "CocFzf: typedefs"}
    )

    -- M.map("n", "<C-x><C-h>", "fzf-preview.CocDiagnostics", {cocc = true, desc = "CocFzf: diagnostics"})
    -- M.map("n", "<LocalLeader>d", "fzf-preview.ProjectFiles", {cocc = true, desc = "CocFzf: project files"})
    -- M.map("n", "<LocalLeader>g", "fzf-preview.GitFiles", {cocc = true, desc = "CocFzf: git files"})
    -- M.map("n", "<Leader>ab", "fzf-preview.AllBuffers", {cocc = true, desc = "CocFzf: all buffers"})
    -- M.map("n", "<LocalLeader>;", "fzf-preview.Lines", {cocc = true, desc = "CocFzf: buffer lines"})
    -- M.map("n", "<A-/>", "fzf-preview.Marks", {cocc = true, desc = "CocFzf: marks"})
    -- M.map("n", "<Leader>C", "fzf-preview.Changes", {cocc = true, desc = "CocFzf: changes"})

    map({"n", "s"}, "<C-f>", [['plugs.coc'.scroll(v:true)]], {expr = true, vluar = true})
    map({"n", "s"}, "<C-b>", [['plugs.coc'.scroll(v:false)]], {expr = true, vluar = true})
    map("i", "<C-f>", [['plugs.coc'.scroll_insert(v:true)]], {expr = true, vluar = true})
    map("i", "<C-b>", [['plugs.coc'.scroll_insert(v:false)]], {expr = true, vluar = true})

    M.map(
        "n",
        "<Leader>sf",
        [[clangd.switchSourceHeader]],
        {cocc = true, desc = "Coc: switch header"}
    )
end

function M.init()
    opts.diag_qfid = -1
    opts.hlfb_bl_ft = {
        "c",
        "cpp",
        "css",
        "fzf",
        "go",
        "help",
        "html",
        "java",
        "javascript",
        "lua",
        "python",
        "qf",
        "rust",
        "sh",
        "typescript",
        "typescriptreact",
        "vim",
        "xml",
    }

    -- g.coc_fzf_opts = {"--reverse", "--no-separator", "--history=/dev/null", "--border"}
    g.coc_fzf_preview_fullscreen = 0
    g.coc_fzf_preview_toggle_key = "?"
    g.coc_snippet_next = "<C-j>"
    g.coc_snippet_prev = "<C-k>"
    g.coc_open_url_command = "handlr open"


    -- CocAction('inspectSemanticToken')
    -- :CocCommand semanticTokens.checkCurrent
    -- :CocCommand semanticTokens.inspect
    hl.plugin("Coc", {
        CocSemVariable = {link = "@variable"},
        CocSemNamespace = {link = "Namespace"},
        CocSemClass = {link = "@type"},
        CocSemEnum = {link = "@type"},
        CocSemEnumMember = {link = "@field"},
        CocSemProperty = {link = "@field"},
        CocSemMethod = {link = "@function"},
        CocSemFunction = {link = "@function"},
        CocSemDefaultLibrary = {link = "@function.builtin"},
        CocSemKeyword = {link = "@keyword"},

        CocSemDocumentation = {link = "Number"},
        CocSemStatic = {gui = "bold"},
        CocUnderline = {gui = "none"},
    })

    M.setup_autocmds()

    vim.defer_fn(function()
        M.setup_maps()
        M.setup_commands()
    end, 50)

end

return M
