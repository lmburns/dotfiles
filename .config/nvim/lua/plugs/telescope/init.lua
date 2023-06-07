---@module 'plugs.telescope'
local M = {}

local lazy = require("usr.lazy")
local shared = require("usr.shared")
local F = shared.F

local telescope = F.npcall(lazy.require_on.call_rec, "telescope")
if not telescope then
    return
end

local neoclip = lazy.require("plugs.neoclip")

-- local action_generate = require("telescope.actions.generate")
local action_layout = require("telescope.actions.layout")
local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")
local builtin = require("telescope.builtin")
local conf = require("telescope.config").values
local finders = require("telescope.finders")
local make_entry = require("telescope.make_entry")
local pickers = require("telescope.pickers")
local previewers = require("telescope.previewers")
local themes = require("telescope.themes")
local sorters = require("telescope.sorters")
local tutils = require("telescope.utils")

-- FIX: after removing impatient, these won't work on startup
-- local fb_utils = require("telescope._extensions.file_browser.utils")
-- local z_utils = lazy.require("telescope._extensions.zoxide.utils")

local P = require("plugs.telescope.pickers")
local Job = require("plenary.job")
local Path = require("plenary.path")
local wk = require("which-key")

local utils = shared.utils
local log = require("usr.lib.log")
local mpi = require("usr.api")
local command = mpi.command
local map = mpi.map

local fn = vim.fn
local api = vim.api
local cmd = vim.cmd
local uv = vim.loop
local env = vim.env

-- Custom actions
local c_actions = {
    which_key = function(opts)
        opts = opts or {}
        local inner = {
            name_width = 20,          -- typically leads to smaller floats
            max_height = 0.5,         -- increase potential maximum height
            separator = "  ",      -- change sep between mode, keybind, and name
            close_with_action = true, -- do not close float on action
            normal_hl = "TelescopePrompt",
            border_hl = "Parameter",
        }

        opts = vim.tbl_deep_extend("force", inner, opts)

        -- Doing this prevents anonymouse function notification
        local function which_key(prompt_bufnr)
            actions.which_key(prompt_bufnr, opts)
        end

        return which_key
    end,
    insert_space = function(_)
        -- api.nvim_input(" ")
        utils.normal("n", "<Space>")
    end,
    single_selection_hop = function(prompt_bufnr)
        telescope.extensions.hop.hop(prompt_bufnr)
    end,
    -- custom hop loop to multi selects and sending selected entries to quickfix list
    multi_selection_hop = function(prompt_bufnr)
        local opts = {
            callback = actions.toggle_selection,
            loop_callback = actions.send_selected_to_qflist,
        }
        telescope.extensions.hop._hop_loop(prompt_bufnr, opts)
    end,
    set_prompt_to_entry_value = function(prompt_bufnr)
        local entry = action_state.get_selected_entry()
        if not entry or not type(entry) == "table" then
            return
        end

        action_state.get_current_picker(prompt_bufnr):reset_prompt(entry.ordinal)
    end,
    yank = function(_prompt_bufnr)
        local entry = action_state.get_selected_entry()
        require("usr.lib.yank").yank_reg(vim.v.register, entry.display)
    end,
    debug = function(_prompt_bufnr)
        local entry = action_state.get_selected_entry()
        N(entry)
    end,
    qf_multi_select = function(prompt_bufnr)
        local picker = action_state.get_current_picker(prompt_bufnr)
        local num_selections = #picker:get_multi_selection()

        if num_selections > 1 then
            actions.send_selected_to_qflist(prompt_bufnr)
            actions.open_qflist(prompt_bufnr)
        else
            actions.file_edit(prompt_bufnr)
        end
    end,
    -- FIX: Get this to work better
    cd_parent = function(prompt_bufnr, opts)
        -- local current_picker = action_state.get_current_picker(prompt_bufnr)
        -- local finder = current_picker.finder
        -- local parent_dir = Path:new(finder.path):parent()
        --
        -- finder.path = parent_dir:absolute()
        -- finder.cwd = finder.path
        -- cmd("lcd " .. finder.path)
        -- current_picker:refresh(finder, {reset_prompt = true, multi = current_picker._multi})

        local current_picker = action_state.get_current_picker(prompt_bufnr)
        local finder = current_picker.finder
        local parent_dir = Path:new(finder.path):parent()

        opts.cwd = parent_dir:absolute()
        -- Doesn't work cause it is overridden
        current_picker.prompt_border:change_title(opts.cwd)

        actions.close(prompt_bufnr)
        builtin.live_grep(opts)
    end,
}

---Create a previewer based off of the file's mimetype
---@param filepath string
---@param bufnr number
---@param opts table
local new_maker = function(filepath, bufnr, opts)
    filepath = fn.expand(filepath) --[[@as string]]
    Job:new({
        command = "file",
        args = {"--mime-type", "-b", filepath},
        on_exit = function(j)
            local mime_class = vim.split(j:result()[1], "/")[1]
            local mime_type = j:result()[1]
            if
                mime_type == "inode/directory"
                or mime_class == "text"
                or (mime_class == "application"
                    and mime_type ~= "application/x-pie-executable")
            then
                previewers.buffer_previewer_maker(filepath, bufnr, opts)
            else
                -- This might be a little quicker than the binary-buffer previewer
                vim.schedule(function()
                    api.nvim_buf_set_lines(bufnr, 0, -1, false, {"BINARY"})
                end)
            end
        end,
    }):sync()
end
-- ============================ Config ===========================

telescope.setup({
    defaults = {
        history = {
            path = lb.dirs.data .. "/databases/telescope_history.sqlite3",
            limit = 1000,
        },
        dynamic_preview_title = true,
        preview = {
            filesize_limit = 5,
            timeout = 150,
            treesitter = true,
            filesize_hook = function(filepath, bufnr, opts)
                local path = Path:new(filepath)
                local height = api.nvim_win_get_height(opts.winid)
                local lines = vim.split(path:head(height), "[\r]?\n")
                api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
            end,
        },
        prompt_prefix = "❱ ",
        selection_caret = "❱ ",
        entry_prefix = "  ",
        multi_icon = "<>",
        -- cache_picker = { num_pickers = 20 },
        initial_mode = "insert",
        winblend = 3,
        wrap_results = false,
        set_env = {["COLORTERM"] = "truecolor"},
        -- Direction "better" results are sorted towards
        --     ascending, descending
        sorting_strategy = "descending",
        -- How the cursor acts after each sort iteration
        --     reset, follow, row, closest, none
        selection_strategy = "reset",
        -- What happens if you try to scroll past the view of the picker
        --     cycle, limit
        scroll_strategy = "cycle",
        layout_strategy = "horizontal", -- "flex"
        cycle_layout_list = {"horizontal", "vertical"},
        use_less = true,
        color_devicons = true,
        border = {},
        borderchars = {"─", "│", "─", "│", "╭", "╮", "╯", "╰"},
        path_display = {},
        mappings = {
            i = {
                ["<C-x>"] = false,
                ["<C-Left>"] = actions.move_selection_next,
                ["<C-Right>"] = actions.move_selection_previous,
                ["<C-d>"] = actions.results_scrolling_down,
                ["<C-h>"] = c_actions.single_selection_hop,
                ["<C-j>"] = actions.cycle_history_prev,
                ["<C-k>"] = actions.cycle_history_next,
                ["<C-o>"] = c_actions.which_key(),
                ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
                ["<C-s>"] = actions.select_horizontal,
                ["<C-t>"] = action_layout.toggle_preview,
                ["<C-u>"] = actions.results_scrolling_up,
                ["<C-y>"] = c_actions.yank,
                ["<M-,>"] = c_actions.qf_multi_select,
                ["<M-;>"] = c_actions.multi_selection_hop,
                ["<M-[>"] = actions.cycle_history_prev,
                ["<M-]>"] = actions.cycle_history_next,
                ["<M-a>"] = actions.select_all,
                ["<M-p>"] = action_layout.toggle_prompt_position,
                ["<M-q>"] = actions.smart_send_to_qflist,
                ["<Tab>"] = actions.toggle_selection + actions.move_selection_next,
            },
            n = {
                ["-"] = action_layout.toggle_mirror,
                ["<C-d>"] = actions.results_scrolling_down,
                ["<C-o>"] = c_actions.which_key(),
                ["<C-q>"] = actions.send_selected_to_qflist,
                ["<C-u>"] = actions.results_scrolling_up,
                ["<C-y>"] = c_actions.yank,
                ["<Down>"] = actions.move_selection_next,
                ["<ESC>"] = actions.close,
                ["<M-,>"] = actions.smart_send_to_qflist,
                ["<M-[>"] = actions.cycle_history_prev,
                ["<M-]>"] = actions.cycle_history_next,
                ["<M-q>"] = c_actions.qf_multi_select,
                ["<Up>"] = actions.move_selection_previous,
                ["?"] = action_layout.toggle_preview,
                ["G"] = actions.move_to_bottom,
                ["H"] = actions.move_to_top,
                ["L"] = actions.move_to_bottom,
                ["M"] = actions.move_to_middle,
                ["gg"] = actions.move_to_top,
                ["j"] = actions.move_selection_next,
                ["k"] = actions.move_selection_previous,
            },
        },
        vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--pcre2",
        },
        find_command = {
            "fd",
            "--type=f",
            "--hidden",
            "--follow",
            "--exclude=.git",
        },
        file_ignore_patterns = {
            "%.jpg",
            "%.jpeg",
            "%.png",
            "%.gif",
            "%.svg",
            "%.otf",
            "%.ttf",
            "%.xcf",
            "%.xls",
            "%.ods",
            "%.odt",
            "%.pdf",
            "^tags$",
            "^%.tags$",
            "target/",
            "%.git/",
            "%.vscode/",
            "node_modules/",
            "%.mypy_cache/",
            "%.ruff_cache/",
            "__pycache__/",
            "_backup/",
            "sessions/",
            "^lua-language-server/",
            "lua-language-server",
            "cache",
            "parser.c",
            "_disabled",
        },
        file_sorter = sorters.get_fuzzy_file,
        generic_sorter = sorters.get_generic_fuzzy_sorter,
        file_previewer = previewers.vim_buffer_cat.new,
        grep_previewer = previewers.vim_buffer_vimgrep.new,
        qflist_previewer = previewers.vim_buffer_qflist.new,
        buffer_previewer_maker = new_maker,
        layout_config = {
            width = 0.95,
            height = 0.85,
            horizontal = {
                mirror = false,
                prompt_position = "bottom",
                -- preview_cutoff = 120,
                preview_width = function(_, cols, _)
                    if cols > 200 then
                        return math.floor(cols * 0.4)
                    else
                        return math.floor(cols * 0.5)
                    end
                end,
            },
            vertical = {
                width = 0.9,
                height = 0.95,
                mirror = false,
                prompt_position = "bottom",
                -- preview_cutoff = 120,
                preview_width = 0.5,
            },
            flex = {horizontal = {preview_width = 0.9}},
        },
    },
    pickers = {
        current_buffer_fuzzy_find = {
            tiebreak = function(a, b)
                return a.lnum < b.lnum
            end,
        },
        oldfiles = {
            path_display = {"truncate"},
            -- path_display = {"smart"},
            layout_strategy = "horizontal",
            layout_config = {preview_width = 0.45},
        },
        buffers = {
            sort_mru = true,
            -- sort_lastused = true,
            preview = true,
            only_cwd = false,
            show_all_buffers = true,
            ignore_current_buffer = true,
            theme = "dropdown",
            sorter = sorters.get_substr_matcher(),
            selection_strategy = "closest",
            path_display = {"smart"},
            layout_strategy = "center",
            winblend = 0,
            layout_config = {width = 70},
            color_devicons = true,
            mappings = {
                i = {["<c-d>"] = actions.delete_buffer},
                n = {
                    ["<c-d>"] = actions.delete_buffer,
                    ["x"] = function(prompt_bufnr)
                        local current_picker = action_state.get_current_picker(
                            prompt_bufnr
                        )
                        local selected_bufnr = action_state.get_selected_entry()
                            .bufnr

                        --- get buffers with lower number
                        local replacement_buffers = {}
                        for entry in current_picker.manager:iter() do
                            if entry.bufnr < selected_bufnr then
                                table.insert(
                                    replacement_buffers, 1, entry.bufnr
                                )
                            end
                        end

                        current_picker:delete_selection(
                            function(selection)
                                local bufnr = selection.bufnr
                                -- get associated window(s)
                                local winids = fn.win_findbuf(bufnr)
                                -- get windows in current tab to check
                                local tabwins = api.nvim_tabpage_list_wins(0)
                                -- fill winids with new empty buffers
                                for _, winid in ipairs(winids) do
                                    if vim.tbl_contains(tabwins, winid) then
                                        local new_buf = F.if_nil(
                                            table.remove(
                                                replacement_buffers
                                            ), api.nvim_create_buf(
                                                false, true
                                            )
                                        )
                                        api.nvim_win_set_buf(winid, new_buf)
                                    end
                                end
                                -- remove buffer at last
                                api.nvim_buf_delete(bufnr, {force = true})
                            end
                        )
                    end,
                },
            },
        },
        live_grep = {
            grep_open_files = false,
            only_sort_text = true,
            theme = "ivy",
            -- cwd = fn.expand("%:p:h"),
            on_input_filter_cb = function(prompt)
                -- AND operator for live_grep like how fzf handles spaces with wildcards in rg
                return {
                    prompt = prompt:gsub("%s", ".*"),
                }
            end,
        },
        find_files = {
            theme = "ivy",
            find_command = {"fd", "--type", "f", "--strip-cwd-prefix"},
            on_input_filter_cb = function(prompt)
                if prompt:sub(#prompt) == "@" then
                    vim.schedule(
                        function()
                            local prompt_bufnr = api.nvim_get_current_buf()
                            actions.select_default(prompt_bufnr)
                            builtin.current_buffer_fuzzy_find()
                            -- properly enter prompt in insert mode
                            cmd[[normal! A]]
                        end
                    )
                end
            end,
        },
        git_commits = {
            mappings = {
                i = {
                    ["<C-l>"] = function(prompt_bufnr)
                        R("telescope.actions").close(prompt_bufnr)
                        local value = action_state.get_selected_entry()
                            .value
                        cmd.DiffviewOpen(("%s~1.. %s"):format(value, value))
                    end,
                    ["<C-s>"] = function(prompt_bufnr)
                        R("telescope.actions").close(prompt_bufnr)
                        local value = action_state.get_selected_entry()
                            .value
                        cmd.DiffviewOpen(value)
                    end,
                    ["<C-u>"] = function(prompt_bufnr)
                        R("telescope.actions").close(prompt_bufnr)
                        local value = action_state.get_selected_entry().value
                        local rev = tutils.get_os_command_output({
                            "git",
                            "rev-parse",
                            "upstream/master",
                        }, fn.expand("%:p:h") or uv.cwd())[1]
                        cmd.DiffviewOpen(("%s %s"):format(rev, value))
                    end,
                },
            },
        },
    },
    extensions = {
        bookmarks = {
            selected_browser = "buku",
            url_open_command = "handlr open",
            url_open_plugin = nil,
            full_path = true,
            firefox_profile_name = nil,
        },
        fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
        },
        fzf_writer = {
            minimum_grep_characters = 2,
            minimum_files_characters = 2,
            -- Disabled by default.
            -- Will probably slow down some aspects of the sorter, but can make color highlights.
            -- I will work on this more later.
            use_highlighter = true,
        },
        rualdi = {
            prompt_title = "Rualdi",
            alias_hl = "MoreMsg",
            path_hl = "Comment",
            opener = "Lfnvim",
            theme = "ivy",
        },
        hop = {
            -- keys define your hop keys in order; defaults to roughly lower- and uppercased home row
            keys = {
                "a",
                "s",
                "d",
                "f",
                "q",
                "w",
                "e",
                "r",
                "t",
                ";",
                "b",
                "z",
                "x",
                "i",
                "o",
                "y",
                "j",
                "k",
                "l",
                "m",
            },
            -- Highlight groups to link to signs and lines; the below configuration refers to demo
            -- sign_hl typically only defines foreground to possibly be combined with line_hl
            sign_hl = {"WarningMsg", "Title"},
            -- optional, typically a table of two highlight groups that are alternated between
            line_hl = {"CursorLine", "Normal"},
            -- options specific to `hop_loop`
            -- true temporarily disables Telescope selection highlighting
            clear_selection_hl = false,
            -- highlight hopped to entry with telescope selection highlight
            -- note: mutually exclusive with `clear_selection_hl`
            trace_entry = true,
            -- jump to entry where hoop loop was started from
            reset_selection = true,
        },
        frecency = {
            db_root = lb.dirs.data .. "/databases",
            show_scores = true,
            show_unindexed = true,
            ignore_patterns = {
                "*.git/*",
                "*/tmp/*",
                "*/node_modules/*",
                "*/target/*",
            },
            disable_devicons = false,
            default_workspace = "cwd",
            workspaces = {
                conf = "/home/lucas/.config",
                nvim = "/home/lucas/.config/nvim",
                data = "/home/lucas/.local/share",
                project = "/home/lucas/projects",
            },
        },
        file_browser = {
            theme = "ivy",
            -- These aren't working
            attach_mappings = function(prompt_bufnr, map)
                local current_picker = action_state.get_current_picker(prompt_bufnr)

                local modify_cwd = function(new_cwd)
                    local finder = current_picker.finder

                    finder.path = new_cwd
                    finder.files = true
                    current_picker:refresh(false, {reset_prompt = true})
                end

                map("i", "-", function()
                    modify_cwd(current_picker.cwd .. "/..")
                end)

                map("i", "~", function()
                    modify_cwd(fn.expand("~"))
                end)

                map("n", "yy", function()
                    local entry = action_state.get_selected_entry()
                    require("usr.lib.yank").yank_reg(vim.v.register, entry.value)
                    -- vim.fn.setreg("+", entry.value)
                end)

                return true
            end,
        },
        aerial = {
            -- Display symbols as <root>.<parent>.<symbol>
            show_nesting = true,
        },
        heading = {treesitter = true},
        -- This needs to be used on setup
        zoxide = {
            prompt_title = "[ Zoxide List ]",
            -- Zoxide list command with score
            list_command = "zoxide query -ls",
            mappings = {
                default = {
                    action = function(selection)
                        cmd.cd(selection.path)
                    end,
                    after_action = function(selection)
                        print("Directory changed to " .. selection.path)
                    end,
                },
                -- ["<C-s>"] = {
                --     action = require("telescope._extensions.zoxide.utils").create_basic_command("split"),
                -- },
                -- ["<C-v>"] = {
                --     action = z_utils.create_basic_command("vsplit"),
                -- },
                -- ["<C-e>"] = {
                --     action = z_utils.create_basic_command("edit"),
                -- },
                ["<C-b>"] = {
                    keepinsert = true,
                    -- FIX:
                    action = function(selection)
                        R("telescope").extensions.file_browser.file_browser({cwd = selection.path})
                    end,
                },
                ["<C-f>"] = {
                    keepinsert = true,
                    action = function(selection)
                        builtin.find_files({cwd = selection.path})
                    end,
                },
                ["<A-x>"] = {
                    keepinsert = true,
                    action = function(selection)
                        builtin.live_grep({
                            search_dirs = selection.path,
                            initial_mode = "insert",
                        })
                    end,
                },
            },
        },
        -- project = {
        --     base_dirs = (function()
        --         local dirs = {}
        --         local f = "~/ghq"
        --         if uv.fs_stat(fn.expand(f)) then
        --             table.insert(dirs, {f, max_depth = 5})
        --         end
        --         f = "~/projects"
        --         if uv.fs_stat(fn.expand(f)) then
        --             table.insert(dirs, {f, max_depth = 3})
        --         end
        --
        --         return #dirs == 0 and nil or dirs
        --     end)()
        -- }
        -- ["ui-select"] = {
        --     themes.get_dropdown {}
        -- },
    },
})

