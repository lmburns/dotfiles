---@diagnostic disable:undefined-field

local M = {}

local gittool = require("common.gittool")
local coc = require("plugs.coc")
local log = require("common.log")

local backends = require("aerial.backends")
local config = require("aerial.config")
local data = require("aerial.data")

local ex = nvim.ex
local F = vim.F
local api = vim.api
local fn = vim.fn
local cmd = vim.cmd

---@class Outline
---@field filter_kind table<number, "Array"|"Boolean"|"Class"|"Constant"|"Constructor"|"Enum"|"EnumMember"|"Event"|"Field"|"...">
---@field fzf boolean
---@field bufnr number?

-- Array Boolean Class    Constant  Constructor Enum     EnumMember Event
-- Field File    Function Interface Key         Method   Module     Namespace
-- Null  Number  Object   Operator  Package     Property String     Struct
-- TypeParameter Variable

-- ╭──────────────────────────────────────────────────────────╮
-- │                          Aerial                          │
-- ╰──────────────────────────────────────────────────────────╯

---Fill a quickfix-list with symbols from Aerial
---@param opts Outline
function M.outline_aerial(opts)
    opts =
        vim.tbl_extend(
        "keep",
        opts or {},
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
    elseif not data:has_symbols(bufnr) then
        backend.fetch_symbols_sync(bufnr)
    end

    if data:has_symbols(bufnr) then
        data[0]:visit(
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
                -- type = s.kind, -- Not sure why this would be needed
                icon = icon, -- Not needed
                kind = s.kind
            }
        )
    end

    fn.setloclist(
        0,
        {},
        " ",
        {
            title = ("Outline Bufnr: %d"):format(bufnr),
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

    local winid = fn.getloclist(0, {winid = 0}).winid
    if winid == 0 then
        ex.bel("lw")
    else
        api.nvim_set_current_win(winid)
    end

    if vim.b.bqf_enabled and opts.fzf then
        api.nvim_feedkeys("zf", "m", false)
    end

    -- TODO: How to clear sign column on close?
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
---@param opts Outline
function M.outline(opts)
    if not coc.did_init() then
        log.err("Coc not ready yet ...", true)
        return
    end

    opts = opts or {}

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
    )

    local bufnr = api.nvim_get_current_buf()
    if vim.bo[bufnr].bt == "quickfix" then
        bufnr = fn.bufnr("#")
    end
    coc.run_command(
        "kvs.symbol.docSymbols",
        {bufnr, opts.filter_kind},
        function(e, r)
            if e ~= vim.NIL or type(r) ~= "table" or #r == 0 then
                return
            end

            local items = {}
            local text_fmt = "%-32s│%5d:%-3d│%10s%s%s"
            for _, s in ipairs(r) do
                local range = s.selectionRange
                local rs, re = range.start, range["end"]
                local lnum, col = rs.line + 1, rs.character + 1
                table.insert(
                    items,
                    {
                        bufnr = bufnr,
                        lnum = lnum,
                        col = col,
                        end_lnum = re.line + 1,
                        end_col = re.character + 1,
                        text = text_fmt:format(s.kind, lnum, col, " ", ("| "):rep(s.level), s.text)
                    }
                )
            end
            fn.setloclist(
                0,
                {},
                " ",
                {
                    title = ("Outline Bufnr: %d"):format(bufnr),
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

            local winid = fn.getloclist(0, {winid = 0}).winid
            if winid == 0 then
                if opts.fzf then
                    ex.abo("lw")
                else
                    ex.bel("lw")
                end
            else
                api.nvim_set_current_win(winid)
            end
            if vim.b.bqf_enabled and opts.fzf then
                api.nvim_feedkeys("zf", "m", false)
            end
        end
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                        Treesitter                        │
-- ╰──────────────────────────────────────────────────────────╯

---@diagnostic disable-next-line:unused-local
local function prepare_match(entry, kind)
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

local treesitter_type_highlight = {
    ["associated"] = "TSConstant",
    ["constant"] = "TSConstant",
    ["field"] = "TSField",
    ["function"] = "TSFunction",
    ["method"] = "TSMethod",
    ["parameter"] = "TSParameter",
    ["property"] = "TSProperty",
    ["struct"] = "Struct",
    ["var"] = "TSVariableBuiltin"
}

---Create an outline using treesitter
---@param opts Outline?
function M.outline_treesitter(opts)
    opts =
        vim.tbl_extend(
        "keep",
        opts or {},
        {
            bufnr = api.nvim_get_current_buf(),
            fzf = false
        }
    )
    local parsers = require("nvim-treesitter.parsers")
    if not parsers.has_parser(parsers.get_buf_lang(opts.bufnr)) then
        utils.notify(
            "No parser for the current buffer",
            log.levels.ERROR,
            {
                title = "builtin.treesitter"
            }
        )
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

    -- local ns = api.nvim_create_namespace("treesitter-qf")
    local ts_utils = require "nvim-treesitter.ts_utils"
    local items = {}
    local text_fmt = "%-32s│%5d:%-3d│%10s%s"

    for _, entry in pairs(results) do
        local start_row, start_col, end_row, end_col = ts_utils.get_node_range(entry.node)
        local node_text = vim.treesitter.get_node_text(entry.node, opts.bufnr)

        table.insert(
            items,
            {
                bufnr = opts.bufnr,
                lnum = start_row + 1,
                col = start_col,
                end_lnum = end_row,
                end_col = end_col,
                kind = entry.kind,
                text = text_fmt:format(entry.kind, start_row, start_col, " ", vim.trim(node_text)),
                hl_group = treesitter_type_highlight[entry.kind]
            }
        )
    end

    fn.setloclist(
        0,
        {},
        " ",
        {
            title = ("Treesitter Bufnr: %d"):format(opts.bufnr),
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

                    -- for j = 1, #items do
                    --     local item = items[j]
                    --     if item.text == ele.text then
                    --         -- TODO: Get this to work
                    --         api.nvim_buf_add_highlight(bufnr, ns, item.hl_group, i, 0, 1)
                    --     end
                    -- end
                end
                return ret
            end
        }
    )

    local winid = fn.getloclist(0, {winid = 0}).winid
    if winid == 0 then
        ex.bel("lw")
    else
        api.nvim_set_current_win(winid)
    end

    if vim.b.bqf_enabled and opts.fzf then
        api.nvim_feedkeys("zf", "m", false)
    end
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

            ex.badd(("+%d %s"):format(lnum, fname))
            local bufnr = fn.bufnr(fname)
            local text = nvim.buf.get_lines(bufnr, tonumber(lnum), tonumber(lnum) + 1, false)[1]

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
            ex.copen()
        end
    end
end

function M.outline_syntax()
    cmd [[
        syn match Function /^\(Method\|Function\)\s*/ nextgroup=qfSeparator
        syn match Structure /^\(Interface\|Struct\|Class\)\s*/ nextgroup=qfSeparator
        syn match TSMethod /^\(Constructor\)\s*/ nextgroup=qfSeparator
        syn match qfSeparator /│/ contained nextgroup=qfLineNr
        syn match qfLineNr /[^│]*/ contained
        hi def link qfSeparator Delimiter
        hi def link qfLineNr LineNr
    ]]
end

return M
