#===========================================================================
#    @author: Lucas Burns <burnsac@me.com> [lmburns]                       #
#   @created: 2023-08-11                                                   #
#    @module: gvariables                                                   #
#      @desc: Variables that aren needed for startup                       #
#===========================================================================

typeset -gx ABSD=${${(M)OSTYPE:#*(darwin|bsd)*}:+1}
typeset -ga histignore=(youtube-dl you-get yt-dlp history exit)
typeset -g DIRSTACKSIZE=20
typeset -g SAVEHIST=$(( 10 ** 7 ))  # 10_000_000
typeset -g HISTSIZE=$(( 1.2 * SAVEHIST ))
typeset -g HISTFILE="${XDG_CACHE_HOME}/zsh/zsh_history"
typeset -g HIST_STAMPS="yyyy-mm-dd"
typeset -g LISTMAX=50                         # Size of asking history
typeset -g ZLE_REMOVE_SUFFIX_CHARS=$' \t\n;)' # Don't eat space with | with tabs
typeset -g ZLE_SPACE_SUFFIX_CHARS=$'&|'
typeset -g MAILCHECK=0                 # Don't check for mail
typeset -g KEYTIMEOUT=25               # Key action time
typeset -g FCEDIT=$EDITOR              # History editor
typeset -g READNULLCMD=$PAGER          # Read contents of file with <file
typeset -g TMPPREFIX="${TMPDIR%/}/zsh" # Temporary file prefix for zsh
typeset -g PROMPT_EOL_MARK="%F{14}⏎%f" # Show non-newline ending # no_prompt_cr
# typeset -g REPORTTIME=5 # report about cpu/system/user-time of command if running longer than 5 seconds
# typeset -g LOGCHECK=0   # interval in between checks for login/logout activity
typeset -g PERIOD=3600                    # how often to execute $periodic
function periodic() { builtin rehash; }   # this overrides the $periodic_functions hooks
watch=(notme)

# Various highlights for CLI
typeset -ga zle_highlight=(
  # region:fg="#a89983",bg="#4c96a8"
  # paste:standout
  region:standout
  special:standout
  suffix:bold
  isearch:underline
  paste:none
)

() {
  # local i; i=${(@j::):-%\({1..36}"e,$( echoti cuf 2 ),)"}
  # typeset -g PS4=$'%(?,,\t\t-> %F{9}%?%f\n)'
  # PS4+=$'%2<< %{\e[2m%}%e%22<<             %F{10}%N%<<%f %3<<  %I%<<%b %(1_,%F{11}%_%f ,)'

  declare -g SPROMPT="Correct '%F{17}%B%R%f%b' to '%F{20}%B%r%f%b'? [%F{18}%Bnyae%f%b] : "  # Spelling correction prompt
  declare -g PS2="%F{1}%B>%f%b "  # Secondary prompt
  declare -g RPS2="%F{14}%i:%_%f" # Right-hand side of secondary prompt

  autoload -Uz colors; colors
  local red=$fg_bold[red] blue=$fg[blue] rst=$reset_color
  declare -g TIMEFMT=(
    "$red%J$rst"$'\n'
    "User: $blue%U$rst"$'\t'"System: $blue%S$rst  Total: $blue%*Es$rst"$'\n'
    "CPU:  $blue%P$rst"$'\t'"Mem:    $blue%M MB$rst"
  )
}

# === Custom zsh variables =============================================== [[[
# TODO: use these arrays
declare -gxA Plugs

declare -gAH Zkeymaps_nvo=()
declare -gAH Zkeymaps_n=()
declare -gAH Zkeymaps_v=()
declare -gAH Zkeymaps_o=()
declare -gAH Zkeymaps_i=()

# NOTE: when zsh 5.9.1? comes out, use typeset -n (ptr ref)
# print -- ${${(AP)Zkms[o]}[C-r]}
# print -- ${${(P)${Zkms[o]}}[C-r]}
# : ${${(AAP)Zkms[o]}[C-r]::=val} # FIX:
# : ${(AAP)Zkms[o][C-r]::=val} # FIX:
# : ${(AAP)=Zkms[o]::=${(@Pkv)Zkms[o]} "mode=vicmd C-r" func}
declare -gxA Zkms=(
  nvo Zkeymaps_nvo
  n   Zkeymaps_n
  v   Zkeymaps_v
  o   Zkeymaps_o
  i   Zkeymaps_i
)
declare -gxA Zkeymaps=(
  # nvo Zkeymaps_nvo
  # n   Zkeymaps_n
  # v   Zkeymaps_v
  # o   Zkeymaps_o
  # i   Zkeymaps_i
)

local -a Zinfo_FnDirs=(hooks lib utils wrap widgets zonly)

# Can be used like: ${${(P)Zinfo[dirs]}[cache]}
# Can be used like: ${(@P)Zdirs[fn_t]}
declare -gA Zdirs=(
    home   $ZDOTDIR
    rc     $ZRCDIR
    data   $ZDATADIR
    cache  $ZCACHEDIR
    patch  $ZDOTDIR/patches
    theme  $ZDOTDIR/themes
    plug   $ZDOTDIR/plugins
    snip   $ZDOTDIR/snippets
    func   $ZDOTDIR/functions
    fn_t   Zinfo_FnDirs
)
declare -gxA Zinfo=(
    patchd  $ZDOTDIR/patches
    themed  $ZDOTDIR/themes
    plugd   $ZDOTDIR/plugins
    maps    Zkeymaps
    dirs    Zdirs
)
# ]]]

# === Non-zsh variables that are used later ============================== [[[
typeset -gx RUST_SYSROOT=$(rustc --print sysroot)
typeset -gx RUST_SRC_PATH=$RUST_SYSROOT/lib/rustlib/src
typeset -gx RUSTDOC_DIR=$XDG_DOCUMENTS_DIR/code/rust/docs
# typeset -gx RUSTDOCFLAGS=""
# ]]]

[[ ${(t)sysexits} != *readonly ]] &&
  readonly -ga sysexits=(
    EPERM           "[1]   Operation not permitted"
    ENOENT          "[2]   No such file or directory"
    ESRCH           "[3]   No such process"
    EINTR           "[4]   Interrupted system call"
    EIO             "[5]   I/O error"
    ENXIO           "[6]   No such device or address"
    E2BIG           "[7]   Argument list too long"
    ENOEXEC         "[8]   Exec format error"
    EBADF           "[9]   Bad file number"
    ECHILD          "[10]  No child processes"
    EAGAIN          "[11]  Try again"
    ENOMEM          "[12]  Out of memory"
    EACCES          "[13]  Permission denied"
    EFAULT          "[14]  Bad address"
    ENOTBLK         "[15]  Block device required"
    EBUSY           "[16]  Device or resource busy"
    EEXIST          "[17]  File exists"
    EXDEV           "[18]  Cross-device link"
    ENODEV          "[19]  No such device"
    ENOTDIR         "[20]  Not a directory"
    EISDIR          "[21]  Is a directory"
    EINVAL          "[22]  Invalid argument"
    ENFILE          "[23]  File table overflow"
    EMFILE          "[24]  Too many open files"
    ENOTTY          "[25]  Not a typewriter"
    ETXTBSY         "[26]  Text file busy"
    EFBIG           "[27]  File too large"
    ENOSPC          "[28]  No space left on device"
    ESPIPE          "[29]  Illegal seek"
    EROFS           "[30]  Read-only file system"
    EMLINK          "[31]  Too many links"
    EPIPE           "[32]  Broken pipe"
    EDOM            "[33]  Math argument out of domain of func"
    ERANGE          "[34]  Math result not representable"
    EDEADLK         "[35]  Resource deadlock would occur"
    ENAMETOOLONG    "[36]  File name too long"
    ENOLCK          "[37]  No record locks available"
    ENOSYS          "[38]  Function not implemented"
    ENOTEMPTY       "[39]  Directory not empty"
    ELOOP           "[40]  Too many symbolic links encountered"
    ENOMSG          "[42]  No message of desired type"
    EIDRM           "[43]  Identifier removed"
    ECHRNG          "[44]  Channel number out of range"
    EL2NSYNC        "[45]  Level 2 not synchronized"
    EL3HLT          "[46]  Level 3 halted"
    EL3RST          "[47]  Level 3 reset"
    ELNRNG          "[48]  Link number out of range"
    EUNATCH         "[49]  Protocol driver not attached"
    ENOCSI          "[50]  No CSI structure available"
    EL2HLT          "[51]  Level 2 halted"
    EBADE           "[52]  Invalid exchange"
    EBADR           "[53]  Invalid request descriptor"
    EXFULL          "[54]  Exchange full"
    ENOANO          "[55]  No anode"
    EBADRQC         "[56]  Invalid request code"
    EBADSLT         "[57]  Invalid slot"
    EBFONT          "[59]  Bad font file format"
    ENOSTR          "[60]  Device not a stream"
    ENODATA         "[61]  No data available"
    ETIME           "[62]  Timer expired"
    ENOSR           "[63]  Out of streams resources"
    ENONET          "[64]  Machine is not on the network"
    ENOPKG          "[65]  Package not installed"
    EREMOTE         "[66]  Object is remote"
    ENOLINK         "[67]  Link has been severed"
    EADV            "[68]  Advertise error"
    ESRMNT          "[69]  Srmount error"
    ECOMM           "[70]  Communication error on send"
    EPROTO          "[71]  Protocol error"
    EMULTIHOP       "[72]  Multihop attempted"
    EDOTDOT         "[73]  RFS specific error"
    EBADMSG         "[74]  Not a data message"
    EOVERFLOW       "[75]  Value too large for defined data type"
    ENOTUNIQ        "[76]  Name not unique on network"
    EBADFD          "[77]  File descriptor in bad state"
    EREMCHG         "[78]  Remote address changed"
    ELIBACC         "[79]  Can not access a needed shared library"
    ELIBBAD         "[80]  Accessing a corrupted shared library"
    ELIBSCN         "[81]  .lib section in a.out corrupted"
    ELIBMAX         "[82]  Attempting to link in too many shared libraries"
    ELIBEXEC        "[83]  Cannot exec a shared library directly"
    EILSEQ          "[84]  Illegal byte sequence"
    ERESTART        "[85]  Interrupted system call should be restarted"
    ESTRPIPE        "[86]  Streams pipe error"
    EUSERS          "[87]  Too many users"
    ENOTSOCK        "[88]  Socket operation on non-socket"
    EDESTADDRREQ    "[89]  Destination address required"
    EMSGSIZE        "[90]  Message too long"
    EPROTOTYPE      "[91]  Protocol wrong type for socket"
    ENOPROTOOPT     "[92]  Protocol not available"
    EPROTONOSUPPORT "[93]  Protocol not supported"
    ESOCKTNOSUPPORT "[94]  Socket type not supported"
    EOPNOTSUPP      "[95]  Operation not supported on transport endpoint"
    EPFNOSUPPORT    "[96]  Protocol family not supported"
    EAFNOSUPPORT    "[97]  Address family not supported by protocol"
    EADDRINUSE      "[98]  Address already in use"
    EADDRNOTAVAIL   "[99]  Cannot assign requested address"
    ENETDOWN        "[100] Network is down"
    ENETUNREACH     "[101] Network is unreachable"
    ENETRESET       "[102] Network dropped connection because of reset"
    ECONNABORTED    "[103] Software caused connection abort"
    ECONNRESET      "[104] Connection reset by peer"
    ENOBUFS         "[105] No buffer space available"
    EISCONN         "[106] Transport endpoint is already connected"
    ENOTCONN        "[107] Transport endpoint is not connected"
    ESHUTDOWN       "[108] Cannot send after transport endpoint shutdown"
    ETOOMANYREFS    "[109] Too many references: cannot splice"
    ETIMEDOUT       "[110] Connection timed out"
    ECONNREFUSED    "[111] Connection refused"
    EHOSTDOWN       "[112] Host is down"
    EHOSTUNREACH    "[113] No route to host"
    EALREADY        "[114] Operation already in progress"
    EINPROGRESS     "[115] Operation now in progress"
    ESTALE          "[116] Stale NFS file handle"
    EUCLEAN         "[117] Structure needs cleaning"
    ENOTNAM         "[118] Not a XENIX named type file"
    ENAVAIL         "[119] No XENIX semaphores available"
    EISNAM          "[120] Is a named type file"
    EREMOTEIO       "[121] Remote I/O error"
    EDQUOT          "[122] Quota exceeded"
    ENOMEDIUM       "[123] No medium found"
    EMEDIUMTYPE     "[124] Wrong medium type"
    ECANCELED       "[125] Operation Canceled"
    ENOKEY          "[126] Required key not available"
    EKEYEXPIRED     "[127] Key has expired"
    EKEYREVOKED     "[128] Key has been revoked"
    EKEYREJECTED    "[129] Key was rejected by service"
    EOWNERDEAD      "[130] Owner died"
    ENOTRECOVERABLE "[131] State not recoverable"

    EUSAGE          "[132] "
    EDATAERR        "[133] "
    ENOINPUT        "[134] "
    ENOUSER         "[135] "
    EUNAVAILABLE    "[136] "
    ESOFTWARE       "[137] "
    EOSERR          "[138] "
    EOSFILE         "[139] "
    ECANTCREAT      "[140] "
    EIOERR          "[141] "
    ETEMPFAIL       "[142] "
    ECONFIG         "[143] "
  )
