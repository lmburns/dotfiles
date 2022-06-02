local M = {}

local ex = nvim.ex
local fn = vim.fn
local api = vim.api
local cmd = vim.cmd

local themes = require("telescope.themes")
local utils = require("telescope.utils")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local telescope = require("telescope")
local builtin = require("telescope.builtin")
local actions = require("telescope.actions")
local action_layout = require("telescope.actions.layout")
local action_state = require("telescope.actions.state")
local action_generate = require("telescope.actions.generate")
local sorters = require("telescope.sorters")
local previewers = require("telescope.previewers")
local make_entry = require("telescope.make_entry")
local conf = require("telescope.config").values

local fb_utils = require "telescope._extensions.file_browser.utils"
local z_utils = require("telescope._extensions.zoxide.utils")

local P = R("plugs.telescope.pickers")

local b_utils = require("common.utils") -- "builtin" utils
local command = b_utils.command
local map = b_utils.map

local Path = require("plenary.path")
local wk = require("which-key")

-- require("plenary.strings").align_str(string: any, width: any, right_justify: any)
-- require("plenary.strings").dedent(str: any, leave_indent: any)
-- require("plenary.strings").truncate(str: string, len: any, dots: any, direction: any)
-- require("plenary.strings").strdisplaywidth(string, col)

