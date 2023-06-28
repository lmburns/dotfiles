" === Sandwich =========================================================== [[[
fun! plugs#textobjs#sandwich() abort
      let g:sandwich#magicchar#f#patterns = [
                        \ {
                        \   'header': '\<\%(\.\|:\{1,2}\)\@<!\h\k*\%(\.\|:\{1,2}\)\@!',
                        \   'bra': '(',
                        \   'ket': ')',
                        \   'footer': '',
                        \},
                        \ {
                        \     'header': '\<\h\k*!',
                        \     'bra': '(',
                        \     'ket': ')',
                        \     'footer': '',
                        \ },
                        \ {
                        \     'header': '\<\%(\h\k*\.\)\+\h\k*',
                        \     'bra': '(',
                        \     'ket': ')',
                        \     'footer': '',
                        \ },
                        \ {
                        \     'header': '\<\%(\h\k*#\)\+\h\k*',
                        \     'bra': '(',
                        \     'ket': ')',
                        \     'footer': '',
                        \ },
                        \ {
                        \     'header': '\<\h\k*',
                        \     'bra': '<',
                        \     'ket': '>',
                        \     'footer': '',
                        \ },
                        \ {
                        \     'header': '\<\%(\h\k*:\)\h\k*',
                        \     'bra': '(',
                        \     'ket': ')',
                        \     'footer': '',
                        \ },
                        \ {
                        \     'header': '\<\%(\h\k*#\)\h\k*',
                        \     'bra': '(',
                        \     'ket': ')',
                        \     'footer': '',
                        \ },
                        \ {
                        \     'header': '\<\%(\h\k*::\)\+\h\k*',
                        \     'bra': '(',
                        \     'ket': ')',
                        \     'footer': '',
                        \ }]

      runtime macros/sandwich/keymap/surround.vim
      let g:sandwich#recipes = deepcopy(g:sandwich#default_recipes)

      let g:sandwich#recipes += [
                        \   {
                        \     'buns':         ['<', '>'],
                        \     'expand_range': 0,
                        \     'input':        ['>', 'a'],
                        \   },
                        \   {
                        \     'buns': ['sandwich#magicchar#f#fname()', '")"'],
                        \     'kind': ['add', 'replace'],
                        \     'action': ['add'],
                        \     'expr': 1,
                        \     'input': ['f']
                        \   },
                        \   {
                        \     'buns': ['{ ', ' }'],
                        \     'nesting': 1,
                        \     'match_syntax': 1,
                        \     'kind': ['add', 'replace', 'delete'],
                        \     'action': ['add'],
                        \     'input': ['{']
                        \   },
                        \   {
                        \     'buns': ['[ ', ' ]'],
                        \     'nesting': 1,
                        \     'match_syntax': 1,
                        \     'kind': ['add', 'replace', 'delete'],
                        \     'action': ['add'],
                        \     'input': ['[']
                        \   },
                        \   {
                        \     'buns': ['( ', ' )'],
                        \     'nesting': 1,
                        \     'match_syntax': 1,
                        \     'kind': ['add', 'replace', 'delete'],
                        \     'action': ['add'],
                        \     'input': ['(']
                        \   },
                        \   {
                        \     'buns': ['< ', ' >'],
                        \     'nesting': 1,
                        \     'match_syntax': 1,
                        \     'kind': ['add', 'replace', 'delete'],
                        \     'action': ['add'],
                        \     'input': ['<']
                        \   },
                        \   {
                        \     'buns': ['{\s*', '\s*}'],
                        \     'nesting': 1,
                        \     'regex': 1,
                        \     'match_syntax': 1,
                        \     'kind': ['delete', 'replace', 'textobj'],
                        \     'action': ['delete'],
                        \     'input': ['{']
                        \   },
                        \   {
                        \     'buns': ['\[\s*', '\s*\]'],
                        \     'nesting': 1,
                        \     'regex': 1,
                        \     'match_syntax': 1,
                        \     'kind': ['delete', 'replace', 'textobj'],
                        \     'action': ['delete'],
                        \     'input': ['[']
                        \   },
                        \   {
                        \     'buns': ['(\s*', '\s*)'],
                        \     'nesting': 1,
                        \     'regex': 1,
                        \     'match_syntax': 1,
                        \     'kind': ['delete', 'replace', 'textobj'],
                        \     'action': ['delete'],
                        \     'input': ['(']
                        \   },
                        \   {
                        \     'buns': ['<\s*', '\s*>'],
                        \     'nesting': 1,
                        \     'regex': 1,
                        \     'match_syntax': 1,
                        \     'kind': ['delete', 'replace', 'textobj'],
                        \     'action': ['delete'],
                        \     'input': ['<']
                        \   },
                        \   {
                        \     'buns': ['[`', '`]'],
                        \     'nesting': 1,
                        \     'kind': ['add', 'replace', 'delete', 'textobj'],
                        \     'input': ['1']
                        \   },
                        \   {
                        \     'buns': ['[[', ']]'],
                        \     'filetype': ['zsh', 'sh', 'bash', 'lua', 'vim'],
                        \     'nesting': 1,
                        \     'kind': ['add', 'replace', 'delete', 'textobj'],
                        \     'input': ['D']
                        \   },
                        \   {
                        \     'buns': ['\s\+', '\s\+'],
                        \     'regex': 1,
                        \     'kind': ['delete', 'replace', 'query'],
                        \     'input': [' ']
                        \   },
                        \   {
                        \     'buns'        : ['{', '}'],
                        \     'motionwise'  : ['line'],
                        \     'kind'        : ['add'],
                        \     'linewise'    : 1,
                        \     'command'     : ["'[+1,']-1normal! >>"],
                        \   },
                        \   {
                        \     'buns'        : ['{', '}'],
                        \     'motionwise'  : ['line'],
                        \     'kind'        : ['delete'],
                        \     'linewise'    : 1,
                        \     'command'     : ["'[,']normal! <<"],
                        \   },
                        \   {
                        \     'buns':         ['', ''],
                        \     'action':       ['add'],
                        \     'motionwise':   ['line'],
                        \     'linewise':     1,
                        \     'input':        ["\<CR>"]
                        \   },
                        \   {
                        \     'buns':         ['^$', '^$'],
                        \     'regex':        1,
                        \     'linewise':     1,
                        \     'input':        ["\<CR>"]
                        \   },
                        \   {
                        \     'buns':         ['{', '}'],
                        \     'nesting':      1,
                        \     'skip_break':   1,
                        \     'input':        ['}', 'B'],
                        \   },
                        \   {
                        \     'buns':         ['[', ']'],
                        \     'nesting':      1,
                        \     'input':        [']', 'r'],
                        \   },
                        \   {
                        \     'buns':         ['(', ')'],
                        \     'nesting':      1,
                        \     'input':        [')', 'b'],
                        \   },
                        \   {
                        \     'buns':         ['`', '`'],
                        \     'quoteescape':  1,
                        \     'expand_range': 0,
                        \     'nesting':      0,
                        \     'linewise':     0,
                        \     'kind':   ['add', 'replace', 'delete', 'textobj'],
                        \     'input':  ['`', 'v'],
                        \   },
                        \   {
                        \     'buns':         ['"', '"'],
                        \     'quoteescape':  1,
                        \     'expand_range': 0,
                        \     'nesting':      0,
                        \     'linewise':     0,
                        \     'kind':   ['add', 'replace', 'delete', 'textobj'],
                        \     'input':  ['"', 'q'],
                        \   },
                        \
                        \   {
                        \     'buns':         ["'", "'"],
                        \     'quoteescape':  1,
                        \     'expand_range': 0,
                        \     'nesting':      0,
                        \     'linewise':     0,
                        \     'kind':   ['add', 'replace', 'delete', 'textobj'],
                        \     'input':  ["'", 'Q'],
                        \   },
                        \   {
                        \     'buns':   ['=== ', ' ==='],
                        \     'nesting':      1,
                        \     'kind':   ['add', 'replace', 'delete'],
                        \     'action': ['add'],
                        \     'input':  ['='],
                        \   },
                        \   {
                        \     'buns': ["(\n", "\n)"],
                        \     'nesting': 1,
                        \     'kind': ['add'],
                        \     'action': ['add'],
                        \     'input':  ["\<C-S-)>"],
                        \   },
                        \   {
                        \     'buns': ["{\n", "\n}"],
                        \     'nesting': 1,
                        \     'kind': ['add'],
                        \     'action': ['add'],
                        \     'input':  ["\<C-S-}>", "U"],
                        \   },
                        \   {
                        \     'buns': ['(', ')'],
                        \     'cursor': 'head',
                        \     'command': ['startinsert'],
                        \     'kind': ['add', 'replace'],
                        \     'action': ['add'],
                        \     'input': ['F']
                        \   },
                        \ ]


      " Query inner delimiter
      omap is <Plug>(textobj-sandwich-query-i)
      xmap is <Plug>(textobj-sandwich-query-i)
      " Query around delimiter
      omap as <Plug>(textobj-sandwich-query-a)
      xmap as <Plug>(textobj-sandwich-query-a)
      " Auto delimiter
      omap iss <Plug>(textobj-sandwich-auto-i)
      xmap iss <Plug>(textobj-sandwich-auto-i)
      " Auto delimiter
      omap ass <Plug>(textobj-sandwich-auto-a)
      xmap ass <Plug>(textobj-sandwich-auto-a)

      " Surround a word
      nmap y; <Plug>(sandwich-add)iw
      " Surround a word with quotes
      nmap m. <Plug>(sandwich-add)iw'
      " Surround a cword with function
      nmap yf <Plug>(sandwich-add)iwf
      " Surround a cWORD with function
      nmap yF <Plug>(sandwich-add)iWf
      " Surround entire line
      nmap ygs <Plug>(sandwich-add)aL

      " Surround with bold (**)
      xmap mb <Plug>(sandwich-add)*gV<Left><Plug>(sandwich-add)*
      " Surround with code block (```)
      xmap ``` <esc>`<O<esc>S```<esc>`>o<esc>S```<esc>k$|
      " Surround with code block (```zsh)
      xmap ``; <esc>`<O<esc>S```zsh<esc>`>o<esc>S```<esc>k$|
      " Surround with code block (```perl)
      xmap ``, <esc>`<O<esc>S```perl<esc>`>o<esc>S```<esc>k$|

      " Surround entire line
      xmap gS :<C-u>normal! V<CR><Plug>(sandwich-add)

      " Surround with foldmarker
      " "x",
      " "zF",
      " function()
      "     local cms = vim.split(vim.bo.cms, "%s", {trimempty = true})[1] or "#"
      "     utils.normal("n", ("<Esc>`<O<Esc>S%s [[[<Esc>`>o<Esc>S%s ]]]<Esc>k$|"):format(cms, cms))
      " end,
