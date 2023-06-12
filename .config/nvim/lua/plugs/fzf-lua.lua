---@module 'plugs.fzf-lua'
local M = {}

local fzf_lua = Rc.F.npcall(require, "fzf-lua")
if not fzf_lua then
    return
end

local utils = Rc.shared.utils

local cmd = vim.cmd
local fn = vim.fn
local env = vim.env

local std_rg = {
    "--color=always",
    "--hidden",
    "--follow",
    "--smart-case",
    "--auto-hybrid-regex",
    "--max-columns=150",
    "--max-depth=6",
    "--max-columns-preview",
    "--no-binary",
    "--glob='!.git'",
    "--glob='!target'",
    "--glob='!node_modules'",
    --  ━━━━━━━━━━━━━━━━━━━
    -- "--pcre2",
    -- "--vimgrep",
    --  ━━━━━━━━━━━━━━━━━━━
    -- "--search-zip",
    -- "--line-regex",
    -- "--word-regex",
    -- "--fixed-strings",
    -- "--invert-match",
    -- "--count",
    -- "--files",
    -- "--files-with-matches",
    -- "--files-without-matches",
}

local rg_files = _j(std_rg):concat(" ")
local rg_grep = _j(std_rg):merge({"--no-heading", "--with-filename", "--line-number", "--column"})
                          :concat(" ")