-- Custom actions
local c_actions = {
    which_key = function(opts)
        opts = opts or {}
        local inner = {
            name_width = 20, -- typically leads to smaller floats
            max_height = 0.5, -- increase potential maximum height
            separator = "  ", -- change sep between mode, keybind, and name
            close_with_action = true, -- do not close float on action
            normal_hl = "TelescopePrompt",
            border_hl = "Parameter"
        }

        opts = vim.tbl_deep_extend("force", inner, opts)

        -- Doing this prevents anonymouse function notification
        local function which_key(prompt_bufnr)
            actions.which_key(prompt_bufnr, opts)
        end

        return which_key
    end,
    -- TODO: Change once which-key can be disabled in filetypes (needs nowait)
    insert_space = function(_)
        -- api.nvim_input(" ")
        api.nvim_feedkeys(utils.termcodes["<Space>"], "n", false)
    end,
    single_selection_hop = function(prompt_bufnr)
        telescope.extensions.hop.hop(prompt_bufnr)
    end,
    -- custom hop loop to multi selects and sending selected entries to quickfix list
    multi_selection_hop = function(prompt_bufnr)
        local opts = {
            callback = actions.toggle_selection,
            loop_callback = actions.send_selected_to_qflist
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
    end
}

-- ============================ Config ===========================

require("telescope").setup(
    {
        defaults = {
            history = {
                path = fn.stdpath("data") .. "/databases/telescope_history.sqlite3",
                limit = 1000
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
                end
            },
            prompt_prefix = "❱ ",
            selection_caret = "❱ ",
            entry_prefix = "  ",
            multi_icon = "<>",
            -- cache_picker = { num_pickers = 20 },
            initial_mode = "insert",
            winblend = 3,
            set_env = {["COLORTERM"] = "truecolor"},
            selection_strategy = "reset",
            sorting_strategy = "descending",
            layout_strategy = "horizontal",
            color_devicons = true,
            scroll_strategy = "cycle",
            -- layout_strategy = "flex",
            border = {},
            borderchars = {"─", "│", "─", "│", "╭", "╮", "╯", "╰"},
            path_display = {},
            mappings = {
                i = {
                    ["<C-x>"] = false,
                    ["<C-Left>"] = actions.move_selection_next,
                    ["<C-Right>"] = actions.move_selection_previous,
                    -- ["<C-g>"] = actions.add_selection,
                    ["<M-a>"] = actions.select_all,
                    ["<C-k>"] = actions.cycle_history_next,
                    ["<C-j>"] = actions.cycle_history_prev,
                    -- ["<C-m>"] = action_layout.toggle_mirror,
                    ["<C-t>"] = action_layout.toggle_preview,
                    ["<M-p>"] = action_layout.toggle_prompt_position,
                    ["<C-s>"] = actions.select_horizontal,
                    ["<C-d>"] = actions.results_scrolling_down,
                    ["<C-u>"] = actions.results_scrolling_up,
                    ["<Tab>"] = actions.toggle_selection + actions.move_selection_next,
                    ["<C-q>"] = actions.send_selected_to_qflist,
                    ["<M-,>"] = actions.smart_send_to_qflist,
                    ["<M-q>"] = c_actions.qf_multi_select,
                    ["<C-o>"] = c_actions.which_key(),
                    -- ["<Space>"] = c_actions.insert_space,

                    ["<C-h>"] = c_actions.single_selection_hop,
                    ["<M-;>"] = c_actions.multi_selection_hop
                },
                n = {
                    ["j"] = actions.move_selection_next,
                    ["k"] = actions.move_selection_previous,
                    ["<Down>"] = actions.move_selection_next,
                    ["<Up>"] = actions.move_selection_previous,
                    ["gg"] = actions.move_to_top,
                    ["G"] = actions.move_to_bottom,
                    ["H"] = actions.move_to_top,
                    ["M"] = actions.move_to_middle,
                    ["L"] = actions.move_to_bottom,
                    ["?"] = action_layout.toggle_preview,
                    ["<ESC>"] = actions.close,
                    ["<C-d>"] = actions.results_scrolling_down,
                    ["<C-u>"] = actions.results_scrolling_up,
                    ["<C-q>"] = actions.send_selected_to_qflist,
                    ["<M-q>"] = c_actions.qf_multi_select,
                    ["<M-,>"] = actions.smart_send_to_qflist,
                    ["<C-o>"] = c_actions.which_key()
                }
            },
            vimgrep_arguments = {
                "rg",
                "--color=never",
                "--no-heading",
                "--with-filename",
                "--line-number",
                "--column",
                "--smart-case"
            },
            find_command = {
                "fd",
                "--type=f",
                "--hidden",
                "--follow",
                "--exclude=.git"
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
                ".git/",
                ".vscode/",
                "node_modules/",
                "_backup/",
                "sessions/",
                "^lua-language-server/",
                "lua-language-server",
                "cache",
                "node_modules",
                "parser.c"
            },
            file_sorter = sorters.get_fuzzy_file,
            generic_sorter = sorters.get_generic_fuzzy_sorter,
            file_previewer = previewers.vim_buffer_cat.new,
            grep_previewer = previewers.vim_buffer_vimgrep.new,
            qflist_previewer = previewers.vim_buffer_qflist.new,
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
                    end
                },
                vertical = {
                    width = 0.9,
                    height = 0.95,
                    mirror = false,
                    prompt_position = "bottom",
                    -- preview_cutoff = 120,
                    preview_width = 0.5
                },
                flex = {horizontal = {preview_width = 0.9}}
            }
        },
        pickers = {
            oldfiles = {
                path_display = {"truncate"},
                -- path_display = {"smart"},
                layout_strategy = "horizontal",
                layout_config = {preview_width = 0.45}
            },
            buffers = {
                preview = true,
                only_cwd = false,
                show_all_buffers = false,
                ignore_current_buffer = true,
                sort_lastused = true,
                theme = "dropdown",
                sorter = require("telescope.sorters").get_substr_matcher(),
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
                            local current_picker = action_state.get_current_picker(prompt_bufnr)
                            local selected_bufnr = action_state.get_selected_entry().bufnr

                            --- get buffers with lower number
                            local replacement_buffers = {}
                            for entry in current_picker.manager:iter() do
                                if entry.bufnr < selected_bufnr then
                                    table.insert(replacement_buffers, 1, entry.bufnr)
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
                                            local new_buf =
                                                F.if_nil(
                                                table.remove(replacement_buffers),
                                                api.nvim_create_buf(false, true)
                                            )
                                            api.nvim_win_set_buf(winid, new_buf)
                                        end
                                    end
                                    -- remove buffer at last
                                    api.nvim_buf_delete(bufnr, {force = true})
                                end
                            )
                        end
                    }
                }
            },
            live_grep = {
                grep_open_files = false,
                only_sort_text = true,
                theme = "ivy",
                -- cwd = fn.expand("%:p:h"),
                on_input_filter_cb = function(prompt)
                    -- AND operator for live_grep like how fzf handles spaces with wildcards in rg
                    return {prompt = prompt:gsub("%s", ".*")}
                end
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
                                cmd [[normal! A]]
                            end
                        )
                    end
                end
            },
            git_commits = {
                mappings = {
                    i = {
                        ["<C-l>"] = function(prompt_bufnr)
                            R("telescope.actions").close(prompt_bufnr)
                            local value = action_state.get_selected_entry().value
                            ex.DiffviewOpen(("%s~1.. %s"):format(value, value))
                        end,
                        ["<C-s>"] = function(prompt_bufnr)
                            R("telescope.actions").close(prompt_bufnr)
                            local value = action_state.get_selected_entry().value
                            ex.DiffviewOpen(value)
                        end,
                        ["<C-u>"] = function(prompt_bufnr)
                            R("telescope.actions").close(prompt_bufnr)
                            local value = action_state.get_selected_entry().value
                            local rev =
                                utils.get_os_command_output(
                                {"git", "rev-parse", "upstream/master"},
                                fn.expand("%:p:h") or uv.cwd()
                            )[1]
                            ex.DiffviewOpen(("%s %s"):format(rev, value))
                        end
                    }
                }
            }
        },
        extensions = {
            bookmarks = {
                selected_browser = "buku",
                url_open_command = "handlr open",
                url_open_plugin = nil,
                full_path = true,
                firefox_profile_name = nil
            },
            fzf = {
                fuzzy = true,
                override_generic_sorter = true,
                override_file_sorter = true,
                case_mode = "smart_case"
            },
            fzf_writer = {
                minimum_grep_characters = 2,
                minimum_files_characters = 2,
                -- Disabled by default.
                -- Will probably slow down some aspects of the sorter, but can make color highlights.
                -- I will work on this more later.
                use_highlighter = true
            },
            rualdi = {
                prompt_title = "Rualdi",
                alias_hl = "MoreMsg",
                path_hl = "Comment",
                opener = "Lfnvim",
                theme = "ivy"
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
                    "m"
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
                reset_selection = true
            },
            frecency = {
                ignore_patterns = {"*.git/*", "*/tmp/*", "*/node_modules/*"},
                persistent_filter = false,
                show_scores = true,
                show_unindexed = true,
                disable_devicons = false,
                workspaces = {
                    ["conf"] = "/home/lucas/.config",
                    ["nvim"] = "/home/lucas/.config/nvim",
                    ["data"] = "/home/lucas/.local/share",
                    ["project"] = "/home/lucas/projects"
                }
            },
            packer = {
                theme = "ivy",
                layout_config = {height = .5},
                preview = false,
                mappings = {
                    ["j"] = actions.move_selection_next,
                    ["k"] = actions.move_selection_previous,
                    ["<Down>"] = actions.move_selection_next,
                    ["<Up>"] = actions.move_selection_previous
                }
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

                    map(
                        "i",
                        "-",
                        function()
                            modify_cwd(current_picker.cwd .. "/..")
                        end
                    )

                    map(
                        "i",
                        "~",
                        function()
                            modify_cwd(vim.fn.expand "~")
                        end
                    )

                    -- local modify_depth = function(mod)
                    --   return function()
                    --     opts.depth = opts.depth + mod
                    --
                    --     current_picker:refresh(false, { reset_prompt = true })
                    --   end
                    -- end
                    --
                    -- map("i", "<M-=>", modify_depth(1))
                    -- map("i", "<M-+>", modify_depth(-1))

                    map(
                        "n",
                        "yy",
                        function()
                            local entry = action_state.get_selected_entry()
                            require("common.yank").yank_reg(vim.v.register, entry.value)
                            -- vim.fn.setreg("+", entry.value)
                        end
                    )

                    return true
                end
            },
            heading = {
                treesitter = true
            },
            -- This needs to be used on setup
            zoxide = {
                prompt_title = "[ Zoxide List ]",
                -- Zoxide list command with score
                list_command = "zoxide query -ls",
                mappings = {
                    default = {
                        action = function(selection)
                            cmd("cd " .. selection.path)
                        end,
                        after_action = function(selection)
                            print("Directory changed to " .. selection.path)
                        end
                    },
                    ["<C-s>"] = {action = z_utils.create_basic_command("split")},
                    ["<C-v>"] = {action = z_utils.create_basic_command("vsplit")},
                    ["<C-e>"] = {action = z_utils.create_basic_command("edit")},
                    ["<C-b>"] = {
                        keepinsert = true,
                        -- FIX:
                        action = function(selection)
                            R("telescope").extensions.file_browser.file_browser({cwd = selection.path})
                        end
                    },
                    ["<C-f>"] = {
                        keepinsert = true,
                        action = function(selection)
                            builtin.find_files({cwd = selection.path})
                        end
                    },
                    ["<A-x>"] = {
                        keepinsert = true,
                        action = function()
                            builtin.live_grep {search_dirs = selection.path, initial_mode = "insert"}
                        end
                    }
                }
            }
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
        }
    }
)

