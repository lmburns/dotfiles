---@diagnostic disable:param-type-mismatch
---@diagnostic disable:redundant-parameter
---@diagnostic disable:missing-parameter
---@diagnostic disable:undefined-field

local M = {}

local D = require("dev")
local log = require("common.log")
local hl = require("common.color")
local utils = require("common.utils")
local map = utils.map
-- local bmap = utils.bap
local augroup = utils.augroup

local wk = require("which-key")
---@module "promise-async"
local promise = require("promise")

local fn = vim.fn
local api = vim.api
local g = vim.g
local cmd = vim.cmd
local uv = vim.loop
local F = vim.F

local diag_qfid

-- M.get_config = fn["coc#util#get_config"]
-- M.set_config = fn["coc#config"]

---Get an item from Coc's config
---@param section string
---@return any
M.get_config = function(section)
    return fn["coc#util#get_config"](section)
end

---Set an item in Coc's config
---@param section string
---@param value { [string]: string }|{ [string]: table<string, string> }
M.set_config = function(section, value)
    fn["coc#config"](section, value)
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                          Other                           │
-- ╰──────────────────────────────────────────────────────────╯

---Change the diagnostic target
---Can get hard to read sometimes if there are many errors
function M.toggle_diagnostic_target()
    if M.get_config("diagnostic").messageTarget == "float" then
        M.set_config("diagnostic", {messageTarget = "echo"})
    else
        M.set_config("diagnostic", {messageTarget = "float"})
    end
end

---Get the nearest symbol in reference to the location of the cursor
---@return string?
function M.getsymbol()
    local ok, _ = pcall(require, "nvim-gps")

    if not ok then
        local symbol = fn.CocAction("getCurrentFunctionSymbol")
        if #symbol == 0 then
            return "N/A"
        else
            return symbol
        end
    end

    return require("nvim-gps").get_location()
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
            if
                not pcall(
                    function()
                        local wv = utils.save_win_positions()
                        cmd.ltag(cword)
                        local def_size = fn.getloclist(0, {size = 0}).size
                        by = "ltag"
                        if def_size > 1 then
                            api.nvim_set_current_buf(cur_bufnr)
                            wv.restore()
                            cmd("abo lw")
                        elseif def_size == 1 then
                            cmd.lcl()
                            fn.search(cword, "cs")
                        end
                    end
                )
             then
                fn.searchdecl(cword)
                by = "search"
            end
        end
    end
    if api.nvim_get_current_buf() ~= cur_bufnr then
        cmd("norm! zz")
    end

    if by then
        utils.cecho("go2def: " .. by, "Special")
    end
end

-- Use K to show documentation in preview window
function M.show_documentation()
    local winid
    if vim.wo.foldenable and vim.wo.foldmethod == "manual" then
        winid = require("ufo").peekFoldedLinesUnderCursor()
    end

    if not winid then
        local ft = vim.bo.ft
        if _t({"help"}):contains(ft) then
            cmd(("sil! h %s"):format(fn.expand("<cword>")))
        elseif ft == "man" then
            cmd.Man(("%s"):format(fn.expand("<cword>")))
        elseif fn.expand("%:t") == "Cargo.toml" then
            require("crates").show_popup()
        elseif fn["coc#rpc#ready"]() then
            -- definitionHover -- doHover
            local err, res = M.a2sync("definitionHover")
            if err then
                if res == "timeout" then
                    log.warn("Show documentation timeout")
                    return
                end
                cmd("norm! K")
            end
        else
            cmd(("!%s %s"):format(vim.o.keywordprg, fn.expand("<cword>")))
        end
    end
end

---CocActionAsync
---@param action string: CocAction to run
---@param args table: Arguments to pass to that CocAction
---@param time number?: Time to wait for action to be performed
---@return boolean Error
---@return string result
function M.a2sync(action, args, time)
    local done = false
    local err = false
    local res = ""
    args = args or {}
    table.insert(
        args,
        function(e, r)
            if e ~= vim.NIL then
                err = true
            end
            if r ~= vim.NIL then
                res = r
            end
            done = true
        end
    )
    fn.CocActionAsync(action, unpack(args))
    local wait_ret =
        vim.wait(
        time or 1000,
        function()
            ---@diagnostic disable-next-line:redundant-return-value
            return done
        end
    )
    err = err or not wait_ret
    if not wait_ret then
        res = "timeout"
    end
    return err, res
