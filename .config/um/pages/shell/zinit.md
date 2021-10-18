# zinit --
{:data-section="shell"}
{:data-date="June 10, 2021"}
{:data-extra="Um Pages"}

## SYNOPSIS
ZSH plugin manager

## CLONING OPTIONS

`proto`
: Change protocol to `git`,`ftp`,`ftps`,`ssh`, `rsync`, etc. Default is `https`. **Does not work with snippets.**

`from`
: Clone plugin from given site. Supported are `from"github"` (default), `..."github-rel"`, `..."gitlab"`, `..."bitbucket"`, `..."notabug"` (short names: `gh`, `gh-r`, `gl`, `bb`, `nb`). Can also be a full domain name (e.g. for GitHub enterprise). **Does not work with snippets.**

`ver`
: Used with `from"gh-r"` (i.e. downloading a binary release, e.g. for use with `as"program"`) – selects which version to download. Default is latest, can also be explicitly `ver"latest"`. Works also with regular plugins, checkouts e.g. `ver"abranch"`, i.e. a specific version. **Does not work with snippets.**

`bpick`
: Used to select which release from GitHub Releases to download, e.g. `zini ice from"gh-r" as"program" bpick"*Darwin*"; zini load docker/compose`. **Does not work with snippets.**

`depth`
: Pass `--depth` to `git`, i.e. limit how much of history to download. **Does not work with snippets.**

`cloneopts`
: Pass the contents of `cloneopts` to `git clone`. Defaults to `--recursive`. I.e.: change cloning options. Pass empty ice to disable recursive cloning. **Does not work with snippets.**

`pullopts`
: Pass the contents of `pullopts` to `git pull` used when updating plugins. **Does not work with snippets.**

`svn`
: Use Subversion for downloading snippet. GitHub supports `SVN` protocol, this allows to clone subdirectories as snippets, e.g. `zinit ice svn; zinit snippet OMZP::git`. Other ice `pick` can be used to select file to source (default are: `*.plugin.zsh`, `init.zsh`, `*.zsh-theme`). **Does not work with plugins.**


## SELECTION OF FILES (TO SOURCE, …)

`pick`
: Select the file to source, or the file to set as command (when using `snippet --command` or the ice `as"program"`); it is a pattern, alphabetically first matched file is being chosen; e.g. `zinit ice pick"*.plugin.zsh"; zinit load …`

`src`
: Specify additional file to source after sourcing main file or after setting up command (via `as"program"`). It is not a pattern but a plain file name.

`multisrc`
: Allows to specify multiple files for sourcing, enumerated with spaces as the separators (e.g. `multisrc'misc.zsh grep.zsh'`) and also using brace-expansion syntax (e.g. `multisrc'{misc,grep}.zsh'`). Supports patterns.

### CONDITIONAL LOADING

`wait`
: Postpone loading a plugin or snippet. For `wait'1'`, loading is done `1` second after prompt. For `wait'[[ ... ]]'`, `wait'(( ... ))'`, loading is done when given condition is meet. For `wait'!...'`, prompt is reset after load. Zsh can start 80% (i.e.: 5x) faster thanks to postponed loading. **Fact:** when `wait` is used without value, it works as `wait'0'`.

`load`
: A condition to check which should cause plugin to load. It will load once, the condition can be still true, but will not trigger second load (unless plugin is unloaded earlier, see `unload` below). E.g.: `load'[[ $PWD = */github* ]]'`.

`unload`
: A condition to check causing plugin to unload. It will unload once, then only if loaded again. E.g.: `unload'[[ $PWD != */github* ]]'`.

`cloneonly`
: Don't load the plugin / snippet, only download it

`if`
: Load plugin or snippet only when given condition is fulfilled, for example: `zinit ice if'[[ -n "$commands[otool]" ]]'; zinit load ...`.

`has`
: Load plugin or snippet only when given command is available (in $PATH), e.g. `zinit ice has'git' ...`

`subscribe` / `on-update-of`
: Postpone loading of a plugin or snippet until the given file(s) get updated, e.g. `subscribe'{~/files-*,/tmp/files-*}'`

`trigger-load`
: Creates a function that loads the associated plugin/snippet, with an option (to use it, precede the ice content with `!`) to automatically forward the call afterwards, to a command of the same name as the function. Can obtain multiple functions to create – separate with `;`.

### PLUGIN OUTPUT

