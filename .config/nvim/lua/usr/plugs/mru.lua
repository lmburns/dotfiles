---@module 'usr.plugs.mru'
local M = {}

local shared = require("usr.shared")
local fss = shared.utils.fs.sync
-- local fs = shared.utils.fs
-- local fsa = fs.async
-- local F = shared.F

local debounce = require("usr.lib.debounce")

-- ---@type Promise
-- local promise = require("promise")
-- local async = require("async")
-- local Mutex = require("usr.lib.mutex")
-- local uva = require("uva")

local fn = vim.fn
local api = vim.api
local uv = vim.uv

local bufs
local mru = {}

local function list(file)
    local mru_list = {}
    local fname_set = {[""] = true}

    local add_list = function(name)
        if not fname_set[name] then
            fname_set[name] = true
            if uv.fs_stat(name) then
                if #mru_list < mru.max then
                    table.insert(mru_list, name)
                else
                    return false
                end
            end
        end
        return true
    end

    while #bufs > 0 do
        local bufnr = table.remove(bufs)
        if api.nvim_buf_is_valid(bufnr)
            and vim.bo[bufnr].bt == ""
            -- and not mru.ignore_ft:contains(vim.bo[bufnr].ft)
            -- and not vim.wo.previewwindow
        then
            local fname = api.nvim_buf_get_name(bufnr)
            if not fname:match(mru.tmp_prefix) and not fname:match("%%") and not fname:match("/dev/shm/") then
            -- if not fname:match(mru.tmp_prefix) and not fname:match("%%") then
                if not add_list(fname) then
                    break
                end
            end
        end
    end

    -- local data = fss.read_file(file)
    -- for _, fname in ipairs(vim.split(data, "\n")) do
    --     if not add_list(fname) then
    --         break
    --     end
    -- end

    local fd = io.open(file, 'r')
    if fd then
        for fname in fd:lines() do
            if not add_list(fname) then
                break
            end
        end
        fd:close()
    end

    return mru_list
end

function M.list()
    local mru_list = list(mru.db)
    fss.write_file(mru.db, table.concat(mru_list, "\n"))
    return mru_list
end

function M.get()
    return list(mru.db)
end

M.flush = (function()
    local debounced
    return function(block)
        -- if block then
        --     vim.wait(1000, function()
        --         return true
        --     end, 30, false)
        -- end
        -- if not debounced then
        --     debounced = debounce:new(function()
        --         M.sync(table.concat(list(mru.db), "\n"))
        --     end, 50)
        -- end
        -- debounced()

        if block then
            fss.write_file(mru.db, table.concat(list(mru.db), "\n"), block)
        else
            if not debounced then
                debounced = debounce:new(function()
                    fss.write_file(mru.db, table.concat(list(mru.db), "\n"))
                end, 50)
            end
            debounced()
        end
    end
end)()

-- function M.sync(data)
--     return mru.mutex:use(function()
--         return async(function()
--             await(fs.write_file(mru.db, data))
--         end)
--     end)
-- end

M.store_buf = (function()
    local count = 0
    return function()
        local ok, bufnr = pcall(fn.expand, "<abuf>", 1)
        if ok then
            bufnr = bufnr and tonumber(bufnr) or api.nvim_get_current_buf()
            table.insert(bufs, bufnr)
            count = (count + 1) % 10
            if count == 0 then
                -- promise.resolve():thenCall(M.list)
                M.list()
            end
        end
    end
end)()

---This doesn't have something going on in the background, adding a file to the
---MRU list across sessions. So, this would only involve files opened in the current session.
M.mru_current_session = function()
    local current_buffer = api.nvim_get_current_buf()
    local current_file = api.nvim_buf_get_name(current_buffer)
    local results = {}

    for _, buffer in ipairs(vim.split(fn.execute(":buffers! t"), "\n")) do
        local match = tonumber(buffer:match("%s*(%d+)"))
        local open_by_lsp = buffer:match("line 0$")
        if match and not open_by_lsp then
            local file = api.nvim_buf_get_name(match)
            if uv.fs_stat(file) and match ~= current_buffer then
                table.insert(results, file)
            end
        end
    end

    for _, file in ipairs(vim.v.oldfiles) do
        if uv.fs_stat(file) and not vim.tbl_contains(results, file) and file ~= current_file then
            table.insert(results, file)
        end
    end

    return results
end

local function init()
    bufs = {}
    mru = {
        -- mutex = Mutex:new(),
        mtime = 0,
        max = 1000,
        cache = "",
        tmp_prefix = uv.os_tmpdir(),
        db = ("%s/%s"):format(Rc.dirs.data, "mru_file"),
        ignore_ft = Rc.blacklist.ft,
    }

    -- if M.get()[1] ~= fn.expand("%:p") then
    M.store_buf()
    -- end

    nvim.autocmd.Mru = {
        {
            event = {"BufEnter", "BufAdd", "FocusGained"},
            pattern = "*",
            command = function()
                require("usr.plugs.mru").store_buf()
            end,
        },
        {
            event = {"VimLeavePre"},
            pattern = "*",
            command = function()
                require("usr.plugs.mru").flush(true)
            end,
        },
        {
            event = {"FocusLost", "VimSuspend"},
            pattern = "*",
            command = function()
                require("usr.plugs.mru").flush()
            end,
        },
        -- {
        --     event = {"VimSuspend"},
        --     pattern = "*",
        --     command = function()
        --         require("usr.plugs.mru").flush()
        --     end,
        -- },
    }
end

init()

return M
