---@module 'plugs.dial'
local M = {}

local augend = Rc.F.npcall(require, "dial.augend")
if not augend then
    return
end

local dmap = require("dial.map")
local dconf = require("dial.config")

local F = Rc.F
local augroup = Rc.api.augroup
local map = Rc.api.map

M.filetypes = {}

---Define an augend constant
---@param elements table
---@param word? boolean
---@param cyclic? boolean
---@return table
local function aug(elements, word, cyclic)
    return augend.constant.new(
        {
            -- { "and", "or" }
            elements = elements,
            -- if false, "sand" is incremented into "sor", "doctor" into "doctand", etc.
            word = F.unwrap_or(word, true),
            -- "or" is incremented into "and"
            cyclic = F.unwrap_or(cyclic, true),
        }
    )
end

---@alias date_t '"year"'|'"month"'|'"day"'|'"hour"'|'"min"'|'"sec"'

--FIX: Doesn't work properly
---Translate dates with the format 'X/Y/Z' -> 'X-Y-Z'
---@param fmt string Must contain '/'
---@param kind? date_t Kind to modify
---@return {[1]: Augend, [2]: Augend}
---@diagnostic disable-next-line:unused-function,unused-local
local function gen_date(fmt, kind)
    local alt = fmt:gsub("/", "-")
    kind = F.unwrap_or(kind, "day")
    return
        augend.date.new({pattern = fmt, default_kind = kind}),
        augend.date.new({pattern = alt, default_kind = kind})
end

