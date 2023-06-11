" Check if the function in {varname} provided exists, and if so, contains a valid function name.
" The function name may be a bare name (`fn`) or have parentheses at the end (`fn()`).
func! F#valid_function(varname) abort
    return exists(a:varname) && exists('*'.substitute(eval(a:varname), '()$', '', ''))
endfun

" Returns the first item in 'iterable' where 'fn' returns 1
" Examples:
" ---------
" ```vim
"   fn#find([], { x -> x == 0 })
"      => [0, 0]
"   fn#find([0], { x -> x == 0 })
"      => [1, 0]
"   fn#find([0, 1], { x -> x == 1 })
"      => [1, 1]
"   fn#find({'a': 1, 'b': 2}, { kv -> kv[0] == 'a' })
"      => [1, ['a', 1]]
"   fn#find({'a': 1, 'b': 2}, { kv -> kv[1] == 2 })
"      => [1, ['b', 2]]
" ```
func! F#find(iterable, fn)
    let found = [0, 0]
    let list = F#as_list(a:iterable)
    for i in list
        if a:fn(i)
            let found = [1, i]
            break
        endif
    endfor

    return found
endfu

" F#fold: fold over 'iterable' with 'fn'
" Examples:
" ---------
"   fn#fold([1, 2, 3], { i, acc -> i + acc })
"      => 6
"   fn#fold(['a', 'b', 'c'], { i, acc -> acc . i })
"      => 'abc'
func! F#fold(iterable, fn)
    if empty(a:iterable)
        throw "fn#fold: empty iterable given"
    endif

    let init = 0
    let val = 0
    let list = F#as_list(a:iterable)
    for i in list
        if init
            let val = a:fn(i, val)
        else
            let val = i
            let init = 1
        endif
    endfor

    return val
endfu

func! F#as_list(iterable)
    if type(a:iterable) == type([])
        return a:iterable
    elseif type(a:iterable) == type({})
        return items(a:iterable)
    endif

    throw printf("F#as_list: unexpected type of 'iterable': '%s'", type(a:iterable))
endfu

" @usage [dict] [default] Func [args]
"   Try to call the given `Func` with an optional dict, default, and arguments.
"       F#try('fugitive#statusline')
"       F#try(function('fugitive#statusline'))
"
"   If `Func` is a dict function (and not a partial function reference),
"   it is necessary to provide the [dict] parameter to properly provide `self`.
"       F#try({}, 'dict.Func')
"
"   A [default] value may be given before the funcref, if it is inside of a list.
"       F#try(['default'], 'F')
"
"   Arguments are passed after the function name or reference.
"       F#try(['default'], 'F', 1, 2, 3)
"
" This function is originally by Tim Pope as part of Flagship.
"
" @default default=''
" @default dict={}
" @default args=[]
func! F#try(...) abort
    let l:args = copy(a:000)
    let l:dict = {}
    let l:default = ''

    if type(get(l:args, 0)) == v:t_dict | let l:dict = remove(l:args, 0) | endif
    if type(get(l:args, 0)) == v:t_list | let l:default = remove(l:args, 0)[0] | endif
    if empty(l:args) | return l:default | endif

    let l:Func = remove(l:args, 0)
    if type(l:Func) == v:t_func || exists('*' . l:Func)
        return call(l:Func, l:args, l:dict)
    else
        return l:default
    endif
endfun

" Add {item} to a copy of {list}. See |add()|.
func! F#add(list, item) abort
    return add(deepcopy(a:list), deepcopy(a:item))
endfun

" Insert {item} into a copy of {list}, at [index]. See |insert()|.
" @default index = 0
func! F#insert(list, item, ...) abort
    let l:list = deepcopy(a:list)
    let l:item = deepcopy(a:item)
    if a:0
        return insert(l:list, l:item, a:1)
    else
        return insert(l:list, l:item)
    endif
endfun

" @usage {list} {idx} [end]
"   Removes and returns a copy of the item at {idx} in {list}. If [end] is
"   present, removes and returns a list containing a copy of the items from {idx}
"   to [end].
"
" @usage {dict} {key}
"   Returns and removes a copy of the item with the key {key} in {dict}.
"
" @all
" This function is similar to |remove()|, but has a different return signature
" (`[item, copy]` or `[[item, ...], copy]`) so that the immutability of the
" list or dictionary is maintained.
func! F#remove(collection, index, ...) abort
    let l:collection = deepcopy(a:collection)
    if type(l:collection) == t:v_dict || !a:0
        return [deepcopy(remove(l:collection, a:index)), l:collection]
    else
        return [deepcopy(remove(l:collection, a:index, a:1)), l:collection]
    endif