end

---Run an asynchronous CocAction using a Javascript type framework of Promise
---@param action string
---@param args table?
---@param timeout number?
---@return Promise
function M.action(action, args, timeout)
    args = vim.deepcopy(F.if_nil(args, {}))
    return promise:new(
        function(resolve, reject)
            table.insert(
                args,
                function(err, res)
                    if err ~= vim.NIL then
                        reject(err)
                    else
                        if res == vim.NIL then
                            res = nil
                        end

                        if timeout then
                            D.setTimeout(
                                function()
                                    resolve(res)
                                end,
                                timeout
                            )
                        else
                            resolve(res)
                        end
                    end
                end
            )
            fn.CocActionAsync(action, unpack(args))
        end
    )
end

---Run a Coc command using Promises
---@param name string Command to run
---@vararg any
---@return Promise
function M.runCommand(name, ...)
    return M.action("runCommand", {name, ...})
end

---Run a Coc command
---@param name string Command to run
---@param args table Arguments to the command
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

---Code actions
function M.code_action(mode, only)
    if type(mode) == "string" then
        mode = {mode}
    end
    local no_actions = true
    for _, m in ipairs(mode) do
        local err, ret = M.a2sync("codeActions", {m, only}, 1000)
        if err then
            if ret == "timeout" then
                log.warn("codeAction timeout")
                break
            end
        else
            if type(ret) == "table" and #ret > 0 then
                fn.CocActionAsync("codeAction", m, only)
                no_actions = false
                break
            end
        end
    end
    if no_actions then
        log.warn("No code Action available")
    end
end

---Jump to location list. Ran on `CocLocationsChange`
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
    M.action("rename"):thenCall(
        function(res)
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
        end
    )
end

---Function to run on `CocDiagnosticChange`
function M.diagnostic_change()
    if vim.v.exiting == vim.NIL then
        local info = fn.getqflist({id = diag_qfid, winid = 0, nr = 0})
        if info.id == diag_qfid and info.winid ~= 0 then
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

    M.action("diagnosticList"):thenCall(
        function(res)
            for _, d in ipairs(res) do
                if d.file == curr_bufname then
                    table.insert(M.document, d)
                end
                table.insert(M.workspace, d)
                curr_bufname = d.file
            end
        end
    )
end

---Fill quickfix with CocDiagnostics
---@param winid number
---@param nr number
---@param keep boolean
function M.diagnostic(winid, nr, keep)
    M.action("diagnosticList"):thenCall(
        function(res)
            local items = {}
            for _, d in ipairs(res) do
                local text =
                    ("[%s%s] %s"):format(
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
                    type = d.severity
                }
                table.insert(items, item)
            end
            local id
            if winid and nr then
                id = diag_qfid
            else
                local info = fn.getqflist({id = diag_qfid, winid = 0, nr = 0})
                id, winid, nr = info.id, info.winid, info.nr
            end
            local action = id == 0 and " " or "r"
            fn.setqflist(
                {},
                action,
                {
                    id = id ~= 0 and id or nil,
                    title = "CocDiagnosticList",
                    items = items
                }
            )

            if id == 0 then
                local info = fn.getqflist({id = id, nr = 0})
                diag_qfid, nr = info.id, info.nr
            end

            if not keep then
                if winid == 0 then
                    cmd("bo cope")
                else
                    api.nvim_set_current_win(winid)
                end
                cmd(("sil %dchi"):format(nr))
            end
        end
    )
end

---Provide a higlighting fallback on cursor hold
---i.e., this will show non-treesitter highlighting on cursor hold
M.hl_fallback =
    (function()
    local fb_bl_ft = {
        "c",
        "cpp",
        "css",
        "fzf",
        "go",
        -- "help",
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
        "xml"
    }
    local hl_fb_tbl = {}
    local re_s, re_e = vim.regex([[\k*$]]), vim.regex([[^\k*]])

    local function cur_word_pat()
        local lnum, col = unpack(nvim.cursor(0))
        local line = nvim.buf.get_lines(0, lnum - 1, lnum, true)[1]:match("%C*")
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
        if vim.tbl_contains(fb_bl_ft, ft) or utils.mode() == "t" then
            return
        end

        local m_id, winid = unpack(hl_fb_tbl)
        pcall(fn.matchdelete, m_id, winid)

        winid = api.nvim_get_current_win()
        m_id = fn.matchadd("CocHighlightText", cur_word_pat(), -1, -1, {window = winid})
        hl_fb_tbl = {m_id, winid}
    end
end)()

