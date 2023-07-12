---@module 'plugs.bqf'
local M = {}

local F = Rc.F
local bqf = F.npcall(require, "bqf")
if not bqf then
    return
end

local hl = Rc.shared.hl
local debounce = Rc.lib.debounce
local autocmd = Rc.api.autocmd

local fn = vim.fn
local api = vim.api

local loaded_preview_bufs = {}
local traps = {}

local function cleanup_preview_bufs(qwinid)
    for _, buf in ipairs(loaded_preview_bufs[qwinid]) do
        if api.nvim_buf_is_valid(buf) and not vim.bo[buf].modified then
            api.nvim_buf_delete(buf, {unload = false})
        end
    end
    loaded_preview_bufs[qwinid] = nil
end

local function trap_cleanup(qwinid)
    if traps[qwinid] then
        return
    end
    traps[qwinid] = true

    autocmd({
        event = "WinClosed",
        pattern = tostring(qwinid),
        once = true,
        command = function(_a)
            cleanup_preview_bufs(qwinid)
            traps[qwinid] = nil

            -- Rc.api.command("CleanupFugitiveBufs", function()
            --     cleanup_preview_bufs(qwinid)
            --     traps[qwinid] = nil
            --     vim.defer_fn(function()
            --         Rc.api.del_command("CleanupFugitiveBufs")
            --     end, 10)
            -- end)
        end,
        desc = "Clean up quickfix preview buffers",
    })
end

local function register_preview_buf(qwinid, fbufnr)
    loaded_preview_bufs[qwinid] = loaded_preview_bufs[qwinid] or {}
    table.insert(loaded_preview_bufs[qwinid], fbufnr)
    trap_cleanup(qwinid)
end

---@diagnostic disable-next-line: unused-local, unused-function
local function preview_fugitive(bufnr, ...)
    local debounced
    if not debounced then
        debounced = debounce:new(function(bufnr, qwinid, bufname)
            if not api.nvim_buf_is_loaded(bufnr) then
                api.nvim_buf_call(bufnr, function()
                    cmd(("doau fugitive BufReadCmd %s"):format(bufname))
                end)
            end
            require("bqf.preview.handler").open(qwinid, nil, true)
            local fbufnr = require("bqf.preview.session").floatBufnr()
            if not fbufnr then
                return
            end
            -- vim.bo[fbufnr].ft = "git"
            register_preview_buf(qwinid, bufnr)
        end, 10)
    end

    if api.nvim_buf_is_loaded(bufnr) then
        debounced:flush(bufnr, ...)
        return true
    end

    debounced(bufnr, ...)
    return false
end

function M.setup()
    hl.link("BqfPreviewBorder", "FloatBorder")
    hl.link("BqfPreviewTitle", "Statement")

    bqf.setup({
        auto_enable = true,
        auto_resize_height = true,
        preview = {
            -- border_chars = {"┃", "┃", "━", "━", "┏", "┓", "┗", "┛", "█"},
            border_chars = {"│", "│", "─", "─", "╭", "╮", "╰", "╯", "█"},
            auto_preview = true,
            win_height = 12,
            win_vheight = 12,
            winblend = 5,
            buf_label = true,
            wrap = false,
            show_title = true,
            show_scroll_bar = true,
            delay_syntax = 40,
            should_preview_cb = function(bufnr, _qwinid)
                local ret = true
                local bufname = api.nvim_buf_get_name(bufnr)
                local fsize = fn.getfsize(bufname)
                if fsize > 500 * 1024 then
                    ret = false
                    -- FIX: This memory usage can get out of hand very quickly
                elseif bufname:match("^fugitive://") then
                    --     preview_fugitive(bufnr, qwinid, bufname)
                    ret = false
                end

                return ret
            end,
        },
        func_map = {
            open = "<CR>",
            openc = "O",
            drop = "o",
            split = "<C-s>",
            vsplit = "<C-v>",
            tab = "t",
            tabb = "T",
            tabc = "<M-t>",
            tabdrop = "<C-t>",
            ptogglemode = "z,",
            ptoggleitem = "p",
            ptoggleauto = "P",
            pscrollup = "<C-b>",
            pscrolldown = "<C-f>",
            pscrollorig = "zo",
            prevfile = "<M-p>",
            nextfile = "<M-n>",
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
            fzffilter = "zf",
        },
        filter = {
            fzf = {
                action_for = {
                    ["enter"] = "drop",
                    ["ctrl-s"] = "split",
                    ["ctrl-t"] = "tab drop",
                    ["ctrl-x"] = "",
                    ["ctrl-q"] = "signtoggle",
                    ["alt-q"] = "signtoggle",
                    ["ctrl-c"] = "closeall",
                },
                extra_opts = {
                    "--delimiter",
                    "│",
                    "--prompt",
                    "❱ ",
                    "--bind",
                    "alt-a:toggle-all",
                },
            },
        },
    })
end

local function init()
    M.setup()
end

init()

return M
