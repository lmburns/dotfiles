local lazy = require("usr.lazy")
local collection = lazy.require("usr.shared.collection") ---@module 'usr.shared.collection'

return {
    utils = lazy.require("usr.shared.utils"), ---@module 'usr.shared.utils'
    collection = collection,
    vec = collection.vec,
    tbl = collection.tbl,
    color = lazy.require("usr.shared.color"), ---@module 'usr.shared.color'
    dev = lazy.require("usr.shared.dev"), ---@module 'usr.shared.dev'
    F = lazy.require("usr.shared.functional"), ---@module 'usr.shared.functional'
}
