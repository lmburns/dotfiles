local utils = require("common.utils")
local map = utils.map

g.wildcharm = "<Tab>"

map(
    "c", "<Tab>", [[wilder#in_context() ? wilder#next() : "\<Tab>"]],
    { noremap = false, expr = true }
)
map(
    "c", "<S-Tab>", [[wilder#in_context() ? wilder#previous() : "\<S-Tab>"]],
    { noremap = false, expr = true }
)

fn["wilder#enable_cmdline_enter"]()
fn["wilder#setup"](
    {
      modes = { ":", "/", "?" },
      next_key = "<Tab>",
      previous_key = "<S-Tab>",
      accept_key = "<A-,>",
      reject_key = "<A-.>",
    }
)

function _G.wilderDisable(e)
  local cmd = fn["wilder#cmdline#parse"](e).cmd
  return cmd == "Man"
end

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
        \   'highlighter': wilder#basic_highlighter(),
        \   'highlights': {
        \     'accent': wilder#make_hl(
        \       'WildmenuAccent', 'StatusLine', [{}, {}, {'foreground': '#EF1D55'}]),
        \   },
        \ }),
        \ 'substitute': wilder#wildmenu_renderer({
        \   'highlighter': wilder#basic_highlighter(),
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

-- cmd [[
--   function! s:shouldDisable(x)
--     let l:cmd = wilder#cmdline#parse(a:x).cmd
--     return l:cmd ==# 'Man' || a:x =~# 'Git fetch origin '
--   endfunction
-- ]]

-- local wilder = require("wilder.shim")

-- fn["wilder#set_option"](
--     "renderer", wilder.call(
--         "wilder#renderer_mux", {
--           [":"] = wilder.call(
--               "wilder#popupmenu_renderer", wilder.call(
--                   "wilder#popupmenu_border_theme", {
--                     highlighter = wilder.call("wilder#basic_highlighter"),
--                     border = "rounded",
--                     max_height = 15,
--                     highlights = {
--                       border = "Normal",
--                       default = "Normal",
--                       accent = wilder.call(
--                           "wilder#make_hl", "PopupmenuAccent", "Normal",
--                           { {}, {}, { foreground = "#A06469" } }
--                       ),
--                     },
--                     left = { " ", wilder.call("wilder#popupmenu_devicons") },
--                     right = { " ", wilder.call("wilder#popupmenu_scrollbar") },
--                   }
--               )
--           ),
--           ["/"] = wilder.call(
--               "wilder#wildmenu_renderer", {
--                 highlighter = wilder.call("wilder#basic_highlighter"),
--                 highlights = {
--                   accent = wilder.call("wilder#make_hl",
--                       "WildmenuAccent", "StatusLine",
--                       { {}, {}, { foreground = "#A06469" } }
--                   ),
--                 },
--               }
--           ),
--         }
--     )
-- )
--
-- {
--   fn['wilder#check']({function() fn.getcmdtype() == ':' end}),
--   {function(ctx, x) > s:shouldDisable(x) ? v:true : v:false},
-- },

-- {
--   fn["wilder#check"](
--       {function() return fn.getcmdtype() == ":" end}, {
--         function(ctx, x)
--           if wilderDisable(x) then
--             return true
--           else
--             return false
--           end
--         end,
--       }
--   ),
-- }

-- fn["wilder#set_option"](
--     "pipeline", {
--       wilder.call(
--           "wilder#branch", wilder.call(
--               "wilder#python_file_finder_pipeline", {
--                 file_command = function(_, arg)
--                   if arg[0] == "." then
--                     return { "rg", "--files", "--hidden" }
--                   else
--                     return { "rg", "--files" }
--                   end
--                 end,
--                 dir_command = function(_, arg)
--                   if arg[0] == "." then
--                     return { "fd", "-tf", "-H" }
--                   else
--                     return { "fd", "-tf" }
--                   end
--                 end,
--                 filters = { "fuzzy_filter", "difflib_sorter" },
--               }
--           ), wilder.call(
--               "wilder#cmdline_pipeline",
--               { language = "python", fuzzy = 1, set_pcre2_pattern = 1 }
--           ), wilder.call(
--               "wilder#python_search_pipeline", {
--                 pattern = wilder.call("wilder#python_fuzzy_pattern"),
--                 sorter = wilder.call("wilder#python_difflib_sorter"),
--                 engine = "re",
--               }
--           )
--       ),
--     }
-- )
