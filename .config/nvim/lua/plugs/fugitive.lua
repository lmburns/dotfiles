---@diagnostic disable: param-type-mismatch
---@module 'plugs.fugitive'
local M = {}

local F = Rc.F
local utils = Rc.shared.utils
local pl = utils.pl
local fs = utils.fs
local op = Rc.lib.op
local C = Rc.shared.C

local W = Rc.api.win
local T = Rc.api.tab
local map = Rc.api.map
local bmap = Rc.api.bmap0
local augroup = Rc.api.augroup
local autocmd = Rc.api.autocmd

local wk = require("which-key")

local cmd = vim.cmd
local fn = vim.fn
local g = vim.g
local api = vim.api

-- vim.b.gitsigns_status_dict.head
-- vim.b.gitsigns_status_dict.root
-- vim.b.gitsigns_status_dict.gitdir

function M.index()
    local bufname = api.nvim_buf_get_name(0)
    if fn.winnr("$") == 1 and bufname == "" then
        cmd.Git()
    else
        cmd.Git({mods = {tab = 1}})
    end
    if bufname == "" then
        -- cmd.bw({"#", bang = true, mods = {silent = true, noautocmd = true}})
        cmd("sil! noa bw #")
    end
end

function M.fugitive_detect()
    if not vim.b.git_dir then
        fn.FugitiveDetect()
    end
end

-- placeholder for Git difftool --name-only
function M.diff_hist()
    local info = fn.getqflist({idx = 0, context = 0})
    local idx, ctx = info.idx, info.context
    if idx and ctx and type(ctx.items) == "table" then
        local diff = ctx.items[idx].diff or {}
        if #diff == 1 then
            cmd("abo vert diffs " .. diff[1].filename)
            cmd.winc("p")
        end
    end
end