endfun
" ]]]

" === Targets ============================================================ [[[
fun! plugs#textobjs#targets() abort
      let g:targets_seekRanges = "cc cr cb cB lc ac Ac lr lb ar ab lB Ar aB Ab AB rr ll rb al rB Al bb aa bB Aa BB AA"
      let g:targets_jumpRanges = g:targets_seekRanges
      let g:targets_aiAI = "aIAi"
      let g:targets_nl = "nm"

      augroup lmb__Targets
            au!
            autocmd User targets#mappings#user call targets#mappings#extend({
                              \ 'j': {
                              \     'argument': [
                              \         {'o': '(', 'c': ')', 's': ','},
                              \         {'o': '{', 'c': '}', 's': ','},
                              \         {'o': '[', 'c': ']', 's': ','},
                              \     ],
                              \ },
                              \ 'a': {'pair': [{'o': '<', 'c': '>'}]},
                              \ 'r': {'pair': [{'o': '[', 'c': ']'}]},
                              \ 'B': {'pair': [{'o': '{', 'c': '}'}]},
                              \ 'b': {
                              \   'pair': [
                              \       {'o': '(', 'c': ')'},
                              \       {'o': '{', 'c': '}'},
                              \   ],
                              \ },
                              \ 'A': {
                              \   'pair': [
                              \       {'o': '(', 'c': ')'},
                              \       {'o': '{', 'c': '}'},
                              \       {'o': '[', 'c': ']'},
                              \   ],
                              \ },
                              \ '-': {'separator': [{'d': '-'}]},
                              \ 'L': {'line': [{'c': 1}]},
                              \ 'l': {'line': [{'c': 1}]},
                              \ 'O': {
                              \   'separator': [
                              \       {'d': ','},
                              \       {'d': '.'},
                              \       {'d': ';'},
                              \       {'d': '='},
                              \       {'d': '+'},
                              \       {'d': '-'},
                              \       {'d': '='},
                              \       {'d': '~'},
                              \       {'d': '_'},
                              \       {'d': '*'},
                              \       {'d': '#'},
                              \       {'d': '/'},
                              \       {'d': '\'},
                              \       {'d': '|'},
                              \       {'d': '&'},
                              \       {'d': '$'},
                              \   ],
                              \   'pair': [
                              \       {'o': '(', 'c': ')'},
                              \       {'o': '{', 'c': '}'},
                              \       {'o': '[', 'c': ']'},
                              \       {'o': '<', 'c': '>'},
                              \   ],
                              \   'quote': [{'d': "'"}, {'d': '"'}, {'d': '`'}],
                              \   'tag': [{}],
                              \ }})
      augroup END

      omap <expr> i targets#e('o', 'I', 'i')
      omap <expr> a targets#e('o', 'a', 'a')
      omap <expr> I targets#e('o', 'i', 'I')
      omap <expr> A targets#e('o', 'A', 'A')
      xmap <expr> i targets#e('o', 'I', 'i')
      xmap <expr> a targets#e('o', 'a', 'a')
      " xmap <expr> I targets#e('o', 'i', 'I')
      " xmap <expr> A targets#e('o', 'A', 'A')

      if exists('g:which_key_map_v')
            let g:which_key_map_v['i'] = {'name': 'Inside, including space'}
            let g:which_key_map_v['a'] = {'name': 'Around, excluding space'}
            let g:which_key_map_v['I'] = {'name': 'Inside, excluding space'}
            let g:which_key_map_v['A'] = {'name': 'Around, including space'}

            let g:which_key_map_v["a"]["r"] = "Around brace [ ]"
            let g:which_key_map_v["a"]["B"] = "Around brace { }"
            let g:which_key_map_v["a"]["b"] = "Around brace ({ })"
            let g:which_key_map_v["a"]["a"] = "Around angle bracket < >"
            let g:which_key_map_v["a"]["A"] = "Around any bracket [({ })]"
            let g:which_key_map_v["a"]["q"] = "Around quote"
            let g:which_key_map_v["a"]["n"] = "Next object"
            let g:which_key_map_v["a"]["m"] = "Previous object"
            let g:which_key_map_v["a"]["O"] = "Around nearest object"
            let g:which_key_map_v["a"]["J"] = "Around parameter (comma)"
            let g:which_key_map_v["a"]["L"] = "Around line"

            let g:which_key_map_v["i"]["r"] = "Inner brace [ ]"
            let g:which_key_map_v["i"]["B"] = "Inner brace { }"
            let g:which_key_map_v["i"]["b"] = "Inner brace ({ })"
            let g:which_key_map_v["i"]["a"] = "Inner angle bracket < >"
            let g:which_key_map_v["i"]["A"] = "Inner any bracket [({ })]"
            let g:which_key_map_v["i"]["q"] = "Inner quote"
            let g:which_key_map_v["i"]["n"] = "Next object"
            let g:which_key_map_v["i"]["m"] = "Previous object"
            let g:which_key_map_v["i"]["O"] = "Inner nearest object"
            let g:which_key_map_v["i"]["J"] = "Inner parameter (comma)"
            let g:which_key_map_v["i"]["L"] = "Inner line"
      endif
