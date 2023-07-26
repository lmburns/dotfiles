---@meta
---@description Types that extend LuaLS

---@class Array<T>  : { [integer]: T }
---@class Vector<T> : { [integer]: T }
---@class Vec<T>    : { [integer]: T }
---@class Dict<T>   : {  [string]: T }
---@class Hash<T>   : {  [string]: T }

---@class ThunkFn<T1, T2, R>   : function(init: T1, ...: T2): R
---@class IThunkFn<T, R>       : function(...: T): R
---@class BindFn<C, T1, T2, R> : function(ctx: C, init: T1, ...: T2): R
---@class IBindFn<C, T, R>     : function(ctx: C, ...: T): R
---@class PartialFn<T1, T2, R> : function(self, init: T1, ...: T2): R
---@class IPartialFn<T, R>     : function(self, ...: T): R
---@class WrapFn1<T, R>        : function(...: T): R
---@class WrapFn2<T, R1, R2>   : function(WrapF1<T, R1>): R2
---@class FlipFn<T, R>         : function(...: T): R

---Table that has a __call field
---@class CallableTable: table
---@operator call():any

---Type representing flags within a table
---Usage:
---  `Flags<'flg1', 'flg2'>`
---@class Flags<F1, F2, F3, F4, F5> : {[F1]: bool, [F2]: bool, [F3]: bool, [F4]: bool, [F5]: bool}

---A unionized vector.
---Alternative syntax for:
---   - `(T | V)[]`
---   - `{[integer]: T | V}`
---@class UnionVec<T, V> : {[integer]: T | V}

---A unionized dictionary
---@class UnionHash<T, V> : {[string]: T | V}

-- TODO: finish these
-- ---@class Union<T, V> : (T | V)
-- ---@class UnionVec<T, V> : ((T | V)[])
-- ---@class Flags<F>  : {[`F`]: bool}
-- ---@class StrOr<T1, T2>  : `T1`
-- ---@class tbl<K, V>: { [K]: V }
-- ---@class Nullable<T> : (T|nil)

--FIX: doesn't work

---Many or one
---Object that can be one of:
---  - a single instance of something (i.e., a `string`)
---  - an array of something (i.e., `string[]`)
---@class Mor1<T> : {[integer]: T} | T

---Many or 1
---@alias Mor1S string|string[]
---@alias Mor1I integer|integer[]
---@alias Mor1N number|number[]

---@alias module  table
---@alias blob    number
---@alias channel integer
---@alias job     integer
---@alias object  any
---@alias sends   number

---@alias str  string  Alias for a string
---@alias bool boolean Alias for a boolean

-- NOTE: These aren't possible to excplicity type in Lua; however,
--       they show intent. Which is the purpose of documenting code in Lua in the
--       first place

---@alias time_t    u32  Number representing a timestamp
---@alias off_t     u32  Number representing a file size
---@alias size_t    u32  Number representing a sized-value (count of bytes)
---@alias index_t   u32  Number representing an index into another object
---@alias uuid_t    u64  Unique identifier

---@alias path_t    string  String representing a file path
---@alias fpath_t   string  String representing a file path

---@alias char   string|integer  A signed or unsigned 8-bit value
---@alias schar  string|integer  A signed 8-bit value
---@alias uchar  string|integer  An unsigned 8-bit value
---@alias short  integer         Represents the C-type `short` (i.e., shorter than `int`)
---@alias ushort integer         Represents the C-type `unsigned short`
---@alias int    integer         Represents the C-type `int` (i.e., longer than `short`, shorter than `long`)
---@alias uint   integer         Represents the C-type `unsigned int`
---@alias long   integer         Represents the C-type `long` (`signed long`)
---@alias ulong  integer         Represents the C-type `unsigned long`
---@alias llong  integer         Represents the C-type `long long`. Guaranteed to be 64-bits
---@alias ullong integer         Represents the C-type `unsigned long long`

---@alias float   number Represents a 32-bit floating point number
---@alias double  number Represents a 64-bit floating point number

---@alias i8   schar  Represents a signed 8-bit integer
---@alias u8   uchar  Represents an unsigned 8-bit integer
---@alias i16  short  Represents a signed 16-bit integer
---@alias u16  ushort Represents an unsigned 8-bit integer
---@alias i32  int    Represents a signed 32-bit integer
---@alias u32  uint   Represents an unsigned 32-bit integer
---@alias i64  llong  Represents a signed 64-bit integer
---@alias u64  ullong Represents an unsigned 64-bit integer

---@alias f32  float  Represents a signed 32-bit floating point number
---@alias f64  double Represents a signed 64-bit floating point number

---@alias int8_t    i8  Represents a signed 8-bit integer
---@alias uint8_t   u8  Represents an unsigned 8-bit integer
---@alias int16_t   i16 Represents a signed 16-bit integer
---@alias uint16_t  u16 Represents an unsigned 8-bit integer
---@alias int32_t   i32 Represents a signed 32-bit integer
---@alias uint32_t  u32 Represents an unsigned 32-bit integer
---@alias int64_t   i64 Represents a signed 64-bit integer
---@alias uint64_t  u64 Represents an unsigned 64-bit integer

---@alias float32   f32 Represents a 32-bit floating point number
---@alias float64   f64 Represents a 64-bit floating point number
---@alias float32_t f32 Represents a 32-bit floating point number
---@alias float64_t f64 Represents a 64-bit floating point number
