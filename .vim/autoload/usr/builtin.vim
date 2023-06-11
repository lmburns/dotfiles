fun! usr#builtin#prefix_timeout(prefix)
    let char = getcharstr(0)
    if empty(char)
        return '\<Ignore>'
    else
        return a:prefix . char
    endif
endfu

fun! usr#builtin#jumps2qf() abort
    let jumplist = getjumplist()
    let [locs, pos] = [jumplist[0], jumplist[1]]
    let cur_bufnr = bufnr()
    let [items, idx] = [[], 1]
    let i = len(locs)

    while i > 0
        let i -= 1
        let loc = locs[i]
        let [bufnr, lnum, col] = [loc.bufnr, loc.lnum, loc.col + 1]

        " if api#buf#is_valid(bufnr)
        " if filereadable(bufname(bufnr))
        if bufexists(bufnr)
            let lines = getbufline(bufnr, lnum)
            if empty(lines)
                let text = '......'
            else
                let text = join(lines)
            endif
            call add(items, {'bufnr': bufnr, 'lnum': lnum, 'col': col, 'text': text})
        endif
       if pos + 1 == i
           let idx = len(items)
       end
    endwhile

    call setloclist(0, [], ' ', {'title': 'JumpList', 'items': items, 'idx': idx})
    let winid = getloclist(0, {'winid': 0}).winid
    if winid == 0
        bel lwindow
    else
        call win_gotoid(winid)
    endif
endfu

fun! usr#builtin#jumps2qf_alt() abort
    redir => output
    silent! jumps
    redir end

    let cur_bufnr = bufnr()
    let items = []
    let qf_idx = 1
    let i = 0
    for line in reverse(split(output, '\n')[1:])
        let m = matchlist(line, '\v^(.)\s*(\d+)\s+(\d+)\s+(\d+)\s*(.*)$')
        if empty(m)
            continue
        end
        let i += 1
        if m[1] == '>'
            let qf_idx = i
        end
        let bufnr = bufnr(m[5])
        let text = '-'
        let [lnum, col] = m[3:4]
        let col += 1
        if bufnr < 0
            let bufnr = cur_bufnr
            let text = m[5]
        else
            let lines = getbufline(bufnr, lnum)
            if empty(lines)
                let text = '......'
            else
                let text = join(lines)
            endif
        endif
        call add(items, {'bufnr': bufnr, 'lnum': lnum, 'col': col, 'text': text})
    endfor
    call setloclist(0, [], ' ', {'title': 'JumpList', 'items': items, 'idx': qf_idx})
    let winid = getloclist(0, {'winid': 0}).winid
    if winid == 0
        bel lwindow
    else
        call win_gotoid(winid)
    endif
endfu
