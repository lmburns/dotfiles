fun! plugs#fixkey#setup() abort
  call Fixkey_setKey("<M-.>", "\e.")
  call Fixkey_setKey("<M-,>", "\e,")
  call Fixkey_setKey("<M-/>", "\e/")
  call Fixkey_setKey("<M-]>", "\e]")
  " call Fixkey_setKey("<M-[>", "\e[93;3")
  " call Fixkey_setKey("<M-[>", "\e[93;3u]")
  call Fixkey_setKey("<M-'>", "\e'")
  call Fixkey_setKey("<M-->", "\e-")
  call Fixkey_setKey("<M-_>", "\e_")

  call Fixkey_setKey("<M-S-i>", "\e[105;4u")
  call Fixkey_setKey("<M-S-o>", "\e[111;4u")

  "  - { key: Colon, mods: Control|Shift, chars: "\x1b[58;6u" } # Colon
  "  - { key: 0x0a, mods: Control|Shift, chars: "\x1b[40;6u" } # LParenthesis

  " exec "set <C-S-:>=\<Esc>[58;6u]"
  " exec "set <C-:>=\<Esc>[58;6u"
  " exec "set <My-C-S-:>=\<Esc>[58;6u"

  " <Char-123>  character 123
  " <Char-033>  character 27
  " <Char-0x7f> character 127
  " <S-Char-114>    character 114 ('r') shifted ('R')

  " " Use vsplit mode http://qiita.com/kefir_/items/c725731d33de4d8fb096
  " if has("vim_starting") && !has('gui_running') && has('vertsplit')
  "   function! s:enable_vsplit_mode()
  "     " enable origin mode and left/right margins
  "     let &t_CS = "y"
  "     let &t_ti = &t_ti . "\e[?6;69h"
  "     let &t_te = "\e[?6;69l\e[999H" . &t_te
  "     let &t_CV = "\e[%i%p1%d;%p2%ds"
  "     call writefile([ "\e[?6;69h" ], "/dev/tty", "a")
  "   endfunction
  "
  "   " old vim does not ignore CPR
  "   map <special> <Esc>[3;9R <Nop>
  "
  "   " new vim can't handle CPR with direct mapping
  "   " map <expr> ^[[3;3R g:EnableVsplitMode()
  "   set t_F9=[3;3R
  "
  "   map <expr> <t_F9> <SID>enable_vsplit_mode()
  "   let &t_RV .= "\e[?6;69h\e[1;3s\e[3;9H\e[6n\e[0;0s\e[?6;69l"
  " endif
endfun
