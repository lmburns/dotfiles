#===========================================================================
#    @author: Lucas Burns <burnsac@me.com> [lmburns]                       #
#   @created: 2021-10-18                                                   #
#    @module: lf                                                           #
#      @desc: Functions and variables for lf file manager                  #
#===========================================================================

emulate -L zsh -o extendedglob -o noshortloops -o warncreateglobal
zmodload -Fa zsh/parameter p:functions

typeset -g REPLY
typeset -ga discard_fn
discard_fn=( gen_lf_colors )
trap "unset -f -- \"\${discard_fn[@]}\" &>/dev/null; unset discard_fn" EXIT

local function gen_lf_colors() {
  # This string is later evaluated to be used as an array
  REPLY="typeset -gxA $1; $1=(
    1  $'\e[38;5;1m'  2  $'\e[38;5;2m'  3   $'\e[38;5;3m'
    4  $'\e[38;5;4m'  5  $'\e[38;5;5m'  6   $'\e[38;5;6m'
    7  $'\e[38;5;7m'  8  $'\e[38;5;8m'  9   $'\e[38;5;9m'
    10 $'\e[38;5;10m' 11 $'\e[38;5;11m' 12  $'\e[38;5;12m'
    13 $'\e[38;5;13m' 14 $'\e[38;5;14m' 15  $'\e[38;5;15m'
    16 $'\e[38;5;16m' 17 $'\e[38;5;17m' 18  $'\e[38;5;18m'
    19 $'\e[38;5;19m' 20 $'\e[38;5;20m' 21  $'\e[38;5;21m'
    22 $'\e[38;5;22m' 23 $'\e[38;5;23m' 24  $'\e[38;5;24m'
    25 $'\e[38;5;25m' 26 $'\e[38;5;26m' 27  $'\e[38;5;27m'
    28 $'\e[38;5;28m' 29 $'\e[38;5;29m' 30  $'\e[38;5;30m'
    31 $'\e[38;5;31m' 32 $'\e[38;5;32m' 33  $'\e[38;5;33m'
    42 $'\e[38;5;42m' 43 $'\e[38;5;43m' 44  $'\e[38;5;44m'
    45 $'\e[38;5;45m' 46 $'\e[38;5;46m' 47  $'\e[38;5;47m'
    48 $'\e[38;5;48m' 49 $'\e[38;5;49m' 50  $'\e[38;5;50m'
    51 $'\e[38;5;51m' 52 $'\e[38;5;52m' 53  $'\e[38;5;53m'
  'U' $'\e[4m'      'B' $'\e[1m'      'bg' $'\e[3m'
  'tb' $' \t '      'nl' $'\n'        'res' $'\e[0m'
  'it' $'\e[3m'     'st' $'\e[9m'     'rnl' $'\e[0m\n'
  'ul' $'\e[4m'      'b' $'\e[1m'        0  $'\e[0m'
  )"
}

gen_lf_colors "c"
export LF_CARRAY="$REPLY"
gen_lf_colors "COLORS"
export LF_COLOR_ARRAY="$REPLY"
eval "$LF_COLOR_ARRAY"                                          # Evaluated now and later on in LF