-- ============================ Setup ============================

local options = {
    hidden = true,
    path_display = {},
    layout_strategy = "horizontal",
    layout_config = {preview_width = 0.65},
    border = true,
    borderchars = {"─", "│", "─", "│", "╭", "╮", "╯", "╰"},
}

-- ========================== Builtin ==========================

-- TODO: prevent showing currently open file
---Custom files function. If it is in a git directory, use that as root, else use CWD
---Note that there should be no need for `lcd`. The `cwd` option should be enough
M.cst_files = function()
    if env.GIT_WORK_TREE == env.DOTBARE_TREE then
        builtin.git_files(options)
    else
        local cwd = fn.expand("%:p:h")
        local root = require("usr.shared.utils.git").root(cwd)
        cmd.lcd(cwd)
        options.cwd = cwd

        if #root == 0 then
            -- Use the current filename instead of the directory
            builtin.find_files(options)
        else
            builtin.git_files(options)
        end
    end
end

M.cst_fd = function()
    local cwd = fn.expand("%:p:h")
    cmd.lcd(cwd)
    options.cwd = cwd
    options.sorting_strategy = "descending"

    builtin.find_files(options)
end

M.cst_buffers = function()
    builtin.buffers(
        themes.get_dropdown{
            preview = true,
            only_cwd = false,
            sort_mru = true,
            show_all_buffers = false,
            ignore_current_buffer = true,
            sort_lastused = true,
            theme = "dropdown",
            sorter = sorters.get_substr_matcher(),
            selection_strategy = "closest",
            path_display = {"smart"},
            layout_strategy = "center",
            winblend = 0,
            layout_config = {width = 70},
            color_devicons = true,
            mappings = {
                i = {["<c-d>"] = actions.delete_buffer},
                n = {["<c-d>"] = actions.delete_buffer},
            },
        }
    )