`silent`
: Mute plugin's or snippet's `stderr` & `stdout`. Also skip `Loaded ...` message under prompt for `wait`, etc. loaded plugins, and completion-installation messages.

`lucid`
: Skip `Loaded ...` message under prompt for `wait`, etc. loaded plugins (a subset of `silent`).

`notify`
: Output given message under-prompt after successfully loading a plugin/snippet. In case of problems with the loading, output a warning message and the return code. If starts with `!` it will then always output the given message. Hint: if the message is empty, then it will just notify about problems.

### COMPLETIONS

`blockf`
: Disallow plugin to modify `fpath`. Useful when a plugin wants to provide completions in traditional way. Zinit can manage completions and plugin can be blocked from exposing them.

`nocompletions`
: Don't detect, install and manage completions for this plugin. Completions can be installed later with `zinit creinstall {plugin-spec}`.

### COMMAND EXECUTION AFTER CLONING, UPDATING OR LOADING

`mv`
: Move file after cloning or after update (then, only if new commits were downloaded). Example: `mv "fzf-* -> fzf"`. It uses `->` as separator for old and new file names. Works also with snippets.

`cp`
: Copy file after cloning or after update (then, only if new commits were downloaded). Example: `cp "docker-c* -> dcompose"`. Ran after `mv`.

`atclone`
: Run command after cloning, within plugin's directory, e.g. `zinit ice atclone"echo Cloned"`. Ran also after downloading snippet.

`atpull`
: Run command after updating (**only if new commits are waiting for download**), within plugin's directory. If starts with "!" then command will be ran before `mv` & `cp` ices and before `git pull` or `svn update`. Otherwise it is ran after them. Can be `atpull'%atclone'`, to repeat `atclone` Ice-mod.

`atinit`
: Run command after directory setup (cloning, checking it, etc.) of plugin/snippet but before loading.

`atdelete`
: Run command after deleting the plugin.

`atload`
: Run command after loading, within plugin's directory. Can be also used with snippets. Passed code can be preceded with `!`, it will then be investigated (if using `load`, not `light`).

`run-atpull`
: Always run the *atpull* hook (when updating), not only when there are new commits to be downloaded.

`nocd`
: Don't switch the current directory into the plugin's directory when evaluating the above ice-mods *atinit''*,*atload''*, etc.

`make`
: Run `make` command after cloning/updating and executing `mv`, `cp`, `atpull`, `atclone` Ice mods. Can obtain argument, e.g. `make"install PREFIX=/opt"`. If the value starts with `!` then `make` is ran before `atclone`/`atpull`, e.g. `make'!'`.

`countdown`
: Causes an interruptable (by Ctrl-C) countdown 5…4…3…2…1…0 to be displayed before executing `atclone''`,`atpull''` and `make` ices

`reset`
: Invokes `git reset --hard HEAD` for plugins or `svn revert` for SVN snippets before pulling any new changes. This way `git` or `svn` will not report conflicts if some changes were done in e.g.: `atclone''` ice. For file snippets and `gh-r` plugins it invokes `rm -rf *`.

### STICKY-EMULATION OF OTHER SHELLS

`sh`, `!sh`
: Source the plugin's (or snippet's) script with `sh` emulation so that also all functions declared within the file will get a *sticky* emulation assigned – when invoked they'll execute also with the `sh` emulation set-up. The `!sh` version switches additional options that are rather not important from the portability perspective.

`bash`, `!bash`
: The same as `sh`, but with the `SH_GLOB` option disabled, so that Bash regular expressions work.

`ksh`, `!ksh`
: The same as `sh`, but emulating `ksh` shell.

`csh`, `!csh`
: The same as `sh`, but emulating `csh` shell.

### OTHERS

`as`
: Can be `as"program"` (also the alias: `as"command"`), and will cause to add script/program to `$PATH` instead of sourcing (see `pick`). Can also be `as"completion"` – use with plugins or snippets in whose only underscore-starting `_*` files you are interested in. The third possible value is `as"null"` – a shorthand for `pick"/dev/null" nocompletions` – i.e.: it disables the default script-file sourcing and also the installation of completions.

`id-as`
: Nickname a plugin or snippet, to e.g. create a short handler for long-url snippet.

`compile`
: Pattern (+ possible `{...}` expansion, like `{a/*,b*}`) to select additional files to compile, e.g. `compile"(pure\async).zsh"` for `sindresorhus/pure`.