local function which_key_register()
    wk.register({
        s = "Fug: stage file",
        u = "Fug: unstage file",
        a = "Fug: (un)stage file or hunk",
        U = "Fug: unstage all",
        x = "Fug: discard change under cursor",
        ["<Tab>"] = "Fug: toggle inline diff",
        [">"] = "Fug: insert inline diff",
        ["<"] = "Fug: remove inline diff",
        gI = "Fug: open .../exclude in split; add file under cursor",
        I = "Fug: :Git add --patch/reset --patch",
        P = "Fug: :Git add --patch/reset --patch",
        --  ══════════════════════════════════════════════════════════════════════
        dp = "Fug: git diff",
        dd = "Fug: :Gdiffsplit",
        dv = "Fug: :Gvdiffsplit",
        ds = "Fug: :Ghdiffsplit",
        dh = "Fug: :Ghdiffsplit",
        dq = "Fug: close all but one diff & :diffoff last",
        ["d?"] = "Fug: diff help",
        --  ══════════════════════════════════════════════════════════════════════
        ["<CR>"] = "Fug: open file",
        o = "Fug: open file in split",
        gO = "Fug: open file in vert split",
        T = "Fug: open file in new tab",
        p = "Fug: open file in preview win",
        ["~"] = "Fug: open file in [c] ancestor",
        -- P =  "Fug: open file in [count] parent",
        C = "Fug: open commit containing curfile",
        ["{"] = "Fug: jump prev file, hunk, revision",
        ["}"] = "Fug: jump next file, hunk, revision",
        ["]c"] = "Fug: next hunk",
        ["[c"] = "Fug: prev hunk",
        ["[f"] = "Fug: jump prev file, close inline diffs",
        ["]f"] = "Fug: jump next file, close inline diffs",
        -- ["[/"] = "Fug: jump to previous file, close inline diffs",
        -- ["]/"] = "Fug: jump to next file, close inline diffs",
        i = "Fug: jump to next file/hunk expanding inline diffs",
        ["[["] = "Fug: [c] prev sections",
        ["]]"] = "Fug: [c] next sections",
        ["[e"] = "Fug: [c] prev sections end",
        ["]e"] = "Fug: [c] next sections end",
        -- ["#"] = "Fug: search forward",
        -- ["*"] = "Fug: search backwards",
        gu = "Fug: jump file [c] unstaged/untracked section",
        gU = "Fug: jump file [c] unstaged section",
        gs = "Fug: jump file [c] staged section",
        gp = "Fug: jump file [c] unpushed section",
        gP = "Fug: jump file [c] unpulled section",
        gr = "Fug: jump file [c] rebasing section",
        gi = "Fug: open split .git/info/exclude",
        --  ══════════════════════════════════════════════════════════════════════
        cc = "Fug: create commit",
        ca = "Fug: amend last commit, edit msg",
        ce = "Fug: amend last commit, don't edit msg",
        cw = "Fug: reword last commit",
        cvc = "Fug: create commit with -v",
        cva = "Fug: amend last commit with -v",
        cf = "Fug: create fixup commit under cursor",
        cF = "Fug: create fixup-commit & rebase",
        cs = "Fug: create squash commit",
        cS = "Fug: create squash commit & rebase",
        cA = "Fug: create squash commit & edit",
        ["c<Space>"] = "Fug: pop CLI with `Git commit`",
        crc = "Fug: rev commit under cursor",
        crn = "Fug: rev commit in worktree don't commit",
        ["cr<Space>"] = "Fug: pop CLI with `Git revert`",
        ["cm<Space>"] = "Fug: pop CLI with `Git merge`",
        ["c?"] = "Fug: commit help",
        --  ══════════════════════════════════════════════════════════════════════
        coo = "Fug: checkout commit under cursor",
        ["cb<Space>"] = "Fug: pop CLI with `Git branch`",
        ["co<Space>"] = "Fug: pop CLI with `Git checkout`",
        ["cb?"] = "Fug: checkout help",
        ["co?"] = "Fug: checkout help",
        --  ══════════════════════════════════════════════════════════════════════
        czz = "Fug: push stash ([cnt]: 1=inc-untracked, 2=all)",
        czw = "Fug: push stash of worktree",
        czs = "Fug: push stash of stage",
        czA = "Fug: apply top stash[@[count]]",
        cza = "Fug: apply top stash[@[count]] preserve index",
        czP = "Fug: pop top stash[@[count]]",
        czp = "Fug: pop top stash[@[count]] preserve index",
        ["cz<Space>"] = "Fug: populate cli with Git stash",
        ["cz?"] = "Fug: stash help",
        --  ══════════════════════════════════════════════════════════════════════
        ri = "Fug: interactive rebase",
        -- u = "Fug: interactive rebase",
        rf = "Fug: autosquash rebase w/o editing todo list",
        ru = "Fug: i rebase against @{upstream}",
        rp = "Fug: i rebase against @{push}",
        rr = "Fug: continue cur rebase",
        rs = "Fug: skip cur commit & continue cur rebase",
        ra = "Fug: abort cur rebase",
        re = "Fug: edit cur rebase todo list",
        rw = "Fug: i-rebase, commit set to `reword`",
        rm = "Fug: i-rebase, commit set to `edit`",
        rd = "Fug: i-rebase, commit set to `drop`",
        ["r<Space>"] = "Fug: populate command line with ':Git rebase '",
        ["r?"] = "Fug: rebase help",
        --  ══════════════════════════════════════════════════════════════════════
        gq = "Fug: close status buffer",
        ["."] = "Fug: open cli with file under cursor prepopulated",
        ["g?"] = "Fug: help: fugitive overall",
        -- d2o = "d2o",
        -- d3o = "d3o",
        -- ["<C-W>gf"] = "gF",
        -- a = "",
    }, {buffer = 0})
end

local function find_usable_tabs()
    local all = api.nvim_list_tabpages()
    local fugitive_tabs = vim.tbl_filter(function(v)
        return vim.t[v].fugitive_form == "tab"
    end, all)
    local other_tabs = C.vec_diff(all, fugitive_tabs)
    local prev_tab = T.tab_nr2id(fn.tabpagenr("#")) or -1

    if api.nvim_tabpage_is_valid(prev_tab) and not C.vec_indexof(fugitive_tabs, prev_tab) then
        return C.vec_join(prev_tab, other_tabs)
    else
        return other_tabs
    end
end

M.sid_cache = {}

