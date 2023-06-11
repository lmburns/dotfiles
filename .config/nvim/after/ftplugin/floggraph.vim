setl lcs-=trail:•
set ve=all

augroup Flog
    au! * <buffer>
    au BufEnter <buffer> set ve=all
    au BufLeave <buffer> set ve=
augroup END

" Misc. mappings [[[
nmap <buffer> g? <Plug>(FlogHelp)
nmap <buffer> y<C-G> <Plug>(FlogYank)
vmap <buffer> y<C-G> <Plug>(FlogYank)
nmap <buffer> git <Plug>(FlogGit)
vmap <buffer> git <Plug>(FlogGit)
nmap <buffer> ZZ <Plug>(FlogQuit)
nmap <buffer> gq <Plug>(FlogQuit)
nmap <buffer> dq <Plug>(FlogCloseTmpWin)

nmap <buffer> qd <Plug>(FlogCloseTmpWin)
" nmap <buffer> qq <Plug>(FlogQuit)
nmap <buffer> Q <Plug>(FlogQuit)
" ]]]

" Diff mappings [[[
nmap <buffer> d? <Plug>(FlogDiffHelp)
nmap <buffer> dd <Plug>(FlogVDiffSplitRight)
vmap <buffer> dd <Plug>(FlogVDiffSplitRight)
nmap <buffer> dv <Plug>(FlogVDiffSplitRight)
vmap <buffer> dv <Plug>(FlogVDiffSplitRight)
nmap <buffer> DD <Plug>(FlogVDiffSplitPathsRight)
vmap <buffer> DD <Plug>(FlogVDiffSplitPathsRight)
nmap <buffer> DV <Plug>(FlogVDiffSplitPathsRight)
vmap <buffer> DV <Plug>(FlogVDiffSplitPathsRight)
nmap <buffer> d! <Plug>(FlogVDiffSplitLastCommitRight)
nmap <buffer> D! <Plug>(FlogVDiffSplitLastCommitPathsRight)

nmap <buffer> dp <Plug>(FlogVDiffSplitPathsRight)
vmap <buffer> dp <Plug>(FlogVDiffSplitPathsRight)
nmap <buffer> ss <Plug>(FlogVDiffSplitRight)
vmap <buffer> ss <Plug>(FlogVDiffSplitRight)
nmap <buffer> sp <Plug>(FlogVDiffSplitPathsRight)
vmap <buffer> sp <Plug>(FlogVDiffSplitPathsRight)
nmap <buffer> sc <Plug>(FlogVDiffSplitLastCommitRight)
" ]]]

