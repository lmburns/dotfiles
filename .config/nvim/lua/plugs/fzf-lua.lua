local M = {}

require("dev")
require("common.utils")
local fzf_lua = require("fzf-lua")

function M.setup()
    local actions = require "fzf-lua.actions"

    fzf_lua.setup {
        fzf_bin = "fzf", -- use skim instead of fzf?
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
            width = 0.85, -- window width
            row = 0.35, -- window row position (0=top, 1=bottom)
            col = 0.50, -- window col position (0=left, 1=right)
            -- border argument passthrough to nvim_open_win(), also used
            -- to manually draw the border characters around the preview
            -- window, can be set to 'false' to remove all borders or to
            -- 'none', 'single', 'double' or 'rounded' (default)
            border = {"╭", "─", "╮", "│", "╯", "─", "╰", "│"},
            fullscreen = false, -- start fullscreen?
            hl = {
                normal = "Normal", -- window normal color (fg+bg)
                border = "Normal", -- border color (try 'FloatBorder')
                -- Only valid with the builtin previewer:
                cursor = "Cursor", -- cursor highlight (grep/LSP matches)
                cursorline = "CursorLine", -- cursor line
                search = "Search" -- search matches (ctags)
                -- title       = 'Normal',        -- preview border title (file/buffer)
                -- scrollbar_f = 'PmenuThumb',    -- scrollbar "full" section highlight
                -- scrollbar_e = 'PmenuSbar',     -- scrollbar "empty" section highlight
            },
            preview = {
                -- default     = 'bat',           -- override the default previewer?
                -- default uses the 'builtin' previewer
                border = "noborder", -- border|noborder, applies only to
                -- native fzf previewers (bat/cat/git/etc)
                wrap = "nowrap", -- wrap|nowrap
                hidden = "nohidden", -- hidden|nohidden
                vertical = "down:45%", -- up|down:size
                horizontal = "right:60%", -- right|left:size
                layout = "flex", -- horizontal|vertical|flex
                flip_columns = 120, -- #cols to switch to horizontal on flex
                -- Only valid with the builtin previewer:
                title = true, -- preview border title (file/buf)?
                scrollbar = "float", -- `false` or string:'float|border'
                -- float:  in-window floating border
                -- border: in-border chars (see below)
                scrolloff = "-2", -- float scrollbar offset from right
                -- applies only when scrollbar = 'float'
                scrollchars = {"█", ""}, -- scrollbar chars ({ <full>, <empty> }
                -- applies only when scrollbar = 'border'
                delay = 100, -- delay(ms) displaying the preview
                -- prevents lag on fast scrolling
                winopts = {
                    -- builtin previewer window options
                    number = true,
                    relativenumber = false,
                    cursorline = true,
                    cursorlineopt = "both",
                    cursorcolumn = false,
                    signcolumn = "no",
                    list = false,
                    foldenable = false,
                    foldmethod = "manual"
                }
            },
            on_create = function()
                -- called once upon creation of the fzf main window
                -- can be used to add custom fzf-lua mappings, e.g:
                --   vim.api.nvim_buf_set_keymap(0, "t", "<C-j>", "<Down>",
                --     { silent = true, noremap = true })
            end
        },
        winopts_fn = function()
            -- Use custom borders hls if they exist in the colorscheme
            local border = "Normal"
            local hls = {"TelescopeBorder", "FloatermBorder", "FloatBorder"}
            for _, hl in ipairs(hls) do
                if #vim.fn.synIDattr(vim.fn.hlID(hl), "fg") > 0 then
                    border = hl
                    break
                end
            end
            return {
                hl = {border = border}
                -- preview = {
                --   -- conditionally override the layout paramter thus overriding the 'flex' layout
                --   layout = vim.api.nvim_win_get_width(0)<100 and 'vertical' or 'horizontal'
                -- }
            }
        end,
        keymap = {
            -- These override the default tables completely
            -- no need to set to `false` to disable a bind
            -- delete or modify is sufficient
            builtin = {
                -- neovim `:tmap` mappings for the fzf win
                ["<F1>"] = "toggle-help",
                ["<F2>"] = "toggle-fullscreen",
                -- Only valid with the 'builtin' previewer
                ["<F3>"] = "toggle-preview-wrap",
                ["<F4>"] = "toggle-preview",
                -- Rotate preview clockwise/counter-clockwise
                ["<F5>"] = "toggle-preview-ccw",
                ["<F6>"] = "toggle-preview-cw",
                ["<S-down>"] = "preview-page-down",
                ["<S-up>"] = "preview-page-up",
                ["<S-left>"] = "preview-page-reset"
            },
            fzf = {
                -- fzf '--bind=' options
                ["ctrl-z"] = "abort",
                ["esc"] = "abort",
                ["alt-d"] = "unix-line-discard",
                ["ctrl-d"] = "half-page-down",
                ["ctrl-u"] = "half-page-up",
                ["ctrl-a"] = "beginning-of-line",
                ["ctrl-e"] = "end-of-line",
                ["alt-a"] = "toggle-all",
                -- Only valid with fzf previewers (bat/cat/git/etc)
                ["f3"] = "toggle-preview-wrap",
                ["f4"] = "toggle-preview",
                ["?"] = "toggle-preview",
                ["shift-down"] = "preview-page-down",
                ["shift-up"] = "preview-page-up"
            }
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
                ["alt-q"] = actions.file_sel_to_qf
            },
            buffers = {
                -- providers that inherit these actions:
                --   buffers, tabs, lines, blines
                ["default"] = actions.buf_edit,
                ["ctrl-s"] = actions.buf_split,
                ["ctrl-v"] = actions.buf_vsplit,
                ["ctrl-t"] = actions.buf_tabedit
            }
        },
        fzf_opts = {
            -- options are sent as `<left>=<right>`
            -- set to `false` to remove a flag
            -- set to '' for a non-value flag
            -- for raw args use `fzf_args` instead
            ["--ansi"] = "",
            ["--prompt"] = "> ",
            ["--info"] = "inline",
            ["--height"] = "100%",
            ["--layout"] = "reverse",
            ["--border"] = "none"
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
            cat = {cmd = "cat", args = "--number"},
            bat = {
                cmd = "bat",
                args = "--style=numbers,changes --color always",
                theme = "kimbro", -- bat preview theme (bat --list-themes)
                config = nil -- nil uses $BAT_CONFIG_PATH
            },
            head = {cmd = "head", args = nil},
            git_diff = {
                cmd_deleted = "git diff --color HEAD --",
                cmd_modified = "git diff --color HEAD",
                cmd_untracked = "git diff --color --no-index /dev/null"
                -- pager        = "delta",      -- if you have `delta` installed
            },
            -- === Man
            man = {
                -- NOTE: remove the `-c` flag when using man-db
                cmd = "man %s | col -bx"
            },
            -- === Builtin
            builtin = {
                syntax = true, -- preview syntax highlight?
                syntax_limit_l = 0, -- syntax limit (lines), 0=nolimit
                syntax_limit_b = 1024 * 1024, -- syntax limit (bytes), 0=nolimit
                limit_b = 1024 * 1024 * 10, -- preview limit (bytes), 0=nolimit
                -- preview extensions using a custom shell command:
                -- for example, use `viu` for image previews
                -- will do nothing if `viu` isn't executable
                extensions = {
                    -- neovim terminal only supports `viu` block output
                    ["png"] = {"viu", "-b"},
                    ["jpg"] = {"ueberzug"}
                },
                -- if using `ueberzug` in the above extensions map
                -- set the default image scaler, possible scalers:
                --   false (none), "crop", "distort", "fit_contain",
                --   "contain", "forced_cover", "cover"
                -- https://github.com/seebye/ueberzug
                ueberzug_scaler = "cover"
            }
        },
        -- === Files
        files = {
            -- previewer      = "bat",          -- uncomment to override previewer
            -- (name from 'previewers' table)
            -- set to 'false' to disable
            prompt = "Files❯ ",
            multiprocess = true, -- run command in a separate process
            git_icons = true, -- show git icons?
            file_icons = true, -- show file icons?
            color_icons = true, -- colorize file|git icons
            -- path_shorten   = 1,              -- 'true' or number, shorten path?
            -- executed command priority is 'cmd' (if exists)
            -- otherwise auto-detect prioritizes `fd`:`rg`:`find`
            -- default options are controlled by 'fd|rg|find|_opts'
            -- cmd            = "find . -type f -printf '%P\n'",
            find_opts = [[-type f -not -path '*/\.git/*' -printf '%P\n']],
            rg_opts = "--color=never --files --hidden --follow -g '!.git'",
            fd_opts = "--color=never --type f --hidden --follow --exclude .git",
            actions = {
                -- inherits from 'actions.files', here we can override
                -- or set bind to 'false' to disable a default action
                ["default"] = actions.file_edit,
                -- custom actions are available too
                ["ctrl-y"] = function(selected)
                    print(selected[1])
                end
            }
        },
        -- === Git
        git = {
            -- === Git Files
            files = {
                prompt = "GitFiles❯ ",
                cmd = "git ls-files --exclude-standard",
                multiprocess = true, -- run command in a separate process
                git_icons = true, -- show git icons?
                file_icons = true, -- show file icons?
                color_icons = true -- colorize file|git icons
                -- force display the cwd header line regardles of your current working
                -- directory can also be used to hide the header when not wanted
                -- show_cwd_header = true
            },
            -- === Git Status
            status = {
                prompt = "GitStatus❯ ",
                cmd = "git status -s",
                previewer = "git_diff",
                file_icons = true,
                git_icons = true,
                color_icons = true,
                actions = {
                    -- actions inherit from 'actions.files' and merge
                    ["right"] = {actions.git_unstage, actions.resume},
                    ["left"] = {actions.git_stage, actions.resume}
                }
            },
            -- === Git Commits
            commits = {
                prompt = "Commits❯ ",
                cmd = "git log --pretty=oneline --abbrev-commit --color",
                preview = "git show --pretty='%Cred%H%n%Cblue%an%n%Cgreen%s' --color {1}",
                actions = {["default"] = actions.git_checkout}
            },
            -- === Git Bcommits
            bcommits = {
                prompt = "BCommits❯ ",
                cmd = "git log --pretty=oneline --abbrev-commit --color",
                preview = "git show --pretty='%Cred%H%n%Cblue%an%n%Cgreen%s' --color {1}",
                actions = {
                    ["default"] = actions.git_buf_edit,
                    ["ctrl-s"] = actions.git_buf_split,
                    ["ctrl-v"] = actions.git_buf_vsplit,
                    ["ctrl-t"] = actions.git_buf_tabedit
                }
            },
            -- === Git Branches
            branches = {
                prompt = "Branches❯ ",
                cmd = "git branch --all --color",
                preview = "git log --graph --pretty=oneline --abbrev-commit --color {1}",
                actions = {["default"] = actions.git_switch}
            },
            stash = {
                prompt = "Stash> ",
                cmd = "git --no-pager stash list",
                preview = "git --no-pager stash show --patch --color {1}",
                actions = {
                    ["default"] = actions.git_stash_apply,
                    ["ctrl-x"] = {actions.git_stash_drop, actions.resume}
                },
                fzf_opts = {
                    ["--no-multi"] = "",
                    ["--delimiter"] = "'[:]'"
                }
            },
            icons = {
                ["M"] = {icon = "M", color = "yellow"},
                ["D"] = {icon = "D", color = "red"},
                ["A"] = {icon = "A", color = "green"},
                ["R"] = {icon = "R", color = "yellow"},
                ["C"] = {icon = "C", color = "yellow"},
                ["?"] = {icon = "?", color = "magenta"}
                -- override git icons?
                -- ["M"]        = { icon = "★", color = "red" },
                -- ["D"]        = { icon = "✗", color = "red" },
                -- ["A"]        = { icon = "+", color = "green" },
            }
        },
        -- === Grep
        grep = {
            prompt = "Rg❯ ",
            input_prompt = "Grep For❯ ",
            multiprocess = true, -- run command in a separate process
            git_icons = true, -- show git icons?
            file_icons = true, -- show file icons?
            color_icons = true, -- colorize file|git icons
            -- executed command priority is 'cmd' (if exists)
            -- otherwise auto-detect prioritizes `rg` over `grep`
            -- default options are controlled by 'rg|grep_opts'
            -- cmd            = "rg --vimgrep",
            grep_opts = "--binary-files=without-match --line-number --recursive --color=auto --perl-regexp",
            rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=512",
            -- set to 'true' to always parse globs in both 'grep' and 'live_grep'
            -- search strings will be split using the 'glob_separator' and translated
            -- to '--iglob=' arguments, requires 'rg'
            -- can still be used when 'false' by calling 'live_grep_glob' directly
            rg_glob = false, -- default to glob parsing?
            glob_flag = "--iglob", -- for case sensitive globs use '--glob'
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
                ["ctrl-g"] = {actions.grep_lgrep}
            },
            no_header = false, -- hide grep|cwd header?
            no_header_i = false -- hide interactive header?
        },
        -- === Args
        args = {
            prompt = "Args❯ ",
            files_only = true,
            -- actions inherit from 'actions.files' and merge
            actions = {["ctrl-x"] = {actions.arg_del, actions.resume}}
        },
        -- === Oldfiles
        oldfiles = {
            prompt = "History❯ ",
            cwd_only = false,
            stat_file = true, -- verify files exist on disk
            include_current_session = false, -- include bufs from current session
            winopts = {preview = {horizontal = "right:40%"}}
        },
        -- === Buffers
        buffers = {
            prompt = "Buffers❯ ",
            file_icons = true, -- show file icons?
            color_icons = true, -- colorize file|git icons
            sort_lastused = true, -- sort buffers() by last used
            actions = {
                -- actions inherit from 'actions.buffers' and merge
                -- by supplying a table of functions we're telling
                -- fzf-lua to not close the fzf window, this way we
                -- can resume the buffers picker on the same window
                -- eliminating an otherwise unaesthetic win "flash"
                ["ctrl-x"] = {actions.buf_del, actions.resume}
            }
        },
        -- === Tabs
        tabs = {
            prompt = "Tabs❯ ",
            tab_title = "Tab",
            tab_marker = "<<",
            file_icons = true, -- show file icons?
            color_icons = true, -- colorize file|git icons
            actions = {
                -- actions inherit from 'actions.buffers' and merge
                ["default"] = actions.buf_switch,
                ["ctrl-x"] = {actions.buf_del, actions.resume}
            },
            fzf_opts = {
                -- hide tabnr
                ["--delimiter"] = "'[\\):]'",
                ["--with-nth"] = "2.."
            }
        },
        -- === Lines
        lines = {
            previewer = "builtin", -- set to 'false' to disable
            prompt = "Lines❯ ",
            show_unlisted = false, -- exclude 'help' buffers
            no_term_buffers = true, -- exclude 'term' buffers
            fzf_opts = {
                -- do not include bufnr in fuzzy matching
                -- tiebreak by line no.
                ["--delimiter"] = "'[\\]:]'",
                ["--nth"] = "2..",
                ["--tiebreak"] = "index"
            },
            -- actions inherit from 'actions.buffers' and merge
            actions = {
                ["default"] = {actions.buf_edit_or_qf},
                ["alt-q"] = {actions.buf_sel_to_qf}
            }
            -- actions inherit from 'actions.buffers'
        },
        -- === Blines
        blines = {
            previewer = "builtin", -- set to 'false' to disable
            prompt = "BLines❯ ",
            show_unlisted = true, -- include 'help' buffers
            no_term_buffers = false, -- include 'term' buffers
            fzf_opts = {
                -- hide filename, tiebreak by line no.
                ["--delimiter"] = "'[\\]:]'",
                ["--with-nth"] = "2..",
                ["--tiebreak"] = "index"
            }
            -- actions inherit from 'actions.buffers'
        },
        -- === Tags
        tags = {
            prompt = "Tags❯ ",
            ctags_file = "tags",
            multiprocess = true,
            file_icons = true,
            git_icons = true,
            color_icons = true,
            -- 'tags_live_grep' options, `rg` prioritizes over `grep`
            rg_opts = "--no-heading --color=always --smart-case",
            grep_opts = "--color=auto --perl-regexp",
            actions = {
                -- actions inherit from 'actions.files' and merge
                -- this action toggles between 'grep' and 'live_grep'
                ["ctrl-g"] = {actions.grep_lgrep}
            },
            no_header = false, -- hide grep|cwd header?
            no_header_i = false -- hide interactive header?
        },
        -- === BTags
        btags = {
            prompt = "BTags❯ ",
            ctags_file = "tags",
            multiprocess = true,
            file_icons = true,
            git_icons = true,
            color_icons = true,
            rg_opts = "--no-heading --color=always",
            grep_opts = "--color=auto --perl-regexp",
            fzf_opts = {
                ["--delimiter"] = "'[\\]:]'",
                ["--with-nth"] = "2..",
                ["--tiebreak"] = "index"
            }
            -- actions inherit from 'actions.files'
        },
        -- === Colorschems
        colorschemes = {
            prompt = "Colorschemes❯ ",
            live_preview = true, -- apply the colorscheme on preview?
            actions = {["default"] = actions.colorscheme},
            winopts = {height = 0.55, width = 0.30},
            post_reset_cb = function()
                -- reset statusline highlights after
                -- a live_preview of the colorscheme
                -- require('feline').reset_highlights()
            end
        },
        -- === Quickfix
        quickfix = {file_icons = true, git_icons = true},
        -- === LSP
        lsp = {
            prompt_postfix = "❯ ", -- will be appended to the LSP label
            -- to override use 'prompt' instead
            cwd_only = false, -- LSP/diagnostics for cwd only?
            async_or_timeout = 5000, -- timeout(ms) or 'true' for async calls
            file_icons = true,
            git_icons = false,
            lsp_icons = true,
            ui_select = true, -- use 'vim.ui.select' for code actions
            severity = "hint",
            icons = {
                ["Error"] = {icon = "", color = "red"}, -- error
                ["Warning"] = {icon = "", color = "yellow"}, -- warning
                ["Information"] = {icon = "", color = "blue"}, -- info
                ["Hint"] = {icon = "", color = "magenta"} -- hint
            }
        },
        -- uncomment to disable the previewer
        -- nvim = { marks = { previewer = { _ctor = false } } },
        -- helptags = { previewer = { _ctor = false } },
        -- manpages = { previewer = { _ctor = false } },
        -- uncomment to set dummy win location (help|man bar)
        -- "topleft"  : up
        -- "botright" : down
        -- helptags = { previewer = { split = "topleft" } },
        -- uncomment to use `man` command as native fzf previewer
        -- manpages = { previewer = { _ctor = require'fzf-lua.previewer'.fzf.man_pages } },
        -- optional override of file extension icon colors
        -- available colors (terminal):
        --    clear, bold, black, red, green, yellow
        --    blue, magenta, cyan, grey, dark_grey, white
        -- padding can help kitty term users with
        -- double-width icon rendering
        file_icon_padding = "",
        file_icon_colors = {lua = "blue", rust = "orange"}
        -- uncomment if your terminal/font does not support unicode character
        -- 'EN SPACE' (U+2002), the below sets it to 'NBSP' (U+00A0) instead
        -- nbsp = '\xc2\xa0',
    }

    -- register fzf-lua as vim.ui.select interface
    -- fzf_lua.register_ui_select(
    --     { winopts = { win_height = 0.30, win_width = 0.70, win_row = 0.40 } }
    -- )