---Get the script ID of a fugitive script file.
---@param file? string Fugitive script file name (default: "autoload/fugitive.vim")
---@return integer?
function M.get_sid(file)
    file = file or "autoload/fugitive.vim"
    if M.sid_cache[file] then
        return M.sid_cache[file]
    end

    local info = utils.get_sid(file)
    -- local script_entry = Rc.api.exec_output(("filter #vim-fugitive.*/%s# scriptnames"):format(file), true)
    -- M.sid_cache[file] = tonumber(script_entry:match("^(%d+)")) --[[@as integer]]
    M.sid_cache[file] = info.sid

    return M.sid_cache[file]
end

---Call a fugitive function.
---@param file_or_sid string|integer name of fugitive script file to call from, or SID of its script (0 = "autoload/fugitive.vim")
---@param func string Function name
---@param ... any Arguments.
---@return unknown
function M.call(file_or_sid, func, ...)
    local sid
    if type(file_or_sid) == "number" then
        if file_or_sid == 0 then
            sid = M.get_sid()
        else
            sid = file_or_sid
        end
    else
        sid = M.get_sid(file_or_sid --[[@as string ]])
    end

    return vim.call(("<SNR>%d_%s"):format(sid, func), ...)
end

---Get the fugitive context for the item under the cursor.
---@return table?
function M.get_status_cursor_info()
    if vim.bo.ft ~= "fugitive" then return end
    return M.call(0, "StageInfo", Rc.api.get_cursor_row())
end

---@return table?
function M.get_blame_cursor_info()
    if vim.bo.ft ~= "fugitiveblame" then return end
    local state = M.call(0, "TempState")
    local cursor = Rc.api.get_cursor()
    local line = api.nvim_buf_get_lines(0, cursor[1] - 1, cursor[1], false)[1]

    return {
        file = pl:join(state.cwd, state.blame_file),
        commit = line:match("^([a-f0-9]+)"),
    }
end

---@param tabid integer
---@return Vector<integer>
local function find_commit_views(tabid)
    return vim.tbl_filter(
        function(v)
            if fn.win_gettype(v) ~= "" then
                return false
            end
            return vim.w[v].fugitive_type == "commit_view"
        end,
        api.nvim_tabpage_list_wins(tabid)
    )
end

function M.map()
    which_key_register()
    bmap(
        "n",
        "dt",
        ":Gtabedit <Plug><cfile><Bar>Gdiffsplit! @<CR>",
        {desc = "Gtabedit", silent = true, noremap = false}
    )
    bmap(
        "n",
        "<LocalLeader>gb",
        [['@_:.GBrowse '.(v:count ? '@' : '<CR>')]],
        {expr = true, desc = "GBrowse"}
    )
    bmap(
        "n",
        "<LocalLeader>gb",
        [[':.GBrowse '.(v:count?'@':'<cr>')]],
        {expr = true, desc = "GBrowse"}
    )
    bmap("n", "<LocalLeader>gb", "GBrowse", {desc = "GBrowse"})
    bmap("n", "<A-p>", "Git pull", {desc = "Git pull", cmd = true})
    bmap("n", "S", "Git add -u", {desc = "Git add known files", cmd = true})
    bmap("n", "<C-s>", "Git add -A", {desc = "Git add/mod/del match worktree", cmd = true})
    bmap("n", "Q", F.ithunk(W.win_smart_close, {keep_last = true}), {desc = "Quit"})
    -- bmap("n", "P", "Git push", {desc = "Git push", cmd = true})
    bmap("n", "P", function()
        utils.confirm("Confirm git push? ", {
            default = true,
            callback = function(choice)
                if choice then cmd("Git push") end
            end,
        })
        -- local ans = fn.input("Confirm git push? ")
        -- if ans and ans:lower() == "y" then
        --     cmd("Git push")
        -- end
    end, {desc = "Git push"})

    bmap("n", "<CR>", function()
        local info = M.get_status_cursor_info()
        if not info then return end

        if #info.paths > 0 then
            if vim.t.fugitive_form ~= "tab" then
                cmd(M.call(0, "GF", "edit"))
            else
                local edit_kind = "edit"
                local tabs = find_usable_tabs()

                if #tabs == 0 then
                    edit_kind = "tabedit"
                else
                    api.nvim_set_current_tabpage(tabs[1])
                    local wins = W.find_usable(tabs[1])

                    if #wins == 0 then
                        edit_kind = "split"
                    else
                        api.nvim_set_current_win(wins[1])
                    end
                end

                cmd(
                    ("G%s %s %s | norm! zv"):format(
                        edit_kind,
                        info.offset and ("+" .. info.offset) or "",
                        fn.fnameescape(info.paths[1])
                    )
                )
            end
        elseif info.commit then
            local wins = find_commit_views(0)

            if #wins > 0 then
                api.nvim_set_current_win(wins[1])
            else
                local win_width = api.nvim_win_get_width(0)
                local win_height = api.nvim_win_get_height(0)
                cmd(win_width / 4 > win_height and "vsplit" or "split")
                vim.w.fugitive_type = "commit_view"
            end

            cmd(("Git ++curwin show --stat --patch --diff-merges=first-parent %s --")
                :format(info.commit))
        end
    end, {desc = "View file"})

    bmap("n", "DD", function()
        local info = M.get_status_cursor_info()
        if info then
            if #info.paths > 0 then
                cmd(("DiffviewOpen --selected-file=%s"):format(fn.fnameescape(info.paths[1])))
            elseif info.commit ~= "" then
                cmd(("DiffviewOpen %s^!"):format(info.commit))
            end
        end
    end, {desc = "Open Diffview for object"})

    bmap("n", "DH", function()
        local info = M.get_status_cursor_info()
        if info then
            if #info.paths > 0 then
                cmd(("DiffviewFileHistory %s"):format(fn.fnameescape(info.paths[1])))
            elseif info.commit ~= "" then
                cmd(("DiffviewFileHistory --range=%s"):format(info.commit))
            end
        end
    end, {desc = "Open DiffviewFileHistory for object"})
