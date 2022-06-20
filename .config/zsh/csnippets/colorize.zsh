local -a cmds
local cmd

if (( $+commands[grc] )); then
  cmds=(
    ping
    traceroute
    cc gcc g++ c++
    make gmake bear
    stat
    ss
    mount
    findmnt
    ps
    df
    du
    ip
    env
    systemctl
    iptables
    lspci
    lsblk
    lsof
    blkid
    id
    iostat sar
    fdisk
    docker docker-compose
    sysctl
    lsmod
    lsattr
    vmstat
    free
    nmap
    uptime
    trash-list
  )

  for cmd ($cmds) {
    if (( $+commands[$cmd] )) ; then
       eval "function $cmd() { stdbuf -oL grc --colour=auto $cmd \$@ }"
    fi
  }
fi

# vim: ft=zsh:et:sw=2:ts=2:sts=-1:tw=100