function M.setup()
    local actions = require("fzf-lua.actions")

    fzf_lua.setup({
        fzf_bin = "fzf",
        global_resume = true, -- enable global `resume`?
        -- can also be sent individually:
        -- `<any_function>.({ gl ... })`
        global_resume_query = true, -- include typed query in `resume`?
        winopts = {
            -- split         = "belowright new",-- open in a split instead?
            -- "belowright new"  : split below
            -- "aboveleft new"   : split above
            -- "belowright vnew" : split right
            -- "aboveleft vnew   : split left
            -- Only valid when using a float window
            -- (i.e. when 'split' is not defined, default)
            height = 0.85, -- window height
            width = 0.85,  -- window width
            row = 0.35,    -- window row position (0=top, 1=bottom)
            col = 0.50,    -- window col position (0=left, 1=right)
            -- border argument passthrough to nvim_open_win(), also used
            -- to manually draw the border characters around the preview
            -- window, can be set to 'false' to remove all borders or to
            -- 'none', 'single', 'double' or 'rounded' (default)
            border = {"╭", "─", "╮", "│", "╯", "─", "╰", "│"},
            fullscreen = false,                 -- start fullscreen?
            hl = {
                normal = "Normal",              -- window normal color (fg+bg)
                border = "FloatBorder",         -- border color
                help_normal = "Normal",         -- <F1> window normal
                help_border = "CocInfoFloat",   -- <F1> window border
                -- Only used with the builtin previewer:
                cursor = "Cursor",              -- cursor highlight (grep/LSP matches)
                cursorline = "CursorLine",      -- cursor line
                cursorlinenr = "CursorLineNr",  -- cursor line number
                search = "IncSearch",           -- search matches (ctags|help)
                title = "Normal",               -- preview border title (file/buffer)
                -- Only used with 'winopts.preview.scrollbar = 'float'
                scrollfloat_e = "PmenuSbar",    -- scrollbar "empty" section highlight
                scrollfloat_f = "PmenuThumb",   -- scrollbar "full" section highlight
                -- Only used with 'winopts.preview.scrollbar = 'border'
                scrollborder_e = "FloatBorder", -- scrollbar "empty" section highlight
                scrollborder_f = "FloatBorder", -- scrollbar "full" section highlight
            },
            preview = {
                -- ["--preview-window"] = "default:right:60%:+{2}+3/2:border-left",
                -- override the default previewer? default uses the 'builtin' previewer
                default      = "bat",
                border       = "border-left", -- border|noborder, applies only to native fzf previewers (bat/cat/git/etc)
                wrap         = "nowrap",      -- wrap|nowrap
                hidden       = "nohidden",    -- hidden|nohidden
                vertical     = "down:45%",    -- up|down:size
                horizontal   = "right:60%",   -- right|left:size
                layout       = "flex",        -- horizontal|vertical|flex
                flip_columns = 120,           -- #cols to switch to horizontal on flex
                -- Only valid with the builtin previewer:
                title        = true,          -- preview border title (file/buf)?
                title_align  = "left",        -- left|center|right, title alignment
                -- `false` or string:'float|border'
                -- float:  in-window floating border
                -- border: in-border chars (see below)
                scrollbar    = "float",
                scrolloff    = "-2",      -- float scrollbar offset from right applies only when scrollbar = 'float'
                scrollchars  = {"█", ""}, -- scrollbar chars ({ <full>, <empty> } applies only when scrollbar = 'border'
                delay        = 100,       -- delay(ms) displaying the preview prevents lag on fast scrolling
                winopts      = {
                    -- builtin previewer window options
                    number = true,
                    relativenumber = false,
                    cursorline = true,
                    cursorlineopt = "both",
                    cursorcolumn = false,
                    signcolumn = "no",
                    list = false,
                    foldenable = false,
                    foldmethod = "manual",
                },
            },
            on_create = function()
                -- called once upon creation of the fzf main window
                -- can be used to add custom fzf-lua mappings, e.g:
                --   api.nvim_buf_set_keymap(0, "t", "<C-j>", "<Down>",
                --     { silent = true, noremap = true })
            end,
        },
        winopts_fn = function()
            -- Use custom borders hls if they exist in the colorscheme
            local border = "Normal"
            local hls = {"TelescopeBorder", "FloatermBorder", "FloatBorder"}
            for _, hl in ipairs(hls) do
                if #fn.synIDattr(fn.hlID(hl), "fg") > 0 then
                    border = hl
                    break
                end
            end
            return {
                hl = {border = border},
                -- preview = {
                --   -- conditionally override the layout paramter thus overriding the 'flex' layout
                --   layout = api.nvim_win_get_width(0)<100 and 'vertical' or 'horizontal'
                -- }
            }
        end,
        keymap = {
            -- These override the default tables completely
            -- no need to set to `false` to disable a bind
            -- delete or modify is sufficient
            builtin = {
                -- neovim `:tmap` mappings for the fzf win
                ["<F1>"]     = "toggle-help",
                ["<F2>"]     = "toggle-fullscreen",
                -- Only valid with the 'builtin' previewer
                ["<F3>"]     = "toggle-preview-wrap",
                ["<F4>"]     = "toggle-preview",
                ["?"]        = "toggle-preview",
                -- Rotate preview clockwise/counter-clockwise
                ["<F5>"]     = "toggle-preview-ccw",
                ["<F6>"]     = "toggle-preview-cw",
                ["<S-down>"] = "preview-page-down",
                ["<S-up>"]   = "preview-page-up",
                ["<C-left>"] = "preview-page-reset",
                ["<A-n>"]    = "preview-page-down",
                ["<A-p>"]    = "preview-page-up",
            },
            fzf = {
                -- fzf '--bind=' options
                ["esc"] = "abort",
                ["ctrl-c"] = "abort",
                ["ctrl-z"] = "abort",
                ["ctrl-q"] = "abort",
                ["ctrl-g"] = "cancel",
                ["home"] = "beginning-of-line",
                ["end"] = "end-of-line",
                -- ["alt-["] = "beginning-of-line",
                -- ["alt-]"] = "end-of-line",
                -- ["ctrl-s"] = "beginning-of-line",
                -- ["ctrl-e"] = "end-of-line",
                ["alt-x"] = "unix-line-discard",
                -- ["alt-c"] = "unix-word-rubout",
                -- ["alt-d"] = "kill-word",
                -- ["ctrl-h"] = "backward-delete-char",
                -- ["alt-bs"] = "backward-kill-word",
                -- ["ctrl-w"] = "backward-kill-word",

                ["ctrl-alt-a"] = "toggle-all+accept",
                ["alt-a"] = "toggle-all",
                ["alt-s"] = "toggle-sort",
                ["ctrl-r"] = "clear-selection",
                ["page-up"] = "prev-history",
                ["page-down"] = "next-history",
                -- ["alt-{"] = "prev-history",
                -- ["alt-}"] = "next-history",
                ["alt-shift-up"] = "prev-history",
                ["alt-shift-down"] = "next-history",
                ["alt-,"] = "first",
                ["alt-."] = "last",
                ["alt-up"] = "prev-selected",
                ["alt-down"] = "next-selected",
                ["ctrl-/"] = "jump",
                ["ctrl-u"] = "half-page-up",
                ["ctrl-d"] = "half-page-down",
                ["ctrl-alt-u"] = "page-up",
                ["ctrl-alt-d"] = "page-down",
                ["ctrl-y"] = "execute-silent(xsel --trim -b <<< {+})",
                ["alt-b"] = "preview(bat -f -- {+})",
                ["ctrl-]"] = "preview(bat -fl bash \"$XDG_DATA_HOME/gkeys/fzf\")",
                -- ["ctrl-j"] = "down",
                -- ["ctrl-k"] = "up",
                ["change"] = "first",
                --
                -- Only valid with fzf previewers (bat/cat/git/etc)
                ["?"] = "toggle-preview",
                ["alt-["] = "toggle-preview",
                ["alt-]"] = "change-preview-window(70%|45%,down,border-top|45%,up,border-bottom|)+show-preview",
                ["alt-w"] = "toggle-preview-wrap",
                ["alt-p"] = "preview-up",
                ["alt-n"] = "preview-down",
                ["ctrl-alt-b"] = "preview-up",
                ["ctrl-alt-f"] = "preview-down",
                ["ctrl-b"] = "preview-page-up",
                ["ctrl-f"] = "preview-page-down",
                ["ctrl-alt-p"] = "preview-page-up",
                ["ctrl-alt-n"] = "preview-page-down",
                -- ["alt-i"] = "preview-page-up",
                -- ["alt-o"] = "preview-page-down",
                ["alt-/"] = "unbind(?)",
                ["ctrl-\\"] = "rebind(?)",
                -- ["f2"] = "unbind(?)",
                -- ["f3"] = "rebind(?)",
            },
        },
        actions = {
            -- These override the default tables completely
            -- no need to set to `false` to disable an action
            -- delete or modify is sufficient
            files = {
                -- providers that inherit these actions:
                --   files, git_files, git_status, grep, lsp
                --   oldfiles, quickfix, loclist, tags, btags
                --   args
                -- default action opens a single selection
                -- or sends multiple selection to quickfix
                -- replace the default action with the below
                -- to open all files whether single or multiple
                -- ["default"]     = actions.file_edit,
                ["default"] = actions.file_edit_or_qf,
                ["ctrl-s"] = actions.file_split,
                ["ctrl-v"] = actions.file_vsplit,
                ["ctrl-t"] = actions.file_tabedit,
                ["alt-q"] = actions.file_sel_to_qf,
                ["alt-o"] = actions.file_sel_to_ll,
            },
            buffers = {
                -- providers that inherit these actions:
                --   buffers, tabs, lines, blines
                ["default"] = actions.buf_edit,
                ["ctrl-s"] = actions.buf_split,
                ["ctrl-v"] = actions.buf_vsplit,
                ["ctrl-t"] = actions.buf_tabedit,
            },
        },
        fzf_opts = {
            -- options are sent as `<left>=<right>`
            -- set to `false` to remove a flag
            -- set to '' for a non-value flag
            -- for raw args use `fzf_args` instead
            ["--prompt"] = "❱ ",
            ["--pointer"] = "》",
            ["--marker"] = "▍",
            ["--layout"] = "reverse",
            ["--height"] = "100%",
            ["--info"] = "'inline: ❰ '",
            ["--no-separator"] = "",
            ["--tabstop"] = "4",
            ["--cycle"] = "",
            ["--ansi"] = "",
            ["--multi"] = "",
            ["--border"] = "none",
            ["--history"] = "/dev/null",
            -- ["--ellipses"] = "''",
        },
        -- fzf '--color=' options (optional)
        --[[ fzf_colors = {
      ["fg"]          = { "fg", "CursorLine" },
      ["bg"]          = { "bg", "Normal" },
      ["hl"]          = { "fg", "Comment" },
      ["fg+"]         = { "fg", "Normal" },
      ["bg+"]         = { "bg", "CursorLine" },
      ["hl+"]         = { "fg", "Statement" },
      ["info"]        = { "fg", "PreProc" },
      ["prompt"]      = { "fg", "Conditional" },
      ["pointer"]     = { "fg", "Exception" },
      ["marker"]      = { "fg", "Keyword" },
      ["spinner"]     = { "fg", "Label" },
      ["header"]      = { "fg", "Comment" },
      ["gutter"]      = { "bg", "Normal" },
  }, ]]
        previewers = {
            cat = {
                cmd = "cat",
                args = "--number",
            },
            bat = {
                cmd = "bat",
                args = "--style=numbers,changes --color always",
                theme = "kimbox", -- bat preview theme (bat --list-themes)
                -- config = nil,     -- nil uses $BAT_CONFIG_PATH
            },
            head = {
                cmd = "head",
                args = nil,
            },
            git_diff = {
                cmd_deleted = "git diff --color HEAD --",
                cmd_modified = "git diff --color HEAD",
                cmd_untracked = "git diff --color --no-index /dev/null",
                pager = "delta --width=$COLUMNS", -- if you have `delta` installed
            },
            -- === Man
            man = {
                cmd = "man %s | col -bx",
            },
            -- === Builtin
            builtin = {
                syntax          = true,             -- preview syntax highlight?
                syntax_limit_l  = 0,                -- syntax limit (lines), 0=nolimit
                syntax_limit_b  = 1024 * 1024,      -- syntax limit (bytes), 0=nolimit
                limit_b         = 1024 * 1024 * 10, -- preview limit (bytes), 0=nolimit
                treesitter      = {enable = true, disable = {}},
                -- By default, the main window dimensions are calculted as if the
                -- preview is visible, when hidden the main window will extend to
                -- full size. Set the below to "extend" to prevent the main window
                -- from being modified when toggling the preview.
                toggle_behavior = "default",
                -- preview extensions using a custom shell command:
                -- for example, use `viu` for image previews
                -- will do nothing if `viu` isn't executable
                extensions      = {
                    -- neovim terminal only supports `viu` block output
                    ["png"] = {"viu", "-b"},
                    ["gif"] = {"viu", "-b"},
                    ["jpg"] = {"viu", "-b"},
                    ["jpeg"] = {"viu", "-b"},
                    ["svg"] = {"chafa"},
                },
                -- if using `ueberzug` in the above extensions map
                -- set the default image scaler, possible scalers:
                --   false (none), "crop", "distort", "fit_contain",
                --   "contain", "forced_cover", "cover"
                -- https://github.com/seebye/ueberzug
                ueberzug_scaler = "cover",
            },
        },
        -- === Files
        files = {
            -- previewer      = "bat",          -- uncomment to override previewer
            -- (name from 'previewers' table)
            -- set to 'false' to disable
            prompt                 = "Files❱ ",
            multiprocess           = true, -- run command in a separate process
            git_icons              = true, -- show git icons?
            file_icons             = true, -- show file icons?
            color_icons            = true, -- colorize file|git icons
            -- path_shorten   = 1,              -- 'true' or number, shorten path?
            -- executed command priority is 'cmd' (if exists)
            -- otherwise auto-detect prioritizes `fd`:`rg`:`find`
            -- default options are controlled by 'fd|rg|find|_opts'
            -- cmd            = "find . -type f -printf '%P\n'",
            find_opts              = [[-type f -not -path '*/\.git/*' -printf '%P\n']],
            -- rg_opts = "--color=never --files --hidden --follow -g '!.git'",
            rg_opts                = rg_files,
            fd_opts                = utils.list({
                "--color=never",
                "--type f",
                "--hidden",
                "--follow",
                "--exclude .git",
                "--exclude target",
                "--exclude node_modules",
            }, " "),
            -- by default, cwd appears in the header only if {opts} contain a cwd
            -- parameter to a different folder than the current working directory
            -- uncomment if you wish to force display of the cwd as part of the
            -- query prompt string (fzf.vim style), header line or both
            -- cwd_header = true,
            cwd_prompt             = true,
            cwd_prompt_shorten_len = 32, -- shorten prompt beyond this length
            cwd_prompt_shorten_val = 1,  -- shortened path parts length
            actions                = {
                -- inherits from 'actions.files', here we can override
                -- or set bind to 'false' to disable a default action
                ["default"] = actions.file_edit,
                -- custom actions are available too
                ["ctrl-y"] = function(selected)
                    print(selected[1])
                end,
            },
        },
        -- === Git
        git = {
            -- === Git Files
            files = {
                prompt = "GitFiles❱ ",
                cmd = "git ls-files --exclude-standard",
                multiprocess = true, -- run command in a separate process
                git_icons = true,    -- show git icons?
                file_icons = true,   -- show file icons?
                color_icons = true,  -- colorize file|git icons
                cwd_header = false,
                fzf_opts = {
                    ["--border"] = "none",
                    ["--preview-window"] = "default:right:60%:+{2}+3/2:border-left",
                },
            },
            -- === Git Status
            status = {
                prompt      = "GitStatus❱ ",
                -- consider using `git status -su` if you wish to see
                -- untracked files individually under their subfolders
                cmd         = "git -c color.status=false status -s",
                previewer   = "git_diff",
                file_icons  = true,
                git_icons   = true,
                color_icons = true,
                actions     = {
                    -- actions inherit from 'actions.files' and merge
                    ["right"]  = {actions.git_unstage, actions.resume},
                    ["left"]   = {actions.git_stage, actions.resume},
                    ["ctrl-x"] = {actions.git_reset, actions.resume},
                    ["ctrl-s"] = {actions.git_stage_unstage, actions.resume},
                    --   ["right"]   = false,
                    --   ["left"]    = false,
                    --   ["ctrl-x"]  = { actions.git_reset, actions.resume },
                },
                fzf_opts    = {
                    ["--border"] = "none",
                    ["--preview-window"] = "default:right:60%:+{2}+3/2:border-left",
                },
            },
            -- === Git Commits
            commits = {
                prompt        = "Commits❱ ",
                cmd           =
                    [[git log --color --abbrev-commit --decorate --date=relative ]] ..
                    [[--format='%C(bold 52)%h%C(reset) %C(17)(%><(12)%cr%><|(12))%C(reset) %C(auto)%d%C(reset) %C(43)%s%C(reset) ]] ..
                    [[%C(bold 13)[%C(reset)%C(21)%an%C(bold 13)]%C(reset) ]] ..
                    [[%C(bold 18)[%C(bold 2)%G?%C(reset):%C(bold 19)%GS%C(bold 13)]%C(reset)']],
                -- cmd     = "git log --pretty=oneline --abbrev-commit --color",
                -- cmd     =
                --     "git log --color " ..
                --     "--pretty=format:'%C(yellow)%h%Creset %Cgreen(%><(12)%cr%><|(12))%Creset %s %C(blue)<%an>%Creset'",
                --
                preview       =
                    "git show " ..
                    "--pretty='%Cred%H%n%Cblue%an <%ae>%n%C(yellow)%cD%n%Cgreen%s' --color {1}",
                -- preview = "git show --pretty='%Cred%H%n%Cblue%an%n%Cgreen%s' --color {1}",
                --
                preview_pager = "delta --width=$FZF_PREVIEW_COLUMNS",
                actions       = {
                    ["default"] = actions.git_checkout,
                },
                fzf_opts      = {
                    ["--border"] = "none",
                    ["--preview-window"] = "default:right:60%:+{2}+3/2:border-left",
                },
            },
            -- === Git Bcommits
            bcommits = {
                prompt   = "BCommits❱ ",
                -- cmd     = "git log --pretty=oneline --abbrev-commit --color",
                cmd      =
                    [[git log --color --abbrev-commit --decorate --date=relative ]] ..
                    [[--format='%C(bold 52)%h%C(reset) %C(17)(%><(12)%cr%><|(12))%C(reset) %C(auto)%d%C(reset) %C(43)%s%C(reset) ]] ..
                    [[%C(bold 18)[%C(bold 2)%G?%C(reset):%C(bold 19)%GS%C(bold 13)]%C(reset) ]] ..
                    [[%C(bold 13)[%C(reset)%C(21)%an%C(bold 13)]%C(reset)']],
                -- cmd     =
                --     "git log --color " ..
                --     "--pretty=format:'%C(yellow)%h%Creset %Cgreen(%><(12)%cr%><|(12))%Creset %s %C(blue)<%an>%Creset' <file>",
                --
                -- preview = "git diff --color {1}~1 {1} -- <file>",
                preview  = "git show --pretty='%Cred%H%n%Cblue%an%n%Cgreen%s' --color {1}",
                --
                -- uncomment if you wish to use git-delta as pager
                --preview_pager = "delta --width=$FZF_PREVIEW_COLUMNS",
                actions  = {
                    ["default"] = actions.git_buf_edit,
                    ["ctrl-s"] = actions.git_buf_split,
                    ["ctrl-v"] = actions.git_buf_vsplit,
                    ["ctrl-t"] = actions.git_buf_tabedit,
                },
                winopts  = {
                    preview = {
                        horizontal = "right:40%",
                        border     = "border-left",
                        wrap       = "nowrap",
                        hidden     = "nohidden",
                        layout     = "flex",
                    },
                },
                fzf_opts = {
                    ["--preview-window"] = "default:right:60%:+{2}+3/2:border-left",
                },
            },
            -- === Git Branches
            branches = {
                prompt = "Branches❱ ",
                cmd = "git branch --all --color",
                preview = "git log --graph --pretty=oneline --abbrev-commit --color {1}",
                actions = {["default"] = actions.git_switch},
            },
            stash = {
                prompt = "Stash❱ ",
                cmd = "git --no-pager stash list",
                preview = "git --no-pager stash show --patch --color {1}",
                actions = {
                    ["default"] = actions.git_stash_apply,
                    ["ctrl-x"] = {actions.git_stash_drop, actions.resume},
                },
                fzf_opts = {
                    ["--no-multi"] = "",
                    ["--delimiter"] = "'[:]'",
                },
            },
            icons = {
                ["M"] = {icon = "M", color = "yellow"},
                ["D"] = {icon = "D", color = "red"},
                ["A"] = {icon = "A", color = "green"},
                ["R"] = {icon = "R", color = "yellow"},
                ["C"] = {icon = "C", color = "yellow"},
                ["?"] = {icon = "?", color = "magenta"},
                -- override git icons?
                -- ["M"]        = { icon = "★", color = "red" },
                -- ["D"]        = { icon = "✗", color = "red" },
                -- ["A"]        = { icon = "+", color = "green" },
            },
        },
        -- === Grep
        grep = {
            prompt = "Rg❱ ",
            input_prompt = "Grep For❱ ",
            multiprocess = true, -- run command in a separate process
            git_icons = true,    -- show git icons?
            file_icons = true,   -- show file icons?
            color_icons = true,  -- colorize file|git icons
            -- executed command priority is 'cmd' (if exists)
            -- otherwise auto-detect prioritizes `rg` over `grep`
            -- default options are controlled by 'rg|grep_opts'
            -- cmd            = "rg --vimgrep",
            grep_opts = utils.list({
                "--binary-files=without-match",
                "--line-number",
                "--recursive",
                "--color=auto",
                "--perl-regexp",
            }, " "),
            rg_opts = rg_grep,
            -- set to 'true' to always parse globs in both 'grep' and 'live_grep'
            -- search strings will be split using the 'glob_separator' and translated
            -- to '--iglob=' arguments, requires 'rg'
            -- can still be used when 'false' by calling 'live_grep_glob' directly
            rg_glob = false,           -- default to glob parsing?
            glob_flag = "--iglob",     -- for case sensitive globs use '--glob'
            glob_separator = "%s%-%-", -- query separator pattern (lua): ' --'
            -- advanced usage: for custom argument parsing define
            -- 'rg_glob_fn' to return a pair:
            --   first returned argument is the new search query
            --   second returned argument are addtional rg flags
            -- rg_glob_fn = function(opts, query)
            --   ...
            --   return new_query, flags
            -- end,
            actions = {
                -- actions inherit from 'actions.files' and merge
                -- this action toggles between 'grep' and 'live_grep'
                ["ctrl-alt-g"] = {actions.grep_lgrep},
            },
            no_header = false,   -- hide grep|cwd header?
            no_header_i = false, -- hide interactive header?
        },
        -- === Args
        args = {
            prompt = "Args❱ ",
            files_only = true,
            -- actions inherit from 'actions.files' and merge
            actions = {["ctrl-x"] = {actions.arg_del, actions.resume}},
        },
        -- === Oldfiles
        oldfiles = {
            prompt = "History❱ ",
            cwd_only = false,
            stat_file = true,               -- verify files exist on disk
            include_current_session = true, -- include bufs from current session
            winopts = {preview = {horizontal = "right:40%"}},
        },
        -- === Buffers
        buffers = {
            prompt        = "Buffers❱ ",
            file_icons    = true,  -- show file icons?
            color_icons   = true,  -- colorize file|git icons
            sort_lastused = true,  -- sort buffers() by last used
            show_unloaded = true,  -- show unloaded buffers
            cwd_only      = false, -- buffers for the cwd only
            cwd           = nil,   -- buffers list for a given dir
            actions       = {
                -- actions inherit from 'actions.buffers' and merge
                -- by supplying a table of functions we're telling
                -- fzf-lua to not close the fzf window, this way we
                -- can resume the buffers picker on the same window
                -- eliminating an otherwise unaesthetic win "flash"
                ["ctrl-x"] = {actions.buf_del, actions.resume},
            },
        },
        -- === Tabs
        tabs = {
            prompt = "Tabs❱ ",
            tab_title = "Tab",
            tab_marker = "<<",
            file_icons = true,  -- show file icons?
            color_icons = true, -- colorize file|git icons
            actions = {
                -- actions inherit from 'actions.buffers' and merge
                ["default"] = actions.buf_switch,
                ["ctrl-x"] = {actions.buf_del, actions.resume},
            },
            fzf_opts = {
                -- hide tabnr
                ["--delimiter"] = "'[\\):]'",
                ["--with-nth"] = "2..",
            },
        },
        -- === Lines
        lines = {
            prompt          = "Lines❱ ",
            previewer       = "builtin", -- set to 'false' to disable
            show_unloaded   = true,      -- show unloaded buffers
            show_unlisted   = false,     -- exclude 'help' buffers
            no_term_buffers = true,      -- exclude 'term' buffers
            fzf_opts        = {
                -- do not include bufnr in fuzzy matching
                -- tiebreak by line no.
                ["--delimiter"] = "'[\\]:]'",
                ["--nth"] = "2..",
                ["--tiebreak"] = "index",
            },
            -- actions inherit from 'actions.buffers' and merge
            actions         = {
                ["default"] = actions.buf_edit_or_qf,
                ["alt-q"] = actions.buf_sel_to_qf,
                ["alt-o"] = actions.buf_sel_to_ll,
            },
            -- actions inherit from 'actions.buffers'
        },
        -- === Blines
        blines = {
            prompt = "BLines❱ ",
            previewer = "builtin",  -- set to 'false' to disable
            show_unlisted = true,   -- include 'help' buffers
            no_term_buffers = true, -- include 'term' buffers
            fzf_opts = {
                -- hide filename, tiebreak by line no.
                ["--delimiter"] = "'[\\]:]'",
                ["--with-nth"]  = "2..",
                ["--tiebreak"]  = "index",
                ["--tabstop"]   = "1",
            },
            actions = {
                ["default"] = actions.buf_edit_or_qf,
                ["alt-q"]   = actions.buf_sel_to_qf,
                ["alt-o"]   = actions.buf_sel_to_ll,
            },
        },
        -- === Tags
        tags = {
            prompt       = "Tags❱ ",
            -- previewer = "bat",
            ctags_file   = nil, -- auto-detect from tags-option
            multiprocess = true,
            file_icons   = true,
            git_icons    = true,
            color_icons  = true,
            -- 'tags_live_grep' options, `rg` prioritizes over `grep`
            rg_opts      = rg_grep,
            grep_opts    = "--color=auto --perl-regexp",
            actions      = {
                -- actions inherit from 'actions.files' and merge
                -- this action toggles between 'grep' and 'live_grep'
                ["ctrl-alt-g"] = {actions.grep_lgrep},
                ["alt-o"] = {actions.grep_lgrep},
            },
            no_header    = false, -- hide grep|cwd header?
            no_header_i  = false, -- hide interactive header?
        },
        tagstack = {
            prompt      = "Tagstack❱ ",
            file_icons  = true,
            color_icons = true,
            git_icons   = true,
        },
        -- === BTags
        btags = {
            prompt        = "BTags❱ ",
            ctags_file    = nil,   -- auto-detect from tags-option
            ctags_autogen = false, -- dynamically generate ctags each call
            multiprocess  = true,
            file_icons    = true,
            git_icons     = true,
            color_icons   = true,
            rg_opts       = "--no-heading --color=always",
            grep_opts     = "--color=auto --perl-regexp",
            fzf_opts      = {
                ["--delimiter"] = "'[\\]:]'",
                ["--with-nth"] = "2..",
                ["--tiebreak"] = "index",
            },
            -- actions inherit from 'actions.files'
        },
        -- === Colorschems
        colorschemes = {
            prompt = "Colorschemes❱ ",
            live_preview = true, -- apply the colorscheme on preview?
            actions = {["default"] = actions.colorscheme},
            winopts = {height = 0.55, width = 0.30},
            post_reset_cb = function()
                -- reset statusline highlights after
                -- a live_preview of the colorscheme
                -- require('feline').reset_highlights()
            end,
        },
        -- === Quickfix
        quickfix = {
            file_icons = true,
            git_icons = true,
        },
        -- === LSP
        lsp = {
            prompt_postfix     = "❱ ", -- will be appended to the LSP label
            -- to override use 'prompt' instead
            cwd_only           = false, -- LSP/diagnostics for cwd only?
            async_or_timeout   = 5000,  -- timeout(ms) or 'true' for async calls
            file_icons         = true,
            git_icons          = nil,
            includeDeclaration = true, -- include current declaration in LSP context
            -- settings for 'lsp_{document|workspace|lsp_live_workspace}_symbols'
            symbols            = {
                async_or_timeout = true, -- symbols are async by default
                symbol_style     = 1,    -- style for document/workspace symbols
                -- false: disable,    1: icon+kind
                --     2: icon only,  3: kind only
                -- vim.lsp.protocol.CompletionItemKind
                -- icons for symbol kind
                symbol_icons     = {
                    File          = "󰈙",
                    Module        = "",
                    Namespace     = "󰦮",
                    Package       = "",
                    Class         = "󰆧",
                    Method        = "󰊕",
                    Property      = "",
                    Field         = "",
                    Constructor   = "",
                    Enum          = "",
                    Interface     = "",
                    Function      = "󰊕",
                    Variable      = "󰀫",
                    Constant      = "󰏿",
                    String        = "",
                    Number        = "󰎠",
                    Boolean       = "󰨙",
                    Array         = "󱡠",
                    Object        = "",
                    Key           = "󰌋",
                    Null          = "󰟢",
                    EnumMember    = "",
                    Struct        = "󰆼",
                    Event         = "",
                    Operator      = "󰆕",
                    TypeParameter = "󰗴",
                },
                -- colorize using Treesitter '@' highlight groups ("@function", etc).
                -- or 'false' to disable highlighting
                symbol_hl        = function(s) return "@" .. s:lower() end,
                -- additional symbol formatting, works with or without style
                symbol_fmt       = function(s, opts) return "[" .. s .. "]" end,
                -- prefix child symbols. set to any string or `false` to disable
                child_prefix     = true,
            },
        },
        diagnostics = {
            prompt       = "Diagnostics❱ ",
            cwd_only     = false,
            file_icons   = true,
            git_icons    = true,
            diag_icons   = true,
            icon_padding = "", -- add padding for wide diagnostics signs
            severity     = "hint",
            signs        = {
                ["Error"] = {icon = "", color = "red"},      -- error
                ["Warning"] = {icon = "", color = "yellow"}, -- warning
                ["Information"] = {icon = "", color = "blue"}, -- info
                ["Hint"] = {icon = "", color = "magenta"},   -- hint
            },
        },

        complete_path = {
            cmd     = nil, -- default: auto detect fd|rg|find
            actions = {["default"] = actions.complete_insert},
        },
        complete_file = {
            cmd         = nil, -- default: auto detect rg|fd|find
            file_icons  = true,
            color_icons = true,
            git_icons   = false,
            -- actions inherit from 'actions.files' and merge
            actions     = {["default"] = actions.complete_insert},
            -- previewer hidden by default
            winopts     = {preview = {hidden = "hidden"}},
        },

        autocmds = {
            prompt    = "Autocmds ",
            previewer = "builtin",
            fzf_opts  = {
                ["--delimiter"] = "'[:]'",
                ["--with-nth"]  = "3..",
            },
        },
        highlights = {
            prompt = "Highlights ",
        },
        commands = {
            prompt = "Comands ",
            actions = {
                ["default"] = actions.ex_run,
            },
        },
        builtin = {
            prompt  = "Builtin ",
            winopts = {
                height = 0.65,
                width  = 0.50,
            },
            actions = {
                ["default"] = actions.run_builtin,
            },
        },
        marks = {
            prompt  = "Marks ",
            actions = {
                ["default"] = actions.goto_mark,
            },
            -- previewer = {_ctor = previewers.builtin.marks},
        },
        jumps = {
            prompt  = "Jumps ",
            cmd     = "jumps",
            actions = {
                ["default"] = actions.goto_jump,
            },
        },
        helptags = {
            prompt   = "Help ",
            actions  = {
                ["default"] = actions.help,
                ["ctrl-s"]  = actions.help,
                ["ctrl-v"]  = actions.help_vert,
                ["ctrl-t"]  = actions.help_tab,
            },
            fzf_opts = {
                ["--delimiter"] = "'[ ]'",
                ["--with-nth"]  = "..-2",
            },
            -- uncomment to disable the previewer
            -- previewer = { _ctor = false } ,
        },
        manpages = {
            prompt    = "Man ",
            cmd       = "man -k .",
            actions   = {
                ["default"] = actions.man,
                ["ctrl-s"]  = actions.man,
                ["ctrl-v"]  = actions.man_vert,
                ["ctrl-t"]  = actions.man_tab,
            },
            fzf_opts  = {["--tiebreak"] = "begin"},
            previewer = "man",
            -- uncomment to disable the previewer
            -- previewer = { _ctor = false } ,
        },
        command_history = {
            prompt   = "Command History ",
            fzf_opts = {["--tiebreak"] = "index"},
            actions  = {
                ["default"] = actions.ex_run_cr,
                ["ctrl-e"]  = actions.ex_run,
            },
        },
        search_history = {
            prompt   = "Search History ",
            fzf_opts = {["--tiebreak"] = "index"},
            actions  = {
                ["default"] = actions.search_cr,
                ["ctrl-e"]  = actions.search,
            },
        },
        keymaps = {
            prompt = "Keymaps ",
            fzf_opts = {["--tiebreak"] = "index"},
            actions = {
                ["default"] = actions.keymap_apply,
            },
        },

        -- nvim = { marks = { previewer = { _ctor = false } } },
        -- uncomment to disable the previewer

        -- uncomment to set dummy win location (help|man bar)
        -- "topleft"  : up
        -- "botright" : down
        -- helptags = { previewer = { split = "topleft" } },
        -- uncomment to use `man` command as native fzf previewer
        -- manpages = { previewer = { _ctor = require'fzf-lua.previewer'.fzf.man_pages } },
        -- optional override of file extension icon colors

        file_icon_padding = "",
        file_icon_colors = {
            lua = "blue",
            rust = "orange",
            sh = "green",
        },
        -- uncomment if your terminal/font does not support unicode character
        -- nbsp = '\xc2\xa0',
    })

    -- register fzf-lua as vim.ui.select interface
    -- fzf_lua.register_ui_select(
    --     { winopts = { height = 0.30, width = 0.70, row = 0.40 } }
    -- )
end

M.branch_compare = function(opts)
    if not opts then
        opts = {}
    end

    local function branch_compare(selected, o)
        -- remove anything past space
        local branch = selected[1]:match("[^ ]+")
        -- do nothing for active branch
        if branch:find("%*") ~= nil then
            return
        end
        -- git_cwd is only required if you want to also run
        -- this outside your current working directory
        -- all it does is add `git -C <cwd_path>`
        -- this enables you to run:
        -- branch_compare({ cwd = "~/Sources/nvim/fzf-lua" })
        o.cmd =
            require("fzf-lua.path").git_cwd(
            -- change this to whaetever command works best for you:
            -- git diff --name-only $(git merge-base HEAD [SELECTED_BRANCH])
                ("git diff --name-only %s"):format(branch),
                o.cwd
            )
        -- replace the previewer with our custom command
        o.previewer = {
            cmd = require("fzf-lua.path").git_cwd("git diff", o.cwd),
            args = ("--color main %s -- "):format(branch),
            _new = function()
                return require"fzf-lua.previewer".cmd_async
            end,
        }
        -- disable git icons, without adjustments they will
        -- display their current status and not the branch status
        -- TODO: supply `files` with `git_diff_cmd`, `git_untracked_cmd`
        o.git_icons = false
        -- reset the default action that was carried over from the
        -- `git_branches` call
        o.actions = nil
        require"fzf-lua".files(o)
    end
    opts.prompt = "BranchCompare❯ "
    opts.actions = {["default"] = branch_compare}
    require("fzf-lua").git_branches(opts)
end

M.installed_plugins = function(opts)
    opts = opts or {}
    opts.prompt = "Plugins "
    opts.cwd = Rc.dirs.pack
    fzf_lua.files(opts)
end

M.edit_nvim = function(opts)
    opts = opts or {}
    opts.prompt = " Neovim  "
    opts.cwd = Rc.dirs.config
    fzf_lua.files(opts)
end

M.edit_git_nvim = function(opts)
    opts = opts or {}
    opts.prompt = " Neovim  "
    opts.cwd = Rc.dirs.config
    opts.git_worktree = env.DOTBARE_TREE
    opts.git_dir = env.DOTBARE_DIR
    fzf_lua.git_files(opts)
end

M.edit_nvim_source = function(opts)
    opts = opts or {}
    opts.prompt = " Neovim Source  "
    opts.cwd = Rc.dirs.xdg.data .. "/neovim/share/nvim/runtime"
    fzf_lua.files(opts)
end

M.edit_vim_source = function(opts)
    opts = opts or {}
    opts.prompt = " Vim Source  "
    opts.cwd = env.GHQ_ROOT .. "/github.com/vim/vim/runtime"
    fzf_lua.files(opts)
end

-- Ϟ
M.edit_zsh = function(opts)
    opts = opts or {}
    opts.prompt = "~ zsh ~ "
    opts.cwd = Rc.dirs.zdot
    fzf_lua.files(opts)
end

M.grep_nvim = function(opts)
    opts = opts or {}
    opts.cwd = Rc.dirs.config
    fzf_lua.live_grep(opts)
end

M.cst_files = function(opts)
    opts = opts or {}
    if env.GIT_WORK_TREE == env.DOTBARE_TREE then
        fzf_lua.git_files(opts)
    else
        local cwd = fn.expand("%:p:h")
        local root = utils.git.root(cwd)
        if #root == 0 then
            opts.cwd = cwd
            fzf_lua.files(opts)
        else
            fzf_lua.git_files(opts)
        end
    end
end

M.cst_fd = function(opts)
    opts = opts or {}
    opts.cwd = fn.expand("%:p:h")
    fzf_lua.files(opts)
end

M.cst_grep = function(opts)
    opts = opts or {}
    opts.cwd = fn.expand("%:p:h")
    fzf_lua.live_grep(opts)
end

M.git_grep = function(opts)
    opts = opts or {}
    opts.cwd = utils.git.root()
    fzf_lua.live_grep(opts)
end

M.marks = function(opts)
    opts = opts or {}
    local marks = require("plugs.marks").get_placed_marks()
    opts.marks = ("ABCDEFGHIJKLMNOPQRSTUVWXYZ%s"):format(_j(marks):keys():concat(""))
    fzf_lua.marks(opts)
end

local function init()
    M.setup()

    local wk = require("which-key")

    wk.register({
        -- ["<Leader>cm"] = {":lua require('fzf-lua').commands()<CR>", "Commands (fzf-lua)"},
        -- ["<Leader>hs"] = {":lua require('fzf-lua').search_history()<CR>", "Search history (fzf-lua)"},

        ["q/"] = {"<Cmd>lua require('fzf-lua').search_history()<CR>", "Hist: search (fzf-lua)"},
        ["qf"] = {"<Cmd>lua require('fzf-lua').quickfix()<CR>", "Quickfix: list (fzf-lua)"},
        -- ["qF"] = {"<Cmd>lua require('fzf-lua').quickfix_stack()<CR>", "Quickfix: stack (fzf-lua)"},
        ["qW"] = {"<Cmd>lua require('fzf-lua').loclist()<CR>", "Loclist: list (fzf-lua)"},
        ["qT"] = {"<Cmd>lua require('fzf-lua').tabs()<CR>", "Tab: list (fzf-lua)"},
        ["<Localleader>l"] = {"<Cmd>lua require('fzf-lua').lines()<CR>", "Lines (fzf-lua)"},

        ["<LocalLeader>e"] = {"<Cmd>lua require('plugs.fzf-lua').cst_grep()<CR>", "Grep (fzf-lua)"},
        ["<Leader>ap"] = {"<Cmd>lua require('fzf-lua').man_pages()<CR>", "Man: pages (fzf-lua)"},
        ["<Leader>aa"] = {"<Cmd>lua require('fzf-lua').help_tags()<CR>", "Help: tags (fzf-lua)"},
        ["<Leader>cs"] = {"<Cmd>lua require('fzf-lua').colorschemes()<CR>", "Colorschemes (fzf-lua)"},
        ["<Leader>cl"] = {"<Cmd>lua require('fzf-lua').highlights()<CR>", "Highlights (fzf-lua)"},
        ["<Leader>ch"] = {"<Cmd>lua require('fzf-lua').changes()<CR>", "Changes (fzf-lua)"},
        ["<Leader>jf"] = {"<Cmd>lua require('fzf-lua').jumps()<CR>", "Jumps (fzf-lua)"},
        ['<M-S-">'] = {"<Cmd>lua require('fzf-lua').oldfiles()<CR>", "Oldfiles (fzf-lua)"},
        ["<M-S-/>"] = {"<Cmd>lua require('fzf-lua').marks()<CR>", "Marks: all (fzf-lua)"},
        ["<M-/>"] = {M.marks, "Marks: important (fzf-lua)"},
        -- ["<M-/>"] = {F.ithunk(fzf_lua.marks, {marks = [[<>^.'"]]}), "Marks: builtin (fzf-lua)"},
        ["<C-,>k"] = {"<Cmd>lua require('fzf-lua').keymaps()<CR>", "Keymaps (fzf-lua)"},
        ["<Leader>pa"] = {"<Cmd>lua require('fzf-lua').packadd()<CR>", "Packadd (fzf-lua)"},
        ["<Leader>jB"] = {"<Cmd>lua require('fzf-lua').tags()<CR>", "Tags (fzf-lua)"},
        ["<Leader>jb"] = {"<Cmd>lua require('fzf-lua').btags()<CR>", "Buffer tags (fzf-lua)"},
        ["<M-[>"] = {"<Cmd>lua require('fzf-lua').btags()<CR>", "Buffer tags (fzf-lua)"},
        ["<M-S-{>"] = {"<Cmd>lua require('fzf-lua').tags()<CR>", "Tags (fzf-lua)"},
        ["<LocalLeader>k"] = {"<Cmd>lua require('fzf-lua').tagstack()<CR>", "Tagstack (fzf-lua)"},
        -- ["<M-S-|>"] = {"<Cmd>lua require('fzf-lua').tags()<CR>", "Tags (fzf-lua)"},
        ["<LocalLeader>v"] = {"<Cmd>lua require('fzf-lua').builtin()<CR>", "Builtin (fzf-lua)"},
        ["<LocalLeader>."] = {"<Cmd>lua require('fzf-lua').resume()<CR>", "Resume (fzf-lua)"},
        ["<LocalLeader>w"] = {M.cst_fd, "Files: CWD (fzf-lua)"},
        ["<LocalLeader>d"] = {M.git_grep, "Grep: git (fzf-lua)"},
        ["<Leader>eh"] = {M.edit_zsh, "Edit: zsh (fzf-lua)"},
        ["<Leader>e;"] = {M.edit_git_nvim, "Edit: nvim git (fzf-lua)"},
        ["<Leader>e'"] = {M.grep_nvim, "Grep: nvim (fzf-lua)"},
        ["<Leader>en"] = {M.edit_nvim_source, "Edit: nvim source (fzf-lua)"},
        ["<Leader>eN"] = {M.edit_vim_source, "Edit: vim source (fzf-lua)"},
        ["<LocalLeader>r"] = {M.cst_files, "Git/Files (fzf-lua)"},
    })

    Rc.plugin.fzf_lua = M
end

init()

return M
