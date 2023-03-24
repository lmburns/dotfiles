" Vim syntax file
" Language:     OpenSSH known_hosts
" Author:       Masaki Hara <ackie.h.gmai@gmail.com>
" Date:         February 09, 2017
" File Types:   known_hosts,ssh_kown_hosts
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

" Stateful syntax
syn match sshknownhostsLine "^.*$" transparent contains=sshknownhostsComment,sshknownhostsAfterHost,sshknownhostsAfterMarker
syn match sshknownhostsAfterHost "[^ \t].*$" transparent contained contains=sshknownhostsHostPart,sshknownhostsKeyAlgoAfterSpace
syn match sshknownhostsComment "#.*$" contained
syn match sshknownhostsAfterMarker "@.*$" transparent contained contains=sshknownhostsMarkerPart,sshknownhostsHostAfterSpace
syn match sshknownhostsAfterKeyAlgo "\S.*$" transparent contained contains=sshknownhostsKeyAlgoPart,sshknownhostsKeyDataAfterSpace
syn match sshknownhostsAfterKeyData "\S.*$" transparent contained contains=sshknownhostsKeyDataPart,sshknownhostsKeyCommentAfterSpace
syn match sshknownhostsAfterKeyComment "\S.*$" transparent contained contains=sshknownhostsKeyCommentPart
syn match sshknownhostsAfterV1KeyBits "[0-9].*$" transparent contained contains=sshknownhostsV1KeyBitsPart,sshknownhostsV1KeyExponentAfterSpace
syn match sshknownhostsAfterV1KeyExponent "\S.*$" transparent contained contains=sshknownhostsV1KeyExponentPart,sshknownhostsV1KeyModulusAfterSpace
syn match sshknownhostsAfterV1KeyModulus "\S.*$" transparent contained contains=sshknownhostsV1KeyModulusPart,sshknownhostsKeyCommentAfterSpace
syn match sshknownhostsHostAfterSpace "\s.*$" transparent contained contains=sshknownhostsAfterHost
syn match sshknownhostsKeyAlgoAfterSpace "\s.*$" transparent contained contains=sshknownhostsAfterKeyAlgo,sshknownhostsAfterV1KeyBits
syn match sshknownhostsKeyDataAfterSpace "\s.*$" transparent contained contains=sshknownhostsAfterKeyData
syn match sshknownhostsKeyCommentAfterSpace "\s.*$" transparent contained contains=sshknownhostsAfterKeyComment
syn match sshknownhostsV1KeyBitsAfterSpace "\s.*$" transparent contained contains=sshknownhostsAfterV1KeyBits
syn match sshknownhostsV1KeyExponentAfterSpace "\s.*$" transparent contained contains=sshknownhostsAfterV1KeyExponent
syn match sshknownhostsV1KeyModulusAfterSpace "\s.*$" transparent contained contains=sshknownhostsAfterV1KeyModulus

" Split out each part in an entry
syn match sshknownhostsMarkerPart "\S\+" transparent contained contains=sshknownhostsMarker
syn match sshknownhostsHostPart "\S\+" transparent contained contains=sshknownhostsNonhashedHosts,sshknownhostsHashedHosts
syn match sshknownhostsKeyAlgoPart "\S\+" transparent contained contains=sshknownhostsHostKeyAlgo
syn match sshknownhostsKeyDataPart "\S\+" transparent contained
syn match sshknownhostsKeyCommentPart ".\+" transparent contained contains=sshknownhostsKeyComment
syn match sshknownhostsV1KeyBitsPart "\S\+" transparent contained contains=sshknownhostsV1KeyBits
syn match sshknownhostsV1KeyExponentPart "\S\+" transparent contained
syn match sshknownhostsV1KeyModulusPart "\S\+" transparent contained

" The only defined markers are as follows.
syn match sshknownhostsMarker "@cert-authority" contained
syn match sshknownhostsMarker "@revoked" contained

" Highlight hosts and ports, with some symbols treated specially.
syn match sshknownhostsNonhashedHosts "\%(^\|\s\@<=\)[^ \t|]\S*" transparent contained contains=sshknownhostsHostPort
syn match sshknownhostsHostPort "\S\+" contained contains=sshknownhostsHostPortSpecial
syn match sshknownhostsHostPortSpecial "[!,*?]" contained
syn match sshknownhostsHashedHosts "\%(^\|\s\@<=\)|\S*" transparent contained contains=sshknownhostsHostPortHash
" This is for the hashed version.
syn match sshknownhostsHostPortHash "\%(^\|\s\@<=\)|1|[A-Za-z0-9+/]\{26}[AEIMQUYcgkosw048]=|[A-Za-z0-9+/]\{26}[AEIMQUYcgkosw048]=\s\@=" contained

" Currently known host key algorithms.
syn keyword sshknownhostsHostKeyAlgo ssh-ed25519 contained
syn match sshknownhostsHostKeyAlgo "\<ssh-ed25519-cert-v01@openssh\.com\>" contained
syn keyword sshknownhostsHostKeyAlgo ssh-rsa contained
syn keyword sshknownhostsHostKeyAlgo ssh-dss contained
syn keyword sshknownhostsHostKeyAlgo ecdsa-sha2-nistp256 contained
syn keyword sshknownhostsHostKeyAlgo ecdsa-sha2-nistp384 contained
syn keyword sshknownhostsHostKeyAlgo ecdsa-sha2-nistp521 contained
syn match sshknownhostsHostKeyAlgo "\<ssh-rsa-cert-v01@openssh\.com\>" contained
syn match sshknownhostsHostKeyAlgo "\<ssh-dss-cert-v01@openssh\.com\>" contained
syn match sshknownhostsHostKeyAlgo "\<ecdsa-sha2-nistp256-cert-v01@openssh\.com\>" contained
syn match sshknownhostsHostKeyAlgo "\<ecdsa-sha2-nistp384-cert-v01@openssh\.com\>" contained
syn match sshknownhostsHostKeyAlgo "\<ecdsa-sha2-nistp521-cert-v01@openssh\.com\>" contained

" The whole part is a comment
syn match sshknownhostsKeyComment ".\+" contained

syn match sshknownhostsV1KeyBits "\%(^\|\s\@<=\)[1-9][0-9]*\%($\|\s\@=\)" contained

" Now we can link them with predefined groups.
hi def link sshknownhostsComment Comment
hi def link sshknownhostsKeyComment Comment
hi def link sshknownhostsV1KeyBits Number
hi def link sshknownhostsMarker Keyword
hi def link sshknownhostsHostKeyAlgo Identifier
hi def link sshknownhostsHostPort String
hi def link sshknownhostsHostPortHash String
hi def link sshknownhostsHostPortSpecial SpecialChar

" Mark the buffer as highlighted.
let b:current_syntax = "ssh_known_hosts"
