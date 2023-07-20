---@module 'usr.shared.utils'
---@description Utility functions that are used in multiple files
---@class Usr.Utils
local M = {}

local lazy = require("usr.lazy")
M = lazy.require("usr.shared.utils.funcs") ---@module 'usr.shared.utils.funcs'
M.async = lazy.require_on.expcall("usr.shared.utils.async") ---@module 'usr.shared.utils.async'
M.mod = lazy.require_on.expcall("usr.shared.utils.mod") ---@module 'usr.shared.utils.mod'
M.git = lazy.require_on.expcall("usr.shared.utils.git") ---@module 'usr.shared.utils.git'
M.fs = lazy.require_on.call_rec("usr.shared.utils.fs") ---@module 'usr.shared.utils.fs'

---@type PathLib
M.pl = lazy.require("diffview.path", function(m)
    return m.PathLib({separator = "/"})
end)

return M

-- TIP: ======================================= [[[
-- :h lua-reference.txt
-- :h luaref

-- ━━ EmmyLua ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--   https://github.com/LuaLS/lua-language-server/wiki/Annotations

-- ━━ Metatable Events ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--   http://lua-users.org/wiki/MetatableEvents
-- __index(t, k)        = index access (t[k])
--    - @field __index table|(fun(t,k):any)|nil
--    - Ran when indexing something that's not a table
--    - Ran when key isn't present
--    - Type: fun(self, k) | table | obj with __index

-- __newindex(t, k, v)  = index assign (t[k] = v)
--    - @field __newindex table|fun(t,k,v)|nil
--    - Ran when indexing something that's not a table
--    - Ran when key isn't present
--    - Type: fun(self, k, v) | table | obj with __newindex

-- __metatable = str|table|nil = metatable representation
--    - @field __metatable any|nil
-- __name = str  = if no __tostring
-- __tostring(t) = string conversion (tostring())
--    - @field __tostring (fun(t):string)|nil

-- __close(val, err?) = when a variable is closed (5.4)
-- __gc()             = garbage collect when table dies
--    - @field __gc fun(t)|nil

-- __call(t, a)      = call as a func (func())
--    - @field __call (fun(t,...):...)|nil
-- __mode = k|v|kv   = table weakness
--    - @field __mode 'v'|'k'|'kv'|nil
--    - "v"  = weak values
--    - "kv" = weak keys and values
--    - "k"  = weak keys (ephemeron)
--      - Only reachable if key is reachable
--      - If only reference to a key is from its value, remove

-- __pairs(t)   = pairs iteration (pairs())
--    - @field __pairs (fun(t): (fun(t,k,v):any,any))|nil
-- __ipairs(t)  = ipairs iteration (ipairs())
--    - @field __ipairs (fun(t):(fun(t,k,v):(integer|nil),any))|nil

-- __concat(t, x) = concatenation (..)
--    - @field __concat (fun(t1,t2):any)|nil
-- __len(t)       = length        (#)
--    - @field __len (fun(t):integer)|nil

-- __add(t, c)  = addition       (+)
--    - @field __add (fun(t1,t2):any)|nil
-- __sub(t, c)  = subtraction    (-)
--    - @field __sub (fun(t1,t2):any)|nil
-- __mul(t, c)  = multiplication (*)
--    - @field __mul (fun(t1,t2):any)|nil
-- __div(t, c)  = division       (/)
--    - @field __div (fun(t1,t2):any)|nil
-- __idiv(t, c) = floor division (//)
--    - @field __idiv (fun(t1,t2):any)|nil
-- __mod(t, c)  = modulo         (%)
--    - @field __mod (fun(t1,t2):any)|nil
-- __pow(t, c)  = exponentiation (^)
--    - @field __pow (fun(t1,t2):any)|nil
-- __unm(t)     = negation       (unary -)
--    - @field __unm (fun(t):any)|nil

-- __band(t, c) = bitwise and          (&)
--    - @field __band (fun(t1,t2):any)|nil
-- __bor(t, c)  = bitwise or           (|)
--    - @field __bor (fun(t1,t2):any)|nil
-- __bxor(t, c) = bitwise exclusive or (~)
--    - @field __bxor (fun(t1,t2):any)|nil
-- __bnot(t)    = bitwise not          (unary ~)
--    - @field __bnot (fun(t):any)|nil
-- __shl(t, c)  = bitwise left-shift   (<<)
--    - @field __shl (fun(t1,t2):any)|nil
-- __shr(t, c)  = bitwise right-shift  (>>)
--    - @field __shr (fun(t1,t2):any)|nil

-- __eq(t, c) = equality           (==)
--    - @field __eq (fun(t1,t2):boolean)|nil
-- __lt(t, c) = less than          (<)
--    - @field __lt (fun(t1,t2):boolean)|nil
-- __le(t, c) = less than or equal (<=)
--    - @field __le (fun(t1,t2):boolean)|nil

-- Iterator Alt
-- for k, v in next, {tbl...} do end

-- String Recipes
-- ━━ String Recipes ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- ━━ String Recipes   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--   http://lua-users.org/wiki/StringRecipes

-- Patterns
--   :h luaref-patterns
--   http://lua-users.org/wiki/PatternsTutorial
--   http://lua-users.org/wiki/FrontierPattern
--   https://www.lua.org/pil/20.2.html
--   https://riptutorial.com/lua/example/20315/lua-pattern-matching
--   https://fhug.org.uk/kb/kb-article/understanding-lua-patterns/
--
--   %b:
--     p(("capture {what is inside} these brackets"):match("%b{}"))
--     --> {what is inside}
--
--   %f:
--     - Detects transition from "not set in" to "in set"
--     - %f[%a]: Find transition from non-letter to letter
--     - %u+:    Find multiple uppercase letters after the transition from non-letter to letter
--     - %f[%A]: Find transition from letter to non-letter
--     - Can't match a transition to a letter when a non-letter follows it

--     - %f[%S]Word%f[%s]
--
--     p(("THE (QUICK) brOWN FOx JUMPS"):match("%f[%a]%u+%f[%A]"))
--     --> THE
--         QUICK
--         JUMPS
--
--   Special characters: ( ) . % + - * ? [ ^ $
--
--    .  | all chars
--    %d | digits                      |                 | %D
--    %x | hexadecimal digits          |                 | %X
--    %s | space chars                 |                 | %S
--    %g | printable chars (not space) |                 | %G
--    %a | letters                     | [A-Za-Z]        | %A
--    %l | lower case letters          | [a-z]           | %L
--    %u | upper case letters          | [A-Z]           | %U
--    %w | alphanumeric chars          | [A-Za-z0-9]     | %W
--    %p | punctuation chars           | [.,?!:;@[]_{}~] | %P
--    %c | control chars               | [\0\r\n\f]      | %C
--    %z | the null char               |                 | %Z
--
-- LPEG:
--    https://www.inf.puc-rio.br/~roberto/lpeg/
--    https://www.inf.puc-rio.br/~roberto/lpeg/re.html
--
-- Replace Nth occurence:        s/\v(.{-}\zsPATT.){N}/REPL/
-- Replace every Nth occurrence: s/\v(\zsPATT.{-}){N}/REPL/g
-- Sort on a given column:       :sort f /\v^(.{-},){2}/
-- ]]] === Tips ===
