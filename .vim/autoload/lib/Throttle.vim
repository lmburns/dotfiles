" Restrict a function so that it is called only once within *wait* ms.
"
" Parameters:
"  * fn: a funcref that can accept no arguments.
"  * wait: ms at most that it will be called.
"  * leading (optional): default of true. trigger the function at the beginning
"  of the 'wait' period. Pass 'false' to trigger the function at the end (like a
"  debounce).
"
" Notes:
"
" call() returns the last return value that 'fn' returned in 'leading' mode. In
" 'tailing/debouncing' mode '<throttled>' is always returned (as 'fn' will be
" called at some future date)
"
" You can call `lastresult()` of the dictionary returned by this method to
" obtain the most recent result of a call to the throttled function.
"
" Returns: A dictionary, execute the function by calling .call(ARGS).
function! lib#Throttle#(fn, wait, ...) abort
  let l:leading = 1
  if exists('a:1')
    let l:leading = a:1
  end

  let l:result = {
      \'data': {
      \   'leading': l:leading,
      \   'lastcall': 0,
      \   'lastresult': 0,
      \   'lastargs': 0,
      \   'timer_id': 0,
      \ 'wait': a:wait},
      \ 'fn': a:fn
      \}

  function l:result.wrap_call_fn(...) dict
    let self.data.lastcall = reltime()
    let self.data.lastresult = call(self.fn, self.data.lastargs)
    let self.data.timer_id = 0
    return self.data.lastresult
  endfunction

  function l:result.lastresult() dict
    return self.data.lastresult
  endfunction

  function l:result.call(...) dict
    if self.data.leading
      let l:lastcall = self.data.lastcall
      let l:elapsed = reltimefloat(reltime(l:lastcall))
      if type(l:lastcall) == 0 || l:elapsed > self.data.wait / 1000.0
        let self.data.lastargs = a:000
        return self.wrap_call_fn()
      endif
    elseif self.data.timer_id == 0
      let self.data.lastargs = a:000
      let self.data.timer_id = timer_start(self.data.wait, self.wrap_call_fn)
      return '<throttled>'
    else
      return '<throttled>'
    endif
    return self.data.lastresult
  endfunction
  return l:result
endfunction
