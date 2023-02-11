let commands = [ 'arch', 'awk', 'b2sum', 'base32', 'base64', 'basename', 'basenc', 'bash', 'brew', 'cat', 'chcon', 'chgrp', 'chown', 'chroot', 'cksum', 'column', 'comm', 'cp', 'csplit', 'curl', 'cut', 'date', 'dd', 'defaults', 'df', 'dir', 'dircolors', 'dirname', 'ed', 'env', 'expand', 'factor', 'fmt', 'fold', 'git', 'grep', 'groups', 'head', 'hexdump', 'hostid', 'hostname', 'hugo', 'id', 'install', 'join', 'killall', 'link', 'ln', 'logname', 'md5sum', 'mkdir', 'mkfifo', 'mknod', 'mktemp', 'nice', 'nl', 'nohup', 'npm', 'nproc', 'numfmt', 'od', 'open', 'paste', 'pathchk', 'pr', 'printenv', 'printf', 'ptx', 'readlink', 'realpath', 'rg', 'runcon', 'scutil', 'sed', 'seq', 'sha1sum', 'sha2', 'shred', 'shuf', 'sort', 'split', 'stat', 'stdbuf', 'stty', 'sudo', 'sum', 'sync', 'tac', 'tee', 'terminfo', 'timeout', 'tmux', 'top', 'touch', 'tput', 'tr', 'truncate', 'tsort', 'tty', 'uname', 'unexpand', 'uniq', 'unlink', 'uptime', 'users', 'vdir', 'vim', 'wc', 'who', 'whoami', 'yabai', 'yes' ]

for i in commands
  execute 'syn match shStatement "\v(\w|-)@<!'
        \ . i
        \ . '(\w|-)@!" containedin=shFunctionOne,shIf,shCmdParenRegion,shCommandSub,zshBrackets'
endfor