end

function M.branch_compare(opts)
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
            require "fzf-lua.path".git_cwd(
            -- change this to whaetever command works best for you:
            -- git diff --name-only $(git merge-base HEAD [SELECTED_BRANCH])
            ("git diff --name-only %s"):format(branch),
            o.cwd
        )
        -- replace the previewer with our custom command
        o.previewer = {
            cmd = require "fzf-lua.path".git_cwd("git diff", o.cwd),
            args = ("--color main %s -- "):format(branch),
            _new = function()
                return require "fzf-lua.previewer".cmd_async
            end
        }
        -- disable git icons, without adjustments they will
        -- display their current status and not the branch status
        -- TODO: supply `files` with `git_diff_cmd`, `git_untracked_cmd`
        o.git_icons = false
        -- reset the default action that was carried over from the
        -- `git_branches` call
        o.actions = nil
        require "fzf-lua".files(o)
    end
    opts.prompt = "BranchCompare❯ "
    opts.actions = {["default"] = branch_compare}
    require "fzf-lua".git_branches(opts)
end

function M.installed_plugins(opts)
    if not opts then
        opts = {}
    end
    opts.prompt = "Plugins❯ "
    opts.cwd = fn.stdpath("data") .. "/site/pack/packer/"
    fzf_lua.files(opts)