-- This doesn't seem to set value locally anymore. But also doesn't seem needed
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

---Used with popup completions
---@return boolean
function _G.check_backspace()
    local _, col = unpack(api.nvim_win_get_cursor(0))
    return (col == 0 or api.nvim_get_current_line():sub(col, col):match("%s")) and true
end

---Used to map <CR> with both autopairs and coc
function _G.map_cr()
    if fn["coc#pum#visible"]() ~= 0 then
        return fn["coc#pum#confirm"]()
    end

    return require("nvim-autopairs").autopairs_cr()
end

---Check whether Coc has been initialized
---@param silent boolean
---@return boolean
function M.did_init(silent)
    if g.coc_service_initialized == 0 then
        if silent then
            log.warn("coc.nvim hasn't initialized")
        end
        return false
    end
    return true
end

function M.skip_snippet()
    fn.CocActionAsync("snippetNext")
    return utils.termcodes["<BS>"]
end

---Organize file imporst
function M.organize_import()
    local err, ret = M.a2sync("organizeImport", {}, 1000)
    if err then
        if ret == "timeout" then
            log.warn("organizeImport timeout")
        else
            log.warn("No action for organizeImport")
        end
    end
end

function M.scroll(down)
    if #fn["coc#float#get_float_win_list"]() > 0 then
        return fn["coc#float#scroll"](down)
    else
        return down and utils.termcodes["<C-f>"] or utils.termcodes["<C-b>"]
    end
end

function M.scroll_insert(right)
    if
        #fn["coc#float#get_float_win_list"]() > 0 and fn["coc#pum#visible"]() == 0 and
            api.nvim_get_current_win() ~= g.coc_last_float_win
     then
        return fn["coc#float#scroll"](right)
    else
        return right and utils.termcodes["<Right>"] or utils.termcodes["<Left>"]
    end
end

---Toggle `:CocOutline`
function M.toggle_outline()
    local winid = fn["coc#window#find"]("cocViewId", "OUTLINE")
    if winid == -1 then
        M.action("showOutline", {1}):thenCall(
            function(_)
                cmd.wincmd("l")
            end
        )
    else
        fn["coc#window#close"](winid)
    end
end

-- If this is ran in `init.lua` the command is not overwritten
function M.tag_cmd()
    augroup(
        "MyCocDef",
        {
            event = "FileType",
            pattern = {
                "rust",
                "scala",
                "python",
                "ruby",
                "perl",
                "lua",
                "c",
                "cpp",
                "zig",
                "d",
                "javascript",
                "typescript"
            },
            command = function()
                map("n", "<C-]>", "<Plug>(coc-definition)", {silent = true})
            end
        }
    )
end

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
    local library = M.get_config("Lua").workspace.library

    local runtime = _t(M.get_lua_runtime()):keys()
    library = vim.list_extend(library, runtime)

    -- These aren't appearing in auto completion
    -- if D.plugin_loaded("promise-async") then
    --     local promise = {
    --         ("%s/typings"):format(_G.packer_plugins["promise-async"].path),
    --     }
    --     library = vim.list_extend(library, promise)
    -- end

    -- if D.plugin_loaded("neodev.nvim") then
    --     local typings = require("neodev.config").types()
    --     library = vim.list_extend(library, {typings})
    -- end

    M.set_config("Lua.workspace", {library = library})

    -- Runtime path
    local path = vim.split(package.path, ";")
    table.insert(path, "?.lua")
    table.insert(path, "?/init.lua")
    M.set_config("Lua.runtime", {path = path})
end

-- ========================== Init ==========================