endfun
" ]]]

" === Matchup ============================================================ [[[
fun! plugs#textobjs#matchup()
      let g:loaded_matchit = 1
      let g:matchup_enabled = 1

      let g:matchup_matchparen_hi_surround_always = 0

      let g:matchup_mappings_enabled = 0
      let g:matchup_surround_enabled = 1
      let g:matchup_matchparen_enabled = 1
      let g:matchup_motion_enabled = 1
      let g:matchup_text_obj_enabled = 1
      " let g:matchup_mouse_enabled = 1

      let g:matchup_motion_override_Npercent = 0
      let g:matchup_motion_cursor_end = 0

      " let g:matchup_matchparen_timeout = 100
      " let g:matchup_matchparen_deferred = 1
      " let g:matchup_matchparen_deferred_show_delay = 50
      " let g:matchup_matchparen_deferred_hide_delay = 300

      let g:matchup_delim_start_plaintext = 1 " loaded for all buffers
      let g:matchup_delim_noskips = 2         " in comments -- 0: All, 1: Brackets
      let g:matchup_delim_nomids = 0          " match func return end

      let g:matchup_matchparen_offscreen = {}

      nmap % <Plug>(matchup-%)
      xmap % <Plug>(matchup-%)
      omap % <Plug>(matchup-%)
      nmap g% <Plug>(matchup-g%)
      xmap g% <Plug>(matchup-g%)
      omap g% <Plug>(matchup-g%)
      omap g5 <Plug>(matchup-g%)

      " Previous outer open word
      nmap [% <Plug>(matchup-[%)
      xmap [% <Plug>(matchup-[%)
      omap [% <Plug>(matchup-[%)
      " Next outer open word
      nmap ]% <Plug>(matchup-]%)
      xmap ]% <Plug>(matchup-]%)
      omap ]% <Plug>(matchup-]%)
      nmap [4 <Plug>(matchup-[%)
      xmap [4 <Plug>(matchup-[%)
      omap [4 <Plug>(matchup-[%)
      nmap ]4 <Plug>(matchup-]%)
      xmap ]4 <Plug>(matchup-]%)
      omap ]4 <Plug>(matchup-]%)

      nmap [5 <Plug>(matchup-Z%)
      xmap [5 <Plug>(matchup-Z%)
      omap [5 <Plug>(matchup-Z%)
      nmap ]5 <Plug>(matchup-z%)
      xmap ]5 <Plug>(matchup-z%)
      omap ]5 <Plug>(matchup-z%)
      " Inside prev matchup
      nmap z{ <Plug>(matchup-Z%)
      xmap z{ <Plug>(matchup-Z%)
      omap z{ <Plug>(matchup-Z%)
      " Inside next matchup
      nmap z} <Plug>(matchup-z%)
      xmap z} <Plug>(matchup-z%)
      omap z} <Plug>(matchup-z%)

      xmap a5 <Plug>(matchup-a%)
      omap a5 <Plug>(matchup-a%)
      xmap i5 <Plug>(matchup-i%)
      omap i5 <Plug>(matchup-i%)

      nmap ds% <Plug>(matchup-ds%)
      nmap cs% <Plug>(matchup-cs%)

      augroup lmb__Matchup
            au!
            autocmd FileType qf let [b:matchup_matchparen_enabled, b:matchup_matchparen_fallback] = [0, 0]
      augroup END
