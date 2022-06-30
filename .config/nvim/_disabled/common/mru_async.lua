local M = {}

local utils = require("common.utils")
local debounce = require("common.debounce")

local json
local db
local max
local bufs
local tmp_prefix

local a = require("plenary.async_lib")
local uva = a.uv

local fn = vim.fn
local api = vim.api
-- local cmd = vim.cmd
local uv = vim.loop

local mru = {}

local function add_file(f)
    a.async_void(
        function()
            mru.lock = true
            local data
            local res = f .. "\n"
            local i, p = 1, 1
            local _, fd = a.await(uva.fs_open(mru.db, "r+", 438))
            local _, stat = a.await(uva.fs_fstat(fd))
            local nums = 0

            if mru.mtime ~= stat.mtime.sec then
                _, data = a.await(uva.fs_read(fd, stat.size, 0))
            else
                data = mru.cache
            end

            while i <= #data do
                if data:sub(i, i) == "\n" then
                    if data:sub(p, i - 1) == f then
                        res = res .. data:sub(1, p - 1) .. data:sub(i + 1, #data)
                        break
                    end
                    p = i + 1
                    nums = nums + 1
                end
                i = i + 1
            end

            -- if file not found in mru, then check nums and append
            if i > #data then
                if nums > nums then
                    local oversize = nums - mru.nums
                    local j = #data
                    while oversize > 0 do
                        j = j - 1
                        if data:sub(j, j) == "\n" then
                            oversize = oversize - 1
                        end
                    end
                    res = res .. data:sub(1, j)
                else
                    res = res .. data
                end
            end

            a.await(uva.fs_write(fd, res, 0))
            a.await(uva.fs_ftruncate(fd, #res))

            _, stat = a.await(uva.fs_fstat(fd))
            mru.cache = res
            mru.mtime = stat.mtime.sec
            a.await(uva.fs_close(fd))
            mru.lock = false
        end
    )()
end

local function list_async(file)
    a.async_void(
        function()
            local mru_list = {}
            local fname_set = {[""] = true}

            local add_list = function(name)
                if not fname_set[name] then
                    fname_set[name] = true
                    local _, fd = a.await(a.uv.fs_open(name, "r+", 438))
                    local _, stat = a.await(a.uv.fs_fstat(fd))

                    if stat then
                        if #mru_list < max then
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
                if api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].bt == "" then
                    local fname = api.nvim_buf_get_name(bufnr)
                    if not fname:match(tmp_prefix) then
                        if not add_list(fname) then
                            break
                        end
                    end
                end
            end

            local _, fd = a.await(a.uv.fs_open(file, "r+", 438))
            local _, stat = a.await(a.uv.fs_fstat(fd))

            -- local fd = io.open(file, "r")
            if mru.mtime ~= stat.mtime.sec then
                _, data = a.await(a.uv.fs_read(fd, stat.size, 0))
            else
                data = mru.cache
            end

            if fd then
                for fname in fd:lines() do
                    if not add_list(fname) then
                        break
                    end
                end
                -- fd:close()
                a.await(a.uv.fs_close(fd))
            end
            return mru_list
        end
    )()
end

local function list(file)
    local mru_list = {}
    local fname_set = {[""] = true}

    local add_list = function(name)
        if not fname_set[name] then
            fname_set[name] = true
            if uv.fs_stat(name) then
                if #mru_list < max then
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
        if api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].bt == "" then
            local fname = api.nvim_buf_get_name(bufnr)
            if not fname:match(tmp_prefix) then
                if not add_list(fname) then
                    break
                end
            end
        end
    end

    local fd = io.open(file, "r")
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
    local mru_list = list(db)
    utils.write_file(db, table.concat(mru_list, "\n"))
    return mru_list
end

M.flush =
    (function()
    local debounced
    return function(force)
        if force then
            utils.write_file(db, table.concat(list(db), "\n"), force)
        else
            if not debounced then
                debounced =
                    debounce(
                    function()
                        utils.write_file(db, table.concat(list(db), "\n"))
                    end,
                    50
                )
            end
            debounced()
        end
    end
end)()

M.store_buf = (function()
    local count = 0
    return function()
        local bufnr = fn.expand("<abuf>", 1)
        bufnr = bufnr and tonumber(bufnr) or api.nvim_get_current_buf()
        table.insert(bufs, bufnr)
        count = (count + 1) % 10
        if count == 0 then
            M.list()
        end
    end
end)()

M.refresh_mru = function()
    if mru.lock then
        return
    end

    vim.defer_fn(
        function()
            local f = fn.expand("%:p")
            if fn.filereadable(f) == 0 then
                return
            end

            if fn.filereadable(mru.db) == 0 then
                local file = io.open(mru.db, "a")
                io.close(file)
            end

            add_file(f)
        end,
        500
    )
end

local function init()
    json = fn.stdpath("data") .. "/recent_files.json"
    db = fn.stdpath("data") .. "/mru_file2"
    max = 1000
    bufs = {}
    tmp_prefix = uv.os_tmpdir()

    mru = {
        mtime = 0,
        cache = "",
        nums = 1024,
        lock = false,
        db = ("%s/%s"):format(fn.stdpath("data"), "mru.json")
    }

    M.store_buf()
    nvim.autocmd.Mru = {
        {
            event = {"BufEnter", "BufAdd", "FocusGained"},
            pattern = "*",
            command = function()
                require("common.mru").store_buf()
                require("common.mru").refresh_mru()
            end
        },
        {
            event = {"VimLeavePre"},
            pattern = "*",
            command = function()
                require("common.mru").flush(true)
            end
        },
        {
            event = {"VimSuspend", "FocusLost"},
            pattern = "*",
            command = function()
                require("common.mru").flush()
            end
        }
    }
end

init()

return M