end

---Fugitive blame buffer mappings
function M.blame_map(buf)
    which_key_register()

    Rc.api.mv_keymap("n", "D", "n", "T", buf)

    bmap("n", "DD", function()
        local info = M.get_blame_cursor_info()

        if info then
            cmd(("DiffviewOpen %s^! --selected-file=%s")
                :format(info.commit, fn.fnameescape(info.file)))
        end
    end, {desc = "Open Diffview for blame"})

    bmap("n", "DH", function()
        local info = M.get_blame_cursor_info()

        if info then
            cmd(("DiffviewFileHistory --range=%s %s")
                :format(info.commit, fn.fnameescape(info.file)))
        end
    end, {desc = "Open file hist from blame"})
end

local function init()
    local bufname = api.nvim_buf_get_name(0)
    if bufname:find("/.git/index$") then
        vim.schedule(function()
            cmd(("doau fugitive BufReadCmd %s"):format(bufname))
        end)
    end

    g.nremap = {
        s = "s",                     -- stage file
        u = "u",                     -- unstage file
        ["-"] = "a",                 -- stage/unstage file or hunk under cursor
        U = "U",                     -- unstage everything
        X = "x",                     -- discard the change under the cursor
        ["="] = "<Tab>",             -- toggle inline diff
        [">"] = ">",                 -- insert inline diff
        ["<"] = "<",                 -- remove inline diff
        gI = "gI",                   -- open .git/info/exclude in a split & add file under cursor
        I = "I",                     -- :Git add --patch / reset --patch
        P = "P",                     -- :Git add --patch / reset --patch
        --  ══════════════════════════════════════════════════════════════════════
        dp = "dp",                   -- git diff
        dd = "dd",                   -- :Gdiffsplit
        dv = "dv",                   -- :Gvdiffsplit
        ds = "ds",                   -- :Ghdiffsplit
        dh = "dh",                   -- :Ghdiffsplit
        dq = "dq",                   -- close all but one diff buffer and :diffoff last
        ["d?"] = "d?",               -- diff help
        --  ══════════════════════════════════════════════════════════════════════
        ["<CR>"] = "O",              -- open file
        o = "o",                     -- open file in a split
        gO = "gO",                   -- open file in new vertical split
        O = "T",                     -- open file in a new tab
        p = "p",                     -- open file in preview window
        ["~"] = "~",                 -- open file in [count] ancestor
        -- P = "P",           -- open file in [count] parent
        C = "C",                     -- open the commit containing the current file
        ["("] = "{",                 -- jump to the previous file, hunk, or revision
        [")"] = "}",                 -- jump to the next file, hunk, or revision
        ["]c"] = "]c",               -- next hunk
        ["[c"] = "[c",               -- previous hunk
        ["[m"] = "[f",               -- jump to previous file, close inline diffs
        ["]m"] = "]f",               -- jump to next file, close inline diffs
        ["[/"] = "",                 -- jump to previous file, close inline diffs
        ["]/"] = "",                 -- jump to next file, close inline diffs
        i = "i",                     -- jump to next file/hunk expanding inline diffs
        ["[["] = "[[",               -- [count] sections backward
        ["]]"] = "]]",               -- [count] sections forward
        ["[]"] = "[e",               -- [count] sections end backward
        ["]["] = "]e",               -- [count] sections end forward
        ["#"] = "",                  -- search forward
        ["*"] = "",                  -- search backwards
        gu = "gu",                   -- jump file [count] unstaged/untracked section
        gU = "gU",                   -- jump file [count] unstaged section
        gs = "gs",                   -- jump file [count] staged section
        gp = "gp",                   -- jump file [count] unpushed section
        gP = "gP",                   -- jump file [count] unpulled section
        gr = "gr",                   -- jump file [count] rebasing section
        gi = "gi",                   -- open .git/info/exclude in a split
        --  ══════════════════════════════════════════════════════════════════════
        cc = "cc",                   -- create commit
        ca = "ca",                   -- amend last commit, edit msg
        ce = "ce",                   -- amend last commit, don't edit msg
        cw = "cw",                   -- reword last commit
        cvc = "cvc",                 -- create commit with -v
        cva = "cva",                 -- amend last commit with -v
        cf = "cf",                   -- create fixup commit for commit under cursor
        cF = "cF",                   -- create fixup commit for commit and rebase
        cs = "cs",                   -- create squash commit
        cS = "cS",                   -- create squash commit and rebase
        cA = "cA",                   -- create squash commit and edit
        ["c<Space>"] = "c<Space>",   -- populate cli with Git commit
        crc = "crc",                 -- revert commit under cursor
        crn = "crn",                 -- revert commit under cursor in worktree but dont commit
        ["cr<Space>"] = "cr<Space>", -- populate cli with Git revert
        ["cm<Space>"] = "cm<Space>", -- populate cli with Git merge
        ["c?"] = "c?",               -- commit help
        --  ══════════════════════════════════════════════════════════════════════
        coo = "coo",                 -- checkout commit under cursor
        ["cb<Space>"] = "cb<Space>", -- populate cli with Git branch
        ["co<Space>"] = "co<Space>", -- populate cli with Git checkout
        ["cb?"] = "cb?",             -- checkout help
        ["co?"] = "co?",             -- checkout help
        --  ══════════════════════════════════════════════════════════════════════
        czz = "czz",                 -- push stash ([count]: 1=include-untracked, 2=all)
        czw = "czw",                 -- push stash of worktree
        czs = "czs",                 -- push stash of stage
        czA = "czA",                 -- apply topmost stash or stash@[count]
        cza = "cza",                 -- apply topmost stash or stash@[count] preserve index
        czP = "czP",                 -- pop topmost stash or stash@[count]
        czp = "czp",                 -- pop topmost stash or stash@[count] preserve index
        ["cz<Space>"] = "cz<Space>", -- populate cli with Git stash
        ["cz?"] = "cz?",             -- stash help
        --  ══════════════════════════════════════════════════════════════════════
        ri = "ri",                   -- interactive rebase
        -- u = "u",                     -- interactive rebase
        rf = "rf",                   -- autosquash rebase without editing todo list
        ru = "ru",                   -- perform an interactive rebase against @{upstream}
        rp = "rp",                   -- perform an interactive rebase against @{push}
        rr = "rr",                   -- continue the current rebase
        rs = "rs",                   -- skip current commit and continue the current rebase
        ra = "ra",                   -- abort current rebase
        re = "re",                   -- edit current rebase todo list
        rw = "rw",                   -- interactive rebase, commit set to `reword`
        rm = "rm",                   -- interactive rebase, commit set to `edit`
        rd = "rd",                   -- interactive rebase, commit set to `drop`
        ["r<Space>"] = "r<Space>",   -- populate command line with ":Git rebase "
        ["r?"] = "r?",               -- rebase help
        --  ══════════════════════════════════════════════════════════════════════
        gq = "gq",                   -- Close the status buffer
        ["."] = ".",                 -- Open cli with file under cursor prepopulated
        ["g?"] = "g?",               -- Help: fugitive overall
        d2o = "d2o",
        d3o = "d3o",
        ["<C-W>gf"] = "gF",
        a = "",
    }

    g.xremap = {
        s = "S",
        u = "<C-u>",
        ["-"] = "a",
        X = "x",
    }

    nvim.autocmd.lmb__Fugitive = {
        {
            event = "User",
            pattern = {"FugitiveIndex", "FugitiveCommit"},
            command = function()
                require("plugs.fugitive").map()
                -- if fn["fugitive#buffer"]().type():vmatch([[^\%(tree\|blob\)]]) then
                -- end
            end,
        },
        -- {
        --     event = "User",
        --     pattern = "FugitiveChanged",
        --     command = function()
        --         local neogit = package.loaded.neogit
        --         if neogit then
        --             neogit.dispatch_refresh()
        --         end
        --     end,
        -- },
        {
            event = "User",
            pattern = "FugitiveIndex",
            command = (function()
                local ran = false
                return function(a)
                    if not ran then
                        local fline = api.nvim_buf_get_lines(a.buf, 0, 1, true)[1]
                        if fline:match("Head: ") then
                            utils.normal("m", "}")
                        end
                        ran = true

                        autocmd({
                            event = "BufDelete",
                            once = true,
                            command = function()
                                ran = false
                            end,
                        })
                    end
                end
            end)(),
        },
        {
            event = "BufReadPost",
            pattern = "fugitive://*",
            command = function()
                vim.o.bufhidden = "delete"
            end,
        },
        {
            event = "FileType",
            pattern = {"fugitiveblame"},
            command = function(a)
                require("plugs.fugitive").blame_map(a.buf)
            end,
        },
        {
            event = "FileType",
            pattern = "git",
            command = function()
                -- vim.o.bufhidden = "delete"

                bmap("n", "<CR>", function()
                    local commit, offset, postcmd = unpack(M.call(0, "cfile"))
                    if commit then
                        local wins = find_commit_views(0)
                        if #wins > 0 then
                            api.nvim_set_current_win(wins[1])
                            cmd(("Gedit %s %s %s"):format(
                                offset and ("+" .. offset) or "",
                                commit,
                                postcmd and ("|" .. postcmd) or ""
                            ))
                            return
                        end
                    end

                    cmd(M.call(0, "GF", "edit"))
                end, {desc = "Open file under cursor"})

                bmap("n", "DD", function()
                    local commit = unpack(M.call(0, "cfile"))
                    if commit then
                        if commit:find(":") then
                            local path
                            commit, path = commit:match("^(.-)^?:(.*)")
                            cmd(("DiffviewOpen %s^! --selected-file=%s"):format(
                                commit,
                                fn.fnameescape(pl:join(vim.call("FugitiveWorkTree"), path))
                            ))
                        else
                            cmd(("DiffviewOpen %s^!"):format(commit))
                        end
                    end
                end, {desc = "Open Diffview for object"})

                bmap("n", "DH", function()
                    local commit = unpack(M.call(0, "cfile"))
                    if commit then
                        if commit:find(":") then
                            local path
                            commit, path = commit:match("^(.-)^?:(.*)")
                            cmd(("DiffviewFileHistory --range=%s %s"):format(
                                commit,
                                fn.fnameescape(pl:join(vim.call("FugitiveWorkTree"), path))
                            ))
                        else
                            cmd(("DiffviewFileHistory --range=%s"):format(commit))
                        end
                    end
                end, {desc = "Open DiffviewFileHistory for object"})
            end,
        },
    }

    cmd.packadd("vim-rhubarb")

    wk.register({
        ["<LocalLeader>gg"] = {M.index, "Fugitive: index"},
        ["<LocalLeader>ge"] = {"<Cmd>Gedit<CR>", "Fugitive: Gedit"},
        ["<LocalLeader>gR"] = {"<Cmd>Gread<CR>", "Fugitive: Gread (plain)"},
        ["<LocalLeader>gB"] = {"<Cmd>Git blame -w<Bar>winc p<CR>", "Fugitive: blame split"},
        ["<LocalLeader>gw"] = {
            [[<Cmd>lua require('usr.shared.utils.fs').follow_symlink()<CR><Cmd>Gwrite<CR>]],
            "Fugitive: Gwrite",
        },
        ["<LocalLeader>gW"] = {F.ithunk(fs.follow_symlink, 0, "Gwrite"), "Fugitive: Gwrite"},
        ["<LocalLeader>gr"] = {
            [[<Cmd>lua require('usr.shared.utils.fs').follow_symlink()<CR><Cmd>keepalt Gread<Bar>up!<CR>]],
            "Fugitive: Gread",
        },
        ["<LocalLeader>gf"] = {"<Cmd>Git fetch --all<CR>", "Fugitive: fetch all"},
        ["<LocalLeader>gF"] = {"<Cmd>Git fetch origin<CR>", "Fugitive: fetch origin"},
        ["<LocalLeader>gp"] = {"<Cmd>Git pull<CR>", "Fugitive: pull"},
        ["<LocalLeader>gs"] = {"<Cmd>Gsplit<CR>", "Fugitive: buffer split"},
        ["<LocalLeader>gn"] = {
            "<Cmd>Git! difftool --name-only<Bar>copen<CR>",
            "Fugitive: difftool name-only",
        },
    })

    wk.register(
        {
            ["<LocalLeader>gc"] = {":Git commit<Space>", "Fugitive: commit"},
            ["<LocalLeader>ga"] = {":Git commit --amend<Space>", "Fugitive: commit (amend)"},
            ["<LocalLeader>gT"] = {":tab Gdiffsplit<Space>", "Fugitive: tab Gdiffsplit"},
            -- ["<LocalLeader>gt"] = {":Git difftool -y<Space>", "Fugitive: difftool -y"},
        },
        {silent = false}
    )

    map("n", "<LocalLeader>gl", "Gclog! %", {cmd = true, desc = "Fugitive: Gclog '%'"})
    map("n", "<LocalLeader>gL", "Gclog!", {cmd = true, desc = "Fugitive: Gclog"})
    map("n", "<LocalLeader>gH", "Git! log -- %", {cmd = true, desc = "Fugitive: log '%' (simple)"})
    map("n", "<LocalLeader>gh", M.git_history_op, {desc = "Fugitive: op hist of lines"})
    map("x", "<LocalLeader>gh", M.git_history_visual, {desc = "Fugitive: hist of selection"})
    map(
        "n",
        "<LocalLeader>gz",
        [['@_<Cmd>G log --pretty="%h%d %s  %aL (%cr)" --date=relative'.(v:count ? '' : ' --follow -- %').'<CR>']],
        {expr = true, desc = "Fugitive: relative log"}
    )
    map(
        "n",
        "<LocalLeader>gZ",
        "G log --stat --cumulative -n1",
        {cmd = true, desc = "Fugitive: log stat last"}
    )
    -- nnoremap <silent> ,g, :diffget //2<CR>
    -- nnoremap <silent> ,g. :diffget //3<CR>
    -- xnoremap <c-p> :diffput<cr>
    -- xnoremap <c-o> :diffget<cr>
    -- nnoremap <expr>   Ur  '@_<cmd>Gread'.(v:count?(' @'.repeat('^',v:count).':%'):'').'<cr>'
end

---Show Git history
---@param mode string
function M.git_history(mode)
    local regions = op.get_region(mode)
    cmd(("Git log -L %d,%d:%%"):format(regions.start.row, regions.finish.row))
end

---'Operator function' function to show Git history
---@param motion string text motion
function M.git_history_op(motion)
    op.operator({cb = "v:lua.require'plugs.fugitive'.git_history", motion = motion})
end

---Show Git history of visual selection
function M.git_history_visual()
    utils.normal("x", "<esc>")
    M.git_history(fn.visualmode())
end

init()

return M