---Returns a list of all characters in the given string.
---@param str string The string to get the characters from
---@return table
---@diagnostic disable-next-line:unused-function,unused-local
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
        augend.integer.alias.hex,         -- nonnegative hex number  (0x01, 0x1a20, etc.)
        augend.integer.alias.octal,       -- 0o00, 0o11, 0o24,
        augend.integer.alias.binary,      -- 0b0101, 0b11000111
        -- %a = "Sun", "Mon", "Tue"
        -- %A = "Sunday", "Monday", "Tuesday"
        -- %b = "Jan", "Feb", "Mar"
        -- %B = "January", "February", "March"
        -- %p = "AM", "PM"
        augend.date.alias["%Y/%m/%d"], -- 2023/01/20
        augend.date.alias["%d/%m/%Y"], -- 20/01/2023
        augend.date.alias["%d/%m/%y"], -- 20/01/23
        augend.date.alias["%m/%d/%Y"], -- 01/20/2023
        augend.date.alias["%m/%d/%y"], -- 01/20/23
        augend.date.alias["%m/%d"],    -- 01/20
        augend.date.alias["%Y-%m-%d"], -- 2023-01-20
        augend.date.alias["%-m/%-d"],  -- 1/20 | 01/20
        augend.date.alias["%d.%m.%Y"], -- 20.01.2023
        augend.date.alias["%d.%m.%y"], -- 20.01.23
        augend.date.alias["%d.%m."],   -- 20.01
        augend.date.alias["%-d.%-m."], -- 20.1 | 20.01
        -- FIX: Skips 2 on each
        augend.date.alias["%H:%M:%S"], -- 13:49:23
        augend.date.alias["%H:%M"],    -- hour/minute 13:49
        augend.date.new({
            pattern = "%I:%M%p",
            default_kind = "hour",
            -- only_valid = false,
            clamp = true,
            -- cyclic = true,
        }), -- 03:30PM
        -- augend.date.new({pattern = "%b. %d, %Y", default_kind = "day"}), -- Apr. 21, 2023
        -- augend.date.new({pattern = "%B. %d, %Y", default_kind = "day"}), -- April 21, 2023
        augend.date.new({
            pattern = "%b.",
            default_kind = "month", -- September
            word = false,
            cyclic = true,
            end_sensitive = true,
        }), -- May.
        augend.date.new({
            pattern = "%B",
            default_kind = "month",
            only_valid = false, -- stops at current month
            word = true,
            cyclic = true,
            end_sensitive = true,
        }), -- May
        -- FIX: Always only_valid (I think, goes from Sun->Tue and stops)
        -- augend.date.new({
        --     pattern = "%a.",
        --     default_kind = "day",
        --     -- only_valid = false,
        --     -- clamp = false,
        --     word = false,
        --     cyclic = true,
        --     end_sensitive = true,
        -- }), -- Sun.
        -- augend.date.new({
        --     pattern = "%A",
        --     default_kind = "day",
        --     only_valid = false,
        --     word = true,
        --     cyclic = true,
        --     -- clamp = false,
        --     -- end_sensitive = true,
        -- }), -- Tuesday
        augend.case.new({
            types = {"camelCase", "snake_case", "PascalCase", "SCREAMING_SNAKE_CASE"},
            cyclic = true,
            word = true,
        }),
        augend.date.new({pattern = "%m-%d-%Y", default_kind = "day"}),
        augend.date.new({pattern = "%m-%d-%y", default_kind = "day"}),
        augend.date.new({pattern = "%-H:%M:%S", default_kind = "min"}),
        augend.date.new({pattern = "%-H:%M", default_kind = "min"}),
        augend.constant.alias.bool,  -- boolean value (true <-> false)
        augend.constant.alias.alpha, -- a b c d
        augend.constant.alias.Alpha, -- A B C D
        augend.semver.alias.semver,  -- 4.3.0
        -- augend.paren.alias.brackets, -- ( [ {  } ] )
        -- augend.paren.alias.quote,    -- " -> ' | ' -> "
        augend.hexcolor.new({case = "lower"}), -- color #b4c900
        aug({"above", "below"}),
        aug({"after", "before"}),
        aug({"increase", "decrease"}),
        aug({"forward", "backward"}),
        aug({"first", "last"}),
        aug({"and", "&"}, false),
        aug({"and", "or"}),
        aug({"True", "False"}),
        aug({"enable", "disable"}),
        aug({"on", "off"}),
        aug({"in", "out"}),
        aug({"new", "old"}),
        aug({"dark", "light"}),
        aug({"less", "more"}),
        aug({"good", "bad"}),
        aug({"parent", "child"}),
        aug({"inner", "outer"}),
        aug({"from", "to"}),
        aug({"surround", "enclose"}),
        aug({"floor", "ceil"}),
        aug({"get", "set"}),
        aug({"width", "height"}),
        aug({"yes", "no"}),
        aug({"up", "down"}),
        aug({"left", "right"}),
        aug({"top", "bottom"}),
        aug({"read", "write"}),
        aug({"open", "close"}),
        aug({"horizontal", "vertical"}),
        aug({"expand", "collapse"}),
        aug({"positive", "negative"}),
        aug({"previous", "prev", "next"}),
        aug({"Previous", "Prev", "Next"}),
        aug({"start", "beginning", "end"}),
        aug({"capitalize", "uppercase", "lowercase"}),
        aug({"trace", "debug", "info", "warn", "error", "fatal"}),
        -- aug({
        --     "January",
        --     "February",
        --     "March",
        --     "April",
        --     "May",
        --     "June",
        --     "July",
        --     "August",
        --     "September",
        --     "October",
        --     "November",
        --     "December",
        -- }),
        aug({
            "Sunday",
            "Monday",
            "Tuesday",
            "Wednesday",
            "Thursday",
            "Friday",
            "Saturday",
        }),
        aug({
            "Sun.",
            "Mon.",
            "Tue.",
            "Wed.",
            "Thu.",
            "Fri.",
            "Sat.",
        }, false),
        aug({
            "zero",
            "one",
            "two",
            "three",
            "four",
            "five",
            "six",
            "seven",
            "eight",
            "nine",
            "ten",
        }, false),
        aug({"for", "while"}),
        aug({"+", "-", "*", "/", "%"}, false),
        aug({"&&", "||"}, false),
        aug({"==", "!="}, false),
        aug({">=", "<="}, false),
        aug({">>", "<<"}, false),
        aug({"++", "--"}, false), -- ++ --
        aug({"<-", "←"}, false),
        aug({"->", "→"}, false),
        aug(generate_list("abcdefghijklmnopqrstuvwxyz"), false),
        aug(generate_list("ABCDEFGHIJKLMNOPQRSTUVWXYZ"), false),
    }

    local lua = extend("lua", {
        aug({"true", "false", "nil"}),
        aug({"elseif", "if"}),
        aug({"==", "~="}, false),
        aug({"pairs", "ipairs"}),
        aug({"number", "integer"}),
    }, default)

    local python = extend("python", aug({"elif", "if"}), default)
    local sh = extend("sh", aug({"elif", "if"}), default)
    local zsh = extend("zsh", {
        aug({"elif", "if"}),
        aug({"local", "typeset", "integer", "private"}),
        augend.case.new({
            types = {"camelCase", "snake_case", "kebab-case"},
            cyclic = true,
        }),
        augend.paren.alias.quote, -- " -> ' | ' -> "
        augend.paren.new({
            patterns = {{"[[", "]]"}, {"((", "))"}},
            nested = false,
            cyclic = true,
        }),
        -- augend.paren.alias.brackets, -- ( [ {  } ] )
    }, default)
    local typescript = extend("typescript", {
        aug({"let", "const", "var"}),
        aug({"of", "in"}),
        aug({"===", "!=="}),
        aug({"public", "private", "protected"}),
    }, default)
    -- local javascript = extend("javascript", typescript, {aug({"public", "private", "protected"})})
    local vim_ = extend("vim", default, {aug({"elseif", "if"})})

    local go = extend("go", {
        aug({":=", "="}),
        aug({"interface", "struct"}),
        aug({"int", "int8", "int16", "int32", "int64"}),
        aug({"uint", "uint8", "uint16", "uint32", "uint64"}),
        aug({"float32", "float64"}),
        aug({"complex64", "complex128"}),
    }, default)

    local octal = augend.user.new({
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
                cursor = cursor,
            }
        end,
    })
    local zig = extend("zig", {octal}, default)
    local rust = extend("rust", {
        octal,
        augend.paren.alias.rust_str_literal, -- " r# r## r###
    }, default)

    local markdown = extend(
        "markdown",
        default,
        augend.misc.alias.markdown_header
    )

    dconf.augends:register_group({
        -- default augends used when no group name is specified
        default = default,
        visual = {
            augend.date.alias["%Y/%m/%d"], -- 2023/01/20
            augend.date.alias["%d/%m/%Y"], -- 20/01/2023
            augend.date.alias["%d/%m/%y"], -- 20/01/23
            augend.date.alias["%m/%d/%Y"], -- 01/20/2023
            augend.date.alias["%m/%d/%y"], -- 01/20/23
            augend.date.alias["%m/%d"],    -- 01/20
            augend.date.alias["%Y-%m-%d"], -- 2023-01-20
            augend.date.alias["%-m/%-d"],  -- 1/20 | 01/20
            augend.date.alias["%d.%m.%Y"], -- 20.01.2023
            augend.date.alias["%d.%m.%y"], -- 20.01.23
            augend.date.alias["%d.%m."],   -- 20.01
            augend.date.alias["%-d.%-m."], -- 20.1 | 20.01
            augend.date.alias["%H:%M:%S"], -- 12:49:23
            augend.date.alias["%H:%M"],    -- hour/minute
            augend.integer.alias.decimal,
            augend.integer.alias.hex,
            augend.constant.alias.bool, -- boolean value (true <-> false)
            augend.constant.alias.alpha,
            augend.constant.alias.Alpha,
            augend.paren.alias.lua_str_literal, -- ' " [[ [=[ [==[ [===[
            augend.paren.alias.brackets,        -- ( [ {  } ] )
        },
        luastr = {
            augend.paren.alias.lua_str_literal, -- ' " [[ [=[ [==[ [===[
        },
        bracket = {
            augend.paren.alias.brackets, -- ( [ {  } ] )
        },
        case = {
            augend.case.new({
                types = {"camelCase", "snake_case", "PascalCase", "SCREAMING_SNAKE_CASE"},
                cyclic = true,
                word = true,
            }),
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
    })

    dconf.augends:on_filetype({
        typescript = typescript,
        typescriptreact = typescript,
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
    })
end

-- == ~=

---Create an autocmd for a given filetype
---@param ft string
---@diagnostic disable-next-line:unused-function,unused-local
local function inc_dec_augroup(ft)
    -- Overwrite the default dial mappings that are set below
    augroup({"lmb__DialIncDec", false}, {
        event = "FileType",
        pattern = ft,
        command = function(args)
            local bmap = function(...)
                Rc.api.bmap(args.buf, ...)
            end

            bmap("n", "+", dmap.inc_normal(ft))
            bmap("n", "_", dmap.dec_normal(ft))
            bmap("v", "+", dmap.inc_visual(ft))
            bmap("v", "_", dmap.dec_visual(ft))
            bmap("v", "g+", dmap.inc_gvisual(ft))
            bmap("v", "g_", dmap.dec_gvisual(ft))
        end,
        desc = ("Increment decrement types with dial in %s"):format(ft),
    })
end

local function init()
    M.setup()

    map("n", "s-", dmap.inc_normal("luastr"), {ft = "lua", desc = "Dial: increase luastr"})
    map("n", "s=", dmap.dec_normal("luastr"), {ft = "lua", desc = "Dial: decrease luastr"})
    map("n", "s[", dmap.inc_normal("bracket"), {desc = "Dial: increase bracket"})
    map("n", "s]", dmap.dec_normal("bracket"), {desc = "Dial: decrease bracket"})
    map("n", "s`", dmap.inc_normal("case"), {desc = "Dial: increase case"})
    map("n", "s~", dmap.dec_normal("case"), {desc = "Dial: decrease case"})
    map("n", "+", dmap.inc_normal(), {desc = "Dial: increase"})
    map("n", "_", dmap.dec_normal(), {desc = "Dial: decrease"})
    map("v", "+", dmap.inc_visual(), {desc = "Dial: increase"})
    map("v", "_", dmap.dec_visual(), {desc = "Dial: decrease"})
    map("v", "g+", dmap.inc_gvisual(), {desc = "Dial: increase"})
    map("v", "g_", dmap.dec_gvisual(), {desc = "Dial: decrease"})
end

init()

return M
