---@diagnostic disable:undefined-field

local M = {}

local utils = require("common.utils")
local gittool = require("common.gittool")
local coc = require("plugs.coc")
local log = require("common.log")

local promise = require("promise")
local backends = require("aerial.backends")
local config = require("aerial.config")
local data = require("aerial.data")

local F = vim.F
local api = vim.api
local fn = vim.fn
local cmd = vim.cmd

---@alias SymbolKind table<number,
---|  "Array"
---|  "Boolean"
---|  "Class"
---|  "Constant"
---|  "Constructor"
---|  "Enum"
---|  "EnumMember"
---|  "Event"
---|  "Field"
---|  "File"
---|  "Function"
---|  "Interface"
---|  "Key"
---|  "Method"
---|  "Module"
---|  "Namespace"
---|  "Null"
---|  "Number"
---|  "Object"
---|  "Operator"
---|  "Package"
---|  "Property"
---|  "String"
---|  "Struct"
---|  "TypeParameter"
---|  "Variable">

---@class Outline
---@field filter_kind SymbolKind
---@field fzf boolean
---@field bufnr number?

local function activate_qf(opts)
    local winid = fn.getloclist(0, {winid = 0}).winid
    if winid == 0 then
        if opts.fzf then
            cmd("abo lw")
        else
            cmd("bel lw")
        end
    else
        api.nvim_set_current_win(winid)
    end

    if vim.w.bqf_enabled and opts.fzf then
        utils.normal("m", "zf")
    end
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                          Aerial                          │
-- ╰──────────────────────────────────────────────────────────╯

---Fill a quickfix-list with symbols from Aerial
---@param args Outline
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
                "Type"
            },
            fzf = false
        }
    )
    local results = {}
    local bufnr = nvim.buf.nr()
    if vim.bo[bufnr].bt == "quickfix" then
        bufnr = fn.bufnr("#")
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

        bufdata:visit(
            function(item)
                table.insert(results, item)
            end
        )
    end

    local items = {}
    local text_fmt = "%-32s│%5d:%-3d│%10s%s%s"
    -- local hl_defs = api.nvim__get_hl_defs(0)
    -- local hl_def_keys = _t(hl_defs):keys()

    -- local ns = api.nvim_create_namespace("aerial-sign")
    -- for name, icon in pairs(config.icons) do
    --     -- Choose a random highlight group
    --     local rand = math.random(1, #hl_defs)
    --
    --     fn.sign_define(
    --         "aerial-sign-" .. name,
    --         {
    --             text = icon,
    --             texthl = hl_defs[name] and name or hl_def_keys[rand]
    --         }
    --     )
    -- end

    for _, s in pairs(results) do
        local col = s.col + 1
        local icon = config.get_icon(s.kind)

        table.insert(
            items,
            {
                bufnr = bufnr,
                lnum = s.lnum,
                col = col,
                end_lnum = s.end_lnum,
                end_col = s.end_col,
                text = text_fmt:format(s.kind, s.lnum, col, " ", ("| "):rep(s.level), s.name),
                icon = icon, -- Not needed
                kind = s.kind
            }
        )
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
                bqf = {fzf_action_for = {esc = "closeall", ["ctrl-c"] = ""}}
            },
            items = items,
            quickfixtextfunc = function(qinfo)
                local ret = {}
                local _items = fn.getloclist(qinfo.winid, {id = qinfo.id, items = 0}).items
                bufnr = api.nvim_get_current_buf()

                -- api.nvim_buf_clear_namespace(bufnr, ns, qinfo.start_idx, qinfo.end_idx + 1)

                -- for _, sign in pairs(fn.sign_getplaced(bufnr, {group = "aerial-sign"})[1].signs) do
                --     if sign.lnum - 1 >= qinfo.start_idx and sign.lnum - 1 <= qinfo.end_idx then
                --         fn.sign_unplace("aerial-sign", {buffer = bufnr, id = sign.id})
                --     end
                -- end

                for i = qinfo.start_idx, qinfo.end_idx do
                    local ele = _items[i]
                    table.insert(ret, ele.text)

                    -- for j = 1, #items do
                    --     local item = items[j]
                    --     if item.text == ele.text then
                    --         if type(item.kind) == "string" then
                    --             fn.sign_place(
                    --                 0,
                    --                 "aerial-sign",
                    --                 "aerial-sign-" .. item.kind,
                    --                 bufnr,
                    --                 {
                    --                     lnum = j,
                    --                     priority = 90
                    --                 }
                    --             )
                    --         end
                    --     end
                    -- end
                end
                return ret
            end
        }
    )

    activate_qf(opts)

    -- TODO: How to clear sign column on close?
    --
    -- vim.defer_fn(
    --     function()
    --         fn.sign_unplace("aerial-sign")
    --         api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
    --     end,
    --     1000
    -- )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                           Coc                            │
-- ╰──────────────────────────────────────────────────────────╯

