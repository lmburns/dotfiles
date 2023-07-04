function tsm-clearcompleted() {
  local -a isdone
  isdone=( $(transmission-remote -l | rg '100%' | rg 'Done' | hck -f2) )
  for f (${isdone%\*}) { transmission-remote -t $f -r }
}

function tsm-clearall() {
  local f
  for f ( ${(@f)"$(transmission-remote -l | sed '1d; $d' | hck -f2)"} ) {
    transmission-remote -t $f -r
  }
}

function tsm-speed() {
  while ((1)) {
    clear -x
    transmission-remote -t"$1" -i | rg Speed
    sleep 1
  }
}

# display numbers of ip being blocked by the blocklist (credit: smw from irc #transmission)
function tsm-count() {
  echo "Blocklist rules:" $(curl -s --data \
  '{"method": "session-get"}' localhost:9091/transmission/rpc -H \
  "$(curl -s -D - localhost:9091/transmission/rpc | rg 'X-Transmission-Session-Id')" \
  | cut -d: -f 11 | cut -d, -f1)
}

# Desc: merge multiple ip blocklist into one
function tsm-blocklist() {
  print -Pr -- "%F{1}%B>>> Stopping Transmission Daemon%f" && killall transmission-daemon
  # print -Pr -- "%F{3}%B>>> Updating Blocklist%f" && TODO: <SCRIPT HERE>
  blocklist
  print -Pr -- "%F{1}%B>>>Restarting Transmission Daemon%f" && { transmission-daemon; sleep 3; }
  print -Pr -- "%F{2}%B>>>Numbers of IP Now Blocked%f" && tsm-count
}
# Desc: download default to 900K, else enter your own
function tsm-dlspeed()         { transmission-remote --downlimit "${@:-900}" ; }
function tsm-dlspeed-inf()     { transmission-remote --no-downlimit ; }
# Desc: upload default to 10kpbs, else enter your own
function tsm-limitupload()     { transmission-remote --uplimit "${@:-10}" ; }
function tsm-limitupload-inf() { transmission-remote --no-uplimit ; }
function tsm-reannounce()      { transmission-remote -t"$1" --reannounce ; }
function tsm-daemon()          { transmission-daemon ; }
function tsm-quit()            { killall transmission-daemon ; }
function tsm-add()             { transmission-remote --add "$1" ; }
# Desc: adding via hash info
function tsm-hash()            { transmission-remote --add "magnet:?xt=urn:btih:$1" ; }
function tsm-verify()          { transmission-remote --verify "$1" ; }
# Usage: <id> or all
function tsm-pause()           { transmission-remote -t"$1" --stop ; }
# Usage: <id> or all
function tsm-start()           { transmission-remote -t"$1" --start ; }
# Desc: remove torrent file and delete download
function tsm-purge()           { transmission-remote -t"$1" --remove-and-delete ; }
# Desc: remove torrent file, leave download
function tsm-remove() { transmission-remote -t"$1" --remove ; }
function tsm-info()   { transmission-remote -t"$1" --info ; }
function tsm-grep()   { transmission-remote --list | rg -i "$1" ; }
function tsm()        { transmission-remote --list ; }
function tsm-show()   { transmission-show "$1"; }
function tsm-tui()    { tide; }
function tsm-stui()   { stig; }

export PATH_ARIA_DAEMON_DOWNLOAD_DIR="$HOME/Downloads/Aria"

function dad-start() { dad -d "$PATH_ARIA_DAEMON_DOWNLOAD_DIR" start ;}
function dad-stop() { dad stop ;}

alias mag2torr="aria2c -q --bt-metadata-only --bt-save-metadata"
function aria2c-quit() {
   killall aria2c
   kill $(ps -ef | rg '[h]ttp.server' | awk '{print $2}')
   #kill $(ps -ef | rg '[S]impleHTTPServer' | awk '{print $2}')
}

function aria2c-webui() {
    local dldir webdir
    # download location
    dldir="$HOME/Downloads"

    # run as daemon
    aria2c --enable-rpc --rpc-listen-all -D -d "$dldir"

    # use python simplehttpserver to host the webui
    # this avoids download the index.html file on each computer
    # https://github.com/ziahamza/webui-aria2

    # path to the webui index.html TODO:
    # webdir=~/.bin/webui-aria2/docs/

    # webui-aria2c uses port 6800 so we use 6801 for python_simple_http_server
    integer port; port=6801
    cd "$webdir"
    nohup python3 -m http.server "$port" >/dev/null 2>&1&
    echo "connect via http://localhost:$port or http://ip_address_of_server:$port"
}

function pick_torrent() {
    LBUFFER="transmission-remote -t ${$({
      for torrent in ${(f)"$(transmission-remote -l)"}; do
          torrent_name=$torrent[73,-1]
          [[ $torrent_name != (Name|) ]] && echo ${${${(s. .)torrent}[1]}%\*} $torrent_name
      done
  } | fzf)%% *} -"
}
zle -N pick-torrent-zle
Zkeymaps+=('C-x t' pick-torrent-zle)