endfun
" ]]]

fun! plugs#textobjs#edge() abort
      nmap sJ <Plug>(edgemotion-j)
      nmap sK <Plug>(edgemotion-k)
      xmap sJ <Plug>(edgemotion-j)
      xmap sK <Plug>(edgemotion-k)
endfun

fun! plugs#textobjs#fold() abort
      omap az  <Plug>(textobj-fold-a)
      omap iz  <Plug>(textobj-fold-i)
      xmap az  <Plug>(textobj-fold-a)
      xmap iz  <Plug>(textobj-fold-i)
endfun
"
fun! plugs#textobjs#entire() abort
      omap ae  <Plug>(textobj-entire-a)
      omap ie  <Plug>(textobj-entire-i)
      xmap ae  <Plug>(textobj-entire-a)
      xmap ie  <Plug>(textobj-entire-i)
endfun

fun! plugs#textobjs#indent() abort
      omap ii  <Plug>(textobj-indent-i)
      omap ai  <Plug>(textobj-indent-same-a)
      omap aI  <Plug>(textobj-indent-a)
      omap iI  <Plug>(textobj-indent-same-i)
      xmap ii  <Plug>(textobj-indent-i)
      xmap ai  <Plug>(textobj-indent-same-a)
      xmap aI  <Plug>(textobj-indent-a)
      xmap iI  <Plug>(textobj-indent-same-i)
