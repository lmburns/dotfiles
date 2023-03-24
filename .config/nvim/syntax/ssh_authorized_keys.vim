" Vim syntax file
" Language:     OpenSSH authorized_keys
" Author:       Masaki Hara <ackie.h.gmai@gmail.com>
" Date:         February 09, 2017
" File Types:   authorized_keys
" Version:      1
" Notes:
"

" Setup
if version >= 600
  if exists("b:current_syntax")
    finish
  endif
else
  syntax clear
endif

setlocal iskeyword=_,-,a-z,A-Z,48-57

" Case-sensitive
syn case match

" OpenSSH determines the existence of options in a very ad-hoc way; it just
" tries to parse a line twice, first assuming nonexistence and second
" existence. Here we detect options by their names.
syn match sshauthorizedkeysLine "^.*$" transparent contains=sshauthorizedkeysComment,sshauthorizedkeysAfterKeyAlgo,sshauthorizedkeysAfterV1KeyBits,sshauthorizedkeysAfterOptions
syn match sshauthorizedkeysAfterKeyAlgo "\S.*$" transparent contained contains=sshauthorizedkeysKeyAlgoPart,sshauthorizedkeysKeyDataAfterSpace
syn match sshauthorizedkeysAfterV1KeyBits "[0-9].*$" transparent contained contains=sshauthorizedkeysV1KeyBitsPart,sshauthorizedkeysV1KeyExponentAfterSpace
syn match sshauthorizedkeysComment "#.*$" contained
syn match sshauthorizedkeysAfterOptions "\%(agent\|cert\|com\|env\|from\|no-\|permit\|port\|princ\|pty\|restr\|tun\|user\|X11\|\S*[=,"]\).*$" transparent contained contains=sshauthorizedkeysOptionsPart,sshauthorizedkeysKeyAlgoAfterSpace
syn match sshauthorizedkeysAfterKeyData "\S.*$" transparent contained contains=sshauthorizedkeysKeyDataPart,sshauthorizedkeysKeyCommentAfterSpace
syn match sshauthorizedkeysAfterKeyComment "\S.*$" transparent contained contains=sshauthorizedkeysKeyCommentPart
syn match sshauthorizedkeysAfterV1KeyExponent "\S.*$" transparent contained contains=sshauthorizedkeysV1KeyExponentPart,sshauthorizedkeysV1KeyModulusAfterSpace
syn match sshauthorizedkeysAfterV1KeyModulus "\S.*$" transparent contained contains=sshauthorizedkeysV1KeyModulusPart,sshauthorizedkeysKeyCommentAfterSpace
syn match sshauthorizedkeysKeyAlgoAfterSpace "\s.*$" transparent contained contains=sshauthorizedkeysAfterKeyAlgo,sshauthorizedkeysAfterV1KeyBits
syn match sshauthorizedkeysKeyDataAfterSpace "\s.*$" transparent contained contains=sshauthorizedkeysAfterKeyData
syn match sshauthorizedkeysKeyCommentAfterSpace "\s.*$" transparent contained contains=sshauthorizedkeysAfterKeyComment
syn match sshauthorizedkeysV1KeyExponentAfterSpace "\s.*$" transparent contained contains=sshauthorizedkeysAfterV1KeyExponent
syn match sshauthorizedkeysV1KeyModulusAfterSpace "\s.*$" transparent contained contains=sshauthorizedkeysAfterV1KeyModulus

" Yes this escape is strange...
syn match sshauthorizedkeysOptionsPart '\%(\\\%("\|"\@!\)\|[^\\"\t ]\|"\%(\\\%("\|"\@!\)\|[^\\"]\)*"\)\+' transparent contained contains=sshauthorizedkeysOptionName,sshauthorizedkeysOptionValue
syn match sshauthorizedkeysKeyAlgoPart "\S\+" transparent contained contains=sshauthorizedkeysKeyAlgo
syn match sshauthorizedkeysKeyDataPart "\S\+" transparent contained
syn match sshauthorizedkeysKeyCommentPart ".\+" transparent contained contains=sshauthorizedkeysKeyComment
syn match sshauthorizedkeysV1KeyBitsPart "\S\+" transparent contained contains=sshauthorizedkeysV1KeyBits
syn match sshauthorizedkeysV1KeyExponentPart "\S\+" transparent contained
syn match sshauthorizedkeysV1KeyModulusPart "\S\+" transparent contained

syn keyword sshauthorizedkeysOptionName agent-forwarding contained
syn keyword sshauthorizedkeysOptionName cert-authority contained
syn keyword sshauthorizedkeysOptionName command contained
syn keyword sshauthorizedkeysOptionName environment contained
syn keyword sshauthorizedkeysOptionName from contained
syn keyword sshauthorizedkeysOptionName no-agent-forwarding contained
syn keyword sshauthorizedkeysOptionName no-port-forwarding contained
syn keyword sshauthorizedkeysOptionName no-pty contained
syn keyword sshauthorizedkeysOptionName no-user-rc contained
syn keyword sshauthorizedkeysOptionName no-X11-forwarding contained
syn keyword sshauthorizedkeysOptionName permitopen contained
syn keyword sshauthorizedkeysOptionName port-forwarding contained
syn keyword sshauthorizedkeysOptionName principals contained
syn keyword sshauthorizedkeysOptionName pty contained
syn keyword sshauthorizedkeysOptionName restrict contained
syn keyword sshauthorizedkeysOptionName tunnel contained
syn keyword sshauthorizedkeysOptionName user-rc contained
syn keyword sshauthorizedkeysOptionName X11-forwarding contained

syn match sshauthorizedkeysOptionValue '"\%(\\\%("\|"\@!\)\|[^\\"]\)*"' contained

syn keyword sshauthorizedkeysKeyAlgo ecdsa-sha2-nistp256 contained
syn keyword sshauthorizedkeysKeyAlgo ecdsa-sha2-nistp384 contained
syn keyword sshauthorizedkeysKeyAlgo ecdsa-sha2-nistp521 contained
syn keyword sshauthorizedkeysKeyAlgo ssh-ed25519 contained
syn keyword sshauthorizedkeysKeyAlgo ssh-dss contained
syn keyword sshauthorizedkeysKeyAlgo ssh-rsa contained

syn match sshauthorizedkeysKeyComment ".\+" contained

syn match sshauthorizedkeysV1KeyBits "\%(^\|\s\@<=\)[1-9][0-9]*\%($\|\s\@=\)" contained

" Now we can link them with predefined groups.
hi def link sshauthorizedkeysComment Comment
hi def link sshauthorizedkeysKeyComment Comment
hi def link sshauthorizedkeysOptionName Special
hi def link sshauthorizedkeysOptionValue String
hi def link sshauthorizedkeysKeyAlgo Identifier
hi def link sshauthorizedkeysV1KeyBits Number

" Mark the buffer as highlighted.
let b:current_syntax = "ssh_authorized_keys"
