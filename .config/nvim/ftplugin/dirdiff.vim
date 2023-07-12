if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

setl nolist nobuflisted

let b:undo_ftplugin = "setl list< buflisted<"