end

---Custom grep current working directory (including open file)
---@param opts table
builtin.grep_cwd = function(opts)
    local cwd = fn.expand("%:p:h")
    local h1 = fn.fnamemodify(cwd, ":t")
    local h2 = fn.fnamemodify(cwd, ":h:t")
    local h3 = fn.fnamemodify(cwd, ":h:h:t")
    local default = {
        prompt_title = ("Grep [ %s/%s/%s ]"):format(h3, h2, h1),
        mappings = conf.mappings,
        opts = opts or {},
        path_display = {"smart"},
        grep_open_files = false,
        on_input_filter_cb = function(prompt)
            -- AND operator for live_grep like how fzf handles spaces with wildcards in rg
            return {prompt = prompt:gsub("%s", ".*")}
        end,
        theme = "ivy",
        sorting_strategy = "ascending",
        layout_strategy = "bottom_pane",
        layout_config = {height = 25},
        border = true,
        borderchars = {
            prompt = {"─", " ", " ", " ", "─", "─", " ", " "},
            results = {" "},
            preview = {"─", "│", "─", "│", "╭", "╮", "╯", "╰"},
        },
        -- vimgrep_arguments = {
        --     "rg",
        --     "--color=never",
        --     "--no-heading",
        --     "--with-filename",
        --     "--line-number",
        --     "--column",
        --     "--smart-case",
        --     "--pcre2",
        --     -- ("--glob=%s"):format(fn.expand("%"))
        -- }
    }

    default.cwd = fn.expand("%:p:h")
    default.attach_mappings = function(_, map)
        map("n", "<M-i>", function(prompt_bufnr)
            c_actions.cd_parent(prompt_bufnr, default)
        end)
        map("i", "<M-i>", function(prompt_bufnr)
            c_actions.cd_parent(prompt_bufnr, default)
        end)

        return true
    end

    builtin.live_grep(default)
