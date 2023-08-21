---@module 'usr.plugs.qfext'
local M = {}

local lib = require("usr.lib")
local log = lib.log
local shared = require("usr.shared")
local utils = shared.utils
local gittool = shared.utils.git
local F = shared.F

local coc = require("plugs.coc")

---@type Promise
local promise = require("promise")
local backends = require("aerial.backends")
local config = require("aerial.config")
local data = require("aerial.data")

local api = vim.api
local fn = vim.fn
local cmd = vim.cmd

---This is actually loclist, not QF
---@param opts? Outline
local function activate_qf(opts)
    local winid = fn.getloclist(0, {winid = 0}).winid
    if winid == 0 then
        if opts.fzf then
            cmd("abo lw")

            if vim.w.bqf_enabled then
                utils.normal("m", "zf")
            end
        else
            cmd("bel lw")
        end
    else
        api.nvim_set_current_win(winid)
    end
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                          Aerial                          │
-- ╰──────────────────────────────────────────────────────────╯

---Fill a quickfix-list with symbols from Aerial
---@param args? Outline
function M.outline_aerial(args)
    local opts =
        vim.tbl_extend(
            "keep",
            args or {},
            {
                filter_kind = {
                    "Class",
                    "Constructor",
                    "Enum",
                    "Function",
                    "Interface",
                    "Module",
                    "Method",
                    "Struct",
                    "Type",
                },
                fzf = false,
                bufnr = api.nvim_get_current_buf(),
            }
        )
    local results = {}
    local bufnr = opts.bufnr
    if vim.bo[bufnr].bt == "quickfix" then
        -- bufnr = fn.bufnr("#")
        return
    end

    config.setup({filter_kind = opts.filter_kind})

    local backend = backends.get(bufnr)

    if not backend then
        backends.log_support_err()
        return
    elseif not data.has_symbols(bufnr) then
        backend.fetch_symbols_sync(bufnr)
    end

    if data.has_symbols(bufnr) then
        local bufdata = data.get_or_create(bufnr)

        bufdata:visit(function(item)
            table.insert(results, item)
        end)
    end

    local items = {}
    local text_fmt = "%s%-32s│%5d:%-3d│%s%s%s"

    for _, s in pairs(results) do
        local icon = config.get_icon(bufnr, s.kind)
        table.insert(items, {
            bufnr = bufnr,
            lnum = s.lnum,
            col = s.col + 1,
            end_lnum = s.end_lnum,
            end_col = s.end_col + 1,
            text = text_fmt:format(
                icon,
                s.kind,
                s.lnum,
                s.col + 1,
                " ",
                ("| "):rep(s.level),
                s.name
            ),
            icon = icon, -- Not needed
            kind = s.kind,
        })
    end

    local title = fn.getloclist(0, {title = 0, nr = "$"}).title
    local new_title = ("Outline Bufnr (Aerial): %d"):format(bufnr)
    fn.setloclist(
        0,
        {},
        title == new_title and "r" or " ",
        {
            title = title,
            id = "$",
            context = {
                bqf = {fzf_action_for = {esc = "closeall", ["ctrl-c"] = ""}},
            },
            items = items,
            quickfixtextfunc = function(qinfo)
                local ret = {}
                local _items = fn.getloclist(qinfo.winid, {id = qinfo.id, items = 0}).items
                for i = qinfo.start_idx, qinfo.end_idx do
                    local ele = _items[i]
                    table.insert(ret, ele.text)
                end
                return ret
            end,
        }
    )

    activate_qf(opts)
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                           Coc                            │
-- ╰──────────────────────────────────────────────────────────╯

