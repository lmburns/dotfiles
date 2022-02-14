############################################################################
#   Created: 2021-06-10 14:18                                              #
############################################################################

# fzf-clipboard() {
#   echo -n "$(greenclip print | fzf -e -i)" | xclip -selection clipboard
# }

# greenclip-cfg() {
#   killall greenclip
#   $EDITOR $XDG_CONFIG_HOME/greenclip.cfg && nohup greenclip daemon > /dev/null 2>&1 &
# }
#
# greenclip-rld() {
#   killall greenclip
#   nohup greenclip daemon > /dev/null 2>&1 &
# }
#
# greenclip-derez() {
#   killall greenclip
#   rm $XDG_CACHE_HOME/greenclip.history && nohup greenclip daemon > /dev/null 2>&1 &
# }

tsm-clearcompleted() {
  local -a done
  done=( $(transmission-remote -l | rg '100%' | rg 'Done' | hck -f2) )
  for f (${done%\*}) { transmission-remote -t $f -r }
}

tsm-clearall() {
  for f ( $(transmission-remote -l | hck -f2) ) { transmission-remote -t $f -r }
}

# display numbers of ip being blocked by the blocklist (credit: smw from irc #transmission)
tsm-count() {
  echo "Blocklist rules:" $(curl -s --data \
  '{"method": "session-get"}' localhost:9091/transmission/rpc -H \
  "$(curl -s -D - localhost:9091/transmission/rpc | grep X-Transmission-Session-Id)" \
  | cut -d: -f 11 | cut -d, -f1)
}

# DEMO: http://www.youtube.com/watch?v=TyDX50_dC0M
# DESC: merge multiple ip blocklist into one
# LINK: https://github.com/gotbletu/shownotes/blob/master/blocklist.sh
tsm-blocklist() {
  echo -e "${Red}>>>Stopping Transmission Daemon ${Color_Off}"
    killall transmission-daemon
  echo -e "${Yellow}>>>Updating Blocklist ${Color_Off}"
    ~/.scripts/blocklist.sh
  echo -e "${Red}>>>Restarting Transmission Daemon ${Color_Off}"
    transmission-daemon
    sleep 3
  echo -e "${Green}>>>Numbers of IP Now Blocked ${Color_Off}"
    tsm-count
}
tsm-altdownloadspeed() { transmission-remote --downlimit "${@:-900}" ;} # download default to 900K, else enter your own
tsm-altdownloadspeedunlimited() { transmission-remote --no-downlimit ;}
tsm-limitupload() { transmission-remote --uplimit "${@:-10}" ;} # upload default to 10kpbs, else enter your own
tsm-limituploadunlimited() { transmission-remote --no-uplimit ;}
tsm-askmorepeers() { transmission-remote -t"$1" --reannounce ;}
tsm-daemon() { transmission-daemon ;}
tsm-quit() { killall transmission-daemon ;}
tsm-add() { transmission-remote --add "$1" ;}
tsm-hash() { transmission-remote --add "magnet:?xt=urn:btih:$1" ;}       # adding via hash info
tsm-verify() { transmission-remote --verify "$1" ;}
tsm-pause() { transmission-remote -t"$1" --stop ;}    # <id> or all
tsm-start() { transmission-remote -t"$1" --start ;}   # <id> or all
tsm-purge() { transmission-remote -t"$1" --remove-and-delete ;} # delete data also
tsm-remove() { transmission-remote -t"$1" --remove ;}   # leaves data alone
tsm-info() { transmission-remote -t"$1" --info ;}
tsm-speed() { while true;do clear; transmission-remote -t"$1" -i | grep Speed;sleep 1;done ;}
tsm-grep() { transmission-remote --list | grep -i "$1" ;}
tsm() { transmission-remote --list ;}
tsm-show() { transmission-show "$1" ;}                          # show .torrent file information

tsm-ncurse() { tide;}

export PATH_ARIA_DAEMON_DOWNLOAD_DIR="$HOME/Downloads/Aria"

dad-start() { dad -d "$PATH_ARIA_DAEMON_DOWNLOAD_DIR" start ;}
dad-stop() { dad stop ;}

alias magnet-to-torrent="aria2c -q --bt-metadata-only --bt-save-metadata"
aria2c-quit() {
   killall aria2c
   kill $(ps -ef | grep '[h]ttp.server' | awk '{print $2}')
   #kill $(ps -ef | grep '[S]impleHTTPServer' | awk '{print $2}')
}

aria2c-webui() {
    # download location
    DIR_DL=~/Downloads

    # run as daemon
    aria2c --enable-rpc --rpc-listen-all -D -d "$DIR_DL"


    # use python simplehttpserver to host the webui
    # this avoids download the index.html file on each computer
    # https://github.com/ziahamza/webui-aria2

    # path to the webui index.html
    DIR_WEBUI=~/.bin/webui-aria2/docs/

    # webui-aria2c uses port 6800 so we use 6801 for python_simple_http_server
    PORT=6801
    cd "$DIR_WEBUI"
    nohup python3 -m http.server "$PORT" >/dev/null 2>&1&
    echo "connect via http://localhost:$PORT or http://ip_address_of_server:$PORT"
}

pick_torrent() {
    LBUFFER="transmission-remote -t ${$({
      for torrent in ${(f)"$(transmission-remote -l)"}; do
          torrent_name=$torrent[73,-1]
          [[ $torrent_name != (Name|) ]] && echo ${${${(s. .)torrent}[1]}%\*} $torrent_name
      done
  } | fzf)%% *} -"
}

zle -N pick_torrent