end

M.cst_buffer_fuzzy_find = function()
    builtin.current_buffer_fuzzy_find{
        layout_config = {
            prompt_position = "top",
            preview_width = 0,
        },
        sorting_strategy = "ascending",
        layout_strategy = "horizontal",
    }
end

M.cst_commits = function()
    builtin.git_commits({
        layout_strategy = "horizontal",
        layout_config = {preview_width = 0.55},
    })
end

M.keymaps = function(mode)
    local title = ""
    mode = type(mode) == "string" and {mode} or mode
    for _, m in ipairs(mode) do
        if m == "n" then
            title = ("%s,%s"):format(title, "Normal")
        elseif m == "i" then
            title = ("%s,%s"):format(title, "Insert")
        elseif m == "o" then
            title = ("%s,%s"):format(title, "Operator")
        end
    end
    title = title:trim(",")

    builtin.keymaps({
        modes = mode,
        show_plug = true,
        prompt_title = ("Mappings (%s)"):format(title),
    })
end

-- ========================== Builtin ============================
-- Grep a string with a prompt
M.grep_prompt = function(opts)
    opts.search = fn.input("Grep String > ")
    builtin.grep_cwd(opts)
end

-- TODO: Get this to work for dotbare git
---Grep in the base of a git directory
---@param opts table
builtin.git_grep = function(opts)
    opts.search_dirs = {}
    opts.search_dirs[1] = tutils.get_os_command_output{
        "git",
        "rev-parse",
        "--show-toplevel",
    }[1]

    if utils.is.empty(opts.search_dirs) or utils.is.empty(opts.search_dirs[1]) then
        log.err("Not in a git directory")
        return
    end

    builtin.live_grep({
        mappings = conf.mappings,
        opts = opts,
        prompt_title = "~ Git Grep ~",
        search_dirs = opts.search_dirs,
        path_display = {"smart"},
    })