# export LF_COLOR_ARRAY="typeset -gxA COLORS; COLORS=(
#   1  $'\e[38;5;1m'  2  $'\e[38;5;2m'  3   $'\e[38;5;3m'
#   4  $'\e[38;5;4m'  5  $'\e[38;5;5m'  6   $'\e[38;5;6m'
#   7  $'\e[38;5;7m'  8  $'\e[38;5;8m'  9   $'\e[38;5;9m'
#   10 $'\e[38;5;10m' 11 $'\e[38;5;11m' 12  $'\e[38;5;12m'
#   13 $'\e[38;5;13m' 14 $'\e[38;5;14m' 15  $'\e[38;5;15m'
#   16 $'\e[38;5;16m' 17 $'\e[38;5;17m' 18  $'\e[38;5;18m'
#   19 $'\e[38;5;19m' 20 $'\e[38;5;20m' 21  $'\e[38;5;21m'
#   22 $'\e[38;5;22m' 23 $'\e[38;5;23m' 24  $'\e[38;5;24m'
#   25 $'\e[38;5;25m' 26 $'\e[38;5;26m' 27  $'\e[38;5;27m'
#   28 $'\e[38;5;28m' 29 $'\e[38;5;29m' 30  $'\e[38;5;30m'
#   31 $'\e[38;5;31m' 32 $'\e[38;5;32m' 33  $'\e[38;5;33m'
#   42 $'\e[38;5;42m' 43 $'\e[38;5;43m' 44  $'\e[38;5;44m'
#   45 $'\e[38;5;45m' 46 $'\e[38;5;46m' 47  $'\e[38;5;47m'
#   48 $'\e[38;5;48m' 49 $'\e[38;5;49m' 50  $'\e[38;5;50m'
#   51 $'\e[38;5;51m' 52 $'\e[38;5;52m' 53  $'\e[38;5;53m'
#  'U' $'\e[4m'      'B' $'\e[1m'      'bg' $'\e[3m'
# 'tb' $' \t '      'nl' $'\n'        'res' $'\e[0m'
# 'it' $'\e[3m'     'st' $'\e[9m'     'rnl' $'\e[0m\n'
# 'ul' $'\e[4m'      'b' $'\e[1m'        0  $'\e[0m'
# )"
#
# # Evaluated now and later on in LF
# eval "$LF_COLOR_ARRAY"
#
# export LF_CARRAY="typeset -gxA c; c=(
#   1  $'\e[38;5;1m'  2  $'\e[38;5;2m'  3   $'\e[38;5;3m'
#   4  $'\e[38;5;4m'  5  $'\e[38;5;5m'  6   $'\e[38;5;6m'
#   7  $'\e[38;5;7m'  8  $'\e[38;5;8m'  9   $'\e[38;5;9m'
#   10 $'\e[38;5;10m' 11 $'\e[38;5;11m' 12  $'\e[38;5;12m'
#   13 $'\e[38;5;13m' 14 $'\e[38;5;14m' 15  $'\e[38;5;15m'
#   16 $'\e[38;5;16m' 17 $'\e[38;5;17m' 18  $'\e[38;5;18m'
#   19 $'\e[38;5;19m' 20 $'\e[38;5;20m' 21  $'\e[38;5;21m'
#   22 $'\e[38;5;22m' 23 $'\e[38;5;23m' 24  $'\e[38;5;24m'
#   25 $'\e[38;5;25m' 26 $'\e[38;5;26m' 27  $'\e[38;5;27m'
#   28 $'\e[38;5;28m' 29 $'\e[38;5;29m' 30  $'\e[38;5;30m'
#   31 $'\e[38;5;31m' 32 $'\e[38;5;32m' 33  $'\e[38;5;33m'
#   42 $'\e[38;5;42m' 43 $'\e[38;5;43m' 44  $'\e[38;5;44m'
#   45 $'\e[38;5;45m' 46 $'\e[38;5;46m' 47  $'\e[38;5;47m'
#   48 $'\e[38;5;48m' 49 $'\e[38;5;49m' 50  $'\e[38;5;50m'
#   51 $'\e[38;5;51m' 52 $'\e[38;5;52m' 53  $'\e[38;5;53m'
#  'U' $'\e[4m'      'B' $'\e[1m'      'bg' $'\e[3m'
# 'tb' $' \t '      'nl' $'\n'        'res' $'\e[0m'
# 'it' $'\e[3m'     'st' $'\e[9m'     'rnl' $'\e[0m\n'
# 'ul' $'\e[4m'      'b' $'\e[1m'        0  $'\e[0m'
# )"

export LF_FZF_OPTS="$FZF_DEFAULT_OPTS --height=100% +m"         # Maximize FZF output
export LF_DIRSTACK_FILE="${XDG_DATA_HOME}/lf/chpwd-recent-dirs" # Use different dirstack
export LF_COLORS="$(vivid -d $ZDOTDIR/zsh.d/vivid/filetypes.yml generate $ZDOTDIR/zsh.d/vivid/kimbie.yml)"

# lc() { local __="$(mktemp)" && lf -last-dir-path="$__" "$@";
# d="${"$(<$__)"}" && chronic rm -f "$__" && [ -d "$d" ] && cd "$d"; }'