-- builtin.packer = function(opts)
--   require("telescope").extensions.packer.plugins(opts)
-- end

-- ============================ Setup ============================

local options = {
    hidden = true,
    path_display = {},
    layout_strategy = "horizontal",
    layout_config = {preview_width = 0.65},
    border = {},
    borderchars = {"─", "│", "─", "│", "╭", "╮", "╯", "╰"},
    cwd = fn.expand("%:p:h")
}

-- ========================== Helper ==========================

local function join_uniq(tbl, tbl2)
    local res = {}
    local hash = {}
    for _, v1 in ipairs(tbl) do
        res[#res + 1] = v1
        hash[v1] = true
    end

    for _, v in pairs(tbl2) do
        if not hash[v] then
            table.insert(res, v)
        end
    end
    return res
end

local function filter_by_cwd_paths(tbl, cwd)
    local res = {}
    local hash = {}
    for _, v in ipairs(tbl) do
        if v:find(cwd, 1, true) then
            local v1 = Path:new(v):normalize(cwd)
            if not hash[v1] then
                res[#res + 1] = v1
                hash[v1] = true
            end
        end
    end
    return res
end

-- ========================== Builtin ==========================

---Custom files function. If it is in a git directory, use that as root, else use CWD
---Note that there should be no need for `lcd`. The `cwd` option should be enough
M.cst_files = function()
    local cwd = fn.expand("%:p:h")
    local root = require("common.gittool").root(cwd)
    ex.lcd(cwd)
    -- Override this so it gets ran on each file
    options.cwd = cwd

    if #root == 0 then
        -- Use the current filename instead of the directory
        builtin.find_files(options)
    else
        builtin.git_files(options)
    end
end

M.cst_fd = function()
    local cwd = fn.expand("%:p:h")
    ex.lcd(cwd)
    -- Override this so it gets ran on each file
    options.cwd = cwd
    options.sorting_strategy = "descending"

    builtin.find_files(options)
end

M.cst_buffers = function()
    builtin.buffers(
        themes.get_dropdown {
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
                n = {["<c-d>"] = actions.delete_buffer}
            }
        }
    )
end

M.cst_grep = function(opts)
    local default = {
        prompt_title = "Grep",
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
        layout_config = {
            height = 25
        },
        border = true,
        borderchars = {
            prompt = {"─", " ", " ", " ", "─", "─", " ", " "},
            results = {" "},
            preview = {"─", "│", "─", "│", "╭", "╮", "╯", "╰"}
        }
    }

    default.cwd = fn.expand("%:p:h")
    default.attach_mappings = function(_, map)
        map(
            "n",
            "<M-i>",
            function(prompt_bufnr)
                c_actions.cd_parent(prompt_bufnr, default)
            end
        )
        map(
            "i",
            "<M-i>",
            function(prompt_bufnr)
                c_actions.cd_parent(prompt_bufnr, default)
            end
        )

        return true
    end

    builtin.live_grep(default)
end

M.cst_commits = function()
    builtin.git_commits {
        layout_strategy = "horizontal",
        layout_config = {preview_width = 0.55}
    }
end

-- Doesn't work
M.cst_grep_cword = function()
    builtin.grep_string {
        path_display = {"absolute"},
        word_match = "-w",
        search = vim.fn.expand("<cword>")
    }
end

-- Doesn't work
M.cst_grep_cWORD = function()
    builtin.grep_string {
        path_display = {"absolute"},
        search = vim.fn.expand("<cWORD>")
    }
end

M.keymaps = function(mode)
    local title =
        require("dev").switch(mode):caseof {
        n = function()
            return "Normal"
        end,
        i = function()
            return "Insert"
        end,
        o = function()
            return "Operator"
        end,
        -- Only time a table is used is in visual mode
        default = function()
            return "Visual"
        end
    }

    if type(mode) == "string" then
        mode = {mode}
    end

    builtin.keymaps {
        modes = mode,
        show_plug = true,
        prompt_title = ("Mappings (%s)"):format(title)
    }
end

map("n", "<C-l>i", "<Cmd>lua require('plugs.telescope').keymaps('n')<CR>")
map("i", "<C-l>i", "<Cmd>lua require('plugs.telescope').keymaps('i')<CR>")
map("x", "<C-l>i", ":lua require('plugs.telescope').keymaps({'x', 'v', 's'})<CR>")
map("o", "<C-l>i", "<Cmd>lua require('plugs.telescope').keymaps('o')<CR>")

-- ========================== Builtin ============================
builtin.cst_mru = function(opts)
    opts = opts or {}
    local get_mru = function(opts)
        if not pcall(require, "telescope._extensions.frecency") then
            return vim.tbl_filter(
                function(val)
                    return 0 ~= fn.filereadable(val)
                end,
                vim.v.oldfiles
            )
        else
            local db_client = require("telescope._extensions.frecency.db_client")
            db_client.init()
            -- too slow
            -- local tbl = db_client.get_file_scores(opts, vim.fn.getcwd())

            local tbl = db_client.get_file_scores(opts)
            local res = {}
            for _, v in pairs(tbl) do
                table.insert(res, v["filename"])
            end

            return res
        end
    end

    local results_mru = get_mru(opts)
    local results_mru_cur = filter_by_cwd_paths(results_mru, fn.expand("%:p:h") or uv.cwd())

    local show_untracked = utils.get_default(opts.show_untracked, true)
    local recurse_submodules = utils.get_default(opts.recurse_submodules, false)
    if show_untracked and recurse_submodules then
        error("Git does not support both --others and --recurse-submodules")
    end
    local cmd = {
        "git",
        "ls-files",
        "--exclude-standard",
        "--cached",
        show_untracked and "--others" or nil,
        recurse_submodules and "--recurse-submodules" or nil
    }
    local results_git = utils.get_os_command_output(cmd)

    local results = join_uniq(results_mru_cur, results_git)

    pickers.new(
        opts,
        {
            prompt_title = "MRU",
            finder = finders.new_table(
                {
                    results = results,
                    entry_maker = opts.entry_maker or make_entry.gen_from_file(opts)
                }
            ),
            -- default_text = vim.fn.getcwd(),
            sorter = conf.file_sorter(opts),
            previewer = conf.file_previewer(opts)
        }
    ):find()
end

-- Grep a string with a prompt
builtin.grep_prompt = function(opts)
    opts.search = vim.fn.input("Grep String > ")
    builtin.cst_grep(opts)
end

-- builtin.cst_live_grep = function(opts)
-- end

builtin.cst_grep = function(opts)
    opts.search_dirs = {fn.expand("%:p:h")}

    builtin.live_grep(
        {
            mappings = conf.mappings,
            opts = opts,
            prompt_title = "Grep",
            cwd = fn.expand("%:p:h"),
            path_display = {"smart"}
        }
    )
end

builtin.cst_grep_in_dir = function(opts)
    opts.search = vim.fn.input("Grep String > ")
    opts.search_dirs = {}
    opts.search_dirs[1] = vim.fn.input("Target Directory > ")
    builtin.grep_string(
        {
            opts = opts,
            prompt_title = "grep_string(dir): " .. opts.search,
            search = opts.search,
            search_dirs = opts.search_dirs
        }
    )
end

---Grep in the base of a git directory
---@param opts table
builtin.git_grep = function(opts)
    opts.search_dirs = {}
    opts.search_dirs[1] =
        utils.get_os_command_output {
        "git",
        "rev-parse",
        "--show-toplevel"
    }[1]

    if #opts.search_dirs == 0 then
        log.err("Not in a git directory", true)
        return
    end

    opts.vimgrep_arguments = {
        "rg",
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case"
    }
    builtin.live_grep(
        {
            mappings = conf.mappings,
            opts = opts,
            prompt_title = "Git Grep",
            search_dirs = opts.search_dirs,
            path_display = {"smart"}
        }
    )
end

---Search for a neovim configuration file
builtin.edit_nvim = function()
    builtin.fd {
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
            "--exclude=_backup",
            "--exclude=sessions"
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
        end
    }
end

-- FIX: Insert mode doesn't start
builtin.grep_nvim = function()
    builtin.live_grep {
        initial_mode = "insert",
        path_display = {"smart"},
        search_dirs = {"~/.config/nvim"},
        prompt_title = "Nvim Grep",
        vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case"
        }
    }
