local M = {}

local utils = require("common.utils")
local augend = utils.prequire("dial.augend")
local dmap = require("dial.map")

local augroup = utils.augroup
local map = utils.map

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

function M.setup()
    local default = {
        augend.integer.alias.decimal, -- nonnegative decimal number (0, 1, 2, 3, ...)
        augend.integer.alias.hex, -- nonnegative hex number  (0x01, 0x1a1f, etc.)
        augend.date.alias["%Y/%m/%d"], -- date (2022/02/19, etc.)
        augend.constant.alias.bool, -- boolean value (true <-> false)
        augend.semver.alias.semver,
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
        aug({"++", "--"}, false)
    }

    -- Extend the default table
    -- Is there a better way to extend the default?
    local lua = {
        aug({"true", "false", "nil"}),
        aug({"elseif", "if"}),
        aug({"==", "~="}, true),
        aug({"pairs", "ipairs"})
    }
    vim.list_extend(lua, default)

    local python = vim.list_extend(default, aug({"elif", "if"}))

    local sh = vim.list_extend(default, aug({"elif", "if"}))

    local zsh = vim.list_extend(default, {aug({"elif", "if"}), aug({"((:))", "[[:]]"}, false)})

    local typescript = vim.list_extend(default, {aug({"let", "const", "var"}), aug({"===", "!=="})})

    local javascript = vim.list_extend(typescript, {aug({"public", "private", "protected"})})

    local go =
        vim.list_extend(
        go,
        {
            aug({":=", "="}),
            aug({"interface", "struct"}),
            aug({"int", "int8", "int16", "int32", "int64"}),
            aug({"uint", "uint8", "uint16", "uint32", "uint64"}),
            aug({"float32", "float64"}),
            aug({"complex64", "complex128"})
        }
    )

    local vim_ = vim.list_extend(default, {aug({"elseif", "if"})})

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
            javascript = javascript,
            lua = lua,
            python = python,
            sh = sh,
            zsh = zsh,
            vim = vim_,
            go = go,
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
---@param group table
---@param ft string
local function inc_dec_augroup(ft)
    -- Overwrite the default dial mappings that are set below
    augroup(
        "lmb__DialIncDec",
        {
            event = "FileType",
            pattern = ft,
            command = function()
                map("n", "+", dmap.inc_normal(ft))
                map("n", "_", dmap.dec_normal(ft))
                map("v", "+", dmap.inc_visual(ft), {silent = true})
                map("v", "_", dmap.dec_visual(ft), {silent = true})
                map("v", "g+", dmap.inc_gvisual(ft), {silent = true})
                map("v", "g_", dmap.dec_gvisual(ft), {silent = true})
            end,
            desc = ("Increment decrement types with dial in %s"):format(ft)
        }
    )
end

local function init()
    M.setup()

    map("n", "+", dmap.inc_normal(), {silent = true})
    map("n", "_", dmap.dec_normal(), {silent = true})
    map("v", "+", dmap.inc_visual(), {silent = true})
    map("v", "_", dmap.dec_visual(), {silent = true})
    map("v", "g+", dmap.inc_gvisual(), {silent = true})
    map("v", "g_", dmap.dec_gvisual(), {silent = true})

    inc_dec_augroup("lua")
    inc_dec_augroup("python")
    inc_dec_augroup("sh")
    inc_dec_augroup("zsh")
    inc_dec_augroup("typescript")
    inc_dec_augroup("javascript")
    inc_dec_augroup("go")
    inc_dec_augroup("vim")
end

init()

return M