---Fill a quickfix-list with symbols from Coc
---@param args Outline
function M.outline(args)
    if not coc.did_init() then
        log.err("Coc not ready yet ...", true)
        return promise.resolve()
    end

    local opts = args or {}

    if opts.filter_kind and opts.filter_kind == false then
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
            "Variable"
        }
    end

    opts =
        vim.tbl_extend(
        "keep",
        opts,
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
                "Type"
            },
            fzf = false
        }
    ) or {} -- NOTE: This is needed to prevent diagnostic warning on casting 'Outline' to table|nil

    local bufnr = api.nvim_get_current_buf()
    if vim.bo[bufnr].bt == "quickfix" then
        -- bufnr = fn.bufnr("#")
        return promise.resolve()
    end

    coc.runCommand("kvs.symbol.docSymbols", bufnr, opts.filter_kind):thenCall(
        function(value)
            if type(value) ~= "table" or #value == 0 then
                return
            end

            local items = {}
            local text_fmt = "%-32s│%5d:%-3d│%10s%s%s"

            for _, s in ipairs(value) do
                local rs, re = s.range.start, s.range["end"]
                local lnum, col = rs.line + 1, rs.character + 1
                table.insert(
                    items,
                    {
                        bufnr = bufnr,
                        lnum = lnum,
                        col = col,
                        end_lnum = re.line + 1,
                        end_col = re.character + 1,
                        text = text_fmt:format(s.kind, lnum, col, " ", ("| "):rep(s.level), s.name)
                    }
                )
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
                        bqf = {fzf_action_for = {esc = "closeall", ["ctrl-c"] = ""}}
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
                    end
                }
            )

            activate_qf(opts)
        end
    ):catch(
        function(reason)
            vim.notify(reason, log.levels.WARN)
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
        vim.tbl_extend(
        "keep",
        args or {},
        {
            bufnr = api.nvim_get_current_buf(),
            fzf = false
        }
    )

    if vim.bo[opts.bufnr].bt == "quickfix" then
        -- bufnr = fn.bufnr("#")
        return
    end

    local parsers = require("nvim-treesitter.parsers")
    if not parsers.has_parser(parsers.get_buf_lang(opts.bufnr)) then
        vim.notify("No parser for the current buffer", log.levels.ERROR, {title = "builtin.treesitter"})
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

    local ts_utils = require("nvim-treesitter.ts_utils")
    local items = {}
    local text_fmt = "%-32s│%5d:%-3d│%10s%s"

    for _, entry in pairs(results) do
        local srow, scol, erow, ecol = ts_utils.get_node_range(entry.node)
        local node_text = vim.treesitter.get_node_text(entry.node, opts.bufnr)

        table.insert(
            items,
            {
                bufnr = opts.bufnr,
                lnum = srow + 1,
                col = scol,
                end_lnum = erow,
                end_col = ecol,
                text = text_fmt:format(entry.kind, srow, scol, " ", vim.trim(node_text)),
                kind = entry.kind
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
            title = ("Outline Bufnr (Treesitter): %d"):format(opts.bufnr),
            id = "$",
            context = {
                bqf = {fzf_action_for = {esc = "closeall", ["ctrl-c"] = ""}}
            },
            items = items,
            quickfixtextfunc = function(qinfo)
                local ret = {}
                local _items = fn.getloclist(qinfo.winid, {id = qinfo.id, items = 0}).items
                -- local bufnr = api.nvim_get_current_buf()

                for i = qinfo.start_idx, qinfo.end_idx do
                    local ele = _items[i]
                    table.insert(ret, ele.text)
                end
                return ret
            end
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

            table.insert(
                conflicts,
                {
                    bufnr = bufnr,
                    lnum = lnum + 1,
                    col = 1,
                    text = text
                    -- type = "M"
                }
            )

            ::continue::
        end

        fn.setqflist(conflicts, "r")

        if #conflicts > 0 then
            cmd("abo lw")
        end
    end
end

function M.outline_syntax()
    cmd(
        [[
        syn match @function /^\(Function\)\s*/ nextgroup=qfSeparator
        syn match @method /^\(Method\)\s*/ nextgroup=qfSeparator
        syn match @keyword /^\(Interface\|Struct\|Class\)\s*/ nextgroup=qfSeparator
        syn match @constructor /^\(Constructor\)\s*/ nextgroup=qfSeparator

        syn match @constant /^\(associated\|constant\)\s*/ nextgroup=qfSeparator
        syn match @field /^\(field\)\s*/ nextgroup=qfSeparator
        syn match @function /^\(function\)\s*/ nextgroup=qfSeparator
        syn match @include /^\(import\)\s*/ nextgroup=qfSeparator
        syn match @method /^\(method\)\s*/ nextgroup=qfSeparator
        syn match HLArgsParam /^\(parameter\)\s*/ nextgroup=qfSeparator
        syn match @property /^\(property\)\s*/ nextgroup=qfSeparator
        syn match @struct /^\(struct\)\s*/ nextgroup=qfSeparator
        syn match @method /^\(var\)\s*/ nextgroup=qfSeparator

        syn match qfSeparator /│/ contained nextgroup=qfLineNr
        syn match qfLineNr /[^│]*/ contained

        hi def link qfSeparator Delimiter
        hi def link qfLineNr LineNr
        hi HLArgsParam guifg=#ea6962
    ]]
    )
end

return M