function M.init()
    diag_qfid = -1

    local shexpr = {expr = true, silent = true}

    vim.defer_fn(
        function()
            M.sumneko_ls()
            -- Without this, not everything loads correctly
            pcall(
                function()
                    M.runCommand("sumneko-lua.restart"):catch(
                        function(_)
                        end
                    )
                end
            )
        end,
        10
    )

    g.coc_fzf_opts = {"--reverse", "--no-separator", "--history=/dev/null", "--border"}
    g.coc_snippet_next = "<C-j>"
    g.coc_snippet_prev = "<C-k>"

    augroup(
        "CocNvimSetup",
        {
            event = "User",
            pattern = "CocLocationsChange",
            nested = true,
            command = function()
                require("plugs.coc").jump2loc()
            end
        },
        {
            event = "User",
            pattern = "CocDiagnosticChange",
            nested = true,
            command = function()
                require("plugs.coc").diagnostic_change()
                -- require("plugs.coc").diagnostics_tracker()
            end
        },
        -- {
        --     event = "BufEnter",
        --     pattern = "*",
        --     command = function(args)
        --         local bufnr = args.buf
        --         require("plugs.coc").diagnostics_tracker()
        --         vim.b[bufnr].coc_trim_trailing_whitespace = 1
        --         vim.b[bufnr].coc_trim_final_newlines = 1
        --     end
        -- },
        -- {
        --     event = "CursorHold",
        --     pattern = "*",
        --     command = function()
        --         if fn["coc#rpc#ready"]() then
        --             vim.defer_fn(
        --                 function()
        --                     fn.CocActionAsync("diagnosticRefresh")
        --                 end,
        --                 1000
        --             )
        --         end
        --     end
        -- },
        {
            event = "CursorHold",
            pattern = "*",
            command = [[sil! call CocActionAsync('highlight', '', v:lua.require('plugs.coc').hl_fallback)]]
        },
        {
            event = "FileType",
            pattern = {"typescript", "json"},
            command = [[setl formatexpr=CocActionAsync('formatSelected')]]
        },
        {
            event = "User",
            pattern = "CocJumpPlaceholder",
            command = [[call CocActionAsync('showSignatureHelp')]]
        },
        {
            event = "FileType",
            pattern = "list",
            command = function()
                cmd.packadd("nvim-bqf")
                require("bqf.magicwin.handler").attach()
            end
        },
        {
            event = "VimLeavePre",
            pattern = "*",
            command = function()
                if api.nvim_get_var("coc_process_pid") ~= nil then
                    os.execute(("kill -9 -- -%d"):format(g.coc_process_pid))
                end
            end
        },
        {
            event = "FileType",
            pattern = "log",
            command = function()
                vim.b.coc_enabled = 0
            end
        },
        {
            event = "BufReadPost",
            pattern = "*",
            command = function()
                local bufnr = api.nvim_get_current_buf()
                if vim.bo[bufnr].readonly then
                    vim.b.coc_diagnostic_disable = 1
                end
            end
        },
        {
            event = "User",
            pattern = "CocOpenFloat",
            command = function()
                require("plugs.coc").post_open_float()
            end
        }
    )

    -- :CocCommand semanticTokens.checkCurrent
    -- :CocCommand semanticTokens.inspect
    hl.plugin(
        "Coc",
        {
            CocSemVariable = {link = "TSVariable"},
            CocSemNamespace = {link = "Namespace"},
            CocSemClass = {link = "Function"},
            CocSemEnum = {link = "Number"},
            CocSemEnumMember = {link = "Enum"},
            CocUnderline = {gui = "none"},
            CocSemStatic = {gui = "bold"},
            CocSemDefaultLibrary = {link = "Constant"},
            CocSemDocumentation = {link = "Number"}
        }
    )

    require("legendary").commands(
        {
            {
                ":CocMarket",
                [[:CocFzfList marketplace]],
                description = "Fzf Marketplace",
                opts = {nargs = 0}
            },
            {
                ":Format",
                [[:call CocAction('format')]],
                description = "Format file with coc",
                opts = {nargs = 0}
            },
            {
                ":Prettier",
                [[:call CocAction('runCommand', 'prettier.formatFile')]],
                description = "Format file with prettier",
                opts = {nargs = 0}
            },
            {
                ":OR",
                [[:call CocAction('runCommand', 'editor.action.organizeImport')]],
                description = "Organize imports",
                opts = {nargs = 0}
            },
            {
                ":CocOutput",
                [[CocCommand workspace.showOutput]],
                description = "Show workspace output",
                opts = {nargs = 0}
            },
            {
                ":DiagnosticToggleBuffer",
                [[call CocAction('diagnosticToggleBuffer')]],
                description = "Turn off diagnostics for buffer",
                opts = {nargs = 0}
            },
            {
                ":Tsc",
                [[:call CocAction('runCommand', 'tsserver.watchBuild')]],
                description = "Typescript watch build",
                opts = {}
            },
            {
                ":Tslint",
                [[:call CocAction('runCommand', 'tslint.lintProject')]],
                description = "Typescript ESLint",
                opts = {}
            }
        }
    )

    wk.register(
        {
            ["gd"] = {":lua require('plugs.coc').go2def()<CR>", "Goto definition"},
            ["gD"] = {":call CocActionAsync('jumpDeclaration', 'drop')<CR>", "Goto declaration"},
            ["gy"] = {
                ":call CocActionAsync('jumpTypeDefinition', 'drop')<CR>",
                "Goto type definition"
            },
            ["gi"] = {
                ":call CocActionAsync('jumpImplementation', 'drop')<CR>",
                "Goto implementation"
            },
            ["gr"] = {":call CocActionAsync('jumpUsed', 'drop')<CR>", "Goto used instances"},
            ["gR"] = {":call CocActionAsync('jumpReferences', 'drop')<CR>", "Goto references"},
            ["<C-A-'>"] = {"<cmd>lua require('plugs.coc').toggle_outline()<CR>", "Coc outline"},
            ["[g"] = {":call CocAction('diagnosticPrevious')<CR>", "Goto previous diagnostic"},
            ["]g"] = {":call CocAction('diagnosticNext')<CR>", "Goto next diagnostic"},
            ["[G"] = {":call CocAction('diagnosticPrevious', 'error')<CR>", "Goto previous error"},
            ["]G"] = {":call CocAction('diagnosticNext', 'error')<CR>", "Goto next error"},
            ["<Leader>?"] = {":call CocAction('diagnosticInfo')<CR>", "Show diagnostic popup"},
            ["<A-q>"] = {
                ":lua vim.notify(require'plugs.coc'.getsymbol(), vim.log.levels.WARN)<CR>",
                "Get current symbol"
            },
            ["<Leader>j;"] = {
                ":lua require('plugs.coc').diagnostic()<CR>",
                "Coc diagnostics (project)"
            },
            ["<Leader>j,"] = {":CocDiagnostics<CR>", "Coc diagnostics (current buffer)"},
            ["<Leader>jr"] = {
                ":call CocActionAsync('diagnosticRefresh', 'drop')<CR>",
                "Coc diagnostics refresh"
            },
            ["<Leader>jt"] = {
                ":lua require('plugs.coc').toggle_diagnostic_target()<CR>",
                "Coc toggle diagnostic target"
            },
            ["<Leader>rn"] = {":lua require('plugs.coc').rename()<CR>", "Coc rename"},
            ["<Leader>fm"] = {"<Plug>(coc-format-selected)", "Format selected (action)"},
            [";x"] = {"<Plug>(coc-fix-current)", "Fix diagnostic on line"},
            ["<Leader><Leader>o"] = {"<Plug>(coc-openlink)", "Coc open link"},
            ["<Leader><Leader>;"] = {"<Plug>(coc-codelens-action)", "Coc codelens"},
            ["<Leader>qi"] = {":lua require('plugs.coc').organize_import()<CR>", "Organize imports"},
            ["K"] = {":lua require('plugs.coc').show_documentation()<CR>", "Show documentation"},
            ["<C-CR>"] = {":lua require('plugs.coc').code_action('')<CR>", "Code action"}
            -- ["<A-CR>"] = {":lua require('plugs.coc').code_action({'cursor', 'line'})<CR>", "Code action cursor"},
            -- ["<C-A-CR>"] = {":lua require('plugs.coc').code_action('line')<CR>", "Code action line"},
        }
    )

    -- === CodeActions ===
    map(
        "n",
        "<A-CR>",
        "<cmd>lua require('coc_code_action_menu').open_code_action_menu('cursor')<CR>"
    )
    map(
        "n",
        "<C-A-CR>",
        "<cmd>lua require('coc_code_action_menu').open_code_action_menu('line')<CR>"
    )
    map("x", "<A-CR>", [[:<C-u>lua require('plugs.coc').code_action(vim.fn.visualmode())<CR>]])

    map("x", "<Leader>fm", "<Plug>(coc-format-selected)", {desc = "Format selected"})

    -- map("s", "<C-h>", '<C-g>"_c')
    -- map("s", "<C-w>", "<Esc>a")
    -- map("s", "<C-o>", "<Nop>")
    -- map("s", "<C-o>o", "<Esc>a<C-o>o")

    -- Refresh coc completions
    map("i", "<C-'>", "coc#refresh()", shexpr)
    map("i", "<CR>", "v:lua.map_cr()", shexpr)

    map(
        "i",
        "<Tab>",
        ("coc#pum#visible() ? %s : %s"):format(
            [[coc#pum#next(1)]],
            [[v:lua.check_backspace() ? "\<Tab>" : coc#refresh()]]
        ),
        shexpr
    )

    map("i", "<S-Tab>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-d>"]], shexpr)

    -- Popup
    map("i", "<C-n>", [[coc#pum#visible() ? coc#pum#next(1) : "\<C-n>"]], shexpr)
    map("i", "<C-p>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-p>"]], shexpr)
    map("i", "<Down>", [[coc#pum#visible() ? coc#pum#next(0) : "\<Down>"]], shexpr)
    map("i", "<Up>", [[coc#pum#visible() ? coc#pum#prev(0) : "\<Up>"]], shexpr)

    -- Snippet
    map(
        "i",
        "<C-]>",
        [[!get(b:, 'coc_snippet_active') ? "\<C-]>" : "\<C-j>"]],
        {expr = true, noremap = false}
    )
    map("s", "<C-]>", [[v:lua.require'plugs.coc'.skip_snippet()]], {expr = true})

    -- Fzf
    -- add_list_source(name, description, command)
    --    call coc_fzf#common#add_list_source('fzf-buffers', 'display open buffers', 'Buffers')
    -- delete_list_source(name)
    --    call coc_fzf#common#delete_list_source('fzf-buffers')
    wk.register(
        {
            -- ["<Leader>ab"] = {":CocCommand fzf-preview.AllBuffers<CR>", "All buffers (fzf)"},
            -- ["<LocalLeader>;"] = {":CocCommand fzf-preview.Lines<CR>", "Buffer lines (fzf)"},
            ["<Leader>se"] = {":CocFzfList snippets<CR>", "Snippets (fzf)"},
            ["<A-[>"] = {":CocCommand fzf-preview.BufferTags<CR>", "List buffer tags (coc)"},
            ["<C-x><C-s>"] = {":CocFzfList symbols<CR>", "List workspace symbol (fzf)"},
            ["<C-x><C-o>"] = {":CocFzfList outline<CR>", "List workspace symbol (fzf)"},
            ["<C-x><C-l>"] = {":CocFzfList<CR>", "List coc commands (fzf)"},
            ["<C-x><C-r>"] = {":CocCommand fzf-preview.CocReferences<CR>", "List coc references"},
            ["<C-x><C-d>"] = {
                ":CocCommand fzf-preview.CocTypeDefinition<CR>",
                "List coc definitions"
            },
            ["<C-x><C-]>"] = {
                ":CocCommand fzf-preview.CocImplementations<CR>",
                "List coc implementations"
            },
            -- ["<C-x><C-h>"] = {":CocCommand fzf-preview.CocDiagnostics<CR>", "List coc diagnostics"},
            -- ["<LocalLeader>d"] = {":CocCommand fzf-preview.ProjectFiles<CR>", "Project files (fzf)"},
            -- ["<LocalLeader>g"] = {":CocCommand fzf-preview.GitFiles<CR>", "Git files (fzf)"},
            -- ["<M-/>"] = {":CocCommand fzf-preview.Marks<CR>", "Marks (fzf)"}
        }
    )

    -- map("n", "<Leader>C", ":CocCommand fzf-preview.Changes<CR>", { silent = true })
    map({"n", "s"}, "<C-f>", [[v:lua.require'plugs.coc'.scroll(v:true)]], shexpr)
    map({"n", "s"}, "<C-b>", [[v:lua.require'plugs.coc'.scroll(v:false)]], shexpr)
    map("i", "<C-f>", [[v:lua.require'plugs.coc'.scroll_insert(v:true)]], shexpr)
    map("i", "<C-b>", [[v:lua.require'plugs.coc'.scroll_insert(v:false)]], shexpr)

    map("n", "<Leader>sf", [[<Cmd>CocCommand clangd.switchSourceHeader<CR>]])
end

return M