end

---Search for a neovim configuration file
builtin.edit_nvim = function()
    builtin.fd({
        -- Frecency won't work with changed prompt title
        -- prompt_title = "< Search Nvim >",

        -- FIX: Theme doesn't change
        theme = "ivy",
        path_display = {"smart"},
        prompt_prefix = "  ",
        search_dirs = {"~/.config/nvim"},
        find_command = {
            "fd",
            "--type=f",
            "--hidden",
            "--follow",
            "--exclude=.git",
            "--exclude=_disabled",
            "--exclude=_backup",
            "--exclude=sessions",
        },
        attach_mappings = function(_, map)
            map("i", "<C-y>", c_actions.set_prompt_to_entry_value)

            -- TODO: Find something useful for this
            -- actions.select_default:replace_if(
            --     function()
            --       -- If this fails, then do regular default
            --     end, function()
            --       -- Do something if first returns true
            --     end
            -- )

            return true
        end,
    })
end

-- FIX: Insert mode doesn't start
builtin.grep_nvim = function()
    builtin.live_grep({
        initial_mode = "insert",
        path_display = {"smart"},
        search_dirs = {"~/.config/nvim"},
        prompt_title = "~ Nvim Grep ~",
    })
end

-- Theme isn't working
builtin.edit_zsh = function()
    builtin.fd({
        theme = "ivy",
        path_display = {"smart"},
        search_dirs = {"~/.config/zsh"},
        prompt_prefix = "  ",
        prompt_title = "~ Edit ZSH ~",
        find_command = {
            "fd",
            "--type=f",
            "--hidden",
            "--follow",
            "--exclude=.git",
            "--exclude=_backup",
            "--exclude=sessions",
        },
        hidden = true,
    })
end

---Find all dotfiles in my git repository
---@param opts table?
builtin.edit_dotfiles = function(opts)
    opts = opts or {}
    opts.cwd = lb.dirs.home
    opts.entry_maker = opts.entry_maker or make_entry.gen_from_file(opts)

    pickers.new(opts, {
        prompt_title = "~~ Dotfiles ~~",
        finder = finders.new_oneshot_job(
            {
                "dotbare",
                "ls-tree",
                "--full-tree",
                "-r",
                "--name-only",
                "HEAD",
            }, opts
        ),
        -- previewer = previewers.cat.new(opts),
        previewer = conf.file_previewer(opts),
        sorter = conf.file_sorter(opts),
    }):find()
end

-- TODO: Fix and get a better list of file paths
M.grep_tags = function()
    local search_dirs = {}
    local files = fn.globpath(vim.o.runtimepath, "doc/*", 1, 1)
    for _, file in ipairs(files) do
        if file ~= "tags" then
            table.insert(search_dirs, file)
        end
    end

    builtin.live_grep({
        initial_mode = "insert",
        path_display = {"smart"},
        search_dirs = search_dirs,
        prompt_title = "Grep Tags",
    })
end

builtin.plugins = function(_opts)
    builtin.find_files({
        cwd = lb.dirs.data .. "/site/pack/packer/",
    })
end

-- builtin.tags = P.tags
builtin.windows = F.thunk(P.windows)
builtin.changes = F.thunk(P.changes)
builtin.scriptnames = F.thunk(P.scriptnames)
builtin.args = F.thunk(P.args)
builtin.cmarks = F.thunk(P.marks)
builtin.live_grep_in_folder = F.thunk(P.live_grep_in_folder)

-- ========================= Extensions ==========================
builtin.ultisnips = F.thunk(telescope.extensions.ultisnips.ultisnips)
builtin.coc = F.thunk(telescope.extensions.coc.coc)
builtin.ghq = F.thunk(telescope.extensions.ghq.list)
builtin.frecency = F.thunk(telescope.extensions.frecency.frecency)
builtin.notify = F.thunk(telescope.extensions.notify.notify)
builtin.zoxide = F.thunk(telescope.extensions.zoxide.list)
builtin.rualdi = F.thunk(telescope.extensions.rualdi.list)
builtin.urlview = F.thunk(telescope.extensions.urlview.urlview)
builtin.todo = F.thunk(telescope.extensions["todo-comments"].todo)
builtin.bookmarks = F.thunk(telescope.extensions.bookmarks.bookmarks)
builtin.heading = F.thunk(telescope.extensions.heading.heading)
builtin.lazygit = F.thunk(telescope.extensions.lazygit.lazygit)
builtin.projects = F.thunk(telescope.extensions.projects.projects)
builtin.gh_issues = F.thunk(telescope.extensions.gh.issues)
builtin.gh_pull_request = F.thunk(telescope.extensions.gh.pull_request)
builtin.gh_gist = F.thunk(telescope.extensions.gh.gist)
builtin.neoclip = F.thunk(telescope.extensions.neoclip.default)
builtin.macroclip = F.thunk(telescope.extensions.macroscope.default)
builtin.noice = F.thunk(telescope.extensions.noice.noice)
builtin.yanky = F.thunk(telescope.extensions.yank_history.yank_history)

-- builtin.possession = F.thunk(telescope.extensions.possession.list)
-- builtin.undo = F.thunk(telescope.extensions.undo.undo)
-- builtin.aerial = F.thunk(telescope.extensions.aerial.aerial)

