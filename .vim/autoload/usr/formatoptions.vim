function usr#formatoptions#setup() abort
  setl formatoptions+=1 " don't break a line after a one-letter word; break before
  setl formatoptions-=2 " use indent from 2nd line of a paragraph
  setl formatoptions+=q " format comments with gq"
  setl formatoptions+=n " recognize numbered lists. Indent past formatlistpat not under
  setl formatoptions+=M " when joining lines, don't insert a space before or after a multibyte char
  " Only break if the line was not longer than 'textwidth' when the insert
  " started and only at a white character that has been entered during the
  " current insert command.
  setl formatoptions+=l
  setl formatoptions-=v  " only break line at blank line I've entered
  setl formatoptions-=c  " auto-wrap comments using textwidth
  setl formatoptions-=t  " autowrap lines using text width value
  setl formatoptions+=r  " continue comments when pressing Enter
  setl formatoptions+=p  " don't break lines at single spaces that follow periods
  setl formatoptions+=o  " automatically insert comment leader after 'o'/'O'
  setl formatoptions-=a  " auto formatting
  setl formatoptions+=/  " when 'o' included: don't insert comment leader for // comment after statement

  if v:version > 703 || v:version == 703 && has("patch541")
    setl formatoptions+=j " remove a comment leader when joining lines.
  endif
endfunction