end

-- Theme isn't working
builtin.edit_zsh = function()
    builtin.fd {
        theme = "ivy",
        path_display = {"smart"},
        prompt_prefix = "  ",
        search_dirs = {"~/.config/zsh"},
        find_command = {
            "fd",
            "--type=f",
            "--hidden",
            "--follow",
            "--exclude=.git",
            "--exclude=_backup",
            "--exclude=sessions"
        },
        hidden = true
    }
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

    builtin.live_grep {
        initial_mode = "insert",
        path_display = {"smart"},
        search_dirs = search_dirs,
        prompt_title = "Grep Tags",
        vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case"
        }
    }
end

builtin.installed_plugins = function()
    builtin.find_files {cwd = fn.stdpath("data") .. "/site/pack/packer/"}
end

-- builtin.tags = P.tags
builtin.windows = P.windows
-- FIX: Why doesn't changes work, but others do?
builtin.changes = P.changes
builtin.scriptnames = P.scriptnames
builtin.args = P.args
builtin.cmarks = P.marks
builtin.live_grep_in_folder = P.live_grep_in_folder

-- ========================= Extensions ==========================
-- Builtin is modified to show a list of all extensions
builtin.ultisnips = function(opts)
    telescope.extensions.ultisnips.ultisnips(opts)
end

builtin.coc = function(opts)
    telescope.extensions.coc.coc(opts)
end

builtin.ghq = function(opts)
    telescope.extensions.ghq.list(opts)
end

builtin.frecency = function(opts)
    telescope.extensions.frecency.frecency(opts)
end

builtin.notify = function(opts)
    telescope.extensions.notify.notify(opts)
end

builtin.zoxide = function(opts)
    telescope.extensions.zoxide.list(opts)
end

builtin.rualdi = function(opts)
    telescope.extensions.rualdi.list(opts)
end

builtin.urlview = function(opts)
    telescope.extensions.urlview.urlview(opts)
end

builtin.todo = function(opts)
    telescope.extensions["todo-comments"].todo(opts)
end

builtin.yanky = function(opts)
    telescope.extensions.yank_history.yank_history(opts)
end

builtin.bookmarks = function(opts)
    telescope.extensions.bookmarks.bookmarks(opts)
end

builtin.heading = function(opts)
    telescope.extensions.heading.heading(opts)
end

builtin.lazygit = function(opts)
    telescope.extensions.lazygit.lazygit(opts)
end

builtin.projects = function(opts)
    telescope.extensions.projects.projects(opts)
end

builtin.gh_issues = function(opts)
    telescope.extensions.gh.issues(opts)
end

builtin.gh_pull_request = function(opts)
    telescope.extensions.gh.pull_request(opts)
end

builtin.gh_gist = function(opts)
    telescope.extensions.gh.gist(opts)
end

-- builtin.aerial = function(opts)
--     telescope.extensions.aerial.aerial(opts)
-- end

command(
    "Ghq",
    function()
        telescope.extensions.ghq.list()
    end,
    {nargs = 0}
)

-- ========================== Mappings ===========================

wk.register(
    {
        [";b"] = {":Telescope builtin<CR>", "Telescope builtins"},
        [";c"] = {":Telescope commands<CR>", "Telescope commands"},
        [";B"] = {":Telescope bookmarks<CR>", "Telescope bookmarks (buku)"},
        [";r"] = {":Telescope git_grep<CR>", "Telescope grep git repo"},
        [";H"] = {":Telescope heading<CR>", "Telescope heading"},
        ["<LocalLeader>a"] = {":lua require('plugs.telescope').cst_fd()<CR>", "Telescope files CWD"},
        [";g"] = {":Telescope git_files<CR>", "Telescope find git files"},
        [";k"] = {":Telescope keymaps<CR>", "Telescope keymaps"},
        [";z"] = {":Telescope zoxide list<CR>", "Telescope zoxide"},
        -- ["<Leader>bl"] = {":Telescope buffers<CR>", "Telescope list buffers"},
        ["<Leader>;"] = {":Telescope current_buffer_fuzzy_find<CR>", "Telescope buffer lines"},
        ["<Leader>hc"] = {":Telescope command_history<CR>", "Telescope command history"},
        -- ["<Leader>hs"] = {":Telescope search_history<CR>", "Telescope search history"},
        ["<A-.>"] = {":Telescope frecency<CR>", "Telescope frecency files"},
        ["<A-,>"] = {":Telescope oldfiles<CR>", "Telescope old files"},
        ["<A-/>"] = {":Telescope marks<CR>", "Telescope marks"},
        ["<LocalLeader>s"] = {
            function()
                -- require("telescope").extensions.aerial.aerial({layout_config = {prompt_position = "top"}})
                require("telescope").extensions.aerial.aerial({layout_config = {prompt_position = "bottom"}})
            end,
            "List workspace symbols"
        },
        ["<LocalLeader>S"] = {
            function()
                -- require("telescope.builtin").treesitter({layout_config = {prompt_position = "top"}})
                require("telescope.builtin").treesitter({layout_config = {prompt_position = "bottom"}})
            end,
            "List treesitter symbols"
        },
        ["<LocalLeader>,"] = {"<Cmd>Telescope resume<CR>", "Telescope resume"}
    }
)

