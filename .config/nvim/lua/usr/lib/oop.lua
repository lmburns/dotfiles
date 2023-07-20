---@module 'usr.lib.oop'
---@description Object-oriented construction
---@class Usr.Lib.Oop
local M = {}

-- FINISH: this module
-- TODO: add multi-inheritance

-- Internal register
M._register = {
    class    = setmetatable({}, {__mode = "v"}),
    instance = setmetatable({}, {__mode = "v"}),
}

local function __tostring(cls)
    local t, name
    if M.is_instance(cls) then
        t = "instance"
        name = cls.class.__name
    elseif M.is_class(cls) then
        t = "class"
        name = cls.__name
    end
    return ("<%s: %s [@%s]>"):format(t, name, M._register[t][cls].__system.__addr)
end

function M.abstract_stub()
    error("unimplemented abstract method")
end

---@generic T
---@param t T
---@return T
function M.enum(t)
    vim.tbl_add_reverse_lookup(t)
    return t
end

local mt_funcs = {
    "__index",
    "__newindex",
    "__call",
    "__metatable",
    -- "__name",
    "__tostring",
    "__eq",
    "__concat",
    "__len",
    "__unm",
    "__add",
    "__sub",
    "__mul",
    "__div",
    "__idiv",
    "__mod",
    "__pow",
    "__lt",
    "__le",
    "__band",
    "__bnot",
    "__bor",
    "__shl",
    "__shr",
}

---Wrap metatable methods to ensure they're called with the instance as `self`
---@generic T : table
---@generic R : any, A1: any
---@param func fun(self: T, ...: A1): R?
---@param instance T
---@return fun(_: table, ...: A1): R?
local function wrap_mt_func(func, instance)
    return function(_, k)
        return func(instance, k)
    end
end

-- Simple helper for building a raw copy of a table
-- Only pointers to classes or objects stored as instances are preserved
local function deepcopy(item, cache)
    local item_t = type(item)
    cache = cache or {}

    if item_t == "table" then
        if cache[item] then
            return cache[item]
        end
        local copy = {}
        cache[item] = copy
        local mt = getmetatable(item)

        for k, v in pairs(item) do
            if (M._register.class[v] or M._register.instance[v]) then
                copy[k] = v
            else
                copy[deepcopy(k, cache)] = deepcopy(v, cache)
            end
        end
        return setmetatable(copy, mt)
    elseif item_t == "userdata" or item_t == "thread" then
        if item == vim.NIL then
            return vim.NIL
        end
        error(("unable to deepcopy object type: %s"):format(item_t))
    end

    return item
end

---Inherit from a class after the another class instance has already been created
---Note: this modifies by reference (i.e., in-place)
---@generic T : usr.Object
---@generic P : usr.Object
---@param cls T
---@param parent P
---@return T|P extended_class
local function inherit(cls, parent)
    -- cls.__index = cls
    cls.class.__super = parent

    for _, mt_func in ipairs(mt_funcs) do
        local super_mt_func = parent[mt_func]

        if type(super_mt_func) == "function" then
            cls[mt_func] = wrap_mt_func(super_mt_func, cls)
        elseif super_mt_func ~= nil then
            cls[mt_func] = super_mt_func
        end
    end

    return cls
end

---Create a new class instance
---@param cls table
---@param ... any
---@return usr.Object
local function new_instance(cls, ...)
    assert(not M._register.class[cls].__system.__abstract,
        "cannot create an instance from and abstract class")

    local copied = deepcopy(cls)
    local inst = {class = copied}
    local mt = {__index = copied}

    for _, mt_func in ipairs(mt_funcs) do
        local class_mt_func = copied[mt_func]

        if type(class_mt_func) == "function" then
            ---@diagnostic disable-next-line:assign-type-mismatch
            mt[mt_func] = wrap_mt_func(class_mt_func, inst)
        elseif class_mt_func ~= nil then
            mt[mt_func] = class_mt_func
        end
    end

    local self = setmetatable(inst, mt)
    if type(self.init) == "function" then
        self:init(...)
    end

    M._register.instance[self] = {
        __system = {
            __type = "instance",
            __base = cls,
            __addr = ("%p"):format(self),
        },
    }

    return self
