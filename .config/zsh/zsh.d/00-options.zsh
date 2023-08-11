#===========================================================================
#    @author: Lucas Burns <burnsac@me.com> [lmburns]                       #
#   @created: 2023-08-10                                                   #
#    @module: options                                                      #
#      @desc: Zsh options                                                  #
#===========================================================================

setopt no_global_rcs          # startup files in /etc/ won't be ran

# setopt hist_ignore_all_dups   # replace duplicate commands in history file
# setopt hist_ignore_dups       # do not enter command lines into the history list if they are duplicates
setopt hist_ignore_space      # don't add if starts with space
setopt hist_reduce_blanks     # remove superfluous blanks from each command
setopt hist_expire_dups_first # if the internal history needs to be trimmed, trim oldest
setopt hist_fcntl_lock        # use fcntl to lock hist file
setopt hist_subst_pattern     # allow :s/:& to use patterns instead of strings
setopt extended_history       # add beginning time, and duration to history
setopt append_history         # all zsh sessions append to history, not replace
setopt share_history          # imports commands and appends, can't be used with inc_append_history
setopt no_hist_no_functions   # don't remove function defs from history
# setopt inc_append_history # append to history file immediately, not when shell exits

setopt auto_cd             # if command name is a dir, cd to it
setopt auto_pushd          # cd pushes old dir onto dirstack
setopt pushd_ignore_dups   # don't push dupes onto dirstack
setopt pushd_minus         # inverse meaning of '-' and '+'
setopt pushd_silent        # don't print dirstack after 'pushd' / 'popd'
setopt cd_silent           # don't print dirstack after 'cd'
setopt cdable_vars         # if item isn't a dir, try to expand as if it started with '~'
# setopt chase_dots          # if path segment has '..' within it, resolve it if it's a symlink

# setopt case_match        # when using =~ make expression sensitive to case
setopt rematch_pcre      # when using =~ use PCRE regex
setopt case_paths        # nocaseglob + casepaths treats only path components containing glob chars as insensitive
setopt no_case_glob      # case insensitive globbing
setopt extended_glob     # extension of glob patterns
setopt glob_complete     # generate glob matches as completions
setopt glob_dots         # do not require leading '.' for dotfiles
setopt glob_star_short   # ** == **/*      *** == ***/*
setopt numeric_glob_sort # sort globs numerically
# setopt glob_assign       # expand globs on RHS of assignment
# setopt glob_subst        # results from param exp are eligible for filename generation
# setopt magicequalsubst   # # ~ substitution and tab completion after a = (for --x=filename args)

# setopt recexact         # if a word matches exactly, accept it even if ambiguous
setopt complete_in_word # allow completions in middle of word
setopt always_to_end    # cursor moves to end of word if completion is executed
setopt auto_menu        # automatically use menu completion (non-fzf-tab)
setopt menu_complete    # insert first match from menu if ambiguous (non-fzf-tab)
setopt list_types       # show type of file with indicator at end
setopt list_packed      # completions don't have to be equally spaced

# setopt hash_dirs     # when command is completed hash it and all in the dir
# setopt hash_list_all # when a completion is attempted, hash it first
setopt hash_cmds     # save location of command preventing path search
setopt correct       # try to correct mistakes

setopt prompt_subst         # allow substitution in prompt (p10k?)
setopt rc_quotes            # allow '' inside '' to indicate a single '
setopt no_rm_star_silent    # query the user before executing `rm *' or `rm path/*'
setopt interactive_comments # allow comments in history
setopt unset                # don't error out when unset parameters are used
setopt long_list_jobs       # list jobs in long format by default
setopt notify               # report status of jobs immediately
setopt short_loops          # allow short forms of for, repeat, select, if, function
# setopt ksh_option_print    # print all options
# setopt brace_ccl           # expand in braces, which would not otherwise, into a sorted list

setopt c_bases              # 0xFF instead of 16#FF
setopt c_precedences        # use precendence of operators found in C
setopt octal_zeroes         # 077 instead of 8#77
setopt multios              # perform multiple implicit tees and cats with redirection

# setopt csh_null_glob   # don't report if a pattern has no matches unless all do
setopt no_nomatch      # don't print an error if pattern doesn't match
setopt no_clobber      # don't overwrite files without >! >|
setopt no_flow_control # don't output flow control chars (^S/^Q)
setopt no_hup          # don't send HUP to jobs when shell exits
setopt no_beep         # don't beep on error
setopt no_mail_warning # don't print mail warning

setopt combining_chars

# setopt multi_func_def  # allow definitions of multiple functions at once
# setopt combining_chars # assume terminal displays combining characters correctly
# setopt multibyte       #

# setopt xtrace           # print commands and their arguments as they are executed
# setopt source_trace     # print an informational message announcing name of each file it loads
# setopt eval_lineno      # lineno of expr evaled using builtin eval are tracked separately of enclosing environment
# setopt debug_before_cmd # run DEBUG trap before each command; otherwise it is run after each command
# setopt err_exit         # if cmd has a non-zero exit status, execute ZERR trap, if set, and exit
# setopt err_returns      # if cmd has a non-zero exit status, return immediately from enclosing function
# setopt traps_async      # while waiting for a program to exit, handle signals and run traps immediately

