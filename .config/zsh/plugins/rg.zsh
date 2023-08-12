# Version 1: Use ripgrep to find files
function Rg() {
  rg --column --line-number --no-heading --color=always --smart-case "$1" |
    fzf --ansi \
      --delimiter : \
      --bind 'ctrl-e:become($EDITOR "$(echo {} | hck -d: -f1)")' \
      --preview 'bat --style=numbers,header,changes,snip --color=always --highlight-line {2} -- {1}' \
      --preview-window 'default:right:60%:~1:+{2}+3/2:border-left'
}

# Version 1: Use skim to find files
function Sk() {
  sk --ansi \
     --prompt '❱ ' \
     --cmd-prompt '❱ ' \
     --interactive \
     --delimiter : \
     --bind 'ctrl-e:execute($EDITOR "$(echo {} | hck -d: -f1)" >/dev/tty </dev/tty)' \
     --preview 'bat --style=numbers,header,changes,snip --color=always --highlight-line {2} -- {1}' \
     --preview-window 'default:right:60%:~1:+{2}+3/2:border-left' \
     --cmd 'rg --column --line-number --no-heading --color=always --smart-case "{}"' \
     --cmd-query "$1"
}

# --skip-to-pattern '[^/]*:'

# Version 2: Use ripgrep to find files (much better)
# Has ability to parse glob and use pcre regex
function RG() {
  emulate -LR zsh
  setopt extendedglob warncreateglobal

  local MATCH; integer MEND MBEGIN
  local RG_PREFIX INITIAL_QUERY
  local -a rg_filtered f_filtered rg_cmd
  local -a opts

  zmodload -Fa zsh/zutil +b:zparseopts
  zparseopts -E -F -D -a opts - \
      x -show-error \
      {g,-glob}+:- \
      {i,-iglob}+:- \
      {t,-type}+:- \
      {T,-type-not}+:- \
      p -pcre -pcre2 \
      F -fixed \
      U -multiline \
      s -sensitive \
      f -files \
      z -search-zip \
      l -follow \
      H -no-hidden \
      n -no-ignore \
      C -no-config \
      N -no-preview \
      {j,-threads}:- \
      {d,-max-depth}:- \
      {Z,-max-filesize}:- \
      {R,-max-count}:- \
      {M,-max-columns}:- \
      {G,-ignore-file}:- \
      {h,-height}:- \
      {b,-bind}:- \
      m -multi

  rg_filtered=( ${${${(M@)opts:#-(g|-glob(=|))*}##-(g|-glob(=|))}//(#m)*/--glob=${(qq)MATCH}} )
  rg_filtered=( ${${${(M@)opts:#-(i|-iglob(=|))*}##-(i|-iglob(=|))}//(#m)*/--iglob=${(qq)MATCH}} )
  rg_filtered+=( ${${${(M@)opts:#-(t|-type(=|))*}##-(t|-type(=|))}//(#m)*/--type=${(q)MATCH}} )
  rg_filtered+=( ${${${(M@)opts:#-(T|-type-not(=|))*}##-(T|-type-not(=|))}//(#m)*/--type-not=${(q)MATCH}} )
  rg_filtered+=( ${${${(M@)opts:#-(d|-max-depth(=|))*}##-(d|-max-depth(=|))}//(#m)*/--max-depth=${(q)MATCH}} )
  rg_filtered+=( ${${${(M@)opts:#-(Z|-max-filesize(=|))*}##-(Z|-max-filesize(=|))}//(#m)*/--max-filesize=${(q)MATCH}} )
  rg_filtered+=( ${${${(M@)opts:#-(R|-max-count(=|))*}##-(R|-max-count(=|))}//(#m)*/--max-count=${(q)MATCH}} )
  rg_filtered+=( ${${${(M@)opts:#-(M|-max-columns(=|))*}##-(M|-max-columns(=|))}//(#m)*/--max-columns=${(q)MATCH}} )
  rg_filtered+=( ${${${(M@)opts:#-(j|-threads(=|))*}##-(j|-threads(=|))}//(#m)*/--threads=${(q)MATCH}} )
  rg_filtered+=( ${${${(M@)opts:#-(G|-ignore-file(=|))*}##-(G|-ignore-file(=|))}//(#m)*/--ignore-file=${(q)MATCH}} )

  rg_filtered+=( ${${${(M)${+opts[(r)-(f|-files)]}:#1}:+--files}:-} )
  rg_filtered+=( ${${${(M)${+opts[(r)-(U|-multiline)]}:#1}:+--multiline}:-} )
  rg_filtered+=( ${${${(M)${+opts[(r)-(z|-search-zip)]}:#1}:+--search-zip}:-} )
  rg_filtered+=( ${${${(M)${+opts[(r)-(C|-no-config)]}:#1}:+--no-config}:-} )
  rg_filtered+=( ${${${(M)${+opts[(r)-(n|-no-ignore)]}:#1}:+--no-ignore}:-} )
  rg_filtered+=( ${${${(M)${+opts[(r)-(l|-no-follow)]}:#1}:+--no-follow}:-} )
  rg_filtered+=( ${${${(M)${+opts[(r)-(H|-no-hidden)]}:#1}:+--no-hidden}:-} )
  rg_filtered+=( ${${${(M)${+opts[(r)-(s|-sensitive)]}:#1}:+--case-sensitive}:-} )
  rg_filtered+=( ${${${(M)${+opts[(r)-(p|-pcre(2|))]}:#1}:+--pcre2}:-} )
  rg_filtered+=( ${${${(M)${+opts[(r)-(F|-fixed)]}:#1}:+--fixed-strings}:-} )

  f_filtered=( ${${${(M@)opts:#-(h|-height(=|))*}##-(h|-height(=|))}//(#m)*/--height=${(q)MATCH}} )
  f_filtered+=( ${${${(M@)opts:#-(b|-bind(=|))*}##-(b|-bind(=|))}//(#m)*/--bind=${(q-)MATCH}} )

  f_filtered+=( ${${${(M)${+opts[(r)-(m|-multi)]}:#1}:+--multi}:-} )

  rg_cmd=(
    rg --column --hidden --line-number --no-heading --color=always --smart-case --pcre2 --follow
    ${(j: :)rg_filtered}
  )
  RG_PREFIX="${(j: :)rg_cmd}"
  INITIAL_QUERY="${*:-}"
  FZF_DEFAULT_COMMAND="$RG_PREFIX ${(qq)INITIAL_QUERY} ${${${(M)${+opts[(r)-(x|-show-error)]}:#0}:+|| true}:-}" \
    fzf \
      --ansi \
      --exit-0 \
      --disabled \
      --query="$INITIAL_QUERY" \
      --delimiter : \
      --bind="focus:transform-border-label:echo [ {1} ]" \
      --bind='ctrl-e:become($EDITOR {1} +{2})' \
      --bind='ctrl-x:execute($EDITOR {1} +{2})' \
      --bind='enter:become($EDITOR {1} +{2})' \
      --bind='ctrl-y:execute-silent(xsel -b --trim <<< {1})' \
      --bind="change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
      --preview='bat --style=numbers,changes,snip --color=always --highlight-line {2} -- {1}' \
      --preview-window="default:right:60%:+{2}+3/2:border-left${${${(M)${+opts[(r)-(N|-no-preview)]}:#1}:+:hidden}:-}" \
      ${(j: :)f_filtered}
}

# --preview-window 'nohidden,up,60%,border-bottom,+{2}+3/3,~3'

# Find todo comments
function TODOS() {
  local RG_PREFIX
  local -a selected
  RG_PREFIX="rg --column --hidden --line-number --no-heading --color=always --smart-case \
    '\bFIXME\b|\bFIX\b|\bDISCOVER\b|\bNOTE\b|\bNOTES\b|\bINFO\b|\bOPTIMIZE\b|\bXXX\b|\bEXPLAIN\b|\bTODO\b|\bHACK\b|\bBUG\b|\bBUGS\b'"
  selected=("$(
    FZF_DEFAULT_COMMAND="$RG_PREFIX || true" \
      fzf --bind "change:reload:$RG_PREFIX {q} || true" \
        --ansi --disabled \
        --delimiter : \
        --bind 'ctrl-e:execute($EDITOR "$(echo {} | hck -d: -f1)" >/dev/tty </dev/tty)' \
        --bind='ctrl-y:execute-silent(echo {+} | hck -d: -f1 | xsel -b)' \
        --preview 'bat --style=numbers,header,changes,snip --color=always --highlight-line {2} -- {1}' \
        --preview-window 'default:right:60%:~1:+{2}+3/2:border-left'
  )")
  selected=(${(@s.:.)selected})
  [ -n "${selected[1]}" ] && ${EDITOR} "+${selected[2]}" -- "${selected[1]}"
}

# vim: ft=zsh:et:sw=0:ts=2:sts=2:
