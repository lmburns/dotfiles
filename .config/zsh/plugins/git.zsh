
# @desc: open git repo in browser
function grepo() {
  [[ "$#" -ne 0 ]] && return $(handlr open "https://github.com/${(j:/:)@}")
  local url
  url=$(git remote get-url origin) || return $?
  [[ "$url" =~ '^git@' ]] && url=$(echo "$url" | sed -e 's#:#/#' -e 's#git@#https://#')
  command handlr open "$url"
}