endfun

" Merge {expr2} to a copy of {expr1}. See |extend()|.
func! F#extend(expr1, expr2, ...) abort
    let l:expr1 = deepcopy(a:expr1)
    let l:expr2 = deepcopy(a:expr2)
    if a:0
        return extend(l:expr1, l:expr2, a:1)
    else
        return extend(l:expr1, l:expr2)
    endif
endfun

" Returns a copy of {expr1} containing items where {expr2} is true. See
" |filter()|.
func! F#filter(expr1, expr2) abort
    return filter(deepcopy(a:expr1), a:expr2)
endfun

" Return a reversed copy of {list}. See |reverse()|.
func! F#reverse(list) abort
    return reverse(deepcopy(a:list))
endfun

" @usage {list} [func] [dict]
"   Return a sorted copy of {list}. See |sort()|.
func! F#sort(list, ...) abort
    let l:list = deepcopy(a:list)
    if a:0 > 1
        return sort(l:list, a:1, a:2)
    elseif a:0
        return sort(l:list, a:1)
    else
        return sort(l:list)
    endif
endfun

" @usage {list} [func] [dict]
"   Return a copy of a list with second and succeeding copies of repeated
"   adjacent list items in-place. See |uniq()|.
func! F#uniq(list, ...) abort
    let l:list = deepcopy(a:list)
    if a:0 > 1
        return uniq(l:list, a:1, a:2)
    elseif a:0
        return uniq(l:list, a:1)
    else
        return uniq(l:list)
    endif
endfun

" Return a copy of the values of {dict}. See |values()|.
"
" Note that there is no F#keys() because dictionary keys are essentially
" immutable in Vim as they can only be strings.
func! F#values(dict) abort
    return deepcopy(values(a:dict))
endfun

" Returns a copy of {expr1} that has each item replaced with the result of
" evaluating {expr2}. See |map()|.
func! F#map(expr1, expr2) abort
    return map(deepcopy(a:expr1), a:expr2)
endfun

" Returns a list with a copy of all the key-value pairs of {dict}. Each item is
" a list containing the key and the corresponding value. See |items()|.
func! F#items(dict) abort
    return items(deepcopy(a:dict))
endfun

" Returns a copy of {expr1} containing items where {expr2} is false.
" See |filter()|.
func! F#reject(expr1, expr2) abort
    let l:expr1 = deepcopy(a:expr1)
    if type(a:expr2 == v:t_string)
        return filter(l:expr1, printf('!(%s)', a:expr2))
    elseif type(l:expr1 == v:t_dict)
        return filter(l:expr1, { k, v -> !a:expr2(k, v) })
    else
        return filter(l:expr1, { v -> !a:expr2(k, v) })
    endif
endfun

" @usage {expr} [initial] {Fn}
"   Loops over the items in {expr} (which must be a |List| or |Dictionary|) and
"   executes {Fn}. If [initial] is not provided, the first item in {expr} is
"   used as the initial value. The default [initial] value for a dictionary is an
"   empty dictionary.
"
" When {expr} is empty, the [initial] value will be returned.
"
" {Fn} must be a function reference or lambda that returns the accumulator
" (`acc`) value. If {expr} is a |List|, {Fn} must accept two arguments (`val`
" and `acc`). If {expr} is a |Dict|, {Fn} must accept three arguments (`key`,
" `val`, and `acc`). Unlike |map()| and |filter()|, {Fn} may not be a string
" value (there is no easy way to simulate a `v:acc` parameter).
func! F#reduce(expr, initial, ...) abort
    let l:expr = deepcopy(a:expr)
    if a:0
        let l:Fn = a:1
        let l:a = deepcopy(a:initial)
    else
        let l:Fn = a:initial
        if type(l:expr) == v:t_dict
            let l:a = {}
        else
            let l:a = remove(l:expr, 0)
        endif
    endif

    let l:Fn = F#_ref(l:Fn)
    if type(l:Fn) != v:t_func
        throw 'F#reduce requires a function name or reference.'
    endif

    if type(l:expr) == v:t_dict
        for [l:k, l:v] in items(l:expr) | let l:a = l:Fn(l:k, l:v, l:a) | endfor
    else
        for l:v in l:expr | let l:a = l:Fn(l:v, l:a) | endfor
    endif

    return l:a