-- Coc
wk.register(
    {
        ["<LocalLeader>c"] = {":Telescope coc<CR>", "Telescope coc menu"},
        ["<A-c>"] = {":Telescope coc commands<CR>", "Telescope coc commands"},
        [";s"] = {":Telescope coc document_symbols<CR>", "Telescope coc doc symbols"},
        [";S"] = {":Telescope coc workspace_symbols<CR>", "Telescope coc workspace symbols"},
        ["<C-x>h"] = {":Telescope coc diagnostics<CR>", "Telescope coc diagnostics"},
        ["<C-x><C-h>"] = {":Telescope coc workspace_diagnostics<CR>", "Telescope workspace coc diagnostics"},
        ["<Leader>kd"] = {":Telescope coc definitions<CR>", "Telescope coc definitions"},
        ["<Leader>ky"] = {":Telescope coc type_definitions<CR>", "Telescope coc type_definitions"},
        ["<Leader>kD"] = {":Telescope coc declarations<CR>", "Telescope coc declarations"},
        ["<Leader>ki"] = {":Telescope coc implementations<CR>", "Telescope coc implementations"},
        ["<Leader>kr"] = {":Telescope coc references_used<CR>", "Telescope coc references_used"},
        ["<Leader>kR"] = {":Telescope coc references<CR>", "Telescope coc references"},
        [";l"] = {":Telescope coc locations<CR>", "Telescope coc locations"}
    }
)

