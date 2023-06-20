---@module 'usr.lib'
local lazy = require("usr.lazy")

---@class Usr.Lib
return {
    builtin = lazy.require("usr.lib.builtin"), ---@module 'usr.lib.builtin'
    debounce = lazy.require_on.call_rec("usr.lib.debounce"), ---@module 'usr.lib.debounce'
    disposable = lazy.require_on.call_rec("usr.lib.disposable"), ---@module 'usr.lib.disposable'
    event = lazy.require("usr.lib.event"), ---@module 'usr.lib.event'
    fn = lazy.require("usr.lib.fn"), ---@module 'usr.lib.fn'
    ftplugin = lazy.require("usr.lib.ftplugin"), ---@module 'usr.lib.ftplugin'
    log = lazy.require("usr.lib.log"), ---@module 'usr.lib.log'
    mutex = lazy.require("usr.lib.mutex"), ---@module 'usr.lib.mutex'
    op = lazy.require("usr.lib.op"), ---@module 'usr.lib.op'
    qf = lazy.require("usr.lib.qf"), ---@module 'usr.lib.qf'
    result = lazy.require("usr.lib.result"), ---@module 'usr.lib.result'
    semaphore = lazy.require("usr.lib.semaphore"), ---@module 'usr.lib.semaphore'
    shadowwin = lazy.require("usr.lib.shadowwin"), ---@module 'usr.lib.shadowwin'
    textobj = lazy.require("usr.lib.textobj"), ---@module 'usr.lib.textobj'
    throttle = lazy.require("usr.lib.throttle"), ---@module 'usr.lib.throttle'
    yank = lazy.require("usr.lib.yank"), ---@module 'usr.lib.yank'

    glob = lazy.require("usr.lib.glob"), ---@module 'usr.lib.glob'
}