" Navigation mappings [[[
nmap <buffer> a <Plug>(FlogToggleAll)
nmap <buffer> gb <Plug>(FlogToggleBisect)
nmap <buffer> gm <Plug>(FlogToggleMerges)
nmap <buffer> gr <Plug>(FlogToggleReflog)
nmap <buffer> gx <Plug>(FlogToggleGraph)
nmap <buffer> gp <Plug>(FlogTogglePatch)
nmap <buffer> g/ <Plug>(FlogSearch)
nmap <buffer> g\ <Plug>(FlogPatchSearch)
nmap <buffer> goo <Plug>(FlogCycleOrder)
nmap <buffer> god <Plug>(FlogOrderDate)
nmap <buffer> goa <Plug>(FlogOrderAuthor)
nmap <buffer> got <Plug>(FlogOrderTopo)
nmap <buffer> gor <Plug>(FlogToggleReverse)
nmap <buffer> gcc <Plug>(FlogClearRev)
nmap <buffer> gcg <Plug>(FlogSetSkip)
nmap <buffer> gct <Plug>(FlogSetRev)
nmap <buffer> gs <Plug>(FlogVSplitStaged)
nmap <buffer> gu <Plug>(FlogVSplitUntracked)
nmap <buffer> gU <Plug>(FlogVSplitUnstaged)
nmap <buffer> ^ <Plug>(FlogJumpToCommitStart)
vmap <buffer> ^ <Plug>(FlogJumpToCommitStart)
" FIX: Buffer keeps resizing bigger and bigger
nmap <buffer> ]] <Plug>(FlogSkipAhead)
nmap <buffer> [[ <Plug>(FlogSkipBack)

nmap <buffer> <C-i> <Plug>(FlogJumpToNewer)
nmap <buffer> <C-o> <Plug>(FlogJumpToOlder)
nmap <buffer> [f <Plug>(FlogJumpToChild)
nmap <buffer> ]f <Plug>(FlogJumpToParent)
nmap <buffer> } <Plug>(FlogNextCommit)
nmap <buffer> { <Plug>(FlogPrevCommit)
" nmap <buffer> ) <Plug>(FlogVNextCommitRight)
" nmap <buffer> ( <Plug>(FlogVPrevCommitRight)
nnoremap <buffer><silent> ) <Cmd>call flog#floggraph#nav#NextCommit()<Bar>vert bel Flogsplitcommit<CR><Cmd>vert resize 60<CR>
nnoremap <buffer><silent> ( <Cmd>call flog#floggraph#nav#PrevCommit()<Bar>vert bel Flogsplitcommit<CR><Cmd>vert resize 60<CR>
nnoremap <buffer><silent> <C-n> <Cmd>call flog#floggraph#nav#NextCommit()<Bar>bel Flogsplitcommit<CR>z20<CR>
nnoremap <buffer><silent> <C-p> <Cmd>call flog#floggraph#nav#PrevCommit()<Bar>bel Flogsplitcommit<CR>z20<CR>
nmap <buffer> ]R <Plug>(FlogVNextRefRight)
nmap <buffer> [R <Plug>(FlogVPrevRefRight)
nnoremap <buffer><silent> ]r <Cmd>call flog#floggraph#nav#NextRefCommit()<Bar>belowright Flogsplitcommit<CR>z20<CR>
nnoremap <buffer><silent> [r <Cmd>call flog#floggraph#nav#PrevRefCommit()<Bar>belowright Flogsplitcommit<CR>z20<CR>
" ]]]

" Commit/branch mappings [[[
nmap <buffer> c? <Plug>(FlogCommitHelp)
nmap <buffer> cf <Plug>(FlogFixup)
nmap <buffer> cF <Plug>(FlogFixupRebase)
nmap <buffer> cs <Plug>(FlogSquash)
nmap <buffer> cS <Plug>(FlogSquashRebase)
nmap <buffer> cA <Plug>(FlogSquashEdit)
nmap <buffer> crc <Plug>(FlogRevert)
vmap <buffer> crc <Plug>(FlogRevert)
nmap <buffer> crn <Plug>(FlogRevertNoEdit)
vmap <buffer> crn <Plug>(FlogRevertNoEdit)
nmap <buffer> coo <Plug>(FlogCheckout)
nmap <buffer> cob <Plug>(FlogCheckoutBranch)
nmap <buffer> col <Plug>(FlogCheckoutLocalBranch)
nmap <buffer> c<Space> <Plug>(FlogGitCommit)
vmap <buffer> c<Space> <Plug>(FlogGitCommit)
nmap <buffer> cr<Space> <Plug>(FlogGitRevert)
vmap <buffer> cr<Space> <Plug>(FlogGitRevert)
nmap <buffer> cm<Space> <Plug>(FlogGitMerge)
vmap <buffer> cm<Space> <Plug>(FlogGitMerge)
nmap <buffer> co<Space> <Plug>(FlogGitCheckout)
vmap <buffer> co<Space> <Plug>(FlogGitCheckout)
nmap <buffer> cb<Space> <Plug>(FlogGitBranch)
vmap <buffer> cb<Space> <Plug>(FlogGitBranch)

nmap <buffer> u <Plug>(FlogUpdate)
nmap <buffer> U <Plug>(FlogUpdate)
nmap <buffer><nowait> < <Plug>(FlogCollapseCommit)
vmap <buffer> < <Plug>(FlogCollapseCommit)
nmap <buffer><nowait> > <Plug>(FlogExpandCommit)
vmap <buffer> > <Plug>(FlogExpandCommit)
nmap <buffer><nowait> = <Plug>(FlogToggleCollapseCommit)
vmap <buffer> = <Plug>(FlogToggleCollapseCommit)
nmap <buffer> o <Plug>(FlogVSplitCommitRight)
" nmap <buffer> <CR> <Plug>(FlogVSplitCommitRight)
nnoremap <buffer><silent> <CR> <Cmd>bel Flogsplitcommit<CR>
nmap <buffer> <Tab> <Plug>(FlogVSplitCommitPathsRight)
" ]]]

" Rebase mappings [[[
nmap <buffer> r? <Plug>(FlogRebaseHelp)
nmap <buffer> ri <Plug>(FlogRebaseInteractive)
nmap <buffer> rf <Plug>(FlogRebaseInteractiveAutosquash)
nmap <buffer> ru <Plug>(FlogRebaseInteractiveUpstream)
nmap <buffer> rp <Plug>(FlogRebaseInteractivePush)
nmap <buffer> rr <Plug>(FlogRebaseContinue)
nmap <buffer> rs <Plug>(FlogRebaseSkip)
nmap <buffer> ra <Plug>(FlogRebaseAbort)
nmap <buffer> re <Plug>(FlogRebaseEditTodo)
nmap <buffer> rw <Plug>(FlogRebaseInteractiveReword)
nmap <buffer> rm <Plug>(FlogRebaseInteractiveEdit)
nmap <buffer> rd <Plug>(FlogRebaseInteractiveDrop)
nmap <buffer> r<Space> <Plug>(FlogGitRebase)
vmap <buffer> r<Space> <Plug>(FlogGitRebase)
" ]]]

" Mark mappings [[[
nmap <buffer> m <Plug>(FlogSetCommitMark)
vmap <buffer> m <Plug>(FlogSetCommitMark)
nmap <buffer> ' <Plug>(FlogJumpToCommitMark)
vmap <buffer> ' <Plug>(FlogJumpToCommitMark)
" ]]]


" nnoremap <buffer> rl :Floggit reset <C-r>=flog#get_commit_at_line().short_commit_hash<CR>
" nnoremap <buffer> rh :Floggit reset --hard <C-r>=flog#get_commit_at_line().short_commit_hash<CR>
nnoremap <buffer> rl :exec flog#Format('Git reset %h')<CR>
nnoremap <buffer> rh :exec flog#Format('Git reset --hard %h')<CR>
" nnoremap <buffer> gR :exec flog#Format('Git reset HEAD^')<CR>

" nnoremap <buffer> <Leader>gt :Floggit difftool -y <C-r>=flog#get_commit_at_line().short_commit_hash<CR>
nnoremap <buffer> <Leader>gt :exec flog#Format('Git difftool -y %h')<CR>
xnoremap <buffer> <Leader>gt :Floggit difftool -y<Space>

nnoremap <buffer> <Leader>gs :Flogsetargs -- <C-r>=flog#get_commit_at_line().short_commit_hash<CR>
nnoremap <buffer> <Leader>gp :Flogsetargs -raw-args=--first-parent -- <C-r>=flog#get_commit_at_line().short_commit_hash<CR><CR>
" Update the arguments passed to "git log
nnoremap <buffer> <Leader>gr :Flogsetargs -raw-args=

nnoremap <buffer> qm <Cmd>Flogmarks<CR>
" nnoremap <buffer> gS q:Gedit :<CR>
" nnoremap <buffer> . :call flog#Format('Git ... %h')

nnoremap <buffer> ca :Floggit commit --amend<CR>
nnoremap <buffer> cf :exec flog#Format('Git commit --fixup=%h')<CR>
nnoremap <buffer> cp :exec flog#Format('Git cherry-pick %h')<CR>

nnoremap <buffer> czz :Floggit stash push<CR>
nnoremap <buffer> czp :Floggit stash pop<CR>

"  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

" nmap <buffer> p <CR><C-w>lzMggzj<C-w>h

" Open current commit in browser
" nnoremap <buffer> <Leader>gb :exec flog#Format('GBrowse %h')<CR>
" nnoremap <buffer> <Leader>gb :GBrowse <C-r>=flog#get_commit_at_line().short_commit_hash<CR><CR>

function s:scroll(direction) abort
    let winnr = winnr('$')
    if winnr < 2
        if a:direction
            exe "sil! norm! \<C-f>"
        else
            exe "sil! norm! \<C-b>"
        endif
        return
    endif
    noa winc p
    if a:direction
        exe "sil! norm! \<C-d>"
    else
        exe "sil! norm! \<C-u>"
    endif
    noa winc p
endfunction

nnoremap <buffer><silent> <C-f> <Cmd>call <SID>scroll(1)<CR>
nnoremap <buffer><silent> <C-b> <Cmd>call <SID>scroll(0)<CR>
nnoremap <buffer><silent> gg :<C-U>call flog#floggraph#mark#SetJump()<CR>gg
nnoremap <buffer><silent> G :<C-U>call flog#floggraph#mark#SetJump()<CR>G
nnoremap <buffer><silent> <C-d> :<C-U>call flog#floggraph#mark#SetJump()<CR><C-d>
nnoremap <buffer><silent> <C-u> :<C-U>call flog#floggraph#mark#SetJump()<CR><C-u>
