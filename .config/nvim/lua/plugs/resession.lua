---@module 'plugs.resession'
local M = {}

local resession = Rc.F.npcall(require, "resession")
if not resession then
    return
end

local F = Rc.F
local log = Rc.lib.log

local B = Rc.api.buf
local map = Rc.api.map
local command = Rc.api.command
local it = F.ithunk

local cmd = vim.cmd
local api = vim.api
local fn = vim.fn
local uv = vim.loop

M.visible_buffers = {}

local function is_restorable(bufnr)
    local n = api.nvim_buf_get_name(bufnr)
    return B.buf_is_valid(bufnr) and fn.filereadable(n) == 1
end

local function get_session_name()
    local name = uv.cwd()
    local branch = fn.system("git branch --show-current")
    if vim.v.shell_error == 0 then
        return name .. branch
    else
        return name
    end
end

---@param by "'id'"|"'name'"|"'path'"
---@return string[]|number[]
local function get_bufs(by)
    local all = require("bufferline").get_elements().elements
    local bufs = {}
    vim.iter(all):each(function(b)
        table.insert(bufs, b[by])
    end)
    -- vim.iter(all):each(function(b) bufs[b[by]] = fn.bufwinid(b[by]) end)
    return _t(bufs)
    -- id = 1,
    -- name = "resession.lua",
    -- path = "/home/lucas/.config/nvim/lua/plugs/resession.lua"
end

