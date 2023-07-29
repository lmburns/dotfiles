local lazy = require("usr.lazy") ---@module 'usr.lazy'

---@class Usr.Lib
return {
    oop = lazy.require("usr.lib.oop"), ---@module 'usr.lib.oop'
    event = lazy.require("usr.lib.event"), ---@module 'usr.lib.event'
    mutex = lazy.require("usr.lib.mutex"), ---@module 'usr.lib.mutex'
    semaphore = lazy.require("usr.lib.semaphore"), ---@module 'usr.lib.semaphore'
    disposable = lazy.require_on.call_rec("usr.lib.disposable"), ---@module 'usr.lib.disposable'
    debounce = lazy.require_on.call_rec("usr.lib.debounce"), ---@module 'usr.lib.debounce'
    throttle = lazy.require("usr.lib.throttle"), ---@module 'usr.lib.throttle'
    result = lazy.require("usr.lib.result"), ---@module 'usr.lib.result'

    shadowwin = lazy.require("usr.lib.shadowwin"), ---@module 'usr.lib.shadowwin'
    render = lazy.require("usr.lib.render"), ---@module 'usr.lib.render'

    builtin = lazy.require("usr.lib.builtin"), ---@module 'usr.lib.builtin'
    fn = lazy.require("usr.lib.fn"), ---@module 'usr.lib.fn'
    op = lazy.require("usr.lib.op"), ---@module 'usr.lib.op'

    qf = lazy.require("usr.lib.qf"), ---@module 'usr.lib.qf'
    ftplugin = lazy.require("usr.lib.ftplugin"), ---@module 'usr.lib.ftplugin'
    textobj = lazy.require("usr.lib.textobj"), ---@module 'usr.lib.textobj'
    yank = lazy.require("usr.lib.yank"), ---@module 'usr.lib.yank'

    log = lazy.require("usr.lib.log"), ---@module 'usr.lib.log'

    -- glob = lazy.require("usr.lib.glob"), ---@module 'usr.lib.glob'
}
