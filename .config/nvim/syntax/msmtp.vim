" Vim syntax file
" Language:     msmtp rc files
" Maintainer:   Simon Ruderich <simon@ruderich.com>
"               Eric Pruitt <eric.pruitt@gmail.com>
" Last Change:  2019-09-27
" Filenames:    msmtprc
" Version:      0.3


if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif


" Comments.
syn match msmtpComment /#.*$/ contains=@Spell

" General commands.
syntax match msmtpOption /\<\(defaults\|account\|eval\|host\|port\|source_ip\|proxy_host\|proxy_port\|socket\|timeout\|protocol\|domain\)\>/
" Authentication commands.
syntax match msmtpOption /\<\(auth\|user\|password\|passwordeval\|ntlmdomain\)\>/
" TLS commands.
syntax match msmtpOption /\<\(tls\|tls_starttls\|tls_trust_file\|tls_crl_file\|tls_fingerprint\|tls_key_file\|tls_cert_file\|tls_certcheck\|tls_priorities\|tls_host_override\|tls_min_dh_prime_bits\)\>/
" Sendmail mode specific commands.
syntax match msmtpOption /\<\(from\|allow_from_override\|dsn_notify\|dsn_return\|set_from_header\|set_date_header\|set_msgid_header\|remove_bcc_headers\|undisclosed_recipients\|logfile\|logfile_time_format\|syslog\|aliases\|auto_from\|maildomain\)\>/

" Options which accept only an on/off value.
syn match msmtpWrongOption /\<\(tls\|tls_starttls\|tls_certcheck\|allow_from_override\|remove_bcc_headers\|undisclosed_recipients\|auto_from\) \(on$\|off$\)\@!.*$/
" Options which accept only an on/off/auto value.
syn match msmtpWrongOption /\<\(set_from_header\) \(on$\|off$\|auto$\)\@!.*$/
" Options which accept only an off/auto value.
syn match msmtpWrongOption /\<\(set_date_header\|set_msgid_header\) \(auto$\|off$\)\@!.*$/
" Option port accepts numeric values.
syn match msmtpWrongOption /\<\(port\|proxy_port\) \(\d\+$\)\@!.*$/
" Option timeout accepts off and numeric values.
syn match msmtpWrongOption /\<timeout \(off$\|\d\+$\)\@!.*$/
" Option protocol accepts smtp and lmtp.
syn match msmtpWrongOption /\<protocol \(smtp$\|lmtp$\)\@!.*$/
" Option auth accepts on, off and the method.
syn match msmtpWrongOption /\<auth \(on$\|off$\|plain$\|cram-md5$\|digest-md5$\|scram-sha-1$\|scram-sha-256$\|gssapi$\|external$\|login$\|ntlm$\|oauthbearer\|xoauth2\)\@!.*$/
" Option syslog accepts on, off and the facility.
syn match msmtpWrongOption /\<syslog \(on$\|off$\|LOG_USER$\|LOG_MAIL$\|LOG_LOCAL\d$\)\@!.*$/

" Marks all wrong option values as errors.
syn match msmtpWrongOptionValue /\S* \zs.*$/ contained containedin=msmtpWrongOption

" Mark the option part as a normal option.
highlight default link msmtpWrongOption msmtpOption

"Email addresses (yanked from esmptrc)
syntax match msmtpAddress /[a-z0-9_.-]*[a-z0-9]\+@[a-z0-9_.-]*[a-z0-9]\+\.[a-z]\+/
" Host names
syn match msmtpHost "\%(host\s*\)\@<=\h\%(\w\|\.\|-\)*"
syn match msmtpHost "\%(host\s*\)\@<=\%([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\)"
" Numeric values
syn match msmtpNumber /\<\(\d\+$\)/
"Strings
syntax region msmtpString start=/"/ end=/"/
syntax region msmtpString start=/'/ end=/'/
" Booleans
syntax match msmtpBool "\s\@<=\(on\|off\)$"

highlight default link msmtpComment Comment
highlight default link msmtpOption Type
highlight default link msmtpWrongOptionValue Error
highlight default link msmtpString String
highlight default link msmtpAddress Constant
highlight default link msmtpNumber Number
highlight default link msmtpHost Identifier
highlight default link msmtpBool Constant


let b:current_syntax = "msmtp"
