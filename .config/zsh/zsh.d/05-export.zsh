#===========================================================================
#    @author: Lucas Burns <burnsac@me.com> [lmburns]                       #
#   @created: 2023-08-11                                                   #
#    @module: gvariables                                                   #
#      @desc: Variables that aren needed for startup                       #
#===========================================================================

declare -gx ABSD=${${(M)OSTYPE:#*(darwin|bsd)*}:+1}
declare -gx GENCOMP_DIR="$Zdirs[COMPL]"
declare -gx GENCOMPL_FPATH="$GENCOMP_DIR"
declare -gx ZLOGF="${Zdirs[CACHE]}/my-zsh.log"
declare -gx LFLOGF="${Zdirs[CACHE]}/lf-zsh.log"

typeset -g SAVEHIST=$(( 10 ** 7 ))  # 10_000_000
typeset -g HISTSIZE=$(( 1.2 * SAVEHIST ))
typeset -g HISTFILE="${Zdirs[CACHE]}/history"
typeset -g HIST_STAMPS="yyyy-mm-dd"
typeset -g HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1 # all search results returned will be unique NOTE: for what

typeset -g DIRSTACKSIZE=20
typeset -g LISTMAX=50                               # Size of asking history
typeset -g ZLE_REMOVE_SUFFIX_CHARS=$' \t\n;)'       # Don't eat space with | with tabs
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

# ls lse ls@ ls. lsl lsS lsX lsr
# ll lla lls llb llr llsr lle ll.
# lj lp lpo
# lsm lsmr lsmo lsmn
# lsc lscr lsco lscn
# lsb lsbr lsbo lsbn
# lsat lsbt lsa2 lsb2
# lsa lsao lsan
# lst lsts lstx lstl lstr
# lsd lsdl lsdo lsdn lsde lsdf lsd2
# lsz lszr lszb lszs lsz0 lsze
# lss lssa
# lsur
typeset -ga histignore=(
  # mv cp cat bat vi vim nvim cd rm pushd popd
  youtube-dl you-get yt-dlp history exit tree tmux exit clear reset bg fg pwd
  'ls[sSXletr.@]'
  'll(|[abre.][r]#)'
  'l[pj][o]#'
  'lsm[ron]#'
  'lsc[ron]#'
  'lsb[ron]#'
  'ls[ab][t2]'
  'lsa[on]#'
  'lst[sxlr]#'
  'lsd[lonef2]#'
  'lsz[rbs0e]#'
  'lss[a]#'
  'lsur'
)

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

declare -gAH Zkeymaps_n=()
declare -gAH Zkeymaps_v=()
declare -gAH Zkeymaps_o=()
declare -gAH Zkeymaps_i=()
declare -gAH Zkeymaps_nvo=()

# NOTE: when zsh 5.9.1? comes out, use typeset -n (ptr ref)
#       This array is used for testing now. Zkeymaps is the one used
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
declare -gxA Zkeymaps=()
declare -gxA Zfiles=(
  CHPWD  $Zdirs[CACHE]/chpwd-recent-dirs
)
declare -gxA Zinfo=(
  MAPS    Zkeymaps
  DIRS    Zdirs
  FILES   Zfiles
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
    {1..63}
    # sysexits(3)
    EX_USAGE        # "[64] Command used incorrectly"
    EX_DATAERR      # "[65] Input data was incorrect in some way"
    EX_NOINPUT      # "[66] Input file not readable/doesn't exist"
    EX_NOUSER       # "[67] User specified doesn't exist"
    EX_NOHOST       # "[68] Host specified doesn't exist"
    EX_UNAVAILABLE  # "[69] Service is unavailable"
    EX_SOFTWARE     # "[70] Internal software error"
    EX_OSERR        # "[71] Operating system error"
    EX_OSFILE       # "[72] System file doesn't exist"
    EX_CANTCREAT    # "[73] User specified output file cannot be created"
    EX_IOERR        # "[74] An I/O error occured"
    EX_TEMPFAIL     # "[75] Temporary failure, meaning not really an error"
    EX_PROTOCOL     # "[76] Remote system had an issue during a protocol exchange"
    EX_NOPERM       # "[77] Didn't have sufficient permissions for operation"
    EX_CONFIG       # "[78] Unconfigured / misconfigured state"
  )