endfun

" Loops over the items in {/expr} and executes {Fn}, returning false if {Fn} is
" false for any value in {expr}. The value of {Fn} is the same as can be found
" for |filter()|.
"
" If {Fn} is a string that is not the name of a function, this function will be
" slower than if it is a function name or a function reference.
func! F#all(expr, Fn) abort
    let l:expr = deepcopy(a:expr)
    let l:Fn = F#_ref(a:Fn)

    if type(l:Fn) == v:t_func
        if type(l:expr) == v:t_dict
            let l:Fn = { k, v -> !l:Fn(k, v) }
        else
            let l:Fn = { v -> !l:Fn(v) }
        endif
    else
        let l:Fn = printf('!(%s)', l:Fn)
    endif

    return !F#any(l:expr, l:Fn)
endfun


" Loops over the items in {expr} and executes {Fn}, returning false if {Fn} is
" true for any value in {expr}. The value of {Fn} is the same as can be found
" for |filter()|.
"
" If {Fn} is a string that is not the name of a function, this function will be
" slower than if it is a function name or a function reference.
func! F#none(expr, Fn) abort
    return !F#any(a:expr, a:Fn)
endfun


" Loops over the items in {expr} and executes {Fn}, returning true if {Fn} is
" true for any value in {expr}. The value of {Fn} is the same as can be found
" for |filter()|.
"
" If {Fn} is a string that is not the name of a function, this function will be
" slower than if it is a function name or a function reference.
func! F#any(expr, Fn) abort
    let l:expr = deepcopy(a:expr)
    let l:Fn = F#_ref(a:Fn)

    if type(l:Fn) == v:t_func
        if type(l:expr) == v:t_dict
            for [l:k, l:v] in items(l:expr) |
                if l:Fn(l:k, l:v) | return v:true | endif
            endfor
        else
            for l:v in l:expr
                if l:Fn(l:v) | return v:true | endif
            endfor
        endif

        return v:false
    endif

    return !empty(filter(l:expr, l:Fn))
endfun

" @usage {list} {idx} {item}
"   Returns a copy of {list} where the item at {index} is a copy of {item}.
"
" @usage {dict} {key} {value}
"   Returns a copy of {dict} where the item with key {key} is a copy of {item}.
func! F#replace(collection, index, value) abort
    let l:collection = deepcopy(a:collection)
    let l:collection[a:index] = deepcopy(a:value)
    return l:collection
endfun

" @usage {list} {idx}
"   Returns a copy of {list} where the item at {index} has been removed.
"
" @usage {dict} {key}
"   Returns a copy of {dict} where the item with key {key} has been removed.
func! F#pop(collection, index) abort
    let l:collection = deepcopy(a:collection)
    call remove(l:collection, a:index)
    return l:collection
endfun

" If {expr} is a list, returns {expr}. Otherwise, it wraps {expr} in a list.
func! F#wrap(expr) abort
    if type(a:expr) == v:t_list
        return a:expr
    else
        return [a:expr]
    endif
endfun

" @usage {list...}
" Return a flattened copy of {list...}.
func! F#flatten(list, ...) abort
    let l:flat = []
    let l:list = extend(F#wrap(deepcopy(a:list)), deepcopy(a:000))
    while !empty(l:list)
        let l:item = remove(l:list, 0)
        if type(l:item) == v:t_list
            let l:list = extend(l:item, l:list)
        else
            call add(l:flat, l:item)
        endif
    endwhile
    return l:flat
endfun

" Answers if {needle} can be found in the provided {haystack} which may be a
" string, list, or dictionary (where is searches the values).
"
" If {haystack} is a string, but {needle} is not, returns false.
" If {haystack} is neither a string, list, nor dictionary, returns false.
func! F#in(haystack, needle) abort
    if type(a:haystack) == v:t_string
        return type(a:needle) == v:t_string && strdix(a:haystack, a:needle) != -1
    elseif type(a:haystack) == v:t_list
        return index(a:haystack, a:needle) != -1
    elseif type(a:haystack) == v:t_dict
        return index(values(a:haystack), a:needle) != -1
    endif

    return v:false
endfun