# setopt localloops       # break/continue propagate out of function affecting loops in calling funcs
# setopt localtraps       # global traps are restored when exiting function
# setopt localoptions     # make options local to function
# setopt localpatterns    # disable pattern matching


# setopt no_global_rcs          # startup files in /etc/ won't be ran

# setopt hist_ignore_space      # don't add if starts with space
# setopt hist_reduce_blanks     # remove superfluous blanks from each command
# setopt hist_expire_dups_first # if the internal history needs to be trimmed, trim oldest
# setopt hist_fcntl_lock        # use fcntl to lock hist file
# setopt hist_subst_pattern     # allow :s/:& to use patterns instead of strings
# setopt extended_history       # add beginning time, and duration to history
# setopt append_history         # all zsh sessions append to history, not replace
# setopt share_history          # imports commands and appends, can't be used with inc_append_history
# setopt no_hist_no_functions   # don't remove function defs from history
# # setopt inc_append_history   # append to history file immediately, not when shell exits
# # setopt hist_ignore_all_dups # replace duplicate commands in history file
# # setopt hist_ignore_dups     # do not enter command lines into the history list if they are duplicates

# setopt auto_cd             # if command name is a dir, cd to it
# setopt auto_pushd          # cd pushes old dir onto dirstack
# setopt pushd_minus         # inverse meaning of '-' and '+'
# setopt pushd_silent        # don't print dirstack after 'pushd' / 'popd'
# setopt pushd_ignore_dups   # don't push dupes onto dirstack
# setopt cd_silent           # don't print dirstack after 'cd'
# setopt cdable_vars         # if item isn't a dir, try to expand as if it started with '~'
# # setopt chase_dots          # if path segment has '..' within it, resolve it if it's a symlink

# setopt extended_glob     # extension of glob patterns
# setopt rematch_pcre      # when using =~ use PCRE regex
# setopt glob_complete     # generate glob matches as completions
# setopt glob_dots         # do not require leading '.' for dotfiles
# setopt glob_star_short   # ** == **/*      *** == ***/*
# setopt case_paths        # nocaseglob + casepaths treats only path components containing glob chars as insensitive
# setopt numeric_glob_sort # sort globs numerically
# setopt no_nomatch        # don't print an error if pattern doesn't match
# setopt no_case_glob      # case insensitive globbing
# # setopt case_match      # when using =~ make expression sensitive to case
# # setopt recexact        # if a word matches exactly, accept it even if ambiguous
# # setopt csh_null_glob   # don't report if a pattern has no matches unless all do
# # setopt glob_assign     # expand globs on RHS of assignment
# # setopt glob_subst      # results from param exp are eligible for filename generation
# # setopt magicequalsubst # # ~ substitution and tab completion after a = (for --x=filename args)

# setopt unset             # don't error out when unset parameters are used
# setopt rc_quotes            # allow '' inside '' to indicate a single '
# setopt interactive_comments # allow comments in history
# setopt long_list_jobs       # list jobs in long format by default
# setopt notify               # report status of jobs immediately
# setopt short_loops          # allow short forms of for, repeat, select, if, function
# setopt no_rm_star_silent    # query the user before executing `rm *' or `rm path/*'
# # setopt monitor              # enable job control
# # setopt no_bg_nice           # don't run background jobs in lower priority by default
# # setopt auto_resume          # for single commands, resume matching jobs instead
# # setopt ksh_option_print    # print all options
# # setopt brace_ccl           # expand in braces, which would not otherwise, into a sorted list

# setopt c_bases              # 0xFF instead of 16#FF
# setopt c_precedences        # use precendence of operators found in C
# setopt octal_zeroes         # 077 instead of 8#77
# setopt multios              # perform multiple implicit tees and cats with redirection

# setopt complete_in_word # allow completions in middle of word
# setopt always_to_end    # cursor moves to end of word if completion is executed
# setopt menu_complete    # insert first match from menu if ambiguous (non-fzf-tab)
# setopt auto_menu        # automatically use menu completion (non-fzf-tab)
# setopt list_types       # show type of file with indicator at end
# setopt list_packed      # completions don't have to be equally spaced

# setopt correct       # try to correct mistakes
# setopt prompt_subst  # allow substitution in prompt (p10k?)
# setopt hash_cmds     # save location of command preventing path search
# # setopt hash_dirs     # when command is completed hash it and all in the dir
# # setopt hash_list_all # when a completion is attempted, hash it first

# setopt no_clobber      # don't overwrite files without >! >|
# setopt no_flow_control # don't output flow control chars (^S/^Q)
# setopt no_hup          # don't send HUP to jobs when shell exits
# setopt no_beep         # don't beep on error
# setopt no_mail_warning # don't print mail warning