end

---Assert that the function is called from the class object
---@param x usr.Object
local function assert_staticm(x)
    assert(x.class == nil, "static methods should not be invoked from an instance")
end

---Assert that the function is called from the class instance object
---@param x usr.Object
local function assert_instancem(x)
    assert(type(x.class) == "table", "instance methods must be called from a class instance")
end

---@generic T : usr.Object
---@generic U : usr.Object
---@param name string class name
---@param super? T class to inherit from
---@param inherit_meta? bool inherit both super and the meta M.Object class
---@return U|T new_class
function M.create_class(name, super, inherit_meta)
    vim.validate({
        class_name = {name, "s", false},
        super_class = {super, "t", true},
        inherit_meta = {inherit_meta, "b", true},
    })

    -- Unconditionally merge Object methods to super
    -- Even if there's a parent "class", it may not have a metatable
    -- e.g., the 'table' object doesn't have a metatable
    if super and inherit_meta then
        super = setmetatable(
            super,
            vim.tbl_deep_extend("keep", getmetatable(super) or {}, getmetatable(M.Object))
        )
    else
        super = super or M.Object
    end

    local class = {
        -- not being used as a metamethod here
        __name = name,
        __super = super,
        init = function(...) end,
        new = new_instance,
        inherit = inherit,
    }

    -- TODO: check this
    -- class.new = function(...)
    --     return new_instance(class, ...)
    -- end

    local built = setmetatable(class, {
        __index = super,
        __call = new_instance,
        __tostring = __tostring,
        -- __name = class.name,
    })

    M._register.class[built] = {
        __system = {
            __type = "class",
            __abstract = false,
            __final = false,
            __super = name ~= "Object" and true or false,
            __base = false,
            __subc = {},
            -- __subc = setmetatable({}, {__mode = "k"}),
            __addr = ("%p"):format(built),
        },
    }

    return built
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

---@class usr.Object
---@field protected __name string  the class name
---@field private __init_caller? table
---@field __super table|usr.Object the class that was inherited from
---@field class table|usr.Object
local Object = M.create_class("Object")
M.Object = Object

function Object:__tostring()
    return ("<instance: Object::%s [@%s]>"):format(self.class.__name, M._register.instance[self].__system.__addr)
end

-- ━━━ STATIC METHODS ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- These aren't actually static, as self is still required to call the function.
-- However, they are meant to be called on the class object only, no instances.

---Return the class' name
---@return string
function Object:name()
    assert_staticm(self)
    return self.__name
end

---Check if this class is an ancestor of the given instance.
---`A` is an ancestor of `b` if - and only if - `b` is an instance of a subclass of `A`.
---@param other any
---@return boolean
function Object:ancestorof(other)
    assert_staticm(self)
    if not M.is_instance(other) then return false end

    return other:instanceof(self)
end

function Object:superclass()
    assert_staticm(self)
    return self.__super
end

function Object:subclasses()
    assert_staticm(self)
    return M._register.class[self].__system.__subc or {}
end

function Object:extend(...)
    assert_staticm(self)
    assert(not M._register.class[self].__system.__final, "cannot derive from a final class")

    local new = Object:new(...)
    M._register.class[new].__system.__super = self
    M._register.class[self].__system.__subc[new] = true
    return setmetatable(new, self)
end

---Derive the inheritance path
---@return string name fully-qualified class name
function Object:classpath()
    assert_staticm(self)
    local ret = self.__name
    local cur = self.__super

    while cur do
        ret = cur.__name .. "." .. ret
        cur = cur.__super
    end

    return ret
end

-- ━━━ INSTANCE METHODS ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

---Call initializer
function Object:init(...) end

-- ---Call constructor
-- ---@return self
-- ---@diagnostic disable-next-line: missing-return
-- function Object.new(...) end

