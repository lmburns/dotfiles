<h1 align="center">dotfiles</h1>

## Contents
+ [Colorscheme](#terminal-colors)
    + [Alacritty Colorscheme](#alacritty)
    + [Neovim Colorscheme](#neovim-color)
+ [AutoKey](#AutoKey)
+ [sxhkd](#sxhkd)
+ [ZSH Functions](#zsh-functions)
+ [Scripts](#scripts)

There are several more configuration file than the ones listed in contents. These are the ones that have been configured the most.

## <a name="terminal-colors"></a>Colorschemes

### <a name="alacritty"></a>Alacritty Colorscheme
+ The actual colors may not match the displayed colors
+ The `alacritty` theme file can be found [here](.config/alacritty/alacritty.yml)

#### Displayed Colors

| {b,f}ground                                               | Red                                                             | Green                                                           | Yellow                                                          | Blue                                                            | Magenta                                                         | Cyan                                                            |
| --------------------------------------------------------------- | --------------------------------------------------------------- | --------------------------------------------------------------- | --------------------------------------------------------------- | --------------------------------------------------------------- | --------------------------------------------------------------- | --------------------------------------------------------------- |
| #221a02                                                         | #dc3958                                                         | #088649                                                         | #f79a32                                                         | #733e8b                                                         | #7e5053                                                         | #088649                                                         |
| ![#221a02](https://via.placeholder.com/80/221a02/000000?text=+) | ![#dc3958](https://via.placeholder.com/80/dc3958/000000?text=+) | ![#088649](https://via.placeholder.com/80/088649/000000?text=+) | ![#f79a32](https://via.placeholder.com/80/f79a32/000000?text=+) | ![#733e8b](https://via.placeholder.com/80/733e8b/000000?text=+) | ![#7e5053](https://via.placeholder.com/80/7e5053/000000?text=+) | ![#088649](https://via.placeholder.com/80/088649/000000?text=+) |
| #c2a383                                                         | #f14a68                                                         | #a3b95a                                                         | #f79a32                                                         | #dc3958                                                         | #fe8019                                                         | #4c96a8                                                         |
| ![#c2a383](https://via.placeholder.com/80/c2a383/000000?text=+) | ![#f14a68](https://via.placeholder.com/80/f14a68/000000?text=+) | ![#a3b95a](https://via.placeholder.com/80/a3b95a/000000?text=+) | ![#f79a32](https://via.placeholder.com/80/f79a32/000000?text=+) | ![#dc3958](https://via.placeholder.com/80/dc3958/000000?text=+) | ![#fe8019](https://via.placeholder.com/80/fe8019/000000?text=+) | ![#4c96a8](https://via.placeholder.com/80/4c96a8/000000?text=+) |


### <a name="neovim-color"></a>Neovim Color

+ Theme: [kimbox](https://github.com/lmburns/kimbox)
+ Install with
```sh
Plug 'lmburns/kimbox'
colorscheme kimbox
```

#### Displayed Colors

| #39260E                                                         | #291804                                                         | #EF1D55                                                         | #DC3958                                                         | #FF5813                                                         | #FF9500                                                         | #819C3B                                                         |
| --------------------------------------------------------------- | --------------------------------------------------------------- | --------------------------------------------------------------- | --------------------------------------------------------------- | --------------------------------------------------------------- | --------------------------------------------------------------- | --------------------------------------------------------------- |
| ![#39260E](https://via.placeholder.com/80/39260E/000000?text=+) | ![#291804](https://via.placeholder.com/80/291804/000000?text=+) | ![#EF1D55](https://via.placeholder.com/80/EF1D55/000000?text=+) | ![#DC3958](https://via.placeholder.com/80/DC3958/000000?text=+) | ![#FF5813](https://via.placeholder.com/80/FF5813/000000?text=+) | ![#FF9500](https://via.placeholder.com/80/FF9500/000000?text=+) | ![#819C3B](https://via.placeholder.com/80/819C3B/000000?text=+) |
| #7EB2B1                                                         | #4C96A8                                                         | #98676A                                                         | #A06469                                                         | #7F5D38                                                         | #A89984                                                         | #D9AE80                                                         |
| ![#7EB2B1](https://via.placeholder.com/80/7EB2B1/000000?text=+) | ![#4C96A8](https://via.placeholder.com/80/4C96A8/000000?text=+) | ![#98676A](https://via.placeholder.com/80/98676A/000000?text=+) | ![#A06469](https://via.placeholder.com/80/A06469/000000?text=+) | ![#7F5D38](https://via.placeholder.com/80/7F5D38/000000?text=+) | ![#A89984](https://via.placeholder.com/80/A89984/000000?text=+) | ![#D9AE80](https://via.placeholder.com/80/D9AE80/000000?text=+) |

---

## <a name="AutoKey"></a>AutoKey

+ [AutoKey](.config/AutoKey/AutoKey.json) configuration file

- AutoKey is a very useful utility on MacOS that allows for global keybindings.
- The keybindings that are there mimic Vim's functionality when holding caps lock.
- When <kbd>⇪ Caps lock</kbd> is held down it is mapped to:
  - <kbd>⌃ Control</kbd> + <kbd>⌥ Option</kbd> + <kbd>⌘ Command</kbd> + <kbd>⇧ Shift</kbd>
- When <kbd>⇪ Caps lock</kbd> is pressed it is mapped to <kbd>⎋ Escape</kbd>
- To get <kbd>⇪ Caps lock</kbd> you need to press left <kbd>⇧ Shift</kbd> then right <kbd>⇧ Shift</kbd>
- While holding <kbd>⇪ Caps lock</kbd>, pressing the following keys will do these actions:

<details>
<summary><b>Main AutoKey Mappings</b></summary>

| Key           | Action                                                    |
| :-----        | :-----                                                    |
| <kbd>j</kbd>  | down                                                      |
| <kbd>k</kbd>  | up                                                        |
| <kbd>h</kbd>  | left                                                      |
| <kbd>l</kbd>  | right                                                     |

# TODO:
| <kbd>0</kbd>  | beginning of line                                         |
| <kbd>4</kbd>  | end of line (close enough to $)                           |
| <kbd>gg</kbd> | beginning of document                                     |
| <kbd>G</kbd>  | end of document                                           |
| <kbd>b</kbd>  | move backwards a word                                     |
| <kbd>w</kbd>  | move forward a word                                       |
| <kbd>u</kbd>  | highlight all words to the left                           |
| <kbd>i</kbd>  | highlight one word to the left                            |
| <kbd>o</kbd>  | highlight one word the right                              |
| <kbd>p</kbd>  | highlight all words to the right                          |
| <kbd>yy</kbd> | copy                                                      |
| <kbd>J</kbd>  | <kbd>⌥ Option</kbd> + <kbd>⌃ Control</kbd> + <kbd>←</kbd> |
| <kbd>K</kbd>  | <kbd>⌥ Option</kbd> + <kbd>⌃ Control</kbd> + <kbd>→</kbd> |

</details>

----

## <a name="sxhkd"></a>sxhkd

+ [sxhkdrc](.config/sxhkd/sxhkdrc)
+ <kbd>Hyper</kbd> = <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>Cmd</kbd> + <kbd>Shift</kbd>

<details>
<summary><b>Overall keybindings</b></summary>

| Keys                                                               | Action                         |
|--------------------------------------------------------------------|--------------------------------|
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>Escape</kbd>            | Restart `bspwm`                |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>x</kbd>                 | Restart `sxhkd`                |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>p</kbd>                 | Restart `polybar`              |
| <kbd>Super</kbd> + <kbd>Return</kbd>                               | Launch `alacritty`             |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>Return</kbd>             | Launch `tdrop`                 |
| <kbd>Hyper</kbd> + <kbd>d</kbd>                                    | Launch `rofi -show drun`       |
| <kbd>Hyper</kbd> + <kbd>x</kbd> (release) - <kbd>x</kbd>           | Launch `rofi -show drun`       |
| <kbd>Hyper</kbd> + <kbd>x</kbd> (release) - <kbd>b</kbd>           | Launch `rofi -show window`     |
| <kbd>Hyper</kbd> + <kbd>b</kbd>                                    | Launch `$BROWSER`              |
| <kbd>Hyper</kbd> + <kbd>p</kbd>                                    | Launch `pcmanfm`               |
| <kbd>Hyper</kbd> + <kbd>.</kbd>                                    | Launch `thunderbird`           |
| <kbd>Hyper</kbd> + <kbd>n</kbd>                                    | `dunsctl history-pop`          |
| <kbd>Hyper</kbd> + <kbd>N</kbd>                                    | `dunsctl close-all`            |
| <kbd>Alt</kbd> + <kbd>Space</kbd>                                  | `dmenu` app launcher           |
| <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>p</kbd>                    | `prs` password launcher        |
| <kbd>Super</kbd> + <kbd>Delete</kbd>                               | Lock screen with `xidlehook`   |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>q</kbd>                 | Kill window                    |
| <kbd>Alt</kbd> + <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>x</kbd> | Kill window                    |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>c</kbd>                 | Close window                   |
| <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>x</kbd>                   | Close window                   |
| <kbd>Super</kbd> + <kbd>m</kbd>                                    | `rofi` view minimized          |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>m</kbd>                 | Hide (minimize) window         |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>m</kbd>                  | Focus last minimized window    |
| <kbd>F11</kbd>                                                     | Remap keys                     |
| <kbd>F10</kbd>                                                     | `caffeinate` (`xidlehook`) on  |
| <kbd>Shift</kbd> + <kbd>F10</kbd>                                  | `caffeinate` (`xidlehook`) off |

</details>

<details>
<summary><b>Additional keybindings (extending function keys)</b></summary>

| Keys                                               | Action                                |
|----------------------------------------------------|---------------------------------------|
| <kbd>XF86AudioMute</kbd>                           | Toggle `pulseaudio` mute              |
| <kbd>XF86AudioLowerVolume</kbd>                    | Decrease `pulseaudio` -5%             |
| <kbd>XF86AudioRaiseVolume</kbd>                    | Increase `pulseaudio` +5%             |
| <kbd>Shift</kbd> + <kbd>XF86AudioMute</kbd>        | Bluetooth - Toggle `pulseaudio` mute  |
| <kbd>Shift</kbd> + <kbd>XF86AudioLowerVolume</kbd> | Bluetooth - Decrease `pulseaudio` -5% |
| <kbd>Shift</kbd> + <kbd>XF86AudioRaiseVolume</kbd> | Bluetooth - Increase `pulseaudio` +5% |
| <kbd>Hyper</kbd> + <kbd>XF86AudioPlay</kbd>        | `playerctl` play-pause                |
| <kbd>Hyper</kbd> + <kbd>XF86AudioPrev</kbd>        | `playerctl` previous                  |
| <kbd>Hyper</kbd> + <kbd>XF86AudioNext</kbd>        | `playerctl` next                      |
| <kbd>Print</kbd>                                   | `flameshot` full screen               |
| <kbd>Shift</kbd> + <kbd>Print</kbd>                | `flameshot` gui                       |
| <kbd>Super</kbd> + <kbd>Print</kbd>                | `flameshot` screen pick               |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>3</kbd>  | Alternative full screen-capture       |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>4</kbd>  | Alternative region screen-capture     |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>5</kbd>  | Alternative window screen-capture     |
| <kbd>Super</kbd> + <kbd>F1</kbd>                   | `ncmpcpp`                             |
| <kbd>Super</kbd> + <kbd>F4</kbd>                   | `playerctl` previous                  |
| <kbd>Super</kbd> + <kbd>F5</kbd>                   | `playerctl` play-pause                |
| <kbd>Super</kbd> + <kbd>F6</kbd>                   | `playerctl` next                      |
| <kbd>Super</kbd> + <kbd>F8</kbd>                   | `mailsync`                            |
| <kbd>Super</kbd> + <kbd>F9</kbd>                   | `dmenumount`                          |
| <kbd>Super</kbd> + <kbd>F10</kbd>                  | `dmenuumount`                         |
| <kbd>XF86Mail</kbd>                                | Launch `neomutt`                      |
| <kbd>XF86MonBrightnessDown</kbd>                   | `xbacklight` decrease 15              |
| <kbd>XF86MonBrightnessUp</kbd>                     | `xbacklight` increase 15              |

</details>

<details>
<summary><b>Swapping windows keybindings</b></summary>

| Swapping                                       |            |
|------------------------------------------------|------------|
| <kbd>Shift</kbd> + <kbd>Alt</kbd> <kbd>h</kbd> | Swap west  |
| <kbd>Shift</kbd> + <kbd>Alt</kbd> <kbd>j</kbd> | Swap south |
| <kbd>Shift</kbd> + <kbd>Alt</kbd> <kbd>k</kbd> | Swap north |
| <kbd>Shift</kbd> + <kbd>Alt</kbd> <kbd>l</kbd> | Swap east  |

</details>

<details>
<summary><b>Focusing windows keybindings</b></summary>

| Focusing                                                           |                     |
|--------------------------------------------------------------------|---------------------|
| <kbd>Alt</kbd> + <kbd>h</kbd>                                      | Focus west          |
| <kbd>Alt</kbd> + <kbd>j</kbd>                                      | Focus south         |
| <kbd>Alt</kbd> + <kbd>k</kbd>                                      | Focus north         |
| <kbd>Alt</kbd> + <kbd>l</kbd>                                      | Focus east          |
| <kbd>Super</kbd> + <kbd>,</kbd>                                    | Focus last (cyclic) |
| <kbd>Super</kbd> + <kbd>c</kbd>                                    | Focus last          |
| <kbd>Super</kbd> + <kbd>C</kbd>                                    | Focus next          |
| <kbd>Super</kbd> + <kbd>c</kbd>                                    | Focus last          |
| <kbd>Super</kbd> + <kbd>j</kbd>                                    | Focus next          |
| <kbd>Super</kbd> + <kbd>k</kbd>                                    | Focus last          |
| <kbd>Super</kbd> + <kbd>o</kbd>                                    | Focus older         |
| <kbd>Super</kbd> + <kbd>i</kbd>                                    | Focus newer         |
| <kbd>Alt</kbd> + <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>h</kbd> | Pre-select west     |
| <kbd>Alt</kbd> + <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>j</kbd> | Pre-select south    |
| <kbd>Alt</kbd> + <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>k</kbd> | Pre-select north    |
| <kbd>Alt</kbd> + <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>l</kbd> | Pre-select east     |
| <kbd>Alt</kbd> + <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>c</kbd> | Pre-select cancel   |

</details>

<details>
<summary><b>Resizing windows keybindings</b></summary>

| Resizing                                          |                  |
|---------------------------------------------------|------------------|
| <kbd>L-Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>h</kbd> | Resize left      |
| <kbd>L-Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>j</kbd> | Resize bottom    |
| <kbd>L-Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>k</kbd> | Resize top       |
| <kbd>L-Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>l</kbd> | Resize right     |
| <kbd>L-Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>0</kbd> | Equalize         |

</details>

<details>
<summary><b>Floating windows keybindings</b></summary>

| Floating                                                 |                            |
|----------------------------------------------------------|----------------------------|
| <kbd>Hyper</kbd> + <kbd>Space</kbd>                      | Toggle float               |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>h</kbd>        | Resize west                |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>j</kbd>        | Resize south               |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>k</kbd>        | Resize north               |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>l</kbd>        | Resize east                |
| <kbd>Hyper</kbd> + <kbd>e</kbd>                          | Cycle next floating window |
| <kbd>Hyper</kbd> + <kbd>c</kbd> (release) - <kbd>h</kbd> | Move floating west         |
| <kbd>Hyper</kbd> + <kbd>c</kbd> (release) - <kbd>j</kbd> | Move floating south        |
| <kbd>Hyper</kbd> + <kbd>c</kbd> (release) - <kbd>k</kbd> | Move floating north        |
| <kbd>Hyper</kbd> + <kbd>c</kbd> (release) - <kbd>l</kbd> | Move floating east         |

</details>

<details>
<summary><b>Moving windows keybindings</b></summary>

| Moving Window                   |                     |
|---------------------------------|---------------------|
| <kbd>Hyper</kbd> + <kbd>f</kbd> | Fullscreen layout   |
| <kbd>Hyper</kbd> + <kbd>[</kbd> | Fullscreen next     |
| <kbd>Hyper</kbd> + <kbd>]</kbd> | Fullscreen previous |
| <kbd>Hyper</kbd> + <kbd>m</kbd> | Monocle layout      |
| <kbd>Hyper</kbd> + <kbd>r</kbd> | Rotate 90 degrees   |

# TODO:
| <kbd>Shift</kbd> + <kbd>Alt</kbd> + <kbd>x</kbd> | Mirror x-axis     |
| <kbd>Shift</kbd> + <kbd>Alt</kbd> + <kbd>y</kbd> | Mirror y-axis     |

</details>

<details>
<summary><b>Window stacks (monocle) keybindings</b></summary>

| Stacks                                             |                                        |
|----------------------------------------------------|----------------------------------------|
| <kbd>Hyper</kbd> + <kbd>m</kbd>                    | Monocle layout                         |
| <kbd>Super</kbd> + <kbd>j</kbd>                    | Go to next window (in or out of stack) |
| <kbd>Super</kbd> + <kbd>k</kbd>                    | Go to prev window (in or out of stack) |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>j</kbd> | View layer underneath (no focus)       |

</details>

<details>
<summary><b>Desktop keybindings</b></summary>

| Desktop                                                |                        |
|--------------------------------------------------------|------------------------|
| <kbd>Alt</kbd> + <kbd>Left</kbd>                       | Desktop previous       |
| <kbd>Alt</kbd> + <kbd>Right</kbd>                      | Desktop next           |
| <kbd>Super</kbd> + <kbd>[</kbd>                        | Desktop previous       |
| <kbd>Super</kbd> + <kbd>]</kbd>                        | Desktop next           |
| <kbd>Super</kbd> + <kbd>grave</kbd>                    | Node last              |
| <kbd>Super</kbd> + <kbd>tab</kbd>                      | Desktop last           |
| <kbd>Super</kbd> + <kbd>[0-9]</kbd>                    | Desktop focus          |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>[0-9]</kbd> | Send window to desktop |

</details>

<details>
<summary><b>Continuous input keybindings</b></summary>

These are keybindings where after the '(release)', the previous keys no longer need to be held and the key following the release can be pressed without holding any modifiers. It is the same kind of idea that a `tmux` binding like `bind -r H resize-pane -L 2` does.

| Continuous                                                   |                      |
|--------------------------------------------------------------|----------------------|
| <kbd>Hyper</kbd> + <kbd>c</kbd> (release) - <kbd>h</kbd>     | Resize window west   |
| <kbd>Hyper</kbd> + <kbd>c</kbd> (release) - <kbd>j</kbd>     | Resize window south  |
| <kbd>Hyper</kbd> + <kbd>c</kbd> (release) - <kbd>k</kbd>     | Resize window north  |
| <kbd>Hyper</kbd> + <kbd>c</kbd> (release) - <kbd>l</kbd>     | Resize window east   |
| <kbd>Hyper</kbd> + <kbd>c</kbd> (release) - <kbd>[</kbd>     | Dynamic gaps shrink  |
| <kbd>Hyper</kbd> + <kbd>c</kbd> (release) - <kbd>]</kbd>     | Dynamic gaps enlarge |
| <kbd>Hyper</kbd> + <kbd>c</kbd> (release) - <kbd>Left</kbd>  | Move floating west   |
| <kbd>Hyper</kbd> + <kbd>c</kbd> (release) - <kbd>Up</kbd>    | Move floating north  |
| <kbd>Hyper</kbd> + <kbd>c</kbd> (release) - <kbd>Down</kbd>  | Move floating south  |
| <kbd>Hyper</kbd> + <kbd>c</kbd> (release) - <kbd>Right</kbd> | Move floating east   |

</details>

----

### <a name="zsh-functions"></a>ZSH Functions

+ List of all `zsh` [functions](.config/zsh/functions) and their purpose
+ [`zshrc`](.config/zsh/.zshrc)
+ [`zshenv`](.zshev)
+ [`zsh-aliases`](.config/zsh/zsh-aliases)

<summary>zsh Functions</summary>
<details>

```sh
 $ pflist                                                 【  ~/.conf/zs/functions】─╯
========================================================================================
acc_print                  fancify text
@append_dir-history-var    helper function for per-dir-hist
arc.list                   list contents of archive
aurview                    Temporarily look at an aur package
autoenv-files              NICHOLAS85: find all autoenv zsh files and edit
be                         use fzf to edit bookmark with buku
bindkey::help              list bindkeys prettily
bkpdir                     Backup current directory
bo                         use fzf to open bookmark with buku
bot                        use fzf to open bookmark with buku (search by tag first)
bow2                       a copy of bow but as a zsh func
.btitle                    buku - change title
.btm                       buku - remove tags
.btp                       buku -- add tags
capzsh                     Dumps all functions/vars/commands etc
ccheat                     cheatsheet of cheat and tldr
cdown                      countdown timer
cdownq                     countdown timer; no display
cdrc                       my modification of cdr
cdreal                     cd realpath
cf                         Create lazily loaded Functions
cfile                      copy contents of file to clipboard
chpwd_ls                   func ran on every cd
@chwpd_dir-history-var     helper function for per-dir-hist
codeline                   get specific lang lines colorized
delta                      delta variable column width side by side
deploy-code
dkill                      interactively kill process with dmenu
docka                      select a docker container to start and attach to
dockrm                     select a docker container to remove
dockrmi                    select a docker image or images to remove
docks                      select a running docker container to stop
exchange                   swap files
_ex_cmd                    Helper for vbindkey (taken from marlonrichert)
explainperm                convert letter permissions to octal
fbd                        cd to selected parent directory
fcd                        change directories with fzf
fcd-zle                    change directories with fzf
fcq                        use copyq to view clipboard history (non-tmux)
fcqt                       use copyq to view clipboard history (tmux)
fcs                        get git commit sha
fds                        list file descriptors
fed                        open the selected file with the default editor
fenv                       search environment vars with fzf
ffig                       figlet font selector
fiff                       using ripgrep combined with preview
fim                        open script in editor (this one does functions)
fjj                        autojump fzf
fjrnl                      search JRNL headlines
fkill                      interactively kill process with fzf
flc                        lolcate fzf
fld                        lolcate fzf default (HOME)
flg                        lolcate fzf
fll                        cd to a directory file is in
flp                        lolcate fzf projects
fman                       fzf man pages
fmates                     use fzf with mates contacts open mutt
fmpc                       fzf mpd
fpdf                       search directory for pdf and open in zathura
frd                        fzf recent directories
fsearch                    search fonts on system
fset                       search set items
fssh                       fzf ssh
ftags                      search ctags
ftm                        create new tmux session, or switch
g1all                      Iterates over .git directories, runs git "$@"
g1zip                      Creates basename pwd-date archive
getpid                     get pid and pipe to pstree
gkey                       print keyboard shortcuts to application - iteractive option
godoc                      colorize go docs
gsha                       show sha of branch
help::glob                 show a help message about globbing
hgrep                      grep history
hist_stat                  zsh history stats
id_process                 get num of process by id
inputbox
jotoday                    Show journalctl logs from a given date
jrnlimport                 import file to jrnl
listening                  listen on port entered
listports                  list open ports
lowercasecurdir            lowercase every file in current dir
lsafter                    list files after a date
lsbefore                   list files before a date
macho-zle                  macho for the use of zle
mksub                      creates a subdir, & moves all files or dirs ...
mp3                        use youtube-dl to get audio
ngu                        get git repo url
old_fk                     fzf rualdi and dirstack combined
oomscore                   list processes likely to be killed first when memory is short
opts
p10k::status               show description of p10k parts
pblist                     lists mybin funcs with their embedded descriptions
perldoc                    wrapper to colorize perldoc man pages
pflist                     lists ZDOTDIR/functions/* with their embedded descriptions
pier-exec                  execute pier command colorfully
pllist                     lists mybin linux funcs with their embedded descriptions
printc                     escape code for colors
prompt_my_per_dir_status   helper function for per-dir-hist
rel                        print the relative path of 2 files
rm                         remove wrapper depending on if root
rmhist                     remove a line from history
run-multi                  run tasks in parallel
setopt_wrap
sudo                       sudo wrapper to allow aliases
suppress                   generates a function named  which:
tmfiles                    Display tags and files with tmsu
tmjson                     Convert tmsu tags and files to json
tmls                       Display tags and files with tmsu in current dir
tmlsa                      Display tags of all files with tmsu in current dir
tmm                        attach to tmux session or create new
tmtag                      use tmsu to either edit a file or cd to dir
tm-tagcount                tmsu list tag and count
towebm                     convert an mp4 to a webm
um                         wrapper to colorize um man pages
urlshort                   shorten url with tinyurl
vbindkey                   vim bindkey
vii                        open file interactively with twf
whim                       open script/function/alias
wtag                       use wutag to either edit a file or cd to dir
xevk                       easy key reader
zdr                        fzf-extras cd to parent directory
zed2                       zed2
zicompinit_fast            faster & more efficient compinit
zman-mine                  Searches zshall with special keyword () matching
zsh-help                   easier way to access zsh manual - taken from ZSH
zst
ztes                       Searches zshall with special keyword () matching
zuiprompt                  TODO: Create a prompt used for other scripts with zui
========================================================================================
```

</details>

---

### Scripts

There are many scripts found within this repo.

* `pblist` (`b` = bin) will list all regular scripts
* `pllist` (`l` = Linux) will list all Linux-specific scripts
