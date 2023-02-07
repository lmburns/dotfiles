local M = {}

local utils = require("common.utils")
local coc = require("plugs.coc")

local fn = vim.fn

-- Array
-- Boolean
-- Class
-- Constant
-- Constructor
-- Enum
-- EnumMember
-- Event
-- Field
-- File
-- Function
-- Interface
-- Key
-- Method
-- Module
-- Namespace
-- Null
-- Number
-- Object
-- Operator
-- Package
-- Property
-- String
-- Struct
-- TypeParameter
-- Variable

function M.select(obj, inner, visual)
    if coc.did_init() then
        local symbols = {
            func = {"Method", "Function"},
            class = {"Interface", "Struct", "Class"}
        }
        if not inner then
            local err, res = coc.a2sync("hasProvider", {"documentSymbol"})
            if not err and res == true then
                err =
                    coc.a2sync(
                    "selectSymbolRange",
                    {
                        inner,
                        visual and fn.visualmode() or "",
                        symbols[obj]
                    }
                )
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
