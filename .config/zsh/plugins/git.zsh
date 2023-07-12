# @desc: open git repo in browser
function grepo() {
  [[ "$#" -ne 0 ]] && return $(handlr open "https://github.com/${(j:/:)@}")
  local url
  url=$(git remote get-url origin) || return $?
  [[ "$url" =~ '^git@' ]] && url=$(echo "$url" | sed -e 's#:#/#' -e 's#git@#https://#')
  command handlr open "$url"
}

# @desc: check if inside a git repository
function __git_inside_worktree() {
  command git rev-parse --is-inside-work-tree >/dev/null 2>&1
}

# @desc: check what master branch's name is
function git_main_branch() {
  local b branch="master"
  for b (main trunk) {
    command git show-ref -q --verify refs/heads/$b && { branch=$b; break; }
  }
  print -Pr -- "%B$branch%b"
}

# @desc: open fugitive in neovim
function ngf() {
  __git_inside_worktree && nvim +"lua require('plugs.fugitive').index()"
}
# @desc: open diffview in neovim
function ngd() {
  __git_inside_worktree && nvim +'DiffviewOpen' +'bw 1'
}
# @desc: open diffview history in neovim
function ngh() {
  __git_inside_worktree && nvim +"DiffviewFileHistory ${*:+${(q)*}}" +'bw 1'
}
# @desc: open neogit in neovim
function ngn() {
  __git_inside_worktree && nvim +"Neogit" +'bw 1'
}
# @desc: open flog in neovim
function ngg() {
  __git_inside_worktree && nvim +"Flog -raw-args=${*:+${(q)*}}" +'bw 1'
}
function __ngg_compdef() {
  (( $+functions[_git-log] )) || _git
  _git-log
}
compdef __ngg_compdef ngg

alias ngdt='_ngdt'
compdef __ngdt_compdef _ngdt
function _ngdt() {
  __git_inside_worktree && nvim +"Git difftool -y $*"
}
function __ngdt_compdef() {
  (( $+functions[_git-difftool] )) || _git
  _git-difftool
}

# @desc: open diffview in neovim
# function ngd() {
#   __git_inside_worktree && nvim +'DiffviewOpen' +'bw 1'
# }

# bind generic xnl  !>zsh -c "$EDITOR +'DiffviewOpen %(commit)^! -- \"%(file)\"' +'bw 1'" # diffview with last
# bind generic xdd  !>zsh -c "$EDITOR +'DiffviewOpen %(commit)^!' +'bw 1'"

# @desc: git change root
function gcr() {
  builtin cd "$(git rev-parse --show-toplevel)"
}

# @desc: get a list of all repository urls in the current directory
function git_urls() {
  () {
    rmansi -i $1;
    cat $1 >| out
  } =(mgit remote get-url origin)
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

compdef _rg nrg
function nrg() {
  if [[ $* ]]; then
     nvim +'pa nvim-treesitter' \
          +"Grepper -noprompt -dir cwd -grepprg rg $* --max-columns=200 -H --no-heading --vimgrep -C0 --color=never"
  else
     rg
  fi
}