# @desc lf removes mounted file systems, stay in lf's CWD
function lc() {
  emulate -L zsh
  local tmp==()
  local fid==()
  trap "command rm -rf $tmp $fid" EXIT INT
  command lf -command '$printf $id > '"$fid"'' -last-dir-path="$tmp" "$@"
  local id="${"$(<$fid)"}"
  local archivemount_dir="/tmp/__lf_archivemount_${id}"
  if [[ -f "$archivemount_dir" ]] {
    while read -r line; do
      dunstify "Unmounted" "${line:h:t}/${line:t}"
      fusermount -u "$line"
      command rmdir "$line"
    done <<< ${"$(<$archivemount_dir)"}
   command rm -f "$archivemount_dir"
  }
  if [[ -f "$tmp" ]] {
    local dir="${"$(<$tmp)"}"
    [[ -d "$dir" && "$dir" != "$PWD" ]] && builtin cd "$dir"
  }
}

function xd() {
  pth="$(xplr)"
  if [[ "$pth" != "$PWD" ]]; then
    if [[ -d "$pth" ]]; then
      cd "$pth"
    elif [[ -f "$pth" ]]; then
      cd "$(dirname "$pth")"
    fi
  fi
}

export LF_ICONS="\
tw=:\
st=:\
ow=:\
dt=:\
di=:\
fi=:\
ln=:\
or=:\
ex=:\
*.CFUserTextEncoding=:\
*.DS_store=:\
*.apple=:\
*.applescript=:\
*.ds_store=:\
*.icloud=:\
*.localized=:\
*.swift=:\
*.xcplayground=:\
*.ai=:\
*.android=:\
*.apk=:\
*.aspk=:\
*.gradle=:\
*.asa=:\
*.as=:\
*.clj=:\
*.cljc=:\
*.cljs=:\
*.edn=:\
*.cls=:\
*.coffee=:\
*.cr=:\
*.cfg=:\
*.conf=:\
*.mk=:\
*.toml=:\
*.rasi=:\
*.yaml=:\
*.yml=:\
*.editorconfig=:\
*.kdevelop=:\
*.pro=:\
*.sln=:\
*.suo=:\
*CMakeLists.txt=:\
*CMakeCache.txt=:\
*cmakelists.txt=:\
*cmakecache.txt=:\
*.bat=:\
*.cab=:\
*.cmd=:\
*.dll=:\
*.exe=:\
*.ini=:\
*.msi=:\
*.windows=:\
*.ps1=:\
*.psm1=:\
*.psd1=:\
*.c++=:\
*.c=:\
*.cc=:\
*.clang-format=:\
*.cp=:\
*.cpp=:\
*.cxx=:\
*.def=:\
*.h++=:\
*.h=:\
*.hh=:\
*.hpp=:\
*.hxx=:\
*.inc=:\
*.inl=:\
*.ipp=:\
*.m=:\
*.mm=:\
*.o=:\
*.la=:\
*.lo=:\
*.bc=﴾:\
*.ll=﴾:\
*.mir=﴾:\
*.cs=:\
*.csproj=:\
*.csx=:\
*.csv=:\
*.gsheet=:\
*.ods=:\
*.tsv=:\
*.xls=:\
*.xlsx=:\
*.d=:\
*.di=:\
*.dart=:\
*.db=:\
*.dump=:\
*.log=:\
*.sql=:\
*.sqlite=:\
*.sqlite3=:\
*.dot=:\
*.gv=:\
*.diff=:\
*.patch=:\
*.djvu=:\
*.elm=:\
*.env=:\
*.erl=:\
*.hrl=:\
*.ex=:\
*.exs=:\
*.eex=:\
*.leex=:\
*.heex=:\
*mix.lock=:\
*.f#=:\
*.fsscript=:\
*.fsproj=:\
*.fs=:\
*.fsi=:\
*.fsx=:\
*.gform=:\
*.git=:\
*.gitattributes=:\
*.gitconfig=:\
*.gitignore=:\
*.gitlab-ci.yml=:\
*.gitmodules=:\
*.go=:\
*go.mod=:\
*go.sum=:\
*.groovy=:\
*.gvy=:\
*.mustache=:\
*.hbs=:\
*.haml=:\
*.cabal=:\
*.hs=:\
*.lhs=:\
*.dyn_hi=:\
*.dyn_o=:\
*.cache=:\
*.hi=:\
*.htm=:\
*.html=:\
*.xhtml=:\
*.cshtml=:\
*.razor=:\
*.asp=:\
*.aspx=:\
*.css=:\
*.scss=:\
*.iml=:\
*.iso=:\
*.jar=:\
*.java=:\
*.bsh=:\
*.class=:\
*.jad=:\
*.war=:\
*.jl=:\
*.graphql=:\
*.htc=:\
*.js=:\
*.jsx=:\
*.mjs=:\
*.ts=:\
*.tsx=:\
*React.jsx=:\
*angular.min.js=:\
*backbone.min.js=:\
*favicon.ico=:\
*gruntfile.coffee=:\
*gruntfile.js=:\
*gruntfile.ls=:\
*gulpfile.coffee=:\
*gulpfile.js=:\
*gulpfile.ls=:\
*jquery.min.js=:\
*materialize.min.css=:\
*materialize.min.js=:\
*mootools.min.js=:\
*node_modules=:\
*react.jsx=:\
*require.min.js=:\
*robots.txt=ﮧ:\
*.ejs=:\
*.avro=:\
*.json=:\
*.jq=:\
*.properties=:\
*.webmanifest=:\
*.kt=:\
*.kts=:\
*.less=:\
*.lisp=ﬦ:\
*.el=ﬦ:\
*.license=:\
*LICENSE=:\
*license=:\
*.lock=:\
*.bak=:\
*.lua=:\
*.lua-format=:\
*.luarc.jsonc=:\
*.luacheckrc=:\
*.rockspec=:\
*.tl=:\
*.fnl=:\
*.moon=:\
*.markdown=:\
*.md=:\
*.mdown=:\
*.mdx=:\
*.rmd=:\
*.mkd=:\
*.rdoc=:\
*.readme=:\
*.ml=λ:\
*.mli=λ:\
*.nim=:\
*.aac=:\
*.au=:\
*.aif=:\
*.flac=:\
*.m4a=:\
*.mid=:\
*.midi=:\
*.mka=:\
*.mp3=:\
*.mpc=:\
*.oga=:\
*.ogg=:\
*.opus=:\
*.ra=:\
*.spx=:\
*.wav=:\
*.wma=:\
*.wv=:\
*.xspf=:\
*.avi=:\
*.flv=:\
*.h264=:\
*.m4v=:\
*.mkv=:\
*.mov=:\
*.mp4=:\
*.mp4v=:\
*.mpeg=:\
*.mpg=:\
*.ogv=:\
*.ogx=:\
*.rm=:\
*.swf=:\
*.video=:\
*.vob=:\
*.webm=:\
*.wmv=:\
*.nb=:\
*.nix=:\
*.node=:\
*.npmignore=:\
*.doc=:\
*.docx=:\
*.gdoc=:\
*.odt=:\
*.ps=:\
*.rtf=:\
*.sxw=:\
*.ebook=:\
*.epub=:\
*.mobi=:\
*.eot=:\
*.font=:\
*.fnt=:\
*.fon=:\
*.otf=:\
*.ttf=:\
*.woff2=:\
*.woff=:\
*.p=:\
*.pas=:\
*.dpr=:\
*.pdf=:\
*.pem=:\
*.php=:\
*.pl=:\
*.pm=:\
*.t=:\
*.cgi=:\
*.pod=:\
*.asf=:\
*.bmp=:\
*.cgm=:\
*.dl=:\
*.emf=:\
*.eps=:\
*.flc=:\
*.fli=:\
*.gif=:\
*.gl=:\
*.ico=:\
*.image=:\
*.jfi=:\
*.jfif=:\
*.jif=:\
*.jpe=:\
*.jpeg=:\
*.jpg=:\
*.m2v=:\
*.mjpeg=:\
*.mjpg=:\
*.mng=:\
*.nuv=:\
*.ogm=:\
*.pbm=:\
*.pcx=:\
*.pgm=:\
*.png=:\
*.ppm=:\
*.psb=:\
*.psd=:\
*.pxm=:\
*.qt=:\
*.rmvb=:\
*.svg=:\
*.svgz=:\
*.tga=:\
*.tif=:\
*.tiff=:\
*.webp=:\
*.xbm=:\
*.xcf=:\
*.xpm=:\
*.xwd=:\
*.yuv=:\
*.purs=:\
*.pp=:\
*.epp=:\
*.gslides=:\
*.odp=:\
*.ppt=:\
*.pptx=:\
*.py=:\
*.pyc=:\
*.pyd=:\
*.pyo=:\
*.ipynb=:\
*.flake8=:\
*flake8=:\
*setup.py=:\
*MANIFEST.in=:\
*requirements.txt=:\
*.matlab=:\
*.m=:\
*.mn=:\
*.r=ﳒ:\
*.rdata=:\
*.rds=:\
*.rproj=鉶:\
*.gem=:\
*.gemfile=:\
*.gemspec=:\
*.guardfile=:\
*.procfile=:\
*.rake=:\
*.rakefile=:\
*.rb=:\
*.rbs=:\
*.rspec=:\
*.rspec_parallel=:\
*.rspec_status=:\
*.ru=:\
*Gemfile=:\
*Rakefile=:\
*config.ru=:\
*gemfile=:\
*rakefile=:\
*.rubydoc=:\
*.erb=:\
*.slim=:\
*.rhtml=:\
*.res=:\
*.crdownload=:\
*.torrent=:\
*.magnet=:\
*.bak=:\
*.orig=:\
*.pid=:\
*.swp=:\
*.tmp=:\
*package-lock.json=:\
*.rdb=:\
*.rs=:\
*.rlib=:\
*.rss=:\
*CODEOWNERS=:\
*.ignore=:\
*.cvsignore=:\
*.dockerignore=:\
*.eslintignore=:\
*.fdignore=:\
*.rgignore=:\
*.styluaignore=:\
*.sass=:\
*.scala=:\
*.sbt=:\
*.awk=:\
*.sh=:\
*.shell=:\
*.fish=:\
*.bash=:\
*.bash_history=:\
*.bash_profile=:\
*.bashrc=:\
*.ksh=:\
*.csh=:\
*.so=:\
*.sol=ﲹ:\
*.styl=:\
*.stylus=:\
*.deb=:\
*.rpm=:\
*.7z=:\
*.ace=:\
*.alz=:\
*.arc=:\
*.arj=:\
*.bz2=:\
*.bz=:\
*.cpio=:\
*.dwm=:\
*.dz=:\
*.ear=:\
*.esd=:\
*.gz=:\
*.lha=:\
*.lrz=:\
*.lz4=:\
*.lz=:\
*.lzh=:\
*.lzma=:\
*.lzo=:\
*.rar=:\
*.rz=:\
*.sar=:\
*.swm=:\
*.t7z=:\
*.tar=:\
*.taz=:\
*.tbz2=:\
*.tbz=:\
*.tgz=:\
*.tlz=:\
*.txz=:\
*.tz=:\
*.tzo=:\
*.tzst=:\
*.wim=:\
*.xz=:\
*.z=:\
*.zip=:\
*.zoo=:\
*.zst=:\
*.latex=:\
*.tex=ﭨ:\
*.ltx=ﭨ:\
*.aux=ﭨ:\
*.bbl=ﭨ:\
*.bcf=ﭨ:\
*.blg=ﭨ:\
*.fdb_latexmk=ﭨ:\
*.fls=ﭨ:\
*.idx=ﭨ:\
*.ilg=ﭨ:\
*.ind=ﭨ:\
*.out=ﭨ:\
*.synctex.gz=ﭨ:\
*.toc=ﭨ:\
*.sty=:\
*.twig=:\
*.txt=:\
*.td=:\
*.tcl=:\
*.vb=亮:\
*.gvimrc=:\
*.vim=:\
*.vimrc=:\
*gvimrc=:\
*vimrc=:\
*.vue=﵂:\
*.xml=謹:\
*.pubxml=謹:\
*.xul=謹:\
*.zig=:\
*.zlogin=:\
*.zlogout=:\
*.zprofile=:\
*.zsh-theme=:\
*.zsh=:\
*.zshenv=:\
*.zshrc=:\
*zshrc=:\
*zshenv=:\
*.zwc=:\
*.ztst=:\
*.zcompdump=:\
*.1=ﯹ:\
*.2=ﯹ:\
*.3=ﯹ:\
*.4=ﯹ:\
*.5=ﯹ:\
*Doxyfile=:\
*doxyfile=:\
*.dox=:\
*Docker-compose.yml=:\
*Dockerfile=:\
*docker-compose.yml=:\
*dockerfile=:\
*Dropbox=:\
*dropbox=:\
*Gruntfile.coffee=:\
*Gruntfile.js=:\
*Gruntfile.ls=:\
*Gulpfile.coffee=:\
*Gulpfile.js=:\
*Gulpfile.ls=:\
*Makefile=:\
*Makefile.in=:\
*makefile=:\
*Justfile=:\
*justfile=:\
*Procfile=:\
*procfile=:\
*Vagrantfile=:\
*rc=:\
*=:"

# .scm
# .re

# vim: ft=zsh:et:sw=0:ts=2:sts=2:
