" Utilities for keymapping.

" Variable name convention:
" maparg: Dictionary which maparg() returns when {dict} is true.
" dict: it differs a little from `maparg` above. it contains more keys like "unique", etc.
" chars: String that each character means option. e.g., "b" (which means <buffer>)
" raw: String that option passing to :map command's argument. e.g., "<buffer>"
" mode: a character which means current mode. see s:get_all_modes() for available modes.
" lhs: :help {lhs}
" rhs: :help {rhs}

" Conversion of options: chars <-> dict <-> raw
" To convert `chars` to `raw`, it must convert to `dict` at first.

function! s:options_dict2raw(dict) abort
  return
      \   (get(a:dict, 'expr')     ? '<expr>' : '')
      \   . (get(a:dict, 'buffer') ? '<buffer>' : '')
      \   . (get(a:dict, 'silent') ? '<silent>' : '')
      \   . (get(a:dict, 'script') ? '<script>' : '')
      \   . (get(a:dict, 'unique') ? '<unique>' : '')
      \   . (get(a:dict, 'nowait') ? '<nowait>' : '')
endfunction

function! s:options_dict2chars(dict) abort
  return
      \   (get(a:dict, 'expr')      ? 'e' : '')
      \   . (get(a:dict, 'buffer')  ? 'b' : '')
      \   . (get(a:dict, 'silent')  ? 's' : '')
      \   . (get(a:dict, 'script')  ? 'c' : '')
      \   . (get(a:dict, 'unique')  ? 'u' : '')
      \   . (get(a:dict, 'noremap') ? 'n' : '')
      \   . (get(a:dict, 'nowait')  ? 'w' : '')
endfunction

function! s:options_chars2raw(chars) abort
  return s:options_dict2raw(s:options_chars2dict(a:chars))
endfunction

function! s:options_chars2dict(chars) abort
  return {
      \   'expr': (stridx(a:chars, 'e') isnot -1),
      \   'buffer': (stridx(a:chars, 'b') isnot -1),
      \   'script' : (stridx(a:chars, 'c') isnot -1),
      \   'unique': (stridx(a:chars, 'u') isnot -1),
      \   'silent' : (stridx(a:chars, 'S') is -1),
      \   'noremap': (stridx(a:chars, 'N') is -1 || stridx(a:chars, 'n') isnot -1),
      \   'nowait': (stridx(a:chars, 'W') is -1 || stridx(a:chars, 'w') isnot -1),
      \}
endfunction

function! usr#map#(mode, lhs, rhs, ...) abort
  let maps = usr#map#get_map(a:mode, a:lhs, a:rhs, a:0 ? a:1 : {})
  for map in maps
    execute map
  endfor
endfunction

function! usr#map#get_map(...) abort
  return call('s:__get_map', ['map'] + a:000)
endfunction

function! usr#map#abbr(mode, lhs, rhs, ...) abort
  execute usr#map#get_abbr(a:mode, a:lhs, a:rhs, a:0 ? a:1 : {})
endfunction

function! usr#map#get_abbr(...) abort
  return call('s:__get_map', ['abbr'] + a:000)
endfunction

function! usr#map#unmap(mode, lhs, dict) abort
  execute usr#map#get_unmap(a:mode, a:lhs, a:dict)
endfunction

function! s:__get_map(type, mode, lhs, rhs, dict) abort
  let t = type(a:dict)
  if !( t == v:t_dict || t == v:t_string )
      \   || !s:is_mode_char(a:mode)
      \   || a:lhs ==# ''
      \   || a:rhs ==# ''
    return ''
  endif

  let dict = t == v:t_string ? s:options_chars2dict(a:dict) : a:dict

  let noremap = get(dict, 'noremap', 1)
  let lhs = substitute(a:lhs, '\V|', '<Bar>', 'g')
  let rhs = substitute(a:rhs, '\V|', '<Bar>', 'g')
  let mode_i = type(a:mode) == v:t_list ? a:mode : [a:mode]

  return map(mode_i, {_,m -> join([
      \   m . (noremap ? 'nore' : '') . a:type,
      \   s:options_dict2raw(dict),
      \   lhs,
      \   rhs,
      \])})
endfunction

function! usr#map#get_unmap(...) abort
  return call('s:__get_unmap', ['unmap'] + a:000)
endfunction

function! usr#map#get_unabbr(...) abort
  return call('s:__get_unmap', ['unabbr'] + a:000)
endfunction

function! s:__get_unmap(typ, mode, lhs, dict) abort
  if !type(a:dict) == v:t_dict
      \   || !s:is_mode_char(a:mode)
      \   || a:lhs ==# ''
    return ''
  endif

  let lhs = substitute(a:lhs, '\V|', '<Bar>', 'g')
  return join([
      \   a:mode . a:typ,
      \   s:options_dict2raw(a:dict),
      \   lhs,
      \])
endfunction


let s:ALL_MODES = 'noiclxs'
function! usr#map#get_all_modes() abort
  return s:ALL_MODES
endfunction

let s:ALL_MODES_LIST = split(s:ALL_MODES, '\zs')
function! usr#map#get_all_modes_list() abort
  return copy(s:ALL_MODES_LIST)
endfunction

function! s:is_mode_char(char) abort
  let is_mode = v:true
  if type(a:char) == v:t_list
    for mode in a:char
      if mode !~# '^[v'.s:ALL_MODES.']$'
        let is_mode = v:false
        break
      endif
    endfor
  else
    let is_mode = a:char =~# '^[v'.s:ALL_MODES.']$'
  endif
  return is_mode
endfunction