`nocompile`
: Don't try to compile `pick`-pointed files. If passed the exclamation mark (i.e. `nocompile'!'`), then do compile, but after `make''` and `atclone''` (useful if Makefile installs some scripts, to point `pick''` at the location of their installation).

`service`
: Make following plugin or snippet a *service*, which will be ran in background, and only in single Zshell instance.

`reset-prompt`
: Reset the prompt after loading the plugin/snippet (by issuing `zle .reset-prompt`). Note: normally it's sufficient to precede the value of `wait''` ice with `!`.
`bindmap`
: To hold `;`-separated strings like `Key(s)A -> Key(s)B`, e.g. `^R -> ^T; ^A -> ^B`. In general, `bindmap''`changes bindings (done with the `bindkey` builtin) the plugin does. The example would cause the plugin to map Ctrl-T instead of Ctrl-R, and Ctrl-B instead of Ctrl-A. **Does not work with snippets.**

`trackbinds`
: Shadow but only `bindkey` calls even with `zinit light ...`, i.e. even with investigating disabled (fast loading), to allow `bindmap` to remap the key-binds. The same effect has `zinit light -b ...`, i.e. additional `-b` option to the `light`-subcommand. **Does not work with snippets.**

`wrap-track`
: Takes a `;`-separated list of function names that are to be investigated (meaning gathering report and unload data) **once** during execution. It works by wrapping the functions with a investigating-enabling and disabling snippet of code. In summary, `wrap-track` allows to extend the investigating beyond the moment of loading of a plugin. Example use is to `wrap-track` a precmd function of a prompt (like `_p9k_precmd()` of powerlevel10k) or other plugin that _postpones its initialization till the first prompt_ (like e.g.: zsh-autosuggestions). **Does not work with snippets.**

`aliases`
: Load the plugin with the aliases mechanism enabled. Use with plugins that define **and use** aliases in their scripts.

`light-mode`
: Load the plugin without the investigating, i.e.: as if it would be loaded with the `light` command. Useful for the for-syntax, where there is no `load` nor `light` subcommand

`extract`
: Performs archive extraction supporting multiple formats like `zip`, `tar.gz`, etc. and also notably OS X `dmg` images. If it has no value, then it works in the *auto* mode – it automatically extracts all files of known archive extensions IF they aren't located deeper than in a sub-directory (this is to prevent extraction of some helper archive files, typically located somewhere deeper in the tree). If no such files will be found, then it extracts all found files of known **type** – the type is being read by the `file` Unix command. If not empty, then takes names of the files to extract. Refer to the Wiki page for further information.

`subst`
: Substitute the given string into another string when sourcing the plugin script, e.g.: `zinit subst'autoload → autoload -Uz' …`.

`autoload`
: Autoload the given functions (from their files). Equivalent to calling `atinit'autoload the-function'`. Supports renaming of the function – pass `'… → new-name'` or `'… -> new-name'`, e.g.: `zinit autoload'fun → my-fun; fun2 → my-fun2'`.


## ORDER OF EXECUTION

* Order of execution of related Ice-mods: `atinit` -> `atpull!` -> `make'!!'` -> `mv` -> `cp` -> `make!` -> `atclone`/`atpull` -> `make` -> `(plugin script loading)` -> `src` -> `multisrc` -> `atload`.

### HELP

`-h, --help, help`
:  Usage information.

`man`
:  Manual.

### LOADING AND UNLOADING

`load {plg-spec}`
:  Load plugin, can also receive absolute local path.

`light [-b] {plg-spec}`
:  Light plugin load, without reporting/investigating. `-b` – investigate `bindkey`-calls only. There's also `light-mode` ice which can be used to induce the no-investigating (i.e.: *light*) loading, regardless of the command used.

`unload [-q] {plg-spec}`
:  Unload plugin loaded with `zinit load ...`. `-q` – quiet.

`snippet [-f] {url}`
:  Source local or remote file (by direct URL). *-f* – don't use cache (force redownload). The URL can use the following shorthands: `PZT::` (Prezto), `PZTM::` (Prezto module), `OMZ::` (Oh My Zsh), `OMZP::` (OMZ plugin), `OMZL::` (OMZ library), `OMZT::` (OMZ theme), e.g.: `PZTM::environment`, `OMZP::git`, etc.


### COMPLETIONS

