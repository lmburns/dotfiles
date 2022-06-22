local M = {}

local debounce = require("common.debounce")
local C = require("common.color")
local utils = require("common.utils")
local dev = require("dev")

local autocmd = utils.autocmd

local ex = nvim.ex
local fn = vim.fn
local cmd = vim.cmd
local g = vim.g
local b = vim.bo

local loaded_preview_bufs = {}

local function cleanup_preview_bufs(qwinid)
    for _, buf in ipairs(loaded_preview_bufs[qwinid]) do
        if api.nvim_buf_is_valid(buf) and not vim.bo[buf].modified then
            api.nvim_buf_delete(buf, {unload = false})
        end
    end
    loaded_preview_bufs[qwinid] = nil
end

local traps = {}

local function trap_cleanup(qwinid)
    if traps[qwinid] then
        return
    end
    traps[qwinid] = true

    autocmd(
        {
            event = "WinClosed",
            pattern = tostring(qwinid),
            once = true,
            command = function()
                cleanup_preview_bufs(qwinid)
                traps[qwinid] = nil
            end,
            desc = "Clean up quickfix preview buffers"
        }
    )
end

local function register_preview_buf(qwinid, fbufnr)
    loaded_preview_bufs[qwinid] = loaded_preview_bufs[qwinid] or {}
    table.insert(loaded_preview_bufs[qwinid], fbufnr)
    trap_cleanup(qwinid)
end

local function preview_fugitive(bufnr, ...)
    local debounced
    if not debounced then
        debounced =
            debounce(
            function(bufnr, qwinid, bufname)
                if not api.nvim_buf_is_loaded(bufnr) then
                    dev.buf_call(
                        bufnr,
                        function()
                            ex.doau(("fugitive BufReadCmd %s"):format(bufname))
                        end
                    )
                end

                require("bqf.preview.handler").open(qwinid, nil, true)
                local fbufnr = require("bqf.preview.session").floatBufnr()
                if not fbufnr then
                    return
                end
                vim.bo[fbufnr].ft = "git"
                register_preview_buf(qwinid, bufnr)
            end,
            60
        )
    end

    if api.nvim_buf_is_loaded(bufnr) then
        debounced(bufnr, ...)
        return true
    end
    debounced(bufnr, ...)
    return false
end

function M.setup()
    -- FIX: Sometimes preview window is transparent
    C.link("BqfPreviewBorder", "Parameter")

    require("bqf").setup(
        {
            auto_enable = true,
            auto_resize_height = true,
            preview = {
                auto_preview = true,
                delay_syntax = 50,
                should_preview_cb = function(bufnr, qwinid)
                    local ret = true
                    local bufname = api.nvim_buf_get_name(bufnr)
                    local fsize = fn.getfsize(bufname)
                    -- Skip a file size greater than 500k or is fugitive buffer
                    if fsize > 500 * 1024 then
                        ret = false
                    elseif bufname:match("^fugitive://") then
                        return preview_fugitive(bufnr, qwinid, bufname)
                    end
                    return ret
                end
            },
            func_map = {
                open = "<CR>",
                openc = "O",
                drop = "o",
                split = "<C-s>",
                vsplit = "<C-v>",
                tab = "t",
                tabb = "T",
                tabc = "",
                tabdrop = "<C-t>",
                ptogglemode = "z,",
                ptoggleitem = "p",
                ptoggleauto = "P",
                pscrollup = "<C-u>",
                pscrolldown = "<C-d>",
                pscrollorig = "zo",
                prevfile = "<C-p>",
                nextfile = "<C-n>",
                prevhist = "<",
                nexthist = ">",
                lastleave = [['"]],
                stoggleup = "<S-Tab>",
                stoggledown = "<Tab>",
                stogglevm = "<Tab>",
                stogglebuf = [['<Tab>]],
                sclear = "z<Tab>",
                filter = "zn",
                filterr = "zN",
                fzffilter = "zf"
            },
            filter = {
                fzf = {
                    action_for = {
                        ["enter"] = "drop",
                        ["ctrl-s"] = "split",
                        ["ctrl-t"] = "tab drop",
                        ["ctrl-x"] = ""
                    },
                    extra_opts = {"--delimiter", "│"}
                }
            }
        }
    )
end

local function init()
    M.setup()
end

init()

return M
