local M = {}

local log = require("common.log")
local utils = require("common.utils")
local command = utils.command
local map = utils.map
local augroup = utils.augroup

local C = require("common.color")

local wk = require("which-key")
local promise = require("promise")

local fn = vim.fn
local g = vim.g
local api = vim.api
local ex = nvim.ex

local diag_qfid

-- FIX: Diagnostic signs don't disappear as quick as they used to
--      Sometimes needing file to be saved. Other times that not working either

---Get the nearest symbol in reference to the location of the cursor
---@return string
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
        api.nvim_feedkeys(utils.termcodes["<C-]>"], "n", false)
        by = "tag"
    else
        local err, res = M.a2sync("jumpDefinition", {"drop"})
        if not err then
            by = "coc"
        elseif res == "timeout" then
            log.warn("Go to reference timeout", true)
        else
            local cword = fn.expand("<cword>")
            if
                not pcall(
                    function()
                        local wv = fn.winsaveview()
                        ex.ltag(cword)
                        local def_size = fn.getloclist(0, {size = 0}).size
                        by = "ltag"
                        if def_size > 1 then
                            api.nvim_set_current_buf(cur_bufnr)
                            fn.winrestview(wv)
                            ex.abo("lw")
                        elseif def_size == 1 then
                            ex.lcl()
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
        utils.cool_echo("go2def: " .. by, "Special")
    end
end

-- Use K to show documentation in preview window
function M.show_documentation()
    local ft = vim.bo.ft
    if _t({"help", "vim"}):contains(ft) then
        cmd(("sil! h %s"):format(fn.expand("<cword>")))
    elseif ft == "man" then
        ex.Man(("%s"):format(fn.expand("<cword>")))
    elseif fn.expand("%:t") == "Cargo.toml" then
        require("crates").show_popup()
    elseif fn["coc#rpc#ready"]() then
        -- definitionHover -- doHover
        local err, res = M.a2sync("definitionHover")
        if err then
            if res == "timeout" then
                log.warn("Show documentation timeout", true)
            end
            cmd("norm! K")
        end
    else
        cmd(("!%s %s"):format(o.keywordprg, fn.expand("<cword>")))
    end
end

---CocActionAsync
---@param action string: CocAction to run
---@param args table: Arguments to pass to that CocAction
---@param time number?: Time to wait for action to be performed
---@return string string: Error, result
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
            return done
        end
    )
    err = err or not wait_ret
    if not wait_ret then
        res = "timeout"
    end
    return err, res
end

-- TODO: Learn how to use Promises
---Run an asynchronous CocAction using a Javascript type framework of Promise
---@param action string
---@vararg table
---@return function
function M.action(action, ...)
    local args = {...}
    return promise(
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
                        resolve(res)
                    end
                end
            )
            fn.CocActionAsync(action, unpack(args))
        end
    )
end

-- Code actions
function M.code_action(mode, only)
    if type(mode) == "string" then
        mode = {mode}
    end
    local no_actions = true
    for _, m in ipairs(mode) do
        local err, ret = M.a2sync("codeActions", {m, only}, 1000)
        if err then
            if ret == "timeout" then
                log.warn("codeAction timeout", true)
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
        log.warn("No code Action available", true)
    end
end

---Jump to location list. Ran on `CocLocationsChange`
function M.jump2loc(locs, skip)
    locs = locs or g.coc_jump_locations
    fn.setloclist(0, {}, " ", {title = "CocLocationList", items = locs})
    if not skip then
        local winid = fn.getloclist(0, {winid = 0}).winid
        if winid == 0 then
            ex.abo("lw")
        else
            api.nvim_set_current_win(winid)
        end
    end
end

---Accept the completion
function M.accept_complete()
    local mode = api.nvim_get_mode().mode
    if mode == "i" then
        return utils.termcodes["<C-l>"]
    elseif mode == "ic" then
        local ei_bak = vim.o.ei
        vim.o.ei = "CompleteDone"
        vim.schedule(
            function()
                vim.o.ei = ei_bak
                fn.CocActionAsync("stopCompletion")
            end
        )
        return utils.termcodes["<C-y>"]
    else
        return utils.termcodes["<Ignore>"]
    end