-- Plugins
wk.register(
    {
        ["<A-;>"] = {":Telescope yank_history<CR>", "Telescope clipboard"},
        ["<Leader>si"] = {":Telescope ultisnips<CR>", "Telescope snippets"}
    }
)

wk.register(
    {
        ["<A-;>"] = {"<Cmd>Telescope yank_history<CR>", "Telescope clipboard"}
    },
    {mode = "i"}
)

-- Custom
wk.register(
    {
        ["<LocalLeader>b"] = {":lua require('plugs.telescope').cst_buffers()<CR>", "Telescope buffers (cst)"},
        ["<LocalLeader>f"] = {":lua require('plugs.telescope').cst_files()<CR>", "Telescope files (cst)"},
        [";e"] = {":lua R('plugs.telescope').cst_grep()<CR>", "Telescope grep (cst)"},
        ["<Leader>e;"] = {":Telescope edit_nvim<CR>", "Telescope edit nvim (cst)"},
        ["<Leader>e,"] = {":Telescope grep_nvim<CR>", "Telescope grep nvim (cst)"},
        ["<Leader>rr"] = {":Telescope rualdi list<CR>", "Telescope rualdi (cst)"}
        -- ["<Leader>ch"] = {"<cmd>lua R('plugs.telescope.pickers').changes()<CR>", "Telescope changes (cst)"},
    }
)

-- map("n", "<Leader>cs", ":Telescope colorscheme<CR>")
-- map("n", "<LocalLeader>f", ":Telescope find_files<CR>")
-- map("n", ";e", ":Telescope live_grep theme=get_ivy<CR>")
-- map("n", "<Leader>e,", ":lua require('plugs.telescope').cst_grep_cWORD<CR>")

-- ========================== Highlight ==========================
local colors = require("kimbox.colors")
local color = require("common.color")
local fg = color.fg
-- local bg = require("common.color").bg
-- local hl = color.set_hl

fg("TelescopeSelection", colors.yellow, {bold = true})
fg("TelescopeSelectionCaret", colors.blue)
fg("TelescopeMultiSelection", colors.aqua)
-- bg("TelescopeNormal", colors.bg0)
fg("TelescopeBorder", colors.magenta)
fg("TelescopePromptBorder", colors.magenta)
fg("TelescopeResultsBorder", colors.magenta)
fg("TelescopePreviewBorder", colors.magenta)
fg("TelescopeMatching", colors.orange)
fg("TelescopePromptPrefix", colors.red)

fg("TelescopePathSeparator", colors.magenta)
fg("TelescopeFrecencyScores", colors.green)
fg("TelescopeBufferLoaded", colors.red)

-- telescope.load_extension("notify")
-- telescope.load_extension("ultisnips")
-- telescope.load_extension("coc")
-- telescope.load_extension("bookmarks")
-- telescope.load_extension("fzf")
-- telescope.load_extension("neoclip")
-- telescope.load_extension("frecency")
-- telescope.load_extension("packer")

return M