`clist [*columns*], completions [*columns*]`
:  List completions in use, with *columns* completions per line. `zpl clist 5` will for example print 5 completions per line. Default is 3.

`cdisable {cname}`
:  Disable completion *cname*.

`cenable {cname}`
:  Enable completion *cname*.

`creinstall [-q] {plg-spec}`
:  Install completions for plugin, can also receive absolute local path. *-q* – quiet.

`cuninstall {plg-spec}`
:  Uninstall completions for plugin.

`csearch`
:  Search for available completions from any plugin.

`compinit`
:  Refresh installed completions.

`cclear`
:  Clear stray and improper completions.

`cdlist`
:  Show *compdef* replay list.

`cdreplay [-q]`
:  Replay *compdefs* (to be done after *compinit*). `-q` – quiet.

`cdclear [-q]`
:  Clear compdef replay list. `-q` – quiet.

### TRACKING OF THE ACTIVE SESSION

`dtrace, dstart`
:  Start investigating what's going on in session.

`dstop`
:  Stop investigating what's going on in session.

`dunload`
:  Revert changes recorded between *dstart* and *dstop*.

`dreport`
:  Report what was going on in session.

`dclear`
:  Clear report of what was going on in session.

### REPORTS AND STATISTICS

`times [-s] [-m]`
:  Statistics on plugin load times, sorted in order of loading. `-s` – use seconds instead of milliseconds. `-m` – show plugin loading moments.

`zstatus`
:  Overall Zinit status.

`report {plg-spec} --all`
: Show plugin report. `--all` – do it for all plugins.

`loaded [keyword], list [keyword]`
:  Show what plugins are loaded (filter with 'keyword').

`ls`
:  List snippets in formatted and colorized manner. Requires **tree** program.

`status {plg-spec}\URL\--all`
: Git status for plugin or svn status for snippet. `--all` – do it for all plugins and snippets.

`recently [time-spec]`
:  Show plugins that changed recently, argument is e.g. 1 month 2 days.

`bindkeys`
:  Lists bindkeys set up by each plugin.

### COMPILING

`compile {plg-spec} --all`
: Compile plugin. `--all` – compile all plugins.

`uncompile {plg-spec} --all`
: Remove compiled version of plugin. `--all` – do it for all plugins.

`compiled`
:  List plugins that are compiled.

### OTHER

`self-update`
:  Updates and compiles Zinit.

`update [-q] [-r] {plg-spec} URL\--all`
: Git update plugin or snippet. `--all` – update all plugins and snippets.  `-q` – quiet. `-r` \ `--reset` – run `git reset --hard` / `svn revert` before pulling changes.

`ice <ice specification>`
:  Add ice to next command, argument is e.g. from"gitlab".

`delete {plg-spec}\URL\--clean\--all`
: Remove plugin or snippet from disk (good to forget wrongly passed ice-mods).   `--all` – purge. `--clean` – delete plugins and snippets that are not loaded.

`cd {plg-spec}`
:  Cd into plugin's directory. Also support snippets if fed with URL.

`edit {plg-spec}`
:  Edit plugin's file with $EDITOR.

`glance {plg-spec}`
:  Look at plugin's source (pygmentize, {,source-}highlight).

`stress {plg-spec}`
:  Test plugin for compatibility with set of options.

`changes {plg-spec}`
:  View plugin's git log.

`create {plg-spec}`
:  Create plugin (also together with GitHub repository).

`srv {service-id} [cmd]`
:  Control a service, command can be: stop,start,restart,next,quit; `next` moves the service to another Zshell.

`recall {plg-spec} URL`
: Fetch saved ice modifiers and construct `zinit ice ...` command.

`env-whitelist [-v] [-h] {env..}`
:  Allows to specify names (also patterns) of variables left unchanged during an unload. `-v` – verbose.

`module`
:  Manage binary Zsh module shipped with Zinit, see `zinit module help`.

`add-fpath\fpath` `[-f\--front]` `{plg-spec}` `[subdirectory]`
: Adds given plugin (not yet snippet) directory to `$fpath`. If the second argument is given, it is appended to the directory path. If the option `-f`/`--front` is given, the directory path is prepended instead of appended to `$fpath`. The `{plg-spec}` can be absolute path, i.e.: it's possible to also add regular directories.

`run` `[-l]` `[plugin]` `{command}`
: Runs the given command in the given plugin's directory. If the option `-l` will be given then the plugin should be skipped – the option will cause the previous plugin to be reused.