end

---Coc rename
function M.rename()
    g.coc_jump_locations = nil
    fn.CocActionAsync(
        "rename",
        "",
        function(err, res)
            if err == vim.NIL and res then
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

---Fill quickfix with CocDiagnostics
---@param winid number
---@param nr boolean
---@param keep boolean
function M.diagnostic(winid, nr, keep)
    fn.CocActionAsync(
        "diagnosticList",
        "",
        function(err, res)
            if err == vim.NIL then
                local items = {}
                for _, d in ipairs(res) do
                    local text =
                        ("[%s%s] %s"):format(
                        (d.source == "" and "coc.nvim" or d.source),
                        (d.code == vim.NIL and "" or " " .. d.code),
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
                        ex.bo("cope")
                    else
                        api.nvim_set_current_win(winid)
                    end
                    ex.sil(("%dchi"):format(nr))
                end
            end
        end
    )
end

---Run a Coc command
---@param name string
---@param args table
---@param cb function
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

---Provide a higlighting fallback on cursor hold
---i.e., this will show non-treesitter highlighting on cursor hold
M.hl_fallback =
    (function()
    local fb_bl_ft = {
        "qf",
        "fzf",
        "vim",
        "sh",
        "python",
        "go",
        "c",
        "cpp",
        "rust",
        "java",
        "lua",
        "typescript",
        "javascript",
        "css",
        "html",
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
        if vim.tbl_contains(fb_bl_ft, ft) or nvim.mode().mode == "t" then
            return
        end

        local m_id, winid = unpack(hl_fb_tbl)
        pcall(fn.matchdelete, m_id, winid)

        winid = api.nvim_get_current_win()
        m_id = fn.matchadd("CocHighlightText", cur_word_pat(), -1, -1, {window = winid})
        hl_fb_tbl = {m_id, winid}
    end
end)()

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
function M.check_backspace()
    -- local col = fn.col(".") - 1
    -- return col or (fn.getline(".")[col - 1]):match([[\s]])

    local _, col = unpack(api.nvim_win_get_cursor(0))
    return (col == 0 or api.nvim_get_current_line():sub(col, col):match("%s")) and true
end

---Check whether Coc has been initialized
---@param silent boolean
---@return boolean
function M.did_init(silent)
    if g.coc_service_initialized == 0 then
        if silent then
            log.warn([[coc.nvim hasn't initialized]], true)
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
            log.warn("organizeImport timeout", true)
        else
            log.warn("No action for organizeImport", true)
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
        #fn["coc#float#get_float_win_list"]() > 0 and fn.pumvisible() == 0 and
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
        local err, res = M.a2sync("showOutline", {1})
        if not err then
            if res == "timeout" then
                log.warn("Show outline timeout", true)
            end
            ex.wincmd("l")
        end
    else
        fn["coc#window#close"](winid)
    end
end

-- If this is ran in `init.lua` the command is not overwritten
M.tag_cmd = function()
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

---Adds all lua runtime paths to coc
---@param sumneko boolean?
---@return table
M.get_lua_runtime = function(sumneko)
    local result = {}

    local function add(lib)
        for _, path in pairs(fn.expand(lib .. "/lua", false, true)) do
            path = uv.fs_realpath(path)
            if path and fn.isdirectory(path) then
                result[path] = true
            end
        end
    end

    add("$VIMRUNTIME")

    for _, site in pairs(vim.split(vim.o.packpath, ",")) do
        add(site .. "/pack/*/opt/*")
        add(site .. "/pack/*/start/*")
    end

    for _, run in pairs(api.nvim_list_runtime_paths()) do
        add(run)
    end

    if sumneko then
        add(require("lua-dev.sumneko").types())
    end

    return result
end

--- Setup the Lua language-server
function M.lua_langserver()
    local bin = fn["coc#util#get_config"]("languageserver.lua").command
    local main = fn.fnamemodify(bin, ":h") .. "/main.lua"

    fn["coc#config"]("languageserver.lua", {args = {"-E", main}})

    local settings = fn["coc#util#get_config"]("languageserver.lua").settings

    -- This only works with max397574's fork
    local luadev = require("lua-dev").setup({}).settings
    settings = vim.tbl_deep_extend("force", settings, luadev)

    -- fn["coc#config"]("languageserver.lua.settings.Lua.workspace", {library = M.get_lua_runtime()})
    fn["coc#config"]("languageserver.lua", {settings = settings})

    -- Add async library to Lua workspace library
    local library = fn["coc#util#get_config"]("languageserver.lua").settings.Lua.workspace.library
    local promise = ("%s/typings"):format(_G.packer_plugins["promise-async"].path)
    library = vim.tbl_deep_extend("force", library, {[promise] = true})
    fn["coc#config"]("languageserver.lua.settings.Lua.workspace", {library = library})
end

---Setup the Sumneko-Coc Lua language-server
---Note that the runtime paths here are placed into an array, not a table
function M.sumneko_ls()
    local library = fn["coc#util#get_config"]("Lua").workspace.library
    local runtime = _t(M.get_lua_runtime(true)):keys()
    library = vim.tbl_deep_extend("force", library, runtime)

    local promise = ("%s/typings"):format(_G.packer_plugins["promise-async"].path)
    library = vim.tbl_deep_extend("force", library, {promise})

    fn["coc#config"]("Lua.workspace", {library = library})
end

-- ========================== Init ==========================

M.value = 100

function M.init()
    diag_qfid = -1

    -- TODO: Prevent having to setup both
    -- An error for lua.filetypes is shown
    M.sumneko_ls()
    M.lua_langserver()

    g.coc_fzf_opts = {"--no-border", "--layout=reverse-list"}

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
            end
        },
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
                ex.pa("nvim-bqf")
                require("bqf.magicwin.handler").attach()
            end
        },
        {
            event = "VimLeavePre",
            pattern = "*",
            -- command = [[if get(g:, 'coc_process_pid', 0) | call system('kill -9 -- -' . g:coc_process_pid) | endif]]
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

    C.plugin(
        "Coc",
        {
            CocSemVariable = {link = "TSVariable"},
            CocSemNamespace = {link = "Namespace"},
            CocSemClass = {link = "Function"},
            CocSemEnum = {link = "Number"},
            CocSemEnumMember = {link = "Enum"}
        }
    )

    -- CocCommand semanticTokens.inspect

    --     CocSemNamespace              CocSemType                  CocSemClass                   CocSemEnum
    --     CocSemInterface             CocSemStruct             CocSemTypeParameter             CocSemParameter
    --      CocSemVariable            CocSemProperty             CocSemEnumMember                 CocSemEvent
    --      CocSemFunction             CocSemMethod                 CocSemMacro                  CocSemKeyword
    --      CocSemModifier            CocSemComment                CocSemString                  CocSemNumber
    --      CocSemBoolean              CocSemRegexp               CocSemOperator                CocSemDecorator
    --     CocSemDeprecated        CocSemDefaultLibrary      CocSemDefaultLibraryClass   CocSemDefaultLibraryInterface
    -- CocSemDefaultLibraryEnum  CocSemDefaultLibraryType  CocSemDefaultLibraryNamespace       CocSemDeclaration
    --  CocSemDeclarationClass  CocSemDeclarationInterface     CocSemDeclarationEnum         CocSemDeclarationType
    -- CocSemDeclarationNamespace

    -- use `:Fold` to fold current buffer
    -- command("Fold", [[:call CocAction('fold', <f-args>)]], {nargs = "?"})
    -- command("CocMarket", [[:CocFzfList marketplace]], {nargs = 0})
    -- command("Prettier", [[:CocCommand prettier.formatFile]], {nargs = 0})
    -- command("Format", [[:call CocAction('format')]], {nargs = 0})
    -- command("OR", [[:call CocAction('runCommand', 'editor.action.organizeImport')]], {nargs = 0})
    -- command("CocOutput", [[CocCommand workspace.showOutput]], {nargs = 0})
    -- command("DiagnosticToggleBuffer", [[call CocAction('diagnosticToggleBuffer')]], {nargs = 0})

    require("legendary").bind_commands(
        {
            {
                ":CocMarket",
                [[:CocFzfList marketplace]],
                description = "Fzf Marketplace",
                opts = {nargs = 0}
            },
            {
                ":Prettier",
                [[:CocCommand prettier.formatFile]],
                description = "Format file with prettier",
                opts = {nargs = 0}
            },
            {
                ":Format",
                [[:call CocAction('format')]],
                description = "Format file with coc",
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
            }
        }
    )

    wk.register(
        {
            ["<C-A-'>"] = {"<cmd>lua require('plugs.coc').toggle_outline()<CR>", "Coc outline"},
            ["<C-x><C-s>"] = {":CocFzfList symbols<CR>", "List workspace symbol (fzf)"},
            ["<C-x><C-o>"] = {":CocFzfList outline<CR>", "List workspace symbol (fzf)"},
            ["<A-'>"] = {":CocFzfList yank<CR>", "List coc-yank (fzf)"},
            ["<C-x><C-l>"] = {":CocFzfList<CR>", "List coc commands (fzf)"},
            ["<C-x><C-d>"] = {":CocCommand fzf-preview.CocTypeDefinition<CR>", "List coc definitions"},
            -- ["<C-x><C-r>"] = {":CocCommand fzf-preview.CocReferences<CR>", "List coc references"},
            ["<C-x><C-]>"] = {":CocCommand fzf-preview.CocImplementations<CR>", "List coc implementations"},
            ["<C-x><C-h>"] = {":CocCommand fzf-preview.CocDiagnostics<CR>", "List coc diagnostics"},
            ["<A-[>"] = {":CocCommand fzf-preview.BufferTags<CR>", "List buffer tags (coc)"},
            -- ["<LocalLeader>t"] = {":CocCommand fzf-preview.BufferTags<CR>", "List buffer tags (coc)"},
            ["[g"] = {":call CocAction('diagnosticPrevious')<CR>", "Goto previous diagnostic"},
            ["]g"] = {":call CocAction('diagnosticNext')<CR>", "Goto next diagnostic"},
            ["<Leader>?"] = {":call CocAction('diagnosticInfo')<CR>", "Show diagnostic popup"},
            ["gd"] = {":lua require('plugs.coc').go2def()<CR>", "Goto definition"},
            ["gy"] = {":call CocActionAsync('jumpTypeDefinition', 'drop')<CR>", "Goto type definition"},
            ["gD"] = {":call CocActionAsync('jumpDeclaration', 'drop')<CR>", "Goto declaration"},
            ["gi"] = {":call CocActionAsync('jumpImplementation', 'drop')<CR>", "Goto implementation"},
            ["gr"] = {":call CocActionAsync('jumpUsed', 'drop')<CR>", "Goto used instances"},
            ["gR"] = {":call CocActionAsync('jumpReferences', 'drop')<CR>", "Goto references"},
            ["<A-q>"] = {":lua vim.notify(require'plugs.coc'.getsymbol())<CR>", "Get current symbol"},
            ["<Leader>j;"] = {":lua require('plugs.coc').diagnostic()<CR>", "Coc diagnostics (project)"},
            ["<Leader>j,"] = {":CocDiagnostics<CR>", "Coc diagnostics (current buffer)"},
            ["<Leader>jr"] = {
                ":call CocActionAsync('diagnosticRefresh', 'drop')<CR>",
                "Coc diagnostics (current buffer)"
            },
            -- ["<Leader>jd"] = {":CocDiagnostics<CR>", "Coc diagnostics (current buffer)"},
            ["<Leader>rn"] = {":lua require('plugs.coc').rename()<CR>", "Coc rename"},
            ["<Leader>fm"] = {"<Plug>(coc-format-selected)", "Format selected (action)"},
            ["<Leader>qf"] = {"<Plug>(coc-fix-current)", "Fix diagnostic on line"},
            -- ["[c"] = {"<Plug>(coc-git-prevconflict)", "Goto previous conflict"},
            -- ["]c"] = {"<Plug>(coc-git-nextconflict)", "Goto next conflict"},
            -- ["gC"] = {"<Plug>(coc-git-commit)", "Show commits in current position"},
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
    -- map("n", "<Leader>jo", "<cmd>lua require('code_action_menu').open_code_action_menu()<CR>")
    -- map("n", "<Leader>jl", "<cmd>lua require('code_action_menu').open_code_action_menu('line')<CR>")
    -- map("n", "<Leader>jc", "<cmd>lua R('code_action_menu').open_code_action_menu('cursor')<CR>")
    -- map("n", "<Leader>je", "<cmd>lua R('code_action_menu').open_code_action_menu('')<CR>")

    -- FIX: Empty one doesn't fit popup window correctly and messes up scrolloff
    -- map("n", "<C-CR>", "<cmd>lua R('code_action_menu').open_code_action_menu('')<CR>")
    map("n", "<A-CR>", "<cmd>lua R('code_action_menu').open_code_action_menu('cursor')<CR>")
    map("n", "<C-A-CR>", "<cmd>lua require('code_action_menu').open_code_action_menu('line')<CR>")

    map("x", "<A-CR>", [[:<C-u>lua require('plugs.coc').code_action(vim.fn.visualmode())<CR>]])
    -- map("n", "<C-CR>", "<Plug>(coc-codeaction)")
    -- map("x", "<Leader>w", "<Plug>(coc-codeaction-selected)")
    -- map("n", "<Leader>ww", "<Plug>(coc-codeaction-selected)")

    wk.register(
        {
            ["<Leader>fm"] = {"<Plug>(coc-format-selected)", "Format selected"}
        },
        {mode = "x"}
    )

    -- map("n", "<A-c>", ":CocFzfList commands<CR>")
    -- map("n", "<C-x><C-r>", ":CocCommand fzf-preview.CocReferences<CR>")
    -- map("n", "<A-]>", ":CocCommand fzf-preview.VistaBufferCtags<CR>")

    -- map("s", "<BS>", '<C-g>"_c')
    map("s", "<Del>", '<C-g>"_c')
    map("s", "<C-h>", '<C-g>"_c')
    map("s", "<C-w>", "<Esc>a")

    -- map("s", "<C-o>", "<Nop>")
    -- map("s", "<C-o>o", "<Esc>a<C-o>o")

    -- map("n", "[g", "<Plug>(coc-diagnostic-prev)", { noremap = false })
    -- map("n", "]g", "<Plug>(coc-diagnostic-next)", { noremap = false })
    -- map("n", "gd", "<Plug>(coc-definition)", { noremap = false, silent = true })
    -- map("n", "gy", "<Plug>(coc-type-definition)", { noremap = false })
    -- map("n", "gi", "<Plug>(coc-implementation)", { noremap = false })
    -- map("n", "gr", "<Plug>(coc-references)", { noremap = false, silent = false })
    -- map("n", "<Leader>rn", "<Plug>(coc-rename)", { noremap = false })

    -- Create mappings for function text object
    -- map("x", "if", "<Plug>(coc-funcobj-i)", { noremap = false })
    -- map("x", "af", "<Plug>(coc-funcobj-a)", { noremap = false })
    -- map("o", "if", "<Plug>(coc-funcobj-i)", { noremap = false })
    -- map("o", "af", "<Plug>(coc-funcobj-a)", { noremap = false })

    -- Refresh coc completions
    map("i", "<C-'>", "coc#refresh()", {expr = true, silent = true})

    -- Popup
    map("i", "<Tab>", [[pumvisible() ? coc#_select_confirm() : "\<C-g>u\<tab>"]], {expr = true, silent = true})
    -- map("i", "<S-Tab>", [[pumvisible() ? "\<C-p>" : "\<C-h>"]], {expr = true, silent = true})

    -- map(
    --     "i",
    --     "<Tab>",
    --     [[pumvisible() ? coc#_select_confirm() : ]] ..
    --         [[coc#expandableOrJumpable() ? ]] ..
    --             [["\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" : ]] ..
    --                 [[v:lua.require'plugs.coc'.check_backspace() ? "\<TAB>" : ]] .. [[coc#refresh()]],
    --     {expr = true, silent = true}
    -- )

    -- map(
    --     "i", "<Tab>",
    --     [[pumvisible() ? "\<C-n>" : v:lua.check_back_space() ? "\<TAB>" : coc#refresh()]],
    --     { silent = true, expr = true }
    -- )

    map("i", "<C-m>", [[v:lua.require'plugs.coc'.accept_complete()]], {expr = true})

    -- Git
    -- wk.register(
    --     {
    --         -- ["<Leader>gD"] = {":CocCommand git.diffCached<CR>", "Git diff cached"},
    --         ["<LocalLeader>gg"] = {":CocCommand fzf-preview.GitActions<CR>", "Git actions (fzf)"},
    --         ["<LocalLeader>gs"] = {":CocCommand fzf-preview.GitStatus<CR>", "Git status (fzf)"},
    --         ["<LocalLeader>gr"] = {":CocCommand fzf-preview.GitLogs<CR>", "Git logs (fzf)"},
    --         ["<LocalLeader>gp"] = {":<C-u>CocList --normal gstatus<CR>", "Git status"},
    --         ["<LocalLeader>gu"] = {":<C-u>CocCommand git.chunkUndo<CR>", "Git chunk undo"}
    --     }
    -- )

    -- Git
    -- map("n", ",ga", ":<C-u>CocCommand git.chunkStage<CR>", {silent = true})
    -- map("n", "<Leader>go", ":<C-u>CocCommand git.browserOpen<CR>", {silent = true})
    -- map("n", "<Leader>gla", ":<C-u>CocFzfList commits<cr>", {silent = true})
    -- map("n", "<Leader>glc", ":<C-u>CocFzfList bcommits<cr>", {silent = true})
    -- map("n", "<Leader>gF", ":<C-u>CocCommand git.foldUnchanged<CR>", {silent = true})

    -- nmap <silent> gs <Plug>(coc-git-chunkinfo)
    -- map("n", "<Leader>gll", "<Plug>(coc-git-commit)", {noremap = true, silent = true})

    -- map("n", "{g", "<Plug>(coc-git-prevchunk)")
    -- map("n", "}g", "<Plug>(coc-git-nextchunk)")

    -- Show chunk diff at current position
    -- map("n", "gs", "<Plug>(coc-git-chunkinfo)", { noremap = false })

    -- Snippet
    map("i", "<C-]>", [[!get(b:, 'coc_snippet_active') ? "\<C-]>" : "\<C-j>"]], {expr = true, noremap = false})
    map("s", "<C-]>", [[v:lua.require'plugs.coc'.skip_snippet()]], {expr = true})

    -- Fzf
    wk.register(
        {
            ["<Leader>ab"] = {":CocCommand fzf-preview.AllBuffers<CR>", "All buffers (fzf)"},
            ["<LocalLeader>;"] = {":CocCommand fzf-preview.Lines<CR>", "Buffer lines (fzf)"},
            ["<Leader>se"] = {":CocFzfList snippets<CR>", "Snippets (fzf)"}
            -- ["<LocalLeader>d"] = {":CocCommand fzf-preview.ProjectFiles<CR>", "Project files (fzf)"},
            -- ["<LocalLeader>g"] = {":CocCommand fzf-preview.GitFiles<CR>", "Git files (fzf)"},
            -- ["<M-/>"] = {":CocCommand fzf-preview.Marks<CR>", "Marks (fzf)"}
        }
    )

    -- map("n", "<Leader>C", ":CocCommand fzf-preview.Changes<CR>", { silent = true })

    map({"n", "s"}, "<C-f>", [[v:lua.require'plugs.coc'.scroll(v:true)]], {expr = true, silent = true})
    map({"n", "s"}, "<C-b>", [[v:lua.require'plugs.coc'.scroll(v:false)]], {expr = true, silent = true})
    map("i", "<C-f>", [[v:lua.require'plugs.coc'.scroll_insert(v:true)]], {expr = true, silent = true})
    map("i", "<C-b>", [[v:lua.require'plugs.coc'.scroll_insert(v:false)]], {expr = true, silent = true})

    map("n", "<Leader>sf", [[<Cmd>CocCommand clangd.switchSourceHeader<CR>]])
    -- map("n", "<Leader>st", [[<Cmd>CocCommand go.test.toggle<CR>]])
    -- map("n", "<Leader>tf", [[<Cmd>CocCommand go.test.generate.function<CR>]])
    -- map("x", "<Leader>tf", [[:CocCommand go.test.generate.function<CR>]])
end

return M