end

function M.edit_neovim(opts)
    if not opts then
        opts = {}
    end
    opts.prompt = "<Neovim> "
    opts.cwd = "$XDG_CONFIG_HOME/nvim"
    fzf_lua.files(opts)
end

function M.edit_zsh(opts)
    if not opts then
        opts = {}
    end
    opts.prompt = "~ zsh ~ "
    opts.cwd = "$ZDOTDIR"
    fzf_lua.files(opts)
end

local function map_fzf(mode, key, f, opts, buffer)
    local rhs = function()
        if not pcall(require, "fzf-lua") then
            R("packer").loader("fzf-lua")
        end

        if M[f] then
            R("plugs.fzf-lua")[f](opts or {})
        else
            require("fzf-lua")[f](opts or {})
        end
    end

    require("common.utils").remap(mode, key, rhs, {noremap = true, silent = true, buffer = buffer})
end

function init()
    M.setup()

    -- -- map_fzf("n", "<A-f>", "files")
    -- map_fzf("n", "<Leader>qo", "quickfix")
    -- map_fzf("n", "<Leader>ll", "loclist")
    -- -- map_fzf("n", "<A-,>", "oldfiles")
    -- map_fzf("n", "<LocalLeader>e", "live_grep")
    -- map_fzf("n", "<LocalLeader>h", "man_pages")
    -- map_fzf("n", "<Leader>ht", "help_tags")
    -- map_fzf("n", "<Leader>cs", "colorschemes")
    -- map_fzf("n", "<Leader>cm", "commands")
    -- map_fzf("n", "<Leader>ch", "changes")
    -- map_fzf("n", "<C-l>k", "keymaps")
    -- map_fzf("n", "<Leader>jf", "jumps")
    -- map_fzf("n", "<Leader>pa", "packadd")
    -- map_fzf("n", "<LocalLeader>v", "builtin")

    require("which-key").register(
        {
            -- ["<Leader>cm"] = {":lua require('fzf-lua').commands()<CR>", "Commands (fzf-lua)"},
            ["<Leader>qo"] = {":lua require('fzf-lua').quickfix()<CR>", "Quickfix (fzf-lua)"},
            ["<Leader>ll"] = {":lua require('fzf-lua').loclist()<CR>", "Location list (fzf-lua)"},
            ["<Leader>tl"] = {":lua require('fzf-lua').tabs()<CR>", "Location list (fzf-lua)"},
            ["<LocalLeader>e"] = {":lua require('fzf-lua').live_grep()<CR>", "Live grep (fzf-lua)"},
            ["<LocalLeader>h"] = {":lua require('fzf-lua').man_pages()<CR>", "Man pages (fzf-lua)"},
            ["<Leader>ht"] = {":lua require('fzf-lua').help_tags()<CR>", "Help tags (fzf-lua)"},
            ["<Leader>cs"] = {":lua require('fzf-lua').colorschemes()<CR>", "Colorschemes (fzf-lua)"},
            ["<Leader>ch"] = {":lua require('fzf-lua').changes()<CR>", "Changes (fzf-lua)"},
            ["<C-l>k"] = {":lua require('fzf-lua').keymaps()<CR>", "Keymaps (fzf-lua)"},
            ["<Leader>jf"] = {":lua require('fzf-lua').jumps()<CR>", "Jumps (fzf-lua)"},
            ["<Leader>pa"] = {":lua require('fzf-lua').packadd()<CR>", "Packadd (fzf-lua)"},
            ["<LocalLeader>v"] = {":lua require('fzf-lua').builtin()<CR>", "Builtin (fzf-lua)"}
        }
    )

    -- map_fzf("n", "<Leader>e;", "edit_neovim")
end

init()

return M