endfun

fun! plugs#textobjs#function() abort
      omap af  <Plug>(textobj-function-a)
      omap if  <Plug>(textobj-function-i)
      omap aF  <Plug>(textobj-function-A)
      omap iF  <Plug>(textobj-function-I)
      xmap af  <Plug>(textobj-function-a)
      xmap if  <Plug>(textobj-function-i)
      xmap aF  <Plug>(textobj-function-A)
      xmap iF  <Plug>(textobj-function-I)
endfun

fun! plugs#textobjs#function_call() abort
      xmap ic <Plug>(textobj-functioncall-i)
      omap ic <Plug>(textobj-functioncall-i)
      xmap ac <Plug>(textobj-functioncall-a)
      omap ac <Plug>(textobj-functioncall-a)
endfun

fun! plugs#textobjs#syntax() abort
      omap au  <Plug>(textobj-syntax-a)
      omap iu  <Plug>(textobj-syntax-i)
      xmap au  <Plug>(textobj-syntax-a)
      xmap iu  <Plug>(textobj-syntax-i)
endfun

fun! plugs#textobjs#lastpat() abort
      omap a/  <Plug>(textobj-lastpat-n)
      omap i/  <Plug>(textobj-lastpat-n)
      omap a?  <Plug>(textobj-lastpat-N)
      omap i?  <Plug>(textobj-lastpat-N)
      xmap a/  <Plug>(textobj-lastpat-n)
      xmap i/  <Plug>(textobj-lastpat-n)
      xmap a?  <Plug>(textobj-lastpat-N)
      xmap i?  <Plug>(textobj-lastpat-N)
