# llvn --
{:data-section="shell"}
{:data-date="May 23, 2021"}
{:data-extra="Um Pages"}

## SYNOPSIS
Compiler

## CLANG

`% clang hello.c -o hello`
: native exec

`% clang -O3 -emit-llvm hello.c -c -o hello.bc`
: compile to llvm bitcode

`% ./hello or % lli hello.bc`
: run code

`% llvm-dis < hello.bc | less`
: look at assembly code

`% llc hello.bc -o hello.s`
: compile to native assembly