local function init()
    map("n", "<C-,>i", "<Cmd>lua require('plugs.telescope').keymaps('n')<CR>")
    map("i", "<C-,>i", "<Cmd>lua require('plugs.telescope').keymaps('i')<CR>")
    map(
        "x",
        "<C-,>i",
        "require('plugs.telescope').keymaps({'x', 'v', 's'})",
        {lcmd = true}
    )
    map("o", "<C-,>i", "<Cmd>lua require('plugs.telescope').keymaps('o')<CR>")

    command(
        "Ghq",
        F.ithunk(telescope.extensions.ghq.list),
        {nargs = 0, desc = "GHQ (github)"}
    )

    -- ========================== Mappings ===========================

    wk.register({
        [";b"] = {":Telescope builtin<CR>", "Builtins (telescope)"},
        [";c"] = {":Telescope commands<CR>", "Commands (telescope)"},
        ["<LocalLeader>m"] = {":Telescope bookmarks<CR>", "Buku Bookmarks (telescope)"},
        [";h"] = {":Telescope man_pages<CR>", "Man pages (telescope)"},
        [";H"] = {":Telescope heading<CR>", "Heading (telescope)"},
        ["<Leader>rm"] = {":Telescope reloader<CR>", "Reload Lua module (telescope)"},
        [";r"] = {":Telescope git_files<CR>", "Find git files (telescope)"},
        [";k"] = {":Telescope keymaps<CR>", "Keymaps (telescope)"},
        [";z"] = {":Telescope zoxide list<CR>", "Zoxide (telescope)"},
        ["<Leader>;"] = {
            ":lua require('plugs.telescope').cst_buffer_fuzzy_find()<CR>",
            "Buffer lines (telescope)",
        },
        -- ["q:"] = {":Telescope command_history<CR>", "Telescope command history"},
        -- ["q/"] = {":Telescope search_history<CR>", "Telescope search history"},
        -- ["<A-/>"] = {":Telescope marks<CR>", "Telescope marks"},
        ["<A-.>"] = {":Telescope frecency<CR>", "Frecency (telescope)"},
        ["<A-,>"] = {":Telescope oldfiles<CR>", "Oldfiles (telescope)"},
        ["<LocalLeader>s"] = {
            F.ithunk(telescope.extensions.aerial.aerial,
                {layout_config = {prompt_position = "bottom"}}),
            "Symbols: Aerial",
        },
        ["<LocalLeader>S"] = {
            F.ithunk(builtin.treesitter, {layout_config = {prompt_position = "bottom"}}),
            "Symbols: Treesitter",
        },
        ["<LocalLeader>,"] = {"<Cmd>Telescope resume<CR>", "Resume (telescope)"},
    })

    -- Coc
    wk.register({
        ["<LocalLeader>c"] = {":Telescope coc<CR>", "Coc: menu (telescope)"},
        ["<A-c>"] = {":Telescope coc commands<CR>", "Coc: commands (telescope)"},
        [";s"] = {":Telescope coc document_symbols<CR>", "Symbols: Coc Document"},
        [";S"] = {":Telescope coc workspace_symbols<CR>", "Symbols: Coc Workspace"},
        ["<C-x>h"] = {":Telescope coc diagnostics<CR>", "Coc: diagnostics (telescope)"},
        ["<C-x><C-h>"] = {
            ":Telescope coc workspace_diagnostics<CR>",
            "Coc: workspace diagnostics (telescope)",
        },
        ["<Leader>kd"] = {":Telescope coc definitions<CR>", "Coc: definitions (telescope)"},
        ["<Leader>ky"] = {":Telescope coc type_definitions<CR>", "Coc: type_defs (telescope)"},
        ["<Leader>kD"] = {":Telescope coc declarations<CR>", "Coc: declarations (telescope)"},
        ["<Leader>ki"] = {":Telescope coc implementations<CR>", "Coc: implementations (telescope)"},
        ["<Leader>kr"] = {":Telescope coc references_used<CR>", "Coc: refs_used (telescope)"},
        ["<Leader>kR"] = {":Telescope coc references<CR>", "Coc: references (telescope)"},
        [";l"] = {":Telescope coc locations<CR>", "Coc: locations (telescope)"},
    })

    -- Plugins
    wk.register({
        -- ["<A-;>"] = {":Telescope yank_history<CR>", "Telescope clipboard"},
        -- ["<A-;>"] = {":lua require('telescope').extensions.neoclip.default()<CR>", "Telescope clipboard"},
        ["<A-;>"] = {":lua require('plugs.neoclip').dropdown_clip()<CR>", "Clipboard (telescope)"},
        ["q."] = {":lua require('plugs.neoclip').dropdown_macroclip()<CR>", "Macro (telescope)"},
        ["<Leader>si"] = {":Telescope ultisnips<CR>", "Snippets (telescope)"},
    })

    wk.register(
        {
            -- ["<A-;>"] = {"<Cmd>Telescope yank_history<CR>", "Clipboard (telescope)"}
            -- ["<A-;>"] = {"<Cmd>lua require('telescope').extensions.neoclip.default()<CR>", "Clipboard (telescope)"}
            ["<A-;>"] = {
                "<Cmd>lua require('plugs.neoclip').dropdown_clip()<CR>",
                "Clipboard (telescope)",
            },
        },
        {mode = "i"}
    )

    -- Custom
    wk.register({
        ["<LocalLeader>b"] = {M.cst_buffers, "Buffers (cst) (telescope)"},
        ["<LocalLeader>f"] = {M.cst_files, "Git/Files (telescope)"},
        ["<LocalLeader>a"] = {M.cst_fd, "Files CWD (telescope)"},
        [";g"] = {"<Cmd>Telescope git_grep<CR>", "Grep git repo (telescope)"},
        [";e"] = {"<Cmd>Telescope grep_cwd<CR>", "Grep: cwd (telescope)"},
        ["<Leader>e."] = {"<Cmd>Telescope: edit_dotfiles<CR>", "Edit: dotfiles (telescope)"},
        ["<Leader>e;"] = {"<Cmd>Telescope edit_nvim<CR>", "Edit: nvim (telescope)"},
        ["<Leader>e,"] = {"<Cmd>Telescope grep_nvim<CR>", "Grep: nvim (telescope)"},
        ["<Leader>ru"] = {"<Cmd>Telescope rualdi list<CR>", "Rualdi (telescope)"},
        -- ["<Leader>ch"] = {"<cmd>lua R('plugs.telescope.pickers').changes()<CR>", "Telescope changes (cst)"},
    })
end

init()

return M
