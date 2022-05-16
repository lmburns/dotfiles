local M = {}

local gittool = require("common.gittool")
local coc = require("plugs.coc")

local backends = require("aerial.backends")
local config = require("aerial.config")
local data = require("aerial.data")

-- TODO: Reduce duplicate code here

---@class Outline
---@field filter_kind table<number, "Array"|"Boolean"|"Class"|"Constant"|"Constructor"|"Enum"|"EnumMember"|"Event"|"Field"|"...">
---@field fzf boolean

-- Array Boolean Class    Constant  Constructor Enum     EnumMember Event
-- Field File    Function Interface Key         Method   Module     Namespace
-- Null  Number  Object   Operator  Package     Property String     Struct
-- TypeParameter Variable

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
            }
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
    local text_fmt = "%-1s %-32s│%5d:%-3d│%10s%s%s"

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
                text = text_fmt:format(icon, s.kind, s.lnum, col, " ", ("| "):rep(s.level), s.name)
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
        ex.bel("lw")
    else
        api.nvim_set_current_win(winid)
    end

    if vim.b.bqf_enabled and opts.fzf then
        api.nvim_feedkeys("zf", "m", false)
    end
end

---Fill a quickfix-list with symbols from Coc
---@param opts Outline
function M.outline(opts)
    if not coc.did_init() then
        vim.notify("Coc not ready yet ...")
        return
    end

    opts =
        vim.tbl_extend(
        "keep",
        opts or {},
        {
            filter_kinds = {
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
        {bufnr, opts.filter_kinds},
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
        syn match qfSeparator /│/ contained nextgroup=qfLineNr
        syn match qfLineNr /[^│]*/ contained
        hi def link qfSeparator Delimiter
        hi def link qfLineNr LineNr
    ]]
end

return M
