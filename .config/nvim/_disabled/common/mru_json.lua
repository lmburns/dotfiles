local M = {}

local utils = require("common.utils")
local debounce = require("common.debounce")

local json
local bufs
local mru = {}
local dirs = {}

local fn = vim.fn
local api = vim.api
-- local cmd = vim.cmd
local uv = vim.loop

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
        if api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].bt == "" then
            local fname = api.nvim_buf_get_name(bufnr)
            if not fname:match(mru.tmp_prefix) then
                if not add_list(fname) then
                    break
                end
            end
        end
    end

    local fd = io.open(file, "r")
    if fd then
        local ok, data = pcall(fd.read, fd)
        if ok then
            dirs = vim.json.decode(data)
        end

        for _, fname in ipairs(dirs) do
            if not add_list(fname) then
                break
            end
        end

        -- for fname in fd:lines() do
        --     if not add_list(fname) then
        --         break
        --     end
        -- end
        fd:close()
    end
    return mru_list
end

function M.list()
    local mru_list = list(mru.db)
    -- utils.write_file(mru.db, table.concat(mru_list, "\n"))
    utils.write_file(mru.db, vim.json.encode(mru_list))
    return mru_list
end

M.flush =
    (function()
    local debounced
    return function(force)
        if force then
            -- utils.write_file(mru.db, table.concat(list(mru.db), "\n"), force)
            utils.write_file(mru.db, vim.json.encode(list(mru.db)), force)
        else
            if not debounced then
                debounced =
                    debounce(
                    function()
                        -- utils.write_file(mru.db, table.concat(list(mru.db), "\n"))
                        utils.write_file(mru.db, vim.json.encode(list(mru.db)))
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

-- ╒══════════════════════════════════════════════════════════╕
--                             JSON
-- ╘══════════════════════════════════════════════════════════╛

M.load_cache = function()
    local file = io.open(json, "r")
    if file then
        local ok, data = pcall(file.read, file)
        if ok then
            dirs = vim.json.decode(data)
        end
        file:close()
    end
end

M.save_cache = function()
    local file = io.open(json, "w")
    file:write(vim.json.encode(dirs))
    file:close()
end

M.record_dir = function(dir)
    dirs[dir] = 1
    M.save_cache()
end

M.remove_dir = function(dir)
    dirs[dir] = nil
    M.save_cache()
end

M.get_dirs = function()
    return vim.tbl_keys(dirs)
end

local function init()
    json = fn.stdpath("data") .. "/recent_files.json"
    bufs = {}

    mru = {
        mtime = 0,
        max = 1000,
        cache = "",
        tmp_prefix = uv.os_tmpdir(),
        db = ("%s/%s"):format(fn.stdpath("data"), "mru.json")
    }

    M.store_buf()
    nvim.autocmd.Mru = {
        {
            event = {"BufEnter", "BufAdd", "FocusGained"},
            pattern = "*",
            command = function()
                require("common.mru").store_buf()
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

    --   cmd [[
    --     aug Mru
    --         au!
    --         au BufEnter,BufAdd,FocusGained * lua require('common.mru').store_buf()
    --         au VimLeavePre * lua require('common.mru').flush(true)
    --         au VimSuspend * lua require('common.mru').flush()
    --         au FocusLost * lua require('common.mru').flush()
    --     aug END
    --   ]]
end

init()

return M