---Fill a quickfix-list with symbols from Coc
---@param args? Outline
---@return Promise?
function M.outline(args)
    if not coc.did_init() then
        log.err("Coc not ready yet ...")
        return promise.resolve()
    end

    local opts = args or {}
    if opts.filter_kind == false then
        opts.filter_kind = {
            "Array",
            "Boolean",
            "Class",
            "Constant",
            "Constructor",
            "Enum",
            "EnumMember",
            "Event",
            "Field",
            "File",
            "Function",
            "Interface",
            "Key",
            "Method",
            "Module",
            "Namespace",
            "Null",
            "Number",
            "Object",
            "Operator",
            "Package",
            "Property",
            "String",
            "Struct",
            "TypeParameter",
            "Variable",
        }
    end

    opts =
        vim.tbl_deep_extend("keep", opts, {
            filter_kind = {
                "Class",
                "Constructor",
                "Enum",
                "Function",
                "Interface",
                "Method",
                "Module",
                "Struct",
                "Type",
            },
            fzf = false,
            bufnr = api.nvim_get_current_buf(),
        }) or {}

    -- Aerial icon works for Coc too
    config.setup({filter_kind = opts.filter_kind})

    local bufnr = opts.bufnr
    if vim.bo[bufnr].bt == "quickfix" then
        -- bufnr = fn.bufnr("#")
        return promise.resolve()
    end

    coc.runCommand("kvs.symbol.docSymbols", bufnr, opts.filter_kind):thenCall(function(value)
        if type(value) ~= "table" or #value == 0 then
            return
        end

        local items = {}
        local text_fmt = "%s%-32s│%5d:%-3d│%s%s%s"

        for _, s in ipairs(value) do
            local icon = config.get_icon(bufnr, s.kind)
            local rs, re = s.range.start, s.range["end"]
            local lnum, col = rs.line + 1, rs.character + 1
            table.insert(items, {
                bufnr = bufnr,
                lnum = lnum,
                col = col,
                end_lnum = re.line + 1,
                end_col = re.character + 1,
                text = text_fmt:format(
                    F.if_nil(icon, ""),
                    s.kind,
                    lnum,
                    col,
                    " ",
                    -- ("| "):rep(s.level),
                    s.level > 0 and ("| "):rep(s.level) or "",
                    s.name
                ),
            })
        end

        local title = fn.getloclist(0, {title = 0, nr = "$"}).title
        local new_title = ("Outline Bufnr: %d"):format(bufnr)
        fn.setloclist(
            0,
            {},
            title == new_title and "r" or " ",
            {
                title = new_title,
                context = {
                    bqf = {fzf_action_for = {esc = "closeall", ["ctrl-c"] = ""}},
                },
                items = items,
                quickfixtextfunc = function(qinfo)
                    local ret = {}
                    local _items = fn.getloclist(qinfo.winid, {id = qinfo.id, items = 0}).items
                    for i = qinfo.start_idx, qinfo.end_idx do
                        local ele = _items[i]
                        table.insert(ret, ele.text)
                    end
                    return ret
                end,
            }
        )

        activate_qf(opts)
    end
    ):catch(
        function(reason)
            log.warn(reason, {print = true})
        end
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                        Treesitter                        │
-- ╰──────────────────────────────────────────────────────────╯

local function prepare_match(entry, kind)
    local _ = kind
    local entries = {}

    if entry.node then
        table.insert(entries, entry)
    else
        for name, item in pairs(entry) do
            vim.list_extend(entries, prepare_match(item, name))
        end
    end

    return entries
end

---Create an outline using treesitter
---@param args Outline
function M.outline_treesitter(args)
    local opts =
        vim.tbl_extend("keep", args or {}, {
            bufnr = api.nvim_get_current_buf(),
            fzf = false,
        })

    if vim.bo[opts.bufnr].bt == "quickfix" then
        -- bufnr = fn.bufnr("#")
        return
    end

    local parsers = require("nvim-treesitter.parsers")
    if not parsers.has_parser(parsers.get_buf_lang(opts.bufnr)) then
        log.err("No parser for the current buffer", {title = "qfext.treesitter"})
        return
    end

    local ts_locals = require("nvim-treesitter.locals")
    local results = {}
    for _, definition in ipairs(ts_locals.get_definitions(opts.bufnr)) do
        local entries = prepare_match(ts_locals.get_local_nodes(definition))
        for _, entry in ipairs(entries) do
            entry.kind = F.if_nil(entry.kind, "")
            table.insert(results, entry)
        end
    end

    if vim.tbl_isempty(results) then
        return
    end

    local items = {}
    local text_fmt = "%-32s│%5d:%-3d│%s%s"

    for _, entry in pairs(results) do
        local srow, scol, erow, ecol = vim.treesitter.get_node_range(entry.node)
        local node_text = vim.treesitter.get_node_text(entry.node, opts.bufnr)
        table.insert(
            items,
            {
                bufnr = opts.bufnr,
                lnum = srow + 1,
                col = scol + 1,
                end_lnum = erow + 1,
                end_col = ecol + 1,
                text = text_fmt:format(entry.kind, srow + 1, scol + 1, " ", node_text),
                kind = entry.kind,
                -- text = text_fmt:format(entry.kind, srow + 1, col, " ", ("| "):rep(s.???), node_text)
            }
        )
    end

    local title = fn.getloclist(0, {title = 0, nr = "$"}).title
    local new_title = ("Outline Bufnr (Treesitter): %d"):format(opts.bufnr)
    fn.setloclist(
        0,
        {},
        title == new_title and "r" or " ",
        {
            title = new_title,
            id = "$",
            context = {
                bqf = {fzf_action_for = {esc = "closeall", ["ctrl-c"] = ""}},
            },
            items = items,
            quickfixtextfunc = function(qinfo)
                local ret = {}
                local _items = fn.getloclist(qinfo.winid, {id = qinfo.id, items = 0}).items
                for i = qinfo.start_idx, qinfo.end_idx do
                    local ele = _items[i]
                    table.insert(ret, ele.text)
                end
                return ret
            end,
        }
    )

    activate_qf(opts)
end

---Turn conflict markers into a quickfix list
function M.conflicts2qf()
    if #gittool.root() == 0 then
        log.err("Not in a git directory")
        return
    end

    local conflicts = {}
    local lines = os.capture("git --no-pager diff --no-color --check --relative", true)

    for conflict in vim.gsplit(lines, "\n") do
        if conflict ~= "" then
            local fname = vim.split(conflict, ":")[1]
            local lnum = vim.split(conflict, ":")[2]

            if fn.split(fn.system(("head -n%d %s | tail -n1"):format(lnum, fname)))[1] ~= "<<<<<<<" then
                goto continue
            end

            cmd(("badd +%d %s"):format(lnum, fname))
            local bufnr = fn.bufnr(fname)
            local text = api.nvim_buf_get_lines(bufnr, tonumber(lnum), tonumber(lnum) + 1, false)[1]

            table.insert(conflicts, {
                bufnr = bufnr,
                lnum = lnum + 1,
                col = 1,
                text = text,
                -- type = "M"
            })

            ::continue::
        end

        fn.setqflist(conflicts, "r")

        if #conflicts > 0 then
            -- cmd("bel lw")
            cmd("abo lw")
        end
    end
end

function M.outline_syntax()
    vim.cmd(
        [[
        syn match @function /^.\?\s\?\(Function\)\s*/ nextgroup=qfSeparator
        syn match @method /^.\?\s\?\(Method\)\s*/ nextgroup=qfSeparator
        syn match @keyword /^.\?\s\?\(Interface\|Struct\|Class\|Enum\)\s*/ nextgroup=qfSeparator
        syn match @constructor /^.\?\s\?\(Constructor\)\s*/ nextgroup=qfSeparator
        syn match @code /^.\?\s\?\(Variable\)\s*/ nextgroup=qfSeparator
        syn match @constant /^.\?\s\?\(Constant\)\s*/ nextgroup=qfSeparator
        syn match @field /^.\?\s\?\(Object\)\s*/ nextgroup=qfSeparator
        syn match @field /^.\?\s\?\(Field\|Key\|Property\)\s*/ nextgroup=qfSeparator
        syn match @field /^.\?\s\?\(EnumMember\)\s*/ nextgroup=qfSeparator
        syn match @number /^.\?\s\?\(Number\)\s*/ nextgroup=qfSeparator
        syn match @conditional /^.\?\s\?\(Package\)\s*/ nextgroup=qfSeparator
        syn match @type.builtin /^.\?\s\?\(Type\)\s*/ nextgroup=qfSeparator
        syn match @type /^.\?\s\?\(TypeParameter\)\s*/ nextgroup=qfSeparator
        syn match @boolean /^.\?\s\?\(Null\)\s*/ nextgroup=qfSeparator
        syn match @operator /^.\?\s\?\(Operator\)\s*/ nextgroup=qfSeparator
        syn match @string /^.\?\s\?\(String\)\s*/ nextgroup=qfSeparator
        syn match @boolean /^.\?\s\?\(Boolean\)\s*/ nextgroup=qfSeparator
        syn match @type /^.\?\s\?\(Array\)\s*/ nextgroup=qfSeparator
        syn match @include /^.\?\s\?\(Module\)\s*/ nextgroup=qfSeparator
        syn match @namespace /^.\?\s\?\(Namespace\)\s*/ nextgroup=qfSeparator
        syn match Statement /^.\?\s\?\(Event\)\s*/ nextgroup=qfSeparator
        syn match Title /^.\?\s\?\(File\)\s*/ nextgroup=qfSeparator

        syn match @constant /^\(associated\|constant\)\s*/ nextgroup=qfSeparator
        syn match @field /^\(field\)\s*/ nextgroup=qfSeparator
        syn match @function /^\(function\)\s*/ nextgroup=qfSeparator
        syn match @include /^\(import\)\s*/ nextgroup=qfSeparator
        syn match @method /^\(method\)\s*/ nextgroup=qfSeparator
        syn match HLArgsParam /^\(parameter\)\s*/ nextgroup=qfSeparator
        syn match @property /^\(property\)\s*/ nextgroup=qfSeparator
        syn match @struct /^\(struct\)\s*/ nextgroup=qfSeparator
        syn match @method /^\(var\)\s*/ nextgroup=qfSeparator
        syn match @type /^\(type\)\s*/ nextgroup=qfSeparator

        syn match qfSeparator /│/ contained nextgroup=qfLineNr
        syn match qfLineNr /[^│]*/ contained

        hi def link qfSeparator Delimiter
        hi def link qfLineNr LineNr
        hi HLArgsParam guifg=#ea6962
    ]]
    )
end

return M
