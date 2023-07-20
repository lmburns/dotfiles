---@module 'plugs.notify'
local M = {}

local F = Rc.F
local notify = F.npcall(require, "notify")
if not notify then
    return
end

-- local utils = Rc.shared.utils
local log = Rc.lib.log
local levels = log.levels
local builtin = Rc.lib.builtin

local map = Rc.api.map
local api = vim.api
local fn = vim.fn
local cmd = vim.cmd

local max_width = 65

function M.setup()
    ---@type table<string, fun(bufnr: number, notif: table, highlights: table, config: table)>
    local renderer = require("notify.render")
    -- local stages_util = require("notify.stages.util")

    notify.setup({
        level = F.if_nil(
            F.ift_then(Rc.state.TRACE, levels.TRACE),
            F.ift_then(Rc.state.DEBUG, levels.DEBUG),
            levels.INFO
        ),
        stages = "fade_in_slide_out", -- slide
        top_down = true,
        fps = 60,
        timeout = 3000,
        max_width = nil,
        max_height = nil,
        minimum_width = 30,
        background_color = "NormalFloat",
        -- max_width = math.floor(vim.o.columns * 0.4),
        -- on_close = function()
        -- -- Could create something to write to a file
        -- end,
        on_open = function(winnr)
            if api.nvim_win_is_valid(winnr) then
                api.nvim_win_set_config(winnr, {
                    border = Rc.style.border,
                    zindex = 500,
                })
            end
            local bufnr = api.nvim_win_get_buf(winnr)
            -- bmap(bufnr, "n", "q", "<Cmd>bdelete<CR>", {nowait = true})

            api.nvim_buf_call(bufnr, function()
                vim.wo[winnr].wrap = true
                vim.wo[winnr].showbreak = "NONE"
            end)
        end,
        render = function(bufnr, notif, highlights, config)
            ---@type Render_t
            local style =
                F.if_expr(notif.title[1] == "", "minimal",
                    F.if_expr(notif.title[2] and not notif.title[2]:match("%d%d:%d%d"), "default",
                        F.if_expr(#notif.title[1] + #notif.message[1] <= max_width, "compact",
                            "default"
                        )
                    )
                )

            -- local style = notif.title[1] == "" and "minimal" or "default"
            renderer[style](bufnr, notif, highlights, config)
        end,
        icons = Rc.style.plugins.notify,
    })
end

function M.history(opts)
    opts = opts or {plain = true}
    opts.nl = F.unwrap_or(opts.nl, true)
    local nl_char = F.tern(opts.nl, "\n", " ")

    if opts.plain then
        for _, notif in ipairs(notify.history({include_hidden = opts.hidden})) do
            nvim.echo({{table.concat(notif.message, nl_char), "Normal"}}, false)
        end

        return
    end

    local time = F.const({{"", "Normal"}})
    if opts.time then
        ---@diagnostic disable-next-line: redundant-parameter
        time = function(t)
            return {
                {"[", "Comment"},
                {fn.strftime("%FT%T", t), "@constant"},
                {"] ", "Comment"},
            }
        end
    end
    local title = F.const({{"", "Normal"}})
    if opts.title then
        ---@diagnostic disable-next-line: redundant-parameter
        title = function(t)
            return {{F.tern(#t[1] > 0, t[1] .. " ", ""), "Title"}}
        end
    end
    local icon = F.const({{"", "Normal"}})
    if opts.icon then
        ---@diagnostic disable-next-line: redundant-parameter
        icon = function(icon, level)
            return {{("%s "):format(icon), ("Notify%sTitle"):format(level)}}
        end
    end
    local level = F.const({{"", "Normal"}})
    if opts.level then
        ---@param lvl string
        ---@return table
        ---@diagnostic disable-next-line: redundant-parameter
        level = function(lvl)
            return {{("%s "):format(lvl), ("Notify%sTitle"):format(lvl:upper())}}
        end
    end

    for _, notif in ipairs(notify.history({include_hidden = opts.hidden})) do
        if type(opts.level) == "string" and opts.level ~= notif.level:lower() then
            goto continue
        end
        local args = {}
        vim.list_extend(args, time(notif.time))
        vim.list_extend(args, {
            unpack(title(notif.title)),
            unpack(icon(notif.icon, notif.level)),
            unpack(level(notif.level)),
            {table.concat(notif.message, nl_char), "String"},
        })
        api.nvim_echo(args, false, {})
        -- unpack(time(notif.time)),
        -- unpack(title(notif.title)),
        -- unpack(icon(notif.icon, notif.level)),
        -- unpack(level(notif.level)),
        -- {table.concat(notif.message, nl_char), "String"},
        ::continue::
    end
end

function M.history_full(opts)
    M.history({
        time = true,
        title = true,
        icon = true,
        level = opts.level or true,
        hidden = opts.hidden,
        nl = opts.nl,
    })
end

function M.history_warn(opts)
    M.history_full({
        level = "warn",
        hidden = opts.hidden,
        nl = opts.nl,
    })
end

function M.history_error(opts)
    M.history_full({
        level = "error",
        hidden = opts.hidden,
        nl = opts.nl,
    })
end

local function init()
    M.setup()

    local it = F.ithunk

    map("n", "<Leader>nm", function()
        cmd.Bufferize("messages")
        cmd.wincmd("j")
        builtin.winresize_fit()
        vim.bo.ft = "log"
    end, {desc = "Notify: messages (S)"})

    map("n", "<Leader>ns", function()
        cmd.Bufferize({
            "lua require('notify')._print_history()",
            mods = {emsg_silent = true},
        })
    end, {desc = "Notify: log std (S)"})

    map("n", "<Leader>nf", function()
        cmd.Bufferize({
            "lua require('plugs.notify').history_full({hidden = true})",
            mods = {emsg_silent = true},
        })
        cmd.wincmd("j")
        builtin.winresize_fit()
        vim.bo.ft = "log"
    end, {desc = "Notify: history full (S)"})

    map("n", "<Leader>ne", function()
        cmd.Bufferize({
            "lua require('plugs.notify').history_error({hidden = true})",
            mods = {emsg_silent = true},
        })
        cmd.wincmd("j")
        builtin.winresize_fit()
        vim.bo.ft = "log"
    end, {desc = "Notify: error (S)"})

    map("n", "<Leader>nw", function()
        cmd.Bufferize({
            "lua require('plugs.notify').history_warn({hidden = true})",
            mods = {emsg_silent = true},
        })
        cmd.wincmd("j")
        builtin.winresize_fit()
        vim.bo.ft = "log"
    end, {desc = "Notify: warn (S)"})

    map("n", "<Leader>nd", require("notify").dismiss, {desc = "Notify: dismiss"})
    map("n", "<Leader>no", require("notify")._print_history, {desc = "Notify: log std (P)"})
    map("n", "<Leader>na", it(M.history_full, {hidden = true}), {desc = "Notify: all full (P)"})
    map("n", "<Leader>nV", it(M.history_full, {hidden = false}), {desc = "Notify: shown full (P)"})
    map("n", "<Leader>nv", it(M.history_full, {plain = true, hidden = false}),
        {desc = "Notify: shown (P)"})

    map("n", "<Leader>nM", "<Cmd>messages<CR>", {desc = "Notify: builtin messages (P)"})
    map("n", "<Leader>nE", "<Cmd>echo v:errmsg<CR>", {desc = "Notify: v:errmsg (P)"})

    map("n", "<Leader>nt", "<Cmd>Telescope notify<CR>", {desc = "Notify: telescope"})
    require("telescope").load_extension("notify")
end

init()

return M