endfun

fun! plugs#textobjs#diffpat() abort
      nmap <Leader>dfJ <Plug>(textobj-diff-file-N)
      nmap <Leader>dfK <Plug>(textobj-diff-file-P)
      nmap <Leader>dfj <Plug>(textobj-diff-file-n)
      nmap <Leader>dfk <Plug>(textobj-diff-file-p)
      nmap <Leader>dJ  <Plug>(textobj-diff-hunk-N)
      nmap <Leader>dK  <Plug>(textobj-diff-hunk-P)
      nmap <Leader>dj  <Plug>(textobj-diff-hunk-n)
      nmap <Leader>dk  <Plug>(textobj-diff-hunk-p)
      vmap <Leader>dfJ <Plug>(textobj-diff-file-N)
      vmap <Leader>dfK <Plug>(textobj-diff-file-P)
      vmap <Leader>dfj <Plug>(textobj-diff-file-n)
      vmap <Leader>dfk <Plug>(textobj-diff-file-p)
      vmap <Leader>dJ  <Plug>(textobj-diff-hunk-N)
      vmap <Leader>dK  <Plug>(textobj-diff-hunk-P)
      vmap <Leader>dj  <Plug>(textobj-diff-hunk-n)
      vmap <Leader>dk  <Plug>(textobj-diff-hunk-p)
      omap <Leader>dfJ <Plug>(textobj-diff-file-N)
      omap <Leader>dfK <Plug>(textobj-diff-file-P)
      omap <Leader>dfj <Plug>(textobj-diff-file-n)
      omap <Leader>dfk <Plug>(textobj-diff-file-p)
      omap <Leader>dJ  <Plug>(textobj-diff-hunk-N)
      omap <Leader>dK  <Plug>(textobj-diff-hunk-P)
      omap <Leader>dj  <Plug>(textobj-diff-hunk-n)
      omap <Leader>dk  <Plug>(textobj-diff-hunk-p)

      omap adH   <Plug>(textobj-diff-file)
      omap adf   <Plug>(textobj-diff-file)
      omap adh   <Plug>(textobj-diff-hunk)
      omap idH   <Plug>(textobj-diff-file)
      omap idf   <Plug>(textobj-diff-file)
      omap idh   <Plug>(textobj-diff-hunk)
      xmap adH   <Plug>(textobj-diff-file)
      xmap adf   <Plug>(textobj-diff-file)
      xmap adh   <Plug>(textobj-diff-hunk)
      xmap idH   <Plug>(textobj-diff-file)
      xmap idf   <Plug>(textobj-diff-file)
      xmap idh   <Plug>(textobj-diff-hunk)
endfun

fun! plugs#textobjs#gn() abort
      nmap gn <Plug>(multitarget-gn-gn)
      xmap gn <Plug>(multitarget-gn-gn)
      omap gn <Plug>(multitarget-gn-gn)
endfun

fun! plugs#textobjs#comment() abort
      call textobj#user#plugin('comment', {
                        \   '-': {
                        \     'select-a-function': 'textobj#comment#select_a',
                        \     'select-a': 'aK',
                        \     'select-i-function': 'textobj#comment#select_i',
                        \     'select-i': 'iK',
                        \   },
                        \   'big': {
                        \     'select-a-function': 'textobj#comment#select_big_a',
                        \     'select-a': 'aC',
                        \   }
                        \ })
endfun

fun! plugs#textobjs#column() abort
  " xnoremap <silent> ac :<C-u>call TextObjWordBasedColumn("aw")<cr>
  " xnoremap <silent> aC :<C-u>call TextObjWordBasedColumn("aW")<cr>
  " xnoremap <silent> ic :<C-u>call TextObjWordBasedColumn("iw")<cr>
  " xnoremap <silent> iC :<C-u>call TextObjWordBasedColumn("iW")<cr>
  " onoremap <silent> ac :call TextObjWordBasedColumn("aw")<cr>
  " onoremap <silent> aC :call TextObjWordBasedColumn("aW")<cr>
  " onoremap <silent> ic :call TextObjWordBasedColumn("iw")<cr>
  " onoremap <silent> iC :call TextObjWordBasedColumn("iW")<cr>
endfu
