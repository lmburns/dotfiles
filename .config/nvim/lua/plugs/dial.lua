---@module 'plugs.dial'
local M = {}

local F = Rc.F
local augend = F.npcall(require, "dial.augend")
if not augend then
    return
end

local dmap = require("dial.map")
local dconf = require("dial.config")

local augroup = Rc.api.augroup
local map = Rc.api.map

M.filetypes = {}

---Define an augend constant
---@param elements table
---@param word? boolean
---@param cyclic? boolean
---@return table
local function aug(elements, word, cyclic)
    return augend.constant.new({
        -- { "and", "or" }
        elements = elements,
        -- if false, "sand" is incremented into "sor", "doctor" into "doctand", etc.
        word = F.unwrap_or(word, true),
        -- "or" is incremented into "and"
        cyclic = F.unwrap_or(cyclic, true),
    })
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
        augend.date.new({pattern = "%m-%d-%Y", default_kind = "day"}),
        augend.date.new({pattern = "%m-%d-%y", default_kind = "day"}),
        augend.date.new({pattern = "%-H:%M:%S", default_kind = "min"}),
        augend.date.new({pattern = "%-H:%M", default_kind = "min"}),
        augend.case.new({
            types = {"camelCase", "snake_case", "PascalCase", "SCREAMING_SNAKE_CASE"},
            cyclic = true,
            word = true,
        }),
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
        aug({"inc", "dec"}),
        aug({"forward", "backward"}),
        aug({"first", "last"}),
        aug({"and", "&"}, false),
        aug({"and", "or"}),
        aug({"True", "False"}),
        aug({"enable", "disable"}),
        aug({"incoming", "outgoing"}),
        aug({"on", "off"}),
        aug({"in", "out"}),
        aug({"new", "old"}),
        aug({"dark", "light"}),
        aug({"less", "more"}),
        aug({"largest", "smallest"}),
        aug({"large", "small"}),
        aug({"longest", "shortest"}),
        aug({"long", "short"}),
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
        aug({"foreground", "background"}),
        aug({"fg", "bg"}),
        aug({"positive", "negative"}),
        aug({"pos", "neg"}),
        aug({"previous", "prev", "next"}),
        aug({"Previous", "Prev", "Next"}),
        aug({"beginning", "middle", "end"}),
        aug({"start", "finish"}),
        aug({"capitalize", "uppercase", "lowercase"}),
        aug({"upper", "lower"}),
        aug({"trace", "debug", "info", "warn", "error", "fatal"}),
        aug({"stdin", "stdout", "stderr"}),
        -- aug({
        --     "January", "February", "March", "April", "May", "June",
        --     "July", "August", "September", "October", "November", "December",
        -- }),
        aug({
            "Sunday", "Monday", "Tuesday", "Wednesday",
            "Thursday", "Friday", "Saturday",
        }),
        aug({
            "Sun.", "Mon.", "Tue.", "Wed.",
            "Thu.", "Fri.", "Sat.",
        }, false),
        aug({
            "zero",
            "one", "two", "three", "four", "five",
            "six", "seven", "eight", "nine", "ten",
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
        aug({"i8", "i16", "i32", "i64"}),
        aug({"u8", "u16", "u32", "u64"}),
        aug({"f32", "f64"}),
    }, default)

    local sh = extend("sh", aug({"elif", "if"}), default)
    local zsh = extend("zsh", {
        aug({"elif", "if"}),
        aug({"local", "typeset", "integer", "float", "readonly", "private"}),
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

    local python = extend("python", aug({"elif", "if"}), default)
    local vim_ = extend("vim", default, {aug({"elseif", "if"})})

    local typescript = extend("typescript", {
        aug({"let", "const", "var"}),
        aug({"of", "in"}),
        aug({"===", "!=="}),
        aug({"public", "private", "protected"}),
    }, default)
    -- local javascript = extend("javascript", typescript, {aug({"public", "private", "protected"})})

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
            return {text = text, cursor = cursor}
        end,
    })
    local zig = extend("zig", {octal}, default)
    local rust = extend("rust", {
        octal,
        augend.paren.alias.rust_str_literal,      -- " r# r## r###
        aug({"type", "trait", "struct", "enum"}), -- union
        aug({"isize", "i8", "i16", "i32", "i64", "i128"}),
        aug({"usize", "u8", "u16", "u32", "u64", "u128"}),
        aug({"f32", "f64"}),
    }, default)

    -- 1234; 1234L; 1234LL;
    -- 1234U; 1234UL; 1234ULL;
    -- 1234F; 1234; 1234L;
    local clang = extend("c", {
        aug({"typedef", "struct", "enum", "union"}),
        aug({"malloc", "calloc", "realloc"}),
        aug({"sizeof", "offsetof", "typeof"}),
        aug({"printf", "fprintf", "sprintf", "asprintf", "dprintf"}),
        aug({"vprintf", "vfprintf", "vsprintf", "vasprintf", "vdprintf"}),
        aug({"snprintf", "vsnprintf"}),
        aug({"scanf", "fscanf", "sscanf"}),
        aug({"vscanf", "vfscanf", "vsscanf"}),
        aug({"getc", "fgetc", "getchar"}),
        aug({"putc", "fputc", "putchar"}),
        aug({"getw", "putw"}),
        aug({"puts", "fputs"}),
        aug({"fread", "fwrite"}),
        aug({"fseek", "ftell", "rewind", "ftello", "fseeko"}),
        aug({"flockfile", "ftrylockfile", "funlockfile"}),
        aug({"clearerr", "feof", "ferror"}),
        aug({"perror", "err", "warn", "verr", "vwarn"}),
        aug({"errx", "warnx"}),
        --
        aug({"i8", "i16", "i32", "i64"}),
        aug({"u8", "u16", "u32", "u64"}),
        aug({"f32", "f64", "f128"}),
        --
        aug({"int8", "int16", "int32", "int64"}),
        aug({"uint8", "uint16", "uint32", "uint64"}),
        aug({"float32", "float64"}),
        --
        aug({"int8_t", "int16_t", "int32_t", "int64_t"}),
        aug({"uint8_t", "uint16_t", "uint32_t", "uint64_t"}),
        aug({"u_int8_t", "u_int16_t", "u_int32_t", "u_int64_t"}),
        aug({"float32_t", "float64_t"}),
        --
        aug({"intmax_t", "uintmax_t"}),
        aug({"intptr_t", "uintptr_t", "nullptr_t", "ptrdiff_t"}),
        --
        aug({"quad_t", "u_quad_t"}),
        aug({"s_char", "u_char"}),
        aug({"char", "schar", "uchar"}),
        aug({"short", "int", "long", "llong"}),
        aug({"sshort", "sint", "slong", "sllong"}),
        aug({"ushort", "uint", "ulong", "ullong"}),
        aug({"s_short", "s_int", "s_long", "s_llong"}),
        aug({"u_short", "u_int", "u_long", "u_llong"}),
        aug({"float", "double", "ldouble"}),
        --
        aug({"gid_t", "uid_t"}),
        aug({"ino_t", "ino64_t"}),
        aug({"off_t", "fpos_t"}),
        aug({"size_t", "ssize_t"}),
        aug({"wchar_t", "rsize_t"}),
        aug({"fsid_t", "pid_t", "id_t"}),
        aug({"loff_t", "dev_t", "mode_t", "nlink_t"}),
        aug({"useconds_t", "suseconds_t", "suseconds64_t"}),
        aug({"time_t", "timer_t"}),
        aug({"clock_t", "clockid_t"}),
        aug({"rlim_t", "rlim64_t"}),
        aug({"register_t", "socklen_t", "sigset_t"}),
        aug({"daddr_t", "caddr_t", "key_t"}),
        aug({"fsblkcnt_t", "fsfilcnt_t", "blkcnt_t"}),
        aug({"fsblkcnt64_t", "fsfilcnt64_t", "blkcnt64_t"}),
        aug({"pthread_t", "pthread_attr_t", "pthread_cond_t", "pthread_key_t"}),
        aug({"pthread_once_t", "pthread_mutex_t", "pthread_rwlock_t", "pthread_spinlock_t"}),
        -- aug({"fsword_t"}),
        --
        aug({"signed_char", "unsigned_char"}),
        aug({"signed_short", "unsigned_short", "signed_short_int", "unsigned_short_int"}),
        aug({"signed_int", "unsigned_int", "signed", "unsigned"}),
        aug({"signed_long", "unsigned_long", "signed_long_int", "unsigned_long_int"}),
        aug({"signed_long_long", "unsigned_long_long",
            "signed_long_long_int", "unsigned_long_long_int",}),
        --
        aug({"int_least8_t", "int_least16_t", "int_least32_t", "int_least64_t"}),
        aug({"uint_least8_t", "uint_least16_t", "uint_least32_t", "uint_least64_t"}),
        aug({"int_fast8_t", "int_fast16_t", "int_fast32_t", "int_fast64_t"}),
        aug({"uint_fast8_t", "uint_fast16_t", "uint_fast32_t", "uint_fast64_t"}),
        --
        aug({"INT8_MIN", "INT16_MIN", "INT32_MIN", "INT64_MIN"}),
        aug({"INT8_MAX", "INT16_MAX", "INT32_MAX", "INT64_MAX"}),
        aug({"UINT8_MIN", "UINT16_MIN", "UINT32_MIN", "UINT64_MIN"}),
        aug({"UINT8_MAX", "UINT16_MAX", "UINT32_MAX", "UINT64_MAX"}),
        aug({"INT_LEAST8_MIN", "INT_LEAST16_MIN", "INT_LEAST32_MIN", "INT_LEAST64_MIN"}),
        aug({"INT_LEAST8_MAX", "INT_LEAST16_MAX", "INT_LEAST32_MAX", "INT_LEAST64_MAX"}),
        aug({"UINT_LEAST8_MAX", "UINT_LEAST16_MAX", "UINT_LEAST32_MAX", "UINT_LEAST64_MAX"}),
        aug({"INT_FAST8_MIN", "INT_FAST16_MIN", "INT_FAST32_MIN", "INT_FAST64_MIN"}),
        aug({"INT_FAST8_MAX", "INT_FAST16_MAX", "INT_FAST32_MAX", "INT_FAST64_MAX"}),
        aug({"UINT_FAST8_MAX", "UINT_FAST16_MAX", "UINT_FAST32_MAX", "UINT_FAST64_MAX"}),
        aug({"INTPTR_MIN", "INTPTR_MAX", "UINTPTR_MAX"}),
        aug({"INTMAX_MIN", "INTMAX_MAX", "UINTMAX_MAX"}),
        --
        aug({"INT8_C", "INT16_C", "INT32_C", "INT64_C"}),
        aug({"UINT8_C", "UINT16_C", "UINT32_C", "UINT64_C"}),
        aug({"INTMAX_C", "UINTMAX_C"}),
        --
        aug({"INT8_WIDTH", "INT16_WIDTH", "INT32_WIDTH", "INT64_WIDTH"}),
        aug({"UINT8_WIDTH", "UINT16_WIDTH", "UINT32_WIDTH", "UINT64_WIDTH"}),
        aug({"INT_LEAST8_WIDTH", "INT_LEAST16_WIDTH", "INT_LEAST32_WIDTH", "INT_LEAST64_WIDTH"}),
        aug({"UINT_LEAST8_WIDTH", "UINT_LEAST16_WIDTH", "UINT_LEAST32_WIDTH", "UINT_LEAST64_WIDTH"}),
        aug({"INT_FAST8_WIDTH", "INT_FAST16_WIDTH", "INT_FAST32_WIDTH", "INT_FAST64_WIDTH"}),
        aug({"UINT_FAST8_WIDTH", "UINT_FAST16_WIDTH", "UINT_FAST32_WIDTH", "UINT_FAST64_WIDTH"}),
        --
        aug({"PTRDIFF_MIN", "PTRDIFF_MAX"}),
        aug({"WCHAR_MIN", "WCHAR_MAX"}),
        aug({"WINT_MIN", "WINT_MAX"}),
        --
        aug({"FLT_DECIMAL_DIG", "DBL_DECIMAL_DIG", "LDBL_DECIMAL_DIG", "DECIMAL_DIG"}),
        --
        aug({"F_RDLCK", "F_WRLCK", "F_UNLCK"}),
        aug({"O_RDONLY", "O_WRONLY", "O_RDWR"}),
        aug({"O_CREAT", "O_EXCL", "O_NOCTTY"}),
        aug({"O_TRUNC", "O_APPEND"}),
        aug({"O_DIRECTORY", "O_NOFOLLOW", "O_CLOEXEC", "O_RSYNC"}),
        aug({"O_NOATIME", "O_TMPFILE", "O_PATH", "O_DIRECT"}),
        aug({"F_DUPFD", "F_GETFD", "F_SETFD", "F_GETFL", "F_SETFL"}),
        aug({"F_GETSIG", "F_SETSIG"}),
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
        quote = {
            augend.paren.alias.quote, -- " -> ' | ' -> "
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
        clang = clang,
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
        bash = sh,
        zsh = zsh,
        vim = vim_,
        go = go,
        markdown = markdown,
        c = clang,
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
    map("n", "s'", dmap.inc_normal("quote"), {desc = "Dial: increase quote"})
    map("n", 's"', dmap.dec_normal("quote"), {desc = "Dial: decrease quote"})
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
