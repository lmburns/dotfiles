function cmdsave() {
  PREV=$(fc -lrn | head -n 1)
  sh -c "the-way cmd `printf %q "$PREV"`"
}

function cmdsearch() {
  BUFFER=$(the-way search --stdout --languages="sh")
  print -z $BUFFER
}

function cmdrun() {
  REPLY=$(the-way search --stdout)
  sh -c "$REPLY"
}
