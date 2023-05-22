---@module 'usr.lib.textobj'
local M = {}

local utils = require("usr.shared.utils")
local coc = require("plugs.coc")

local fn = vim.fn

-- Array     Boolean    Class  Constant Constructor
-- Enum      EnumMember Event  Field    File
-- Function  Interface  Key    Method   Module
-- Namespace Null       Number Object   Operator
-- Package   Property   String Struct   TypeParameter
-- Variable

-- p(require("nvim-treesitter.textobjects.shared").available_textobjects('lua'))

-- @assignment.lhs    @assignment.rhs
--                    @comment.outer
M.symbol_map = {
    attribute = {
        {"attribute", "attr"},
        {},
    },
    assignment = {
        {"assignment", "assign"},
        {"Variable", "Array", "Object"},
    },
    block = {
        {"block"},
        {"Array", "Interface", "Struct", "Class", "Constructor", "Package", "Object"},
    },
    call = {
        {"call"},
        {},
    },
    class = {
        {"class"},
        {"Interface", "Struct", "Class", "Constructor"},
    },
    comment = {
        {"comment"},
        {},
    },
    conditional = {
        {"conditional", "cond"},
        {"Package"},
    },
    frame = {
        {"frame"},
        {},
    },
    ["function"] = {
        {"function", "func"},
        {"Method", "Function"},
    },
    loop = {
        {"loop"},
        {"Package"},
    },
    number = {
        {"number", "num"},
        {},
    },
    parameter = {
        {"parameter", "param"},
        {"TypeParameter", "Constant"},
    },
    ["return"] = {
        {"return", "ret"},
        {},
    },
    scopename = {
        {"scopename", "scope"},
        {"Namespace", "Module", "File"},
    },

    ts = {
        "attribute",
        "assignment",
        "block",
        "call",
        "class",
        "comment",
        "conditional",
        "frame",
        "function",
        "loop",
        "number",
        "parameter",
        "return",
        "scopename",
    },
    coc = {
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
    },
}

---select_textobject("@obj.inner", "o")
---coc.a2sync("selectSymbolRange", {inner, visual, symbol})
---@param obj SymbolKind
---@param inner boolean
---@param visual boolean
function M.select(obj, inner, visual)
    if coc.did_init() then
        local symbols = {
            func = {"Method", "Function"},
            class = {"Interface", "Struct", "Class"},
        }
        if not inner then
            local err, res = coc.a2sync("hasProvider", {"documentSymbol"})
            if not err and res == true then
                err = coc.a2sync("selectSymbolRange", {
                    inner,
                    visual and fn.visualmode() or "",
                    symbols[obj],
                })
                if not err then
                    utils.cecho("textobjects: coc", "WarningMsg")
                    return
                end
            end
        end
    end
    if obj == "func" then
        obj = "function"
    end
    require("plugs.treesitter").do_textobj(obj, inner, visual)
    utils.cecho("textobjects: treesitter", "WarningMsg")
end

return M
