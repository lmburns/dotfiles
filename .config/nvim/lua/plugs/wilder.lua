local M = {}

local utils = require("common.utils")
local map = utils.map

local wilder = require("wilder")

function M.wilderDisable()
    local cmd = fn["wilder#cmdline#parse"](e).cmd
    return (cmd == "Man" or cmd:match("Git fetch origin.*")) and true or false
end

function M.setup()
    o.wildcharm = fn.char2nr("	") -- tab
    wilder.enable_cmdline_enter()

    wilder.setup(
        {
            modes = {":", "/", "?"},
            next_key = "<C-j>",
            previous_key = "<C-k>",
            accept_key = "<A-,>",
            reject_key = "<A-.>"
            -- enable_cmdline_enter = 1
        }
    )

    -- wilder.set_option('use_python_remote_plugin', 0)

    -- FIX: Doing this in Lua will sometimes randomly close neovim
    -- Also causes coredumps on some commands like 'gD'
    --
    -- wilder.set_option(
    --     "renderer",
    --     wilder.renderer_mux(
    --         {
    --             [":"] = wilder.popupmenu_renderer(
    --                 wilder.popupmenu_border_theme(
    --                     {
    --                         -- empty_message = wilder.popupmenu_empty_message_with_spinner(),
    --                         highlighter = wilder.lua_pcre2_highlighter(),
    --                         border = "rounded",
    --                         max_height = 15,
    --                         pumblend = 10,
    --                         left = {
    --                             " ",
    --                             wilder.popupmenu_devicons(),
    --                             wilder.popupmenu_buffer_flags(
    --                                 {
    --                                     flags = " a + ",
    --                                     icons = {["+"] = "", a = "", h = ""}
    --                                 }
    --                             )
    --                         },
    --                         right = {" ", wilder.popupmenu_scrollbar()},
    --                         highlights = {
    --                             border = "Normal",
    --                             default = "Normal",
    --                             accent = wilder.make_hl(
    --                                 "PopupmenuAccent",
    --                                 "Normal",
    --                                 {{a = 1}, {a = 1}, {foreground = "#EF1D55"}}
    --                             )
    --                         }
    --                     }
    --                 )
    --             ),
    --             ["/"] = wilder.wildmenu_renderer(
    --                 {
    --                     -- separator = " · ",
    --                     highlighter = wilder.lua_pcre2_highlighter(),
    --                     pumblend = 10,
    --                     left = {" ", wilder.wildmenu_spinner(), " "},
    --                     right = {" ", wilder.wildmenu_index()},
    --                     highlights = {
    --                         accent = wilder.make_hl(
    --                             "WildmenuAccent",
    --                             "StatusLine",
    --                             {{a = 1}, {a = 1}, {foreground = "#EF1D55"}}
    --                         )
    --                     }
    --                 }
    --             ),
    --             ["substitute"] = wilder.wildmenu_renderer(
    --                 {
    --                     highlighter = wilder.lua_pcre2_highlighter(),
    --                     separator = " · ",
    --                     left = {" ", wilder.wildmenu_spinner(), " "},
    --                     right = {" ", wilder.wildmenu_index()},
    --                     highlights = {
    --                         accent = wilder.make_hl(
    --                             "WildmenuAccent",
    --                             "StatusLine",
    --                             {{a = 1}, {a = 1}, {foreground = "#EF1D55"}}
    --                         )
    --                     }
    --                 }
    --             )
    --         }
    --     )
    -- )
    --
    -- wilder.set_option(
    --     "pipeline",
    --     {
    --         wilder.debounce(10),
    --         wilder.branch(
    --             --  \    [
    --             --  \      wilder#check({-> getcmdtype() ==# ':'}),
    --             --  \      {ctx, x -> s:shouldDisable(x) ? v:true : v:false},
    --             --  \    ],
    --             -- {
    --             --     wilder.check(
    --             --         function()
    --             --             return fn.getcmdtype() == ":"
    --             --         end
    --             --     ),
    --             --     function(ctx, x)
    --             --         local cmd = fn["wilder#cmdline#parse"](e).cmd
    --             --         return (cmd == "Man") and true or false
    --             --     end
    --             -- },
    --             wilder.python_file_finder_pipeline(
    --                 {
    --                     file_command = {"rg", "--files", "--hidden", "--color=never"},
    --                     dir_command = {"fd", "-td", "-H"},
    --                     filters = {"fuzzy_filter", "difflib_sorter"}
    --                 }
    --             ),
    --             wilder.substitute_pipeline(
    --                 {
    --                     pipeline = wilder.python_search_pipeline(
    --                         {
    --                             skip_cmdtype_check = 1,
    --                             pattern = wilder.python_fuzzy_pattern(
    --                                 {
    --                                     start_at_boundary = 0
    --                                 }
    --                             )
    --                         }
    --                     )
    --                 }
    --             ),
    --             wilder.cmdline_pipeline(
    --                 {
    --                     language = "python",
    --                     fuzzy = 1,
    --                     set_pcre2_pattern = 1
    --                 }
    --             ),
    --             {
    --                 wilder.check(
    --                     function(_ctx, x)
    --                         return x == ""
    --                     end
    --                 ),
    --                 wilder.history()
    --             },
    --             wilder.python_search_pipeline(
    --                 {
    --                     pattern = wilder.python_fuzzy_pattern(),
    --                     sorter = wilder.python_difflib_sorter(),
    --                     engine = "re"
    --                 }
    --             )
    --         )
    --     }
    -- )

    cmd [[
  function! s:shouldDisable(x)
    let l:cmd = wilder#cmdline#parse(a:x).cmd
    return l:cmd ==# 'Man' || a:x =~# 'Git fetch origin '
  endfunction

   "\      'file_command': {_, arg -> arg[0] ==# '.'
   "\                               ? ['rg', '--files', '--hidden', '--color=never']
   "\                               : ['rg', '--files', '--color=never']},
   "\      'dir_command':  {_, arg -> arg[0] ==# '.' ? ['fd', '-tf', '-H'] : ['fd', '-tf']},

  call wilder#set_option('renderer', wilder#renderer_mux({
        \ ':': wilder#popupmenu_renderer(wilder#popupmenu_border_theme({
        \   'highlighter': wilder#lua_pcre2_highlighter(),
        \   'border': 'rounded',
        \   'max_height': 15,
        \   'highlights': {
        \     'border': 'Normal',
        \     'default': 'Normal',
        \     'accent': wilder#make_hl(
        \       'PopupmenuAccent', 'Normal', [{}, {}, {'foreground': '#EF1D55'}]),
        \   },
        \   'left': [
        \     ' ', wilder#popupmenu_devicons(),
        \   ],
        \   'right': [
        \     ' ', wilder#popupmenu_scrollbar(),
        \   ],
        \ })),
        \
        \ '/': wilder#wildmenu_renderer({
        \   'highlighter': wilder#lua_pcre2_highlighter(),
        \   'left': [
        \     ' ', wilder#wildmenu_spinner(), ' '
        \   ],
        \   'right': [
        \     ' ', wilder#wildmenu_index(),
        \   ],
        \   'highlights': {
        \     'accent': wilder#make_hl(
        \       'WildmenuAccent', 'StatusLine', [{}, {}, {'foreground': '#EF1D55'}]),
        \   },
        \ }),
        \ 'substitute': wilder#wildmenu_renderer({
        \   'highlighter': wilder#lua_pcre2_highlighter(),
        \   'separator': ' · ',
        \   'left': [' ', wilder#wildmenu_spinner(), ' '],
        \   'right': [' ', wilder#wildmenu_index()],
        \ }),
        \ }))

  call wilder#set_option('pipeline', [
             \  wilder#branch(
             \    [
             \      wilder#check({-> getcmdtype() ==# ':'}),
             \      {ctx, x -> s:shouldDisable(x) ? v:true : v:false},
             \    ],
             \    wilder#python_file_finder_pipeline({
             \      'file_command': ['rg', '--files', '--hidden', '--color=never'],
             \      'dir_command': ['fd', '-td', '-H'],
             \      'filters': ['fuzzy_filter', 'difflib_sorter'],
             \    }),
             \    wilder#substitute_pipeline({
             \      'pipeline': wilder#python_search_pipeline({
             \        'skip_cmdtype_check': 1,
             \        'pattern': wilder#python_fuzzy_pattern({
             \          'start_at_boundary': 0,
             \        }),
             \      }),
             \    }),
             \    wilder#cmdline_pipeline({
             \      'language': 'python',
             \      'fuzzy': 1,
             \      'set_pcre2_pattern': 1,
             \    }),
             \    [
             \      wilder#check({_, x -> empty(x)}),
             \      wilder#history(),
             \    ],
             \    wilder#python_search_pipeline({
             \      'pattern': wilder#python_fuzzy_pattern(),
             \      'sorter': wilder#python_difflib_sorter(),
             \      'engine': 're',
             \    }),
             \   ),
             \ ])
]]
end

local function init()
    M.setup()

    -- Allow both Tab/S-Tab and Ctrl{j,k} to rotate through completions
    map("c", "<Tab>", [[wilder#in_context() ? wilder#next() : "\<Tab>"]], {noremap = false, expr = true})
    map("c", "<S-Tab>", [[wilder#in_context() ? wilder#previous() : "\<S-Tab>"]], {noremap = false, expr = true})
end

init()

return M
