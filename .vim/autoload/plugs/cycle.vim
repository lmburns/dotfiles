fun! plugs#cycle#setup() abort
    let g:cycle_default_groups = [
                \ [['true', 'false']], [['enable', 'disable']], [['yes', 'no']], [['on', 'off']],
                \ [['and', 'or']], [['up', 'down']], [['above', 'below']], [['left', 'right']], [['prev', 'next']],
                \ [['in', 'out']], [['top', 'bottom']], [['before', 'after']], [['forward', 'backward']],
                \ [['width', 'height']], [['push', 'pull']], [['max', 'min']], [['new', 'old']],
                \ [['dark', 'light']], [['good', 'bad']], [['floor', 'ceil']], [['read', 'write']],
                \ [['get', 'set']], [['upper', 'lower']], [['open', 'close']], [['&&', '||']], [['==', '!=']],
                \ [['>=', '<=']], [['<<', '>>']], [['++', '--']],
                \ [['trace', 'debug', 'info', 'warn', 'error', 'fatal']],
                \ [['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
                \   'hard_case', {'name': 'Days'}],
                \ [['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August',
                \   'September', 'October', 'November', 'December'],
                \   'hard_case', {'name': 'Months'}],
                \ ['zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten']]

    let g:cycle_default_groups_for_python = [[['elif', 'if']]]
    let g:cycle_default_groups_for_sh = [[['elif', 'if']]]
    let g:cycle_default_groups_for_zsh = [[['elif', 'if']], [['((:))', '[[:]]'], 'sub_pairs']]
    let g:cycle_default_groups_for_vim = [[['elseif', 'if']]]
    let g:cycle_default_groups_for_lua = [[['elseif', 'if']], [['==', '~=']], [['pairs', 'ipairs']]]
    let g:cycle_default_groups_for_go = [
                \ [['==', '!=']], [[':=', '=']], [['interface', 'struct']],
                \ [['int', 'int8', 'int16', 'int32', 'int64']],
                \ [['uint', 'uint8', 'uint16', 'uint32', 'uint64']], [['float32', 'float64']],
                \ [['complex64', 'complex128']]
                \ ]
    let l:javascript_group = [[['===', '!==']], [['let', 'const', 'var']]]
    let g:cycle_default_groups_for_javascript = l:javascript_group
    let g:cycle_default_groups_for_typescript = extend([[['public', 'private', 'protected']]], l:javascript_group)

    nnoremap <Plug>CycleFallbackNext +
    nnoremap <Plug>CycleFallbackPrev _
    nmap + <Plug>CycleNext
    xmap + <Plug>CycleNext
    smap + <C-g>o<Esc><Plug>CycleNext
    nmap _ <Plug>CyclePrev
    xmap _ <Plug>CyclePrev
    smap _ <C-g>o<Esc><Plug>CycleNext

    call cycle#reset_ft_groups()
endfun
