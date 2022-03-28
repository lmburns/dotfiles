require("common.utils")

cmd [[
  augroup rust_env
    autocmd!
    autocmd FileType rust
      \ nmap     <buffer> <Leader>h<CR> :VT cargo clippy<CR>|
      \ nmap     <buffer> <Leader>n<CR> :VT cargo run   -q<CR>|
      \ nmap     <buffer> <Leader><Leader>n :VT cargo run -q<space>|
      \ nmap     <buffer> <Leader>t<CR> :RustTest<CR>|
      \ nmap     <buffer> <Leader>b<CR> :VT cargo build -q<CR>|
      \ nmap     <buffer> <Leader>r<CR> :VT cargo play  %<CR>|
      \ nmap     <buffer> <Leader><Leader>r :VT cargo play % -- |
      \ nmap     <buffer> <Leader>v<CR> :VT rust-script %<CR>|
      \ nmap     <buffer> <Leader><Leader>v :VT rust-script % -- |
      \ nmap     <buffer> <Leader>e<CR> :VT cargo eval  %<CR>|
      \ vnoremap <a-f> <esc>`<O<esc>Sfn main() {<esc>`>o<esc>S}<esc>k$|
      \ nnoremap <Leader>K : set winblend=0 \| FloatermNew --autoclose=0 rusty-man --viewer tui<space>|
      \ nnoremap <Leader>k : set winblend=0 \| FloatermNew --autoclose=0 rusty-man <C-r><C-w> --viewer tui<CR>|
      \ nnoremap <buffer> ;ff           :RustFmt<cr>
  augroup END
]]
