" Vim global plugin for LogEvents
" Last change:  LogEvents
" Maintainer:	Damian Conway|Lucas Burns
" License:	This file is placed in the public domain.

" If already loaded, we're done...
if exists("loaded_LogEvents")
    finish
endif
let loaded_LogEvents = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim

" Is this thing on???
let s:show_events  = 0
let s:start_time   = reltime()
let s:first_report = 1

func! s:ReportEvent(eventtype, match, ...)
    if s:first_report && expand('%:t') != 'events.log'
        redir! > /tmp/nvim-events.log
        let s:first_report = 0
    endif
    redir! >> /tmp/nvim-events.log
    echomsg  '[' . substitute(reltimestr(reltime(s:start_time)),'^\s*','','') . ']'
        \ . ' [' . a:eventtype . ']'
        \ . ' [' . a:match . ']'
        \ . ' [' . join(a:000, "] [") . ']'
    redir END
endf

func! s:expand(kind, ...) abort
    return a:kind . ':' . (a:0 ? expand('<'.a:kind.'>:t') : expand('<'.a:kind.'>'))
endf

func! s:v(var) abort
    return a:var . ':' . string(eval('v:'.a:var))
endf

func! logevents#toggle()
    let s:show_events = !s:show_events
    echo "[Event reporting:" s:show_events ? "on]" : "off]"
    augroup LogEvents
        au!
        if s:show_events
            " just after creating/adding/renaming buffer which is added to buflist. before `BufEnter`
            au BufAdd                 *   silent call <SID>ReportEvent("BufAdd",s:expand("amatch"),s:expand("abuf"))
            " before deleting buffer from buflist
            au BufDelete              *   silent call <SID>ReportEvent("BufDelete",s:expand("amatch"),s:expand("abuf"))
            " after entering buffer. after `BufAdd` and `BufReadPost`
            au BufEnter               *   silent call <SID>ReportEvent("BufEnter",s:expand("amatch", 1),s:expand("abuf"))
            " after changing name of curbuf with `:file` or `:saveas`
            au BufFilePost            *   silent call <SID>ReportEvent("BufFilePost",s:expand("amatch"),s:expand("abuf"))
            " before changing name of curbuf with `:file` or `:saveas`
            au BufFilePre             *   silent call <SID>ReportEvent("BufFilePre",s:expand("amatch"),s:expand("abuf"))
            " just before buffer becomes hidden: no longer wins that show buffer, but buffer is not unloaded or deleted
            au BufHidden              *   silent call <SID>ReportEvent("BufHidden",s:expand("amatch"),s:expand("abuf"))
            " before leaving to another buffer; when leaving/closing curwin and new curwin is not for same buf
            au BufLeave               *   silent call <SID>ReportEvent("BufLeave",s:expand("amatch"),s:expand("abuf"))
            " after `modified` value of buf has been changed
            au BufModifiedSet         *   silent call <SID>ReportEvent("BufModifiedSet",s:expand("amatch"),s:expand("abuf"))
            " just after creating new buffer / renaming buffer
            au BufNew                 *   silent call <SID>ReportEvent("BufNew",s:expand("amatch"),s:expand("abuf"))
            " starting to edit a file that doesn't exist
            au BufNewFile             *   silent call <SID>ReportEvent("BufNewFile",s:expand("amatch"),s:expand("abuf"))
            " starting to edit new buffer, after reading file, before processing modelines
            au BufRead                *   silent call <SID>ReportEvent("BufRead[Post]",s:expand("amatch"))
            " starting to edit new buffer, after reading file, before processing modelines
            au BufReadPost            *   silent call <SID>ReportEvent("BufReadPost",s:expand("amatch"))
            " starting to edit new buffer, before reading file. not used if file doesn't exist
            au BufReadPre             *   silent call <SID>ReportEvent("BufReadPre",s:expand("amatch"))
            " before unloading buffer, when text in buffer is going to be freed. after `BufWritePost`; before `BufDelete`
            au BufUnload              *   silent call <SID>ReportEvent("BufUnload",s:expand("amatch"))
            " after buffer is displayed in window
            au BufWinEnter            *   silent call <SID>ReportEvent("BufWinEnter",s:expand("amatch"))
            " before buffer is removed from window, not when still visible in another window
            au BufWinLeave            *   silent call <SID>ReportEvent("BufWinLeave",s:expand("amatch"))
            " before completely deleting buffer from buflist
            au BufWipeout             *   silent call <SID>ReportEvent("BufWipeout",s:expand("amatch"))
            " starting to write the whole buffer to a file
            au BufWrite               *   silent call <SID>ReportEvent("BufWrite[Pre]",s:expand("amatch"))
            " after writing whole buffer to file (should undo commands for `BufWritePre`)
            au BufWritePost           *   silent call <SID>ReportEvent("BufWritePost",s:expand("amatch"))
            " before starting to write whole buffer to file
            au BufWritePre            *   silent call <SID>ReportEvent("BufWritePre",s:expand("amatch"))
            " state of channel changed (`{v.event}`: info)
            au ChanInfo               *   silent call <SID>ReportEvent("ChanInfo",s:expand("amatch"),s:v('event.info'))
            " just after channel was opened (`{v.event}`: info)
            au ChanOpen               *   silent call <SID>ReportEvent("ChanOpen",s:expand("amatch"),s:v('event.info'))
            " [*] user command is used but it isn't defined (*P*: command name)
            au CmdUndefined           *   silent call <SID>ReportEvent("CmdUndefined",s:expand("amatch"))
            " [*] after change made to text inside command line
            au CmdlineChanged         *   silent call <SID>ReportEvent("CmdlineChanged",s:expand("amatch"))
            " [*] after entering cli (include ":" in map: use `<Cmd>` instead) (`v.event`: cmdlevel, cmdtype)
            au CmdlineEnter           *   silent call <SID>ReportEvent("CmdlineEnter",s:expand("amatch"),s:v('event.cmdlevel'),s:v('event.cmdtype'))
            " [*] before leaving cli (include ":" in map: use `<Cmd>` instead) (`v.event`: abort, cmdlevel, cmdtype)
            au CmdlineLeave           *   silent call <SID>ReportEvent("CmdlineLeave",s:expand("amatch"),s:v('event.cmdlevel'),s:v('event.cmdtype'),s:v('event.abort'))
            " after entering cli-win (`<afile>`: type of)
            au CmdwinEnter            *   silent call <SID>ReportEvent("CmdwinEnter",s:expand("amatch"),s:expand("afile"))
            " before leaving cli-win (`<afile>`: type of)
            au CmdwinLeave            *   silent call <SID>ReportEvent("CmdwinLeave",s:expand("amatch"),s:expand("afile"))
            " after loading colorscheme (*P*: colorscheme name)
            au ColorScheme            *   silent call <SID>ReportEvent("ColorScheme",s:expand("amatch"))
            " [*] before loading colorscheme
            au ColorSchemePre         *   silent call <SID>ReportEvent("ColorSchemePre",s:expand("amatch"))
            " [*] after each time I mode compl menu changed (`{v:event}`: completed_item, height, width, row, col, size, scrollbar?)
            au CompleteChanged        *   silent call <SID>ReportEvent("CompleteChanged",s:expand("amatch"),s:v('event.completed_item'))
            " [*] after I-mode compl is done. after clearing info (`v:completed_item`)
            au CompleteDone           *   silent call <SID>ReportEvent("CompleteDone",s:expand("amatch"),s:v('event.completed_item'))
            " [*] after I-mode compl is done. before clearing info (`v:completed_item`)
            au CompleteDonePre        *   silent call <SID>ReportEvent("CompleteDonePre",s:expand("amatch"),s:v('event.completed_item'))
            " user doesn't press key for time of `updatetime` (*M*: NV)
            au CursorHold             *   silent call <SID>ReportEvent("CursorHold",s:expand("amatch"))
            " `CursorHold`, but in Insert mode (*M*: I)
            au CursorHoldI            *   silent call <SID>ReportEvent("CursorHoldI",s:expand("amatch"))
            " after cursor moved in Normal/Visual mode or to another win. also text of cursor line changes (e.g. "x", "rx", "p") (*M*: NV)
            au CursorMoved            *   silent call <SID>ReportEvent("CursorMoved",s:expand("amatch"))
            " after cursor was moved in Insert mode; not when PUM is visible (*M*: I)
            au CursorMovedI           *   silent call <SID>ReportEvent("CursorMovedI",s:expand("amatch"))
            " [*] after diffs have been updated.
            au DiffUpdated            *   silent call <SID>ReportEvent("DiffUpdated",s:expand("amatch"))
            " [*] after cwd changed (*P*: "window:`:lcd`, "tabpage":`:tcd`, "global":`:cd`, "auto":'autochdir') (`v.event`: cwd, scope, changed_window)
            au DirChanged             *   silent call <SID>ReportEvent("DirChanged",s:expand("amatch"),s:v('event.directory'),s:v('event.scope'),s:v('event.changed_window'))
            " [*] when cwd is going to be changed, as with `DirChanged` (`v.event`: directory, scope, changed_window)
            au DirChangedPre          *   silent call <SID>ReportEvent("DirChangedPre",s:expand("amatch"),s:v('event.directory'),s:v('event.scope'),s:v('event.changed_window'))
            " [*] using `:quit`, `:wq` in way it makes Vim exit, or using `:qall`, just after `QuitPre`
            au ExitPre                *   silent call <SID>ReportEvent("ExitPre",s:expand("amatch"))
            " before appending to file. should do the appending to file.  use `'[` and `']` marks for range of lines
            au FileAppendCmd          *   silent call <SID>ReportEvent("FileAppendCmd",s:expand("amatch"))
            " after appending to file
            au FileAppendPost         *   silent call <SID>ReportEvent("FileAppendPost",s:expand("amatch"))
            " before making first change to read-only file
            au FileChangedRO          *   silent call <SID>ReportEvent("FileChangedRO",s:expand("amatch"))
            " Vim notices that modification time of file has changed since editing started
            au FileChangedShell       *   silent call <SID>ReportEvent("FileChangedShell",s:expand("amatch"))
            " after handling file that was changed outside of Vim.  can be used to update statusline
            au FileChangedShellPost   *   silent call <SID>ReportEvent("FileChangedShellPost",s:expand("amatch"))
            " after reading file with `:read`; sets `'[` and `']` to first/last line read. can be used to operate on lines just read
            au FileReadPost           *   silent call <SID>ReportEvent("FileReadPost",s:expand("amatch"))
            " before reading file with `:read`
            au FileReadPre            *   silent call <SID>ReportEvent("FileReadPre",s:expand("amatch"))
            " 'filetype' option has been set. pattern is matched against filetype
            au FileType               *   silent call <SID>ReportEvent("FileType",s:expand("amatch"))
            " after writing part of buffer to a file
            au FileWritePost          *   silent call <SID>ReportEvent("FileWritePost",s:expand("amatch"))
            " starting to write part of buffer to a file
            au FileWritePre           *   silent call <SID>ReportEvent("FileWritePre",s:expand("amatch"))
            " after reading file from `:filter`
            au FilterReadPost         *   silent call <SID>ReportEvent("FilterReadPost",s:expand("amatch"))
            " before reading file from `:filter`
            au FilterReadPre          *   silent call <SID>ReportEvent("FilterReadPre",s:expand("amatch"))
            " after writing file for `:filter` or making diff with an external diff
            au FilterWritePost        *   silent call <SID>ReportEvent("FilterWritePost",s:expand("amatch"))
            " starting to write file for `:filter` or making diff with an external diff
            au FilterWritePre         *   silent call <SID>ReportEvent("FilterWritePre",s:expand("amatch"))
            " nvim got focused
            au FocusGained            *   silent call <SID>ReportEvent("FocusGained",s:expand("amatch"))
            " nvim lost focus. also when GUI dialog pops up
            au FocusLost              *   silent call <SID>ReportEvent("FocusLost",s:expand("amatch"))
            " typing `<Insert>` while in Insert or Replace mode
            au InsertChange           *   silent call <SID>ReportEvent("InsertChange",s:expand("amatch"))
            " [*] when char is typed in Insert mode, before inserting char.
            au InsertCharPre          *   silent call <SID>ReportEvent("InsertCharPre",s:expand("amatch"))
            " just before starting Insert mode. also for Replace mode and Virtual Replace mode
            au InsertEnter            *   silent call <SID>ReportEvent("InsertEnter",s:expand("amatch"))
            " just after leaving Insert mode. also when using `CTRL-O`
            au InsertLeave            *   silent call <SID>ReportEvent("InsertLeave",s:expand("amatch"))
            " [*] just before leaving Insert mode. also when using `CTRL-O`
            au InsertLeavePre         *   silent call <SID>ReportEvent("InsertLeavePre",s:expand("amatch"))
            " just before showing popup menu (*P*: n, v, o, i, c, tl)
            au MenuPopup              *   silent call <SID>ReportEvent("MenuPopup",s:expand("amatch"))
            " [*] after changing mode (*P*: `old_mode:new_mode`) (`{v.event}`: old_mode, new_mode)
            au ModeChanged            *   silent call <SID>ReportEvent("ModeChanged",s:expand("amatch"))
            " [*] after setting an option (except during startup)
            au OptionSet              *   silent call <SID>ReportEvent("OptionSet",s:expand("amatch"))
            " like `QuickFixCmdPre`, but after quickfix command is run, before jumping to first location
            au QuickFixCmdPost        *   silent call <SID>ReportEvent("QuickFixCmdPost",s:expand("amatch"))
            " before quickfix command is run (*P*: command being run)
            au QuickFixCmdPre         *   silent call <SID>ReportEvent("QuickFixCmdPre",s:expand("amatch"))
            " [*] using `:quit`, `:wq` or `:qall`; before deciding whether it closes curwin or quits Vim
            au QuitPre                *   silent call <SID>ReportEvent("QuitPre",s:expand("amatch"))
            " [*] macro starts recording
            au RecordingEnter         *   silent call <SID>ReportEvent("RecordingEnter",s:expand("amatch"))
            " [*] macro stops recording (`v.event`: regcontents, regname)
            au RecordingLeave         *   silent call <SID>ReportEvent("RecordingLeave",s:expand("amatch"),s:v('event.regcontents'),s:v('event.regname'))
            " a reply from a server Vim was received (`<amatch>`: serverid, `<afile>`: reply)
            au RemoteReply            *   silent call <SID>ReportEvent("RemoteReply",s:expand("amatch"),s:expand("afile"))
            " [*] after making search with `n`/`N` if the search wraps around document
            au SearchWrapped          *   silent call <SID>ReportEvent("SearchWrapped",s:expand("amatch"))
            " after loading session file created using `:mksession`
            au SessionLoadPost        *   silent call <SID>ReportEvent("SessionLoadPost",s:expand("amatch"))
            " after exec shell command with `:!cmd`, `:make`, `:grep`
            au ShellCmdPost           *   silent call <SID>ReportEvent("ShellCmdPost",s:expand("amatch"))
            " after exec shell command with `:{range}!cmd`, `:w !cmd`, `:r !cmd`
            au ShellFilterPost        *   silent call <SID>ReportEvent("ShellFilterPost",s:expand("amatch"))
            " [*] after Nvim receives signal (*P*: signal name)
            au Signal                 *   silent call <SID>ReportEvent("Signal",s:expand("amatch"))
            " [*] after sourcing vim/lua file (`<afile>`: filename)
            au SourcePost             *   silent call <SID>ReportEvent("SourcePost",s:expand("amatch"))
            " [*] before sourcing vim/lua file (`<afile>`: filename)
            au SourcePre              *   silent call <SID>ReportEvent("SourcePre",s:expand("amatch"))
            " when trying to load spellfile and it can't be found (*P*: language) (`<amatch>` = language)
            au SpellFileMissing       *   silent call <SID>ReportEvent("SpellFileMissing",s:expand("amatch"))
            " during startup, after reading from stdin into buffer, before executing modelines
            au StdinReadPost          *   silent call <SID>ReportEvent("StdinReadPost",s:expand("amatch"))
            " during startup, before reading from stdin into buffer
            au StdinReadPre           *   silent call <SID>ReportEvent("StdinReadPre",s:expand("amatch"))
            " detected existing swapfile when editing file (`v:swapname`: swapfile name; `v:swapcommand`, `v:swapchoice`) (`<afile>`: file being edited)
            au SwapExists             *   silent call <SID>ReportEvent("SwapExists",s:expand("amatch"),s:expand("afile"),s:v('swapname'),s:v('swapcommand'))
            " when 'syntax' option has been set (*P*: syntax name) (`<afile>`: filename where set; `<amatch>`: where opt set)
            au Syntax                 *   silent call <SID>ReportEvent("Syntax",s:expand("amatch"),s:expand("afile"))
            " [*] after closing tab page
            au TabClosed              *   silent call <SID>ReportEvent("TabClosed",s:expand("amatch"))
            " just after entering tab page (*A*: `WinEnter`, *B*: `BufEnter`)
            au TabEnter               *   silent call <SID>ReportEvent("TabEnter",s:expand("amatch"))
            " just before leaving tab page (*A*: `WinLeave`)
            au TabLeave               *   silent call <SID>ReportEvent("TabLeave",s:expand("amatch"))
            " [*] when creating new tab page (*A*: `WinEnter`, *B*: `TabEnter`)
            au TabNew                 *   silent call <SID>ReportEvent("TabNew",s:expand("amatch"))
            " [*] after entering new tab page (*A*: `BufEnter`)
            au TabNewEntered          *   silent call <SID>ReportEvent("TabNewEntered",s:expand("amatch"))
            " [*] when `terminal` job ends (`v.event`: status)
            au TermClose              *   silent call <SID>ReportEvent("TermClose",s:expand("amatch"))
            " [*] after entering `Terminal-mode`. after `TermOpen`
            au TermEnter              *   silent call <SID>ReportEvent("TermEnter",s:expand("amatch"))
            " [*] after leaving `Terminal-mode`. after `TermClose`
            au TermLeave              *   silent call <SID>ReportEvent("TermLeave",s:expand("amatch"))
            " [*] when `terminal` job is starting
            au TermOpen               *   silent call <SID>ReportEvent("TermOpen",s:expand("amatch"))
            " after response to `t_RV` is received from terminal
            au TermResponse           *   silent call <SID>ReportEvent("TermResponse",s:expand("amatch"))
            " [*] after text change made to curbuf (*M*: N) (*A*: `b:changedtick`)
            au TextChanged            *   silent call <SID>ReportEvent("TextChanged",s:expand("amatch"))
            " [*] after text change made to curbuf (*M*: I)
            au TextChangedI           *   silent call <SID>ReportEvent("TextChangedI",s:expand("amatch"))
            " [*] after text change made to curbuf when PUM is visible (*M*: I)
            au TextChangedP           *   silent call <SID>ReportEvent("TextChangedP",s:expand("amatch"))
            " [*] after text change made to curbuf (*M*: T)
            au TextChangedT           *   silent call <SID>ReportEvent("TextChangedT",s:expand("amatch"))
            " [*] just after `yank`/`delete`, not if blackhole reg or `setreg()` (`v.event`: inclusive, operator, regcontents, regname, regtype, visual)
            au TextYankPost           *   silent call
                \       <SID>ReportEvent(
                \              "TextYankPost",
                \              s:expand("amatch"),
                \              s:v('event.operator'),
                \              s:v('event.inclusive'),
                \              s:v('event.regcontents'),
                \              s:v('event.regname'),
                \              s:v('event.regtype'),
                \              s:v('event.visual')
                \       )
            " [*] [NVIM] after UI connects via `nvim_ui_attach()`, or after TUI is started (*A*: `VimEnter`) (`v.event`: chan)
            au UIEnter                *   silent call <SID>ReportEvent("UIEnter",s:expand("amatch"),s:v('event.chan'))
            " [*] [NVIM] after UI disconnects from Nvim, or after TUI is stopped (*A*: `VimLeave`) (`v.event`: chan)
            au UILeave                *   silent call <SID>ReportEvent("UILeave",s:expand("amatch"),s:v('event.chan'))
            " to be used in combination with ":doautocmd"
            au User                   *   silent call <SID>ReportEvent("User",s:expand("amatch"))
            " after doing all startup stuff, including loading vimrc files (*A*: `v:vim_did_enter)
            au VimEnter               *   silent call <SID>ReportEvent("VimEnter",s:expand("amatch"))
            " before exiting Vim, just after writing the .shada file; once (`v:dying`, `v:exiting`)
            au VimLeave               *   silent call <SID>ReportEvent("VimLeave",s:expand("amatch"))
            " before exiting Vim, just before writing the .shada file; once (`v:dying`, `v:exiting`)
            au VimLeavePre            *   silent call <SID>ReportEvent("VimLeavePre",s:expand("amatch"))
            " after Vim window was resized
            au VimResized             *   silent call <SID>ReportEvent("VimResized",s:expand("amatch"))
            " [*] Nvim resumes from `suspend` state
            au VimResume              *   silent call <SID>ReportEvent("VimResume",s:expand("amatch"))
            " [*] before Nvim enters `suspend` state
            au VimSuspend             *   silent call <SID>ReportEvent("VimSuspend",s:expand("amatch"))
            " [*] when closing window, just before removed from win layout (*A*: `WinLeave`, *P*: `winid`) (`<amatch>`, `<afile>`: `winid`)
            au WinClosed              *   silent call <SID>ReportEvent("WinClosed",s:expand("amatch"),s:expand("afile"))
            " after entering another window. not for first window
            au WinEnter               *   silent call <SID>ReportEvent("WinEnter",s:expand("amatch"))
            " before leaving window (*B*: `WinClosed`)
            au WinLeave               *   silent call <SID>ReportEvent("WinLeave",s:expand("amatch"))
            " [*] when creating new window; not for first window (*B*: `WinEnter`)
            au WinNew                 *   silent call <SID>ReportEvent("WinNew",s:expand("amatch"))
            " [*] after window in current tab page changed width or height
            au WinResized             *   silent call <SID>ReportEvent("WinResized",s:expand("amatch"))
            " [*] after any window in current tab page scrolled text or changed width or height
            au WinScrolled            *   silent call <SID>ReportEvent("WinScrolled",s:expand("amatch"))

            " ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

            " NOTE: supposedly cause problems; haven't tested
            " user function is used but it isn't defined (*P*: func name) (`<amatch>,` `<afile>` = func name)
            " au FuncUndefined          *   silent call <SID>ReportEvent("FuncUndefined",expand("<amatch>:t"))
            " before starting to edit a new buffer. should read file into buffer
            " au BufReadCmd             *   silent call <SID>ReportEvent("BufReadCmd",expand("<amatch>:t"))
            " before reading file with `:read`. should do reading of file
            " au FileReadCmd            *   silent call <SID>ReportEvent("FileReadCmd",expand("<amatch>:t"))
            " before writing whole buffer to file
            " au BufWriteCmd            *   silent call <SID>ReportEvent("BufWriteCmd",expand("<amatch>:t"))
            " before writing part of buffer to a file. should do writing to the file, and should not change buffer
            " au FileWriteCmd           *   silent call <SID>ReportEvent("FileWriteCmd",expand("<amatch>:t"))
            " starting to append to file. use `'[` and `']` marks for range of lines
            " au FileAppendPre          *   silent call <SID>ReportEvent("FileAppendPre",expand("<amatch>:t"))
            " [*] when sourcing vim/lua file (`<afile>`: filename)
            " au SourceCmd              *   silent call <SID>ReportEvent("SourceCmd",expand("<amatch>:t"),expand("<sfile>:t"))

            " ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

            " NOTE: okay?
            " when user presses same key 42 times
            " au UserGettingBored              *   silent call <SID>ReportEvent("UserGettingBored",expand("<amatch>:t"))

            " ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

            " NOTE: vim only
            " [VIM] just after adding a buffer to the buffer list
            " au BufCreate              *   silent call <SID>ReportEvent("BufCreate",expand("<amatch>:t"))
            " [VIM] after the 'encoding' option has been changed
            " au EncodingChanged        *   silent call <SID>ReportEvent("EncodingChanged",expand("<amatch>:t"))
            " [VIM] after starting the GUI successfully
            " au GUIEnter               *   silent call <SID>ReportEvent("GUIEnter",expand("<amatch>:t"))
            " [*] [VIM] after starting the GUI failed
            " au GUIFailed              *   silent call <SID>ReportEvent("GUIFailed",expand("<amatch>:t"))
            " [VIM] after the value of 'term' has changed
            " au TermChanged            *   silent call <SID>ReportEvent("TermChanged",expand("<amatch>:t"))

            " [*] [VIM] nothing pending, going to wait for the user to type a character
            " au SafeState            *   silent call <SID>ReportEvent("SafeState",expand("<amatch>:t"))
            " [*] [VIM] repeated SafeState
            " au SafeStateAgain       *   silent call <SID>ReportEvent("SafeStateAgain",expand("<amatch>:t"))
            " [*] [VIM] after the SIGUSR1 signal has been detected
            " au SigUSR1       *   silent call <SID>ReportEvent("SigUSR1",expand("<amatch>:t"))
            " [*] [VIM] after a `terminal` buffer was created
            " au TerminalOpen       *   silent call <SID>ReportEvent("TerminalOpen",expand("<amatch>:t"))
            " [*] [VIM] after a `terminal` buffer was created in a new window
            " au TerminalWinOpen       *   silent call <SID>ReportEvent("TerminalWinOpen",expand("<amatch>:t"))
        endif
    augroup END
endf

" Restore previous external compatibility options
let &cpo = s:save_cpo
