local M = {}

local D = require("dev")
local augend = D.npcall(require, "dial.augend")
if not augend then
    return
end

local dmap = require("dial.map")

local utils = require("common.utils")
local augroup = utils.augroup
local map = utils.map

M.filetypes = {}

---Define an augend constant
---@param elements table
---@param word boolean
---@param cyclic boolean
---@return table
local function aug(elements, word, cyclic)
    return augend.constant.new(
        {
            -- { "and", "or" }
            elements = elements,
            -- if false, "sand" is incremented into "sor", "doctor" into "doctand", etc.
            word = word == nil and true or word,
            -- "or" is incremented into "and"
            cyclic = cyclic == nil and true or cyclic
        }
    )
end

---Returns a list of all characters in the given string.
-- @param str The string to get the characters from.
-- @return table
local function generate_list(str)
    local ret = {}
    for i = 1, #str, 1 do
        table.insert(ret, str:sub(i, i))
    end
    return ret
end

---Extend an array of augments
---@param ft string
---@param dst table
---@param src table
---@return table
local function extend(ft, dst, src)
    table.insert(M.filetypes, ft)
    return vim.list_extend(dst, src)
end

function M.setup()
    local default = {
        -- augend.integer.alias.decimal, -- nonnegative decimal number (0, 1, 2, 3, ...)
        augend.integer.alias.decimal_int, -- any decimal number (0, 1, 2, 3, ...)
        augend.integer.alias.hex, -- nonnegative hex number  (0x01, 0x1a20, etc.)
        augend.integer.alias.octal, -- 0o00, 0o11, 0o24,
        augend.integer.alias.binary, -- 0b0101, 0b11000111
        augend.date.alias["%m/%d"],
        augend.date.alias["%H:%M"], -- hour/minute
        augend.date.alias["%H:%M:%S"],
        augend.date.alias["%Y/%m/%d"], -- date (2022/02/19, etc.)
        augend.date.alias["%Y-%m-%d"],
        augend.date.alias["%m/%d"],
        augend.constant.alias.bool, -- boolean value (true <-> false)
        augend.semver.alias.semver, -- 4.3.0
        augend.hexcolor.new {case = "lower"}, -- color #b4c900
        aug({"above", "below"}),
        aug({"and", "or"}),
        aug({"True", "False"}),
        aug({"enable", "disable"}),
        aug({"on", "off"}),
        aug({"up", "down"}),
        aug({"left", "right"}),
        aug({"top", "bottom"}),
        aug({"read", "write"}),
        aug({"open", "close"}),
        aug({"trace", "debug", "info", "warn", "error", "fatal"}),
        aug(
            {
                "Sunday",
                "Monday",
                "Tuesday",
                "Wednesday",
                "Thursday",
                "Friday",
                "Saturday"
            }
        ),
        aug(
            {
                "January",
                "February",
                "March",
                "April",
                "May",
                "June",
                "July",
                "August",
                "September",
                "October",
                "November",
                "December"
            }
        ),
        aug({"&&", "||"}, false),
        aug({"==", "!="}, false),
        aug({">=", "<="}, false),
        aug({">>", "<<"}, false),
        aug({"++", "--"}, false),
        aug(generate_list("abcdefghijklmnopqrstuvwxyz"), false),
        aug(generate_list("ABCDEFGHIJKLMNOPQRSTUVWXYZ"), false)
    }

    -- Extend the default table
    -- Is there a better way to extend the default?
    local lua =
        extend(
        "lua",
        default,
        {
            aug({"true", "false", "nil"}),
            aug({"elseif", "if"}),
            aug({"==", "~="}, false),
            aug({"pairs", "ipairs"})
        }
    )

    local python = extend("python", default, aug({"elif", "if"}))
    local sh = extend("sh", default, aug({"elif", "if"}))
    local zsh = extend("zsh", default, {aug({"elif", "if"}), aug({"((:))", "[[:]]"}, false)})
    local typescript =
        extend(
        "typescript",
        default,
        {aug({"let", "const", "var"}), aug({"===", "!=="}), aug({"public", "private", "protected"})}
    )
    -- local javascript = extend("javascript", typescript, {aug({"public", "private", "protected"})})
    local vim_ = extend("vim", default, {aug({"elseif", "if"})})

    local go =
        extend(
        "go",
        default,
        {
            aug({":=", "="}),
            aug({"interface", "struct"}),
            aug({"int", "int8", "int16", "int32", "int64"}),
            aug({"uint", "uint8", "uint16", "uint32", "uint64"}),
            aug({"float32", "float64"}),
            aug({"complex64", "complex128"})
        }
    )

    local zig =
        extend(
        "zig",
        default,
        augend.user.new(
            {
                desc = "Zig/Rust octal integers",
                find = require("dial.augend.common").find_pattern("0o[0-7]+"),
                add = function(text, addend, cursor)
                    local wid = #text
                    local n = tonumber(string.sub(text, 3), 8)
                    n = n + addend
                    if n < 0 then
                        n = 0
                    end
                    text = "0o" .. require("dial.util").tostring_with_base(n, 8, wid - 2, "0")
                    cursor = #text
                    return {
                        text = text,
                        cursor = cursor
                    }
                end
            }
        )
    )

    local rust = zig

    local markdown =
        extend(
        "markdown",
        default,
        augend.user.new(
            {
                desc = "Markdown Header (# Title)",
                find = function(line)
                    local from, to = line:find("^#+")
                    if from == nil or to > 7 then
                        return nil
                    end
                    return {from = from, to = to}
                end,
                add = function(text, addend)
                    local n = #text
                    n = n + addend
                    if n < 1 then
                        n = 1
                    end
                    if n > 6 then
                        n = 6
                    end
                    text = ("#"):rep(n)
                    return {text = text, cursor = 1}
                end
            }
        )
    )

    require("dial.config").augends:register_group(
        {
            -- default augends used when no group name is specified
            default = default,
            visual = {
                augend.integer.alias.decimal,
                augend.integer.alias.hex,
                augend.date.alias["%Y/%m/%d"],
                augend.constant.alias.alpha,
                augend.constant.alias.Alpha
            },
            typescript = typescript,
            javascript = typescript,
            lua = lua,
            python = python,
            sh = sh,
            zsh = zsh,
            vim = vim_,
            go = go,
            markdown = markdown,
            rust = rust,
            zig = zig,
            -- Maybe use a group for something?
            mygroup = {
                augend.date.alias["%m/%d/%Y"], -- date (02/19/2022, etc.)
                augend.constant.alias.bool, -- boolean value (true <-> false)
                augend.integer.alias.decimal,
                augend.integer.alias.hex,
                augend.semver.alias.semver
            }
        }
    )
end

---Create an autocmd for a given filetype
---@param ft string
local function inc_dec_augroup(ft)
    -- Overwrite the default dial mappings that are set below
    augroup(
        {"lmb__DialIncDec", false},
        {
            event = "FileType",
            pattern = {ft},
            command = function()
                map("n", "+", dmap.inc_normal(ft))
                map("n", "_", dmap.dec_normal(ft))
                map("v", "+", dmap.inc_visual(ft))
                map("v", "_", dmap.dec_visual(ft))
                map("v", "g+", dmap.inc_gvisual(ft))
                map("v", "g_", dmap.dec_gvisual(ft))
            end,
            desc = ("Increment decrement types with dial in %s"):format(ft)
        }
    )
end

local function init()
    M.setup()

    map("n", "+", dmap.inc_normal())
    map("n", "_", dmap.dec_normal())
    map("v", "+", dmap.inc_visual())
    map("v", "_", dmap.dec_visual())
    map("v", "g+", dmap.inc_gvisual())
    map("v", "g_", dmap.dec_gvisual())

    for _, ft in pairs(M.filetypes) do
        inc_dec_augroup(ft)
    end
end

init()

return M
