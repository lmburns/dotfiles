local -a cmds
local cmd

if (( $+commands[grc] )); then
  cmds=(
    blkid
    cc gcc g++ c++
    configure
    curl
    df
    docker docker-compose
    du
    env
    fdisk
    findmnt
    free
    id
    iostat sar
    ip
    iptables
    # iwconfig
    # journalctl
    lsattr
    lsblk
    lsmod
    lsof
    lspci
    make gmake bear
    mount
    nmap
    ping
    ps
    ss
    stat
    sysctl
    systemctl
    traceroute
    trash-list
    uptime
    vmstat
    # whois
  )

  for cmd ($cmds) {
    if (( $+commands[$cmd] )) ; then
       eval "function $cmd() { stdbuf -oL grc --colour=auto $cmd \$@ }"
    fi
  }
fi

# vim: ft=zsh:et:sw=2:ts=2:sts=-1:tw=100
