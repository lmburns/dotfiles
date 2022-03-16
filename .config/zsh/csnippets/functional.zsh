# =============================== Map ================================
# ====================================================================

function __print_start() {
  builtin print -Pu2 "%F{1}%BUsage%f%b: %F{13}$1%f $@[2,-1]";
  builtin print -u2
  builtin print -Pru2 "%F{2}%UExample%f%u:";
}

function __print_tab()       { builtin print -Pru2 -- "    $@"; }
function __print_indent()    { __print_tab "%F{14}%B>%f%b $@"; }
function __print_func_call() { __print_indent "%F{1}$1%f() $@[2,-1]"; }
function __print_func()      { __print_indent "%F{13}$1%f $@[2,-1]"; }

# Exported

function map() {
  emulate -L zsh -o rcquotes
  (( $# )) || {
    __print_start "map" "funcname [list]"
    __print_func_call "foo" '{ print ''x: \$1'' }'
    __print_func "map" "foo a b c d"
    local v; for v ({a..d}) { __print_tab "x: $v" }
    return 1
  }

  local func_name=$1 elem; shift
  for elem ($@) { print -- $(eval $func_name $elem) }
}

function mapl() {
  emulate -L zsh -o rcquotes
  (( $# )) || {
    __print_start "mapl" "lambda-function [list]"
    __print_func "mapl" "'echo \"x: "'\$1'"\"' a b c d"
    local v; for v ({a..d}) { __print_tab "x: $v" }
    return 1
  }
  local f="$1"; shift
  local x result=0
  for x { mapl_ "$x" "$f" || result=$? }
  return result
}

function mapl_() {
  # Honestly unsure how this is working here?
  # Only evaluating the second input
  # $1 => substituted with value
  eval "${(e)==2}"
}

function mapa() {
  emulate -L zsh
  (( $# )) || {
    __print_start "mapa" "lambda-arithmetic [list]\n\t(shorthand for mapl "'\\$[ f ]'" [list])"
    __print_func "mapa" "'"'\$1'" + 5' {1..3}"
    local t; for t ({6..8}) { __print_tab $t }
    return 1
  }
  local f="\$[ $1 ]"; shift
  mapa__ "$f" "$@"
}

function mapa__ () {
  (( $# )) || return 1
  local f="$1"; shift
  local x result=0
  for x { mapa_ "$x" "$f" || result=$? }
  return result
}

function mapa_() {
  print -- "${(e)==2}"
}

# =============================== Each ===============================
# ====================================================================

function eachl() {
  (( $# )) || {
    __print_start "eachl" "lambda-function [list]"
    __print_func "eachl" "'echo \"x: "'\$1'"\"' a b c d"
    local v; for v ({a..d}) { __print_tab "x: $v" }
    return 1
  }

  local f="$1"; shift
  local x result=0
  for x { each_ "$x" "$f" || result=$? }
  return result
}

function each_() {
  eval "${(e)==2}"
}

# This actions like xargs, or `fd`'s -x/-X flags which implicitly add a '{}' to the end
function each() {
  local f="$1 \"\$1\""; shift
  eachl "$f" "$@"
}

# ============================== Filter ==============================
# ====================================================================

function startswith() { print -- "$2" | rg -q "^$1"; }
function endswith()   { print -- "$2" | rg -q "$1$"; }

function filter() {
  (( $# )) || {
    __print_start "filter" "[func-list]"
    __print_func_call "baz" "{ print "'\$*'" | grep baz }"
    __print_func "filter" "baz titi bazaar biz"
    __print_tab 'bazaar'
    return 1
  }
  local f="$1 \"\$1\""; shift
  filterl "$f" "$@"
}

function filterl() {
  (( $# )) || {
    __print_start "filterl" "lambda-function [list]"
    __print_func "filterl" "'echo "'\$1'" | grep a >/dev/null' ab cd ef ada"
    local v; for v (ab ada) { __print_tab "$v" }
    return 1
  }
  local f="$1"; shift
  local x
  for x { filter_ "$x" "$f" }
  return 0
}

function filter_() {
  eval "${==2}" && print -- "$1"
}

### filtera ArithRelation Arg ...  # is shorthand for
### filter '(( ArithRelation ))' Arg ...

function filtera() {
  typeset f="(( $1 ))"; shift
  filterl "$f" "$@"
}

# =============================== Fold ===============================
# ====================================================================

function fold() {
  (( $# < 2 )) && {
    __print_start "fold" "[func-list]"
    __print_func_call "bar" "{ print "'\$(( \$1 + \$2 ))'" }"
    __print_func "fold" "bar 0 1 2 3 4 5"
    __print_tab "15"
    return 1
  }

  local f="\$($1 \$acc \$1)"; shift
  foldlp "$f" "$@"
}

function foldl() {
  (( $# < 2 )) && {
    print::error 'Warning, l is not for left! Its for lambda style expression!'
    print::error 'Though this is left fold still'
    return 1
  }

  local body=$1 acc=$2; shift 2
  for x { acc=$(folde_ $x $acc $body) }
  print -- $acc
  return 0
}

function folda() {
  (( $# >= 2 )) || {
    __print_start "folda" "lambda-function [list]"
    __print_func "folda" "'"'\$1 + \$2'"' {1..5}"
    __print_tab "15"
    __print_func "folda" "'"'\$1 * \$2'"' {1..20}"
    __print_tab "120"
    return 1
  }
  local f="\$[ $1 ]"; shift
  foldlp "$f" "$@"
}

function foldlp() {
  (( $# < 2 )) && {
    print::error 'Warning, l is not for left! Its for lambda style expression!'
    print::error 'Though this is left fold still'
    return 1
  }

  local body=$1 acc=$2; shift 2
  for x { acc=$(fold_ $x $acc $body) }
  print -- $acc
  return 0
}

function fold_() {
  local acc=$2 body=$3
  print "${(e)==body}"
}

function folde_() {
  local acc=$2 body=$3
  eval "${(e)==body}"
}


map_() {
  echo ${(e)==f}
}
