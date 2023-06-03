fun! plugs#fixkey#setup() abort
  call Fixkey_setKey("<M-.>", "\e.")
  call Fixkey_setKey("<M-,>", "\e,")
  call Fixkey_setKey("<M-/>", "\e/")

  " call Fixkey_setKey("<C-S-u>", "\e[[117;6")
  call Fixkey_setKey("<C-S-E>", "\e[[101;6")
  call Fixkey_setKey("<C-e>", "\e[[69;5")
endfun