---Call constructor
---@return self
---@nodiscard
---@diagnostic disable-next-line: missing-return
function Object:new(...) end

---Call super initializer
---@param ... any
function Object:super(...)
    assert_instancem(self)
    local next_super

    -- Track the class currently calling the constructor to avoid loops
    if self.__init_caller then
        next_super = self.__init_caller.__super
    else
        next_super = self.__super
    end

    if not next_super then return end

    self.__init_caller = next_super
    next_super.init(self, ...)
    self.__init_caller = nil
end

---Check whether `other` is an instance of `Object` (i.e., the base class)
---@param other usr.Object
---@return boolean
function Object:instanceof(other)
    assert_instancem(self)
    local cur = self.class

    while cur do
        if cur == other then
            return true
        end
        cur = cur.__super
    end

    return false
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

---@param cls any
---@return boolean
function M.is_class(cls)
    if type(cls) ~= "table" then
        return false
    end
    return type(rawget(cls, "__name")) == "string"
        and cls.instanceof == Object.instanceof
end

---@param instance any
---@return boolean
function M.is_instance(instance)
    if type(instance) ~= "table" then
        return false
    end
    return M.is_class(instance.class)
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- No inheritance at all.
-- Creates a structure like this:
-- {
--   class = <1>{
--     __name = "Table",
--     __super = <2>{
--       __name = "Object",
--       __tostring = <function 1>,
--       ancestorof = <function 2>,
--       classpath = <function 3>,
--       inherit = <function 4>,
--       init = <function 5>,
--       instanceof = <function 6>,
--       name = <function 7>,
--       new = <function 8>,
--       super = <function 9>,
--       <metatable> = {
--         __call = <function 10>,
--         __tostring = <function 11>
--       }
--     },
--     inherit = <function 4>,
--     init = <function 12>,
--     new = <function 10>,
--     <metatable> = {
--       __call = <function 10>,
--       __index = <table 2>,
--       __tostring = <function 11>
--     }
--   },
--   <metatable> = {
--     __index = <table 1>,
--     __tostring = <function 13>
--   }
-- }
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Inheritance during initialization.
-- Creates a structure like this:
-- {
--   class = <1>{
--     __name = "Table",
--     __super = <2>{
--       concat = <function 1>,
--       foreach = <function 2>,
--       foreachi = <function 3>,
--       getn = <function 4>,
--       insert = <function 5>,
--       maxn = <function 6>,
--       move = <function 7>,
--       remove = <function 8>,
--       sort = <function 9>
--     },
--     inherit = <function 10>,
--     init = <function 11>,
--     new = <function 12>,
--     <metatable> = {
--       __call = <function 12>,
--       __index = <table 2>,
--       __tostring = <function 13>
--     }
--   },
--   <metatable> = {
--     __index = <table 1>
--   }
-- }
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Inherit after the fact.
-- Creates a structure like this:
-- {
--   class = <1>{
--     __name = "Table",
--     __super = {
--       concat = <function 1>,
--       foreach = <function 2>,
--       foreachi = <function 3>,
--       getn = <function 4>,
--       insert = <function 5>,
--       maxn = <function 6>,
--       move = <function 7>,
--       remove = <function 8>,
--       sort = <function 9>
--     },
--     inherit = <function 10>,
--     init = <function 11>,
--     new = <function 12>,
--     <metatable> = {
--       __call = <function 12>,
--       __index = {
--         __name = "Object",
--         __tostring = <function 13>,
--         ancestorof = <function 14>,
--         classpath = <function 15>,
--         inherit = <function 10>,
--         init = <function 16>,
--         instanceof = <function 17>,
--         name = <function 18>,
--         new = <function 19>,
--         super = <function 20>,
--         <metatable> = {
--           __call = <function 12>,
--           __tostring = <function 21>
--         }
--       },
--       __tostring = <function 21>
--     }
--   },
--   <metatable> = {
--     __index = <table 1>,
--     __tostring = <function 22>
--   }
-- }
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

return M