function M.setup()
    resession.setup({
        -- Options for automatically saving sessions on a timer
        autosave = {
            enabled = true,
            -- How often to save (in seconds)
            interval = 60,
            -- Notify when autosaved
            notify = false,
        },
        -- Save and restore these options
        options = {
            "binary",
            "bufhidden",
            "buflisted",
            "cmdheight",
            "diff",
            "filetype",
            "modifiable",
            "previewwindow",
            "readonly",
            "scrollbind",
            "winfixheight",
            "winfixwidth",
            "shiftwidth",
            "tabstop",
            "softtabstop",
            "expandtab",
            "smarttab",
        },
        -- Custom logic for determining if the buffer should be included
        -- buf_filter = resession.default_buf_filter,
        buf_filter = function(bufnr)
            if not resession.default_buf_filter(bufnr) or not is_restorable(bufnr) then
                -- Rc.blacklist.ft:contains(vim.bo[bufnr].ft)
                return false
            end
            return M.visible_buffers[bufnr] or get_bufs("id"):contains(bufnr)
        end,
        -- Custom logic for determining if a buffer should be included in a tab-scoped session
        ---@diagnostic disable-next-line:unused-local
        tab_buf_filter = function(tabpage, bufnr)
            local dir = fn.getcwd(-1, api.nvim_tabpage_get_number(tabpage))
            return api.nvim_buf_get_name(bufnr):startswith(dir)
        end,
        -- The name of the directory to store sessions in
        dir = "session",
        -- Show more detail about the sessions when selecting one to load.
        -- Disable if it causes lag.
        load_detail = true,
        -- Configuration for extensions
        extensions = {
            aerial = {},
            quickfix = {},
            -- overseer = {},
            -- config_local = {},
        },
    })

    -- resession.add_hook("post_load", function()
    -- resession.add_hook("post_save", function()
    -- resession.add_hook("pre_load", function()
    --     M.visible_buffers[1] = nil
    -- end)
    resession.add_hook(
        "pre_save",
        function()
            if fn.argc() > 0 then
                cmd("%argdel")
            end
            -- local bufnr = api.nvim_get_current_buf()
            -- M.visible_buffers = {}
            for _, winid in ipairs(api.nvim_list_wins()) do
                -- if not Rc.blacklist.ft:contains(vim.bo[bufnr].ft) then
                if api.nvim_win_is_valid(winid) then
                    M.visible_buffers[api.nvim_win_get_buf(winid)] = winid
                end
                -- end
            end
        end
    )
end

function M.detach()
    local curr = resession.get_current()
    resession.detach()
    log.info(("detached from: %s"):format(curr), {title = "resession"})
end

local function init()
    M.setup()

    map("n", "<Leader>ps", resession.save, {desc = "Session: save"})
    map("n", "<Leader>pt", it(resession.save_tab), {desc = "Session: save tab"})
    map("n", "<Leader>po", resession.load, {desc = "Session: open"})
    map("n", "<Leader>pd", resession.delete, {desc = "Session: delete"})
    map("n", "<Leader>ph", M.detach, {desc = "Session: detach"})
    map(
        "n",
        "<Leader>pl",
        it(resession.load, nil, {reset = false}),
        {desc = "Session: load without reset"}
    )

    command("SessionDetach", M.detach, {desc = "Session: detach"})
    command(
        "SessionRestoreLast",
        function()
            resession.load("last", {attach = true})
        end,
        {desc = "Session: restore last saved"}
    )

    -- FIX: Neovim freezes when trying to load
    -- map(
    --     "n",
    --     "ZZ",
    --     function()
    --         local fname = fn.expand("%:p"):gsub("/", "__"):gsub(":", "++")
    --         pcall(resession.delete, ("__quicksave__%s"):format(fname))
    --         resession.save(("__quicksave__%s"):format(fname), {notify = false})
    --         utils.normal("n", "ZZ")
    --         -- cmd("xa")
    --     end,
    --     {desc = "Quit neovim"}
    -- )

    -- local fname = fn.expand("%:p"):gsub("/", "__"):gsub(":", "++")

    -- FIX: Neovim errors with gitsigns and whichkey. Needs to load bufnr before they attach
    -- if vim.tbl_contains(resession.list(), ("__quicksave__%s"):format(fname)) then
    --         -- if not ok then
    --         --     log.warn(("Failed deleting quicksave session: %s"):format(err), {title = "Resession"})
    --         -- end
    --     vim.defer_fn(function()
    --         local fname = fn.expand("%:p"):gsub("/", "__"):gsub(":", "++")
    --         -- N(("before:%d"):format(api.nvim_get_current_buf()))
    --         pcall(resession.load,("__quicksave__%s"):format(fname), {attach = false})
    --         -- N(("after:%d"):format(api.nvim_get_current_buf()))
    --         pcall(resession.delete, ("__quicksave__%s"):format(fname))
    --     end, 30)
    -- end

    nvim.autocmd.lmb__Resession = {
        -- FIX: This resets a lot of options. Causes node coredump when switching bufs
        -- {
        --     event = "BufEnter",
        --     desc = "Session: load quicksave",
        --     once = true,
        --     command = function()
        --         -- vim.b.coc_enabled = 0
        --
        --         local fname = fn.expand("%:p"):gsub("/", "__"):gsub(":", "++")
        --         -- N(("before:%d"):format(api.nvim_get_current_buf()))
        --         pcall(resession.load, ("__quicksave__%s"):format(fname), {attach = false})
        --         -- N(("after:%d"):format(api.nvim_get_current_buf()))
        --         pcall(resession.detach)
        --         pcall(resession.delete, ("__quicksave__%s"):format(fname))
        --
        --         -- vim.b.coc_enabled = 1
        --
        --         -- vim.defer_fn(
        --         --     function()
        --         --         if
        --         --             g.coc_process_pid and
        --         --                 type(uv.os_getpriority(g.coc_process_pid)) == "number"
        --         --          then
        --         --             uv.kill(g.coc_process_pid, 9)
        --         --         end
        --         --
        --         --         cmd("CocRestart")
        --         --     end,
        --         --     400
        --         -- )
        --     end
        -- },
        {
            event = "VimLeavePre",
            desc = "Session: always save one named 'last'",
            command = function()
                resession.save("last")
            end,
        },
        --  ══════════════════════════════════════════════════════════════════════
        -- {
        --     event = "VimEnter",
        --     desc = "Session: only load if started with no args",
        --     command = function()
        --         if fn.argc(-1) == 0 then
        --             resession.load(get_session_name(), {dir = "dirsession", silence_errors = true})
        --         end
        --     end
        -- },
        -- {
        --     event = "VimLeavePre",
        --     desc = "Session: only load if started with no args",
        --     command = function()
        --         resession.save(get_session_name(), {dir = "dirsession", notify = false})
        --     end
        -- }
        --  ══════════════════════════════════════════════════════════════════════
        -- {
        --     event = "VimEnter",
        --     desc = "Session: only save one per directory",
        --     command = function()
        --         -- Only load the session if nvim was started with no args
        --         if fn.argc(-1) == 0 then
        --             -- Save these to a different directory, so our manual sessions don't get polluted
        --             resession.load(uv.cwd(), {dir = "dirsession", silence_errors = true})
        --         end
        --     end,
        -- },
        -- {
        --     event = "VimLeavePre",
        --     desc = "Session: only save one per directory",
        --     command = function()
        --         resession.save(uv.cwd(), {dir = "dirsession", notify = false})
        --     end,
        -- },
    }

    -- require("telescope").load_extension("resession")
end

init()

return M
