local M = {}

local utils = require("common.utils")
local debounce = require("common.debounce")

local a = require("plenary.async_lib")

local mru = {
    max = 1024,
    mtime = 0,
    cache = "",
    bufs = {},
    tmp_prefix = uv.os_tmpdir(),
    lock = false,
    db = ("%s/%s"):format(fn.stdpath("data"), "/mru_file")
}

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

    while #mru.bufs > 0 do
        local bufnr = table.remove(mru.bufs)
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
        for fname in fd:lines() do
            if not add_list(fname) then
                break
            end
        end
        fd:close()
    end
    return mru_list
end

M.list = function()
    local mru_list = list(mru.db)
    utils.write_file(mru.db, table.concat(mru_list, "\n"))
    return mru_list
end

M.flush =
    (function()
    local debounced
    return function(force)
        if force then
            utils.write_file(mru.db, table.concat(list(mru.db), "\n"), force)
        else
            if not debounced then
                debounced =
                    debounce(
                    function()
                        utils.write_file(mru.db, table.concat(list(mru.db), "\n"))
                    end,
                    50
                )
            end
            debounced()
        end
    end
end)()

M.store_buf =
    (function()
    local count = 0
    return a.async_void(
        function()
            local bufnr = fn.expand("<abuf>", 1)
            bufnr = bufnr and tonumber(bufnr) or api.nvim_get_current_buf()
            table.insert(mru.bufs, bufnr)
            count = (count + 1) % 10
            if count == 0 then
                M.list()
            end
        end
    )
end)()

local function init()
    M.store_buf()
    -- nvim.autocmd.Mru = {
    --     {
    --         event = {"BufEnter", "BufAdd", "FocusGained"},
    --         pattern = "*",
    --         command = function()
    --             require("common.mru").store_buf()
    --         end
    --     },
    --     {
    --         event = {"VimLeavePre"},
    --         pattern = "*",
    --         command = function()
    --             require("common.mru").flush(true)
    --         end
    --     },
    --     {
    --         event = {"VimSuspend", "FocusLost"},
    --         pattern = "*",
    --         command = function()
    --             require("common.mru").flush()
    --         end
    --     }
    -- }

    cmd [[
      aug Mru
          au!
          au BufEnter,BufAdd,FocusGained * lua require('common.mru').store_buf()
          au VimLeavePre * lua require('common.mru').flush(true)
          au VimSuspend * lua require('common.mru').flush()
          au FocusLost * lua require('common.mru').flush()
      aug END
  ]]
end

init()

return M
