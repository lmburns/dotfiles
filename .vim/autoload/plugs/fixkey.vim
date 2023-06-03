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

  " call Fixkey_setKey("<C-S-u>", "\e[[117;6")
  " call Fixkey_setKey("<C-S-E>", "\e[[101;6u]")
  " call Fixkey_setKey("<C-e>", "\e[[69;5u]")
  " call Fixkey_setKey("<C-S-E>", "^E")
  " call Fixkey_setKey("<C-e>", "^e")
endfun
