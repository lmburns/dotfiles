local M = {}

local D = require("dev")
local wilder = D.npcall(require, "wilder")
if not wilder then
    return
end

local utils = require("common.utils")
local autocmd = utils.autocmd
local map = utils.map

local fn = vim.fn

function M.wilder_disable(e)
    local cmd = fn["wilder#cmdline#parse"](e).cmd
    return (cmd == "Man" or cmd:match("Git fetch origin.*")) and true or false
end

function M.setup()
    -- o.wildcharm = fn.char2nr("	") -- tab
    -- wilder.enable_cmdline_enter()

    wilder.setup(
        {
            modes = {":", "/", "?"},
            next_key = "<Tab>",
            previous_key = "<S-Tab>"
            -- accept_key = "<A-,>",
            -- reject_key = "<A-.>",
            -- enable_cmdline_enter = 1
        }
    )

    -- wilder.set_option("use_python_remote_plugin", 0)

    -- FIX: Doing this in Lua will sometimes randomly closes neovim
    -- Also causes coredumps on some commands like 'gD'

    wilder.set_option(
        "pipeline",
        {
            wilder.debounce(10),
            wilder.branch(
                {
                    wilder.check(
                        ---@diagnostic disable:unused-local
                        function(ctx, x)
                            return fn.getcmdtype() == ":"
                        end
                    ),
                    function(ctx, x)
                        return M.wilder_disable(x)
                    end
                },
                wilder.python_file_finder_pipeline(
                    {
                        file_command = {"rg", "--files", "--hidden", "--color=never"},
                        dir_command = {"fd", "-td", "-H"},
                        -- filters = {"cpsm_filter"},
                        filters = {"fuzzy_filter", "difflib_sorter"}
                    }
                ),
                wilder.substitute_pipeline(
                    {
                        pipeline = wilder.python_search_pipeline(
                            {
                                skip_cmdtype_check = 1,
                                pattern = wilder.python_fuzzy_pattern(
                                    {
                                        start_at_boundary = 0
                                    }
                                )
                            }
                        )
                    }
                ),
                wilder.cmdline_pipeline(
                    {
                        fuzzy = 2,
                        fuzzy_filter = wilder.lua_fzy_filter()
                        -- language = "python",
                        -- set_pcre2_pattern = 1
                    }
                ),
                {
                    wilder.check(
                        function(ctx, x)
                            return x == ""
                        end
                    ),
                    wilder.history()
                },
                wilder.python_search_pipeline(
                    {
                        pattern = "fuzzy",
                        -- pattern = wilder.python_fuzzy_pattern(),
                        sorter = wilder.python_difflib_sorter()
                        -- engine = "re"
                    }
                )
            )
        }
    )

    -- local highlighters = {
    --     wilder.pcre2_highlighter(),
    --     wilder.lua_fzy_highlighter()
    -- }

    local popupmenu_renderer =
        wilder.popupmenu_renderer(
        wilder.popupmenu_border_theme(
            {
                -- highlighter = highlighters,
                highlighter = wilder.lua_fzy_highlighter(),
                border = "rounded",
                max_height = 15,
                pumblend = 10,
                -- empty_message = wilder.popupmenu_empty_message_with_spinner(),
                highlights = {
                    border = "Normal",
                    default = "Normal",
                    accent = wilder.make_hl("PopupmenuAccent", "Normal", {{a = 1}, {a = 1}, {foreground = "#EF1D55"}})
                },
                left = {
                    " ",
                    wilder.popupmenu_devicons()
                    -- wilder.popupmenu_buffer_flags(
                    --     {
                    --         flags = " a + ",
                    --         icons = {["+"] = "", a = "", h = ""}
                    --     }
                    -- )
                },
                right = {
                    " ",
                    wilder.popupmenu_scrollbar()
                }
            }
        )
    )

    local wildmenu_renderer =
        wilder.wildmenu_renderer(
        {
            highlighter = wilder.lua_fzy_highlighter(),
            separator = " · ",
            left = {" ", wilder.wildmenu_spinner(), " "},
            right = {" ", wilder.wildmenu_index()},
            highlights = {
                accent = wilder.make_hl("WildmenuAccent", "StatusLine", {{a = 1}, {a = 1}, {foreground = "#EF1D55"}})
            }
        }
    )

    -- ["/"] = wilder.popupmenu_renderer(
    --     wilder.popupmenu_palette_theme(
    --         {
    --             border = "single",
    --             max_height = "75%",
    --             min_height = 0,
    --             prompt_position = "top",
    --             reverse = 0
    --         }
    --     )
    -- ),

    wilder.set_option(
        "renderer",
        wilder.renderer_mux(
            {
                [":"] = popupmenu_renderer,
                ["/"] = wildmenu_renderer,
                substitute = wildmenu_renderer
            }
        )
    )

    -- ╭──────────────────────────────────────────────────────────╮
    -- │                        Vimscript                         │
    -- ╰──────────────────────────────────────────────────────────╯

    -- cmd [[
    --
    --   function! s:shouldDisable(x)
    --     let l:cmd = wilder#cmdline#parse(a:x).cmd
    --     return l:cmd ==# 'Man' || a:x =~# 'Git fetch origin '
    --   endfunction
    --
    --   call wilder#set_option('renderer', wilder#renderer_mux({
    --         \ ':': wilder#popupmenu_renderer(wilder#popupmenu_border_theme({
    --         \   'highlighter': wilder#basic_highlighter(),
    --         \   'border': 'rounded',
    --         \   'max_height': 15,
    --         \   'pumblend': 10,
    --         \   'highlights': {
    --         \     'border': 'Normal',
    --         \     'default': 'Normal',
    --         \     'accent': wilder#make_hl(
    --         \       'PopupmenuAccent', 'Normal', [{}, {}, {'foreground': '#EF1D55'}]),
    --         \   },
    --         \   'left': [
    --         \     ' ', wilder#popupmenu_devicons(),
    --         \   ],
    --         \   'right': [
    --         \     ' ', wilder#popupmenu_scrollbar(),
    --         \   ],
    --         \ })),
    --         \
    --         \ '/': wilder#wildmenu_renderer({
    --         \   'highlighter': wilder#lua_fzy_highlighter(),
    --         \   'left': [
    --         \     ' ', wilder#wildmenu_spinner(), ' '
    --         \   ],
    --         \   'right': [
    --         \     ' ', wilder#wildmenu_index(),
    --         \   ],
    --         \   'highlights': {
    --         \     'accent': wilder#make_hl(
    --         \       'WildmenuAccent', 'StatusLine', [{}, {}, {'foreground': '#EF1D55'}]),
    --         \   },
    --         \ }),
    --         \ 'substitute': wilder#wildmenu_renderer({
    --         \   'highlighter': wilder#lua_fzy_highlighter(),
    --         \   'separator': ' · ',
    --         \   'left': [' ', wilder#wildmenu_spinner(), ' '],
    --         \   'right': [' ', wilder#wildmenu_index()],
    --         \ }),
    --         \ }))
    --
    --   call wilder#set_option('pipeline', [
    --              \  wilder#branch(
    --              \    [
    --              \      wilder#check({-> getcmdtype() ==# ':'}),
    --              \      {ctx, x -> s:shouldDisable(x) ? v:true : v:false},
    --              \    ],
    --              \    wilder#python_file_finder_pipeline({
    --              \      'file_command': ['rg', '--files', '--hidden', '--color=never'],
    --              \      'dir_command': ['fd', '-td', '-H'],
    --              \      'filters': ['fuzzy_filter', 'difflib_sorter'],
    --              \    }),
    --              \    wilder#substitute_pipeline({
    --              \      'pipeline': wilder#python_search_pipeline({
    --              \        'skip_cmdtype_check': 1,
    --              \        'pattern': wilder#python_fuzzy_pattern({
    --              \          'start_at_boundary': 0,
    --              \        }),
    --              \      }),
    --              \    }),
    --              \    wilder#cmdline_pipeline({
    --              \      'fuzzy': 2,
    --              \    }),
    --              \    [
    --              \      wilder#check({_, x -> empty(x)}),
    --              \      wilder#history(),
    --              \    ],
    --              \    wilder#python_search_pipeline({
    --              \      'pattern': wilder#python_fuzzy_pattern(),
    --              \      'sorter': wilder#python_difflib_sorter(),
    --              \      'engine': 're',
    --              \    }),
    --              \   ),
    --              \ ])
    -- ]]
end

local function init()
    M.setup()

    nvim.autocmd.lmb__TelescopeFixes = {
        event = "FileType",
        pattern = "Telescope*",
        command = function()
            autocmd(
                {
                    event = "CmdlineEnter",
                    pattern = "*",
                    once = true,
                    command = function()
                        require("wilder").disable()
                    end
                }
            )

            -- map("i", "<Leader>", " ", {nowait = true})
            utils.reset_keymap("i", "<C-r>", {buffer = true})
        end,
        desc = "Disable Wilder in Telescope"
    }

    -- See: autocmds.lua for Telescope disabling
    nvim.autocmd.lmb__WilderEnable = {
        event = "CmdlineEnter",
        pattern = "*",
        once = false, -- Needed for coming back out of Telescope
        command = function()
            require("wilder").enable()
        end,
        desc = "Enable wilder manually"
    }

    -- Allow both Tab/S-Tab and Ctrl{j,k} to rotate through completions
    map("c", "<C-j>", [[wilder#in_context() ? wilder#next() : "\<Tab>"]], {noremap = false, expr = true})
    map("c", "<C-k>", [[wilder#in_context() ? wilder#previous() : "\<S-Tab>"]], {noremap = false, expr = true})
end

init()

return M
