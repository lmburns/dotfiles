<h1 align="center">dotfiles</h1>

## Contents
+ [Colorscheme](#terminal-colors)
    + [Alacritty Colorscheme](#alacritty)
    + [Neovim Colorscheme](#neovim-color)
+ [AutoKey](#AutoKey)
+ [sxhkd](#sxhkd)
+ [ZSH Functions](#zsh-functions)
+ [Scripts](#scripts)
    + [All Scripts](#all-scripts)
    + [More Complex Scripts](#complex-scripts)

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

```sh
 $ pflist                                                 【  ~/.conf/zs/functions】─╯
======================================================================================
acc_print                  fancify text
@append_dir-history-var    helper function for per-dir-hist
autoenv-files              NICHOLAS85: find all autoenv zsh files and edit
bcp                        delete (one or multiple) selected application(s)
be                         use fzf to edit bookmark with buku
bip                        brew install package fzf
bo                         use fzf to open bookmark with buku
bot                        use fzf to open bookmark with buku (search by tag first)
bow2                       a copy of bow but as a zsh func
bracketed-paste-win-path
.btitle                    buku - change title
.btm                       buku - remove tags
.btp                       buku -- add tags
bup                        update (one or multiple) selected application(s)
capzsh
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
fbd                        cd to selected parent directory
fcd                        change directories with fzf
fcd-zle                    change directories with fzf
fcq                        use copyq to view clipboard history
fcs                        get git commit sha
fed                        open the selected file with the default editor
fenv                       search environment vars with fzf
ffig                       figlet font selector
fif                        using ripgrep combined with preview
fim                        open script in editor (this one does functions)
fjj                        autojump fzf
fjrnl                      search JRNL headlines
fkill                      interactively kill process with fzf
flc                        lolcate fzf
fld                        lolcate fzf default (HOME)
flg                        lolcate fzf
flp                        lolcate fzf projects
fman                       fzf man pages
fmas                       install app with mas and fzf
fmates                     use fzf with mates contacts open mutt
fmpc                       fzf mpd
fpdf                       search directory for pdf and open in zathura
frd                        fzf recent directories
from-where                 tells from-where a zsh completion is coming from
fsearch                    search fonts on system
fssh                       fzf ssh
ftags                      search ctags
ftm                        create new tmux session, or switch
fzf-close                  interactively close window with fzf
g1all                      Iterates over .git directories, runs git "$@"
g1zip                      Creates basename pwd-date archive
getpid                     get pid and pipe to pstree
gkey                       print keyboard shortcuts to application - iteractive option
gman                       wrapper for gman to colorize
gsha                       show sha of branch
hgrep                      grep history
hist_stat                  zsh history stats
id_process                 get num of process by id
iso2dmg                    Converts file  (iso) to .dmg
jrnlimport                 import file to jrnl
listening                  listen on port entered
listports                  list open ports
lowercasecurdir            lowercase every file in current dir
manfind                    find location of manpage
mp3                        use youtube-dl to get audio
ngu                        get git repo url
old_fk                     fzf rualdi and dirstack combined
osx-ls-download-history    list download history
paleta                     escape codes instead of prompt expansion
palette                    display colors
palette2                   palette alternative
palette::colortest         print full palette with blocks
pblist                     lists mybin funcs with their embedded descriptions
perldoc                    wrapper to colorize perldoc man pages
pflist                     lists ZDOTDIR/functions/* with their embedded descriptions
pier-exec                  execute pier command colorfully
printc                     escape code for colors
prompt_my_per_dir_status   helper function for per-dir-hist
psfind                     queries mdfind by kMDItemDisplayName
rm                         remove wrapper depending on if root
rmhist                     remove a line from history
run-multi                  run tasks in parallel
sudo_                      sudo wrapper to allow aliases
tab                        open new terminal tab in current dir
tmm                        attach to tmux session or create new
um                         wrapper to colorize um man pages
urlshort                   shorten url with tinyurl
vbindkey                   vim bindkey
vii                        open file interactively with twf
whichcomp                  tell which completion a command is using
whim                       edit script from path
wtag                       use wutag to either edit a file or cd to dir
xevk                       easy key reader
zdr                        fzf-extras cd to parent directory
zicompinit_fast            faster & more efficient compinit
zman                       Searches zshall with special keyword () matching
zsh-help                   easier way to access zsh manual - taken from ZSH
zstyle++
ztes                       Searches zshall with special keyword () matching
======================================================================================
```

---

## <a name="scripts"></a>[Scripts](mybin)

+ [All Scripts](#all-scripts)
+ [More Complex Scripts](#complex-scripts)

+ Can be found [here](mybin/)

### <a name="all-scripts"></a>All Scripts

```sh
 $ pblist                                                                              【  ~/mybin】─╯
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
backup_calcurse      bash      backup calcurse reminders
backup_crontab       sh        backup crontab
backup_pkgs          bash      backup packages from brew, cargo, gem, go, npm, pip
backup_task          sh        backup task folder
brew-pkg-size        bash      brew packages and their sizes
brew-why             bash      list all installed apps & dependencies
btc-price            bash      send email to myself of current bitcoin price
bunch_fzf            bash      bunch of
checkdns             bash      check dnsmas, stubby, and dns servers
clean-my-mac         bash      clean macos cache
compiler             sh        compiles various kinds of documents
cps                  zsh       when using a git alias for tracking dotfiles, send to multiple remotes
cryptocheck          sh        check crypocurrency prices
cryptonotify         zsh       send a notification of cryptocurrency prices
downl                sh        uses dragon to download files
fast-pp              bash      fast-p pdf finder source code
flist                bash      fzf view of script directory with descriptions
free                 python    get free memory like debian's 'free'
frm                  bash      fuzzy remove files - trash-put
ftr                  zsh       fzf trash-restore
fzf_pdf              bash      search directory for pdfs, open with zathura
gclp                 bash      git clone from clipboard
glsha                bash      copy a git commits shasum
grm                  sh        git repo manager for self-hosted git servers
gstatd               sh        directory size information
guprj                bash      upload projects to google drive
gutxt                bash      upload text files to google drive
guwww                bash      upload server to google drive
harden               sh        harden a link (convert it to a singly linked file)
html5check.py        python3   check html5 syntax
image-mag-gen        sh        search for font files and add to imagemagick
index-gen            bash      generate template for my website when creating new repo
jupsync              sh        sync jupyter notebook and python file
killport             sh        kills all processes running on the specified port
launchd-creator      bash      generate launch daemon/agent
lctl                 bash      a launchctl wrapper
lf-chdir             bash      change directories with lf file manager
lf-select            sh        reads file names from stdin and selects them in lf
lf-updater-script    sh        update lf file manager
linkhandler          sh        handle urls and do some action
lockscreen           bash      lockscreen, change wallpaper
macho                sh        fzf man pages macOS
macho-pdf            sh        fzf man pages macOS - view in zathura
mailboxes_sync       sh        count mail with mutt
manp                 bash      view manpage in zathura
manp1                bash      output manpage and view in zathura
mbsync-hook          sh        mbsync hook
mbsync-pre-post      sh        mbsync pre-post hooks
mksc                 bash      generate a script in script directory
my-pinentry          bash      choose pinentry depending on PINENTRY_USER_DATA
newsb-notifier       sh        notifications for newsboat
not-touch-hd         sh        use something without it touching harddrive
notmuch-tagging.sh   bash      tag notmuch mail
nv                   bash      open most recently viewed files in nvim with fzf
opout                sh        open output of file for vim
osx-cmds             bash      general rules for macos
passcomp.zsh         zsh       adds call to _pass-vera completion from _pass completion
perlii               perl
pfctl-rules          sh        manipulate pfctl firewall
port-scan            bash      performs port scan using nmap
post-receive         sh        generic git post-receive hook
ppkill               sh        interactive process killer
pretty_csv           bash      create a pretty csv
proxstat             bash      see if dnsmasq stuby privoxy are on
pzz                  bash      search directory for pdf and open in zathura
qndl                 sh        queue up tasks for urls
rclg                 sh        general rclone copier
remind               bash      add reminders from command line
rf                   sh        search directory for files using ripgrep (obsolte, used fd)
rga-fzf              bash      ripgrep preview matches with fzf
rgf                  bash      interactively search files with rg (with reload)
rgfa                 bash      interactively search for files (preview on size)
rglf                 bash      ripgrep search directory for lf file manager
rgn                  bash      interactively search files with rg (with reload) no preview
rmcrap               bash      deletes .DS_Store and __MACOSX directories
rotdir               sh        rotate image order with sxiv
rss-notify           python    parse rss feeds and get notified
rssadd               zsh       add url to newsboat, mod Luke Smiths to add tags
santa-rules          bash      whitelist/blacklist apps with santactl
santa-uninstall      bash      uninstall santa-ctl
shortcuts            sh        update all shortcuts when one file is updated
small_funcs          bash      list of all kinds of small functions to work on
srv-bkp              bash      backup server
srv-up               bash      backup server
synctask             bash      sync tasks from taskwarrior to Reminders.app
take                 zsh       create directory and cd into it
todos                sh        grep for vim comments
tomb                 bash      tomb but for macOS
tordone              bash      notifier of finished torrent
torque               bash      torque - minimal tui for transmission-daemon
transadd             bash      add torrent to transmission
trns                 zsh       transission wrapper
update_block         bash      update block lists
updb                 bash      updatedb for bash, macOS is sh which it is not
webpull              sh        make a local archive of an entire website
wim                  sh        open script in editor
yabai-codesign       bash      codesign yabai
ymld                 bash      parse a yaml file
zm                   zsh       search zshall more efficiently
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
```

### <a name="complex-scripts"></a>More Scripts

### `jupview`

Meant to be used with terminal file managers (`lf`, `nnn`, `ranger`, `vifm`) without any parameters given. For example:

```sh
#!/bin/sh

handle_other() {
  case "${1}" in
    *.ipynb) jupview "${1}";;
  esac
}
```

This will show a preview of the .ipynb file in the terminal.

![jupview preview](https://burnsac.xyz/gallery/media/large/jupview-preview.png)

#### Usage

```sh
Options:
    -P, --pager             View .ipynb file with a pager instead of stdout
    -I, --no-input          Clear input cells of .ipynb file
    -p, --no-prompt         Clear input / output prompts
    -O, --clear-output      Clear output cells of .ipynb file
    -t, --theme             Change syntax highlighting theme (gruvbox default)
```

---
