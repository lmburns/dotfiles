" Vim syntax file
"      Language: Adblock Plus Filter Lists
"    Maintainer: Thomas Greiner <https://www.greinr.com/>
"       Version: 0.1

if exists("b:current_syntax")
  finish
endif

" Blocking
syntax match abpBlocking "^[^\$]*" nextgroup=abpBlockingSeparator
syntax match abpBlockingSeparator "\$" contained nextgroup=abpBlockingOption
syntax match abpBlockingOption ".*" contained

" Blocking Exception
syntax match abpBlockingExceptionSeparator "^@@" nextgroup=abpBlockingException
syntax match abpBlockingException "[^\$]*" contained nextgroup=abpBlockingSeparator

" Comments
syntax match abpHeader "\c^\s*\[\s*adblock\s*\(plus\s*\(\d\+\(\.\d\+\)*\s*\)\?\)\?]\s*$"
syntax match abpComment "^\s*!.*" contains=abpCommentKey
syntax match abpCommentKey "^\s*!\s*[^:]\+:" contained nextgroup=abpCommentValue skipwhite
syntax match abpCommentValue ".*" contained

" Element Hiding
syntax match abpHidingOption "^[^#]*#@\?#.*" contains=abpHidingSeparator,abpHidingExceptionSeparator
syntax match abpHidingSeparator "##" contained nextgroup=abpHiding
syntax match abpHidingExceptionSeparator "#@#" contained nextgroup=abpHidingException
syntax match abpHiding ".*" contained
syntax match abpHidingException ".*" contained

" https://github.com/gorhill/uBlock/wiki/Static-filter-syntax

"   'uboPreParsingDirective': '', // !#
"   'agHint': '', // !+
"   'comment': '', // !
"   'hosts': '',
"   'domain': '',
"   'exception': '', // @@
"   'domainRegEx': '', // /regex/
"   'exceptionRegEx': '', // @@/regex/
"   'option': '', // $
"   'selector': '', // ##
"   'selectorException': '', // #@#
"   'htmlFilter': '', // ##^
"   'htmlFilterException': '', // #@#^
"   'abpExtendedSelector': '', // #?#
"   'uboScriptlet': '', // ##+js()
"   'uboScriptletException': '', // #@#+js()
"   'abpSnippet': '', // #$#
"   'agJSRule': '', // #%#
"   'agJSException': '', // #@%#
"   'agExtendedSelector': '', // #?#
"   'agExtendedSelectorException': '', // #@?#
"   'agStyling': '', // #$#
"   'agStylingException': '', // #@$#
"   'agAdvancedStyling': '', // #$?#
"   'agAdvancedStylingException': '', // #@$?#
"   // actionOperator type stuff must be on the bottom, to make sure _checkForMismatch rebuilds the string in the correct order
"   'actionOperator': '', // :style() :remove()
"   'agActionOperator': '', // { }

" ╭─────────────────────╮
" │ abpExtendedSelector │
" ╰─────────────────────╯
" https://help.eyeo.com/en/adblockplus/how-to-write-filters#elemhide-emulation
" https://easylist-downloads.adblockplus.org/abp-filters-anti-cv.txt
" :-abp-has(
" :-abp-contains(
" :-abp-properties(

" ╭────────────╮
" │ abpSnippet │
" ╰────────────╯
" https://help.eyeo.com/en/adblockplus/snippet-filters-tutorial
" https://easylist-downloads.adblockplus.org/abp-filters-anti-cv.txt
" log
" uabinject-defuser
" hide-if-shadow-contains
" hide-if-contains
" hide-if-contains-visible-text
" hide-if-contains-and-matches-style
" hide-if-has-and-matches-style
" hide-if-contains-image
" dir-string
" abort-on-property-read
" abort-on-property-write
" abort-current-inline-script
" strip-fetch-query-parameter
" ml-hide-if-graph-matches
" hide-if-contains-image-hash
" hide-if-labelled-by
" hide-if-matches-xpath
" debug
" profile
" trace
" readd

" ╭─────────╮
" │ options │
" ╰─────────╯
" https://help.eyeo.com/en/adblockplus/how-to-write-filters#options
" https://kb.adguard.com/en/general/how-to-create-your-own-ad-filters#modifiers
"
" without equals
" 1p
" 3p
" all
" app // adguard
" badfilter
" beacon // undocumented shortcut for ping
" cname
" content // adguard
" cookie // adguard
" csp // allowed both without equals and with equals
" css
" doc
" document
" domain // domain with no equals is adguard only
" ehide
" elemhide
" empty
" extension // adguard
" first-party
" font
" frame
" genericblock // adguard
" generichide
" ghide
" image
" important
" inline-font
" inline-script
" jsinject // adguard
" match-case
" media
" mp4
" network // adguard
" object
" object-subrequest // adguard
" other
" ping
" popunder
" popup
" script
" shide
" specifichide
" stealth // adguard
" stylesheet
" subdocument
" third-party
" urlblock // adguard
" webrtc
" websocket
" xhr
" xmlhttprequest

" with equals
" csp // = [a-z\-: *]  // allowed both without equals and with equals
" denyallow // = [a-z.|]
" domain // = [~|a-z.]
" redirect // = [a-z0-9\-./]
" redirect-rule // = [a-z0-9\-./]     // ubo specific
" removeparam // adguard
" replace // adguard
" rewrite // = [a-z\-:]
" sitekey // = [a-z]

" ╭────────────────────╮
" │ uboCosmeticFilters │
" ╰────────────────────╯
" https://github.com/gorhill/uBlock/wiki/Procedural-cosmetic-filters
" https://github.com/gorhill/uBlock/wiki/Inline-script-tag-filtering
" :has(
" :has-text(
" :matches-css(
" :matches-css-before(
" :matches-css-after(
" :min-text-length(
" :not(
" :upward(
" :watch-attr(
" :xpath(
" // deprecated
" :contains( // use ##^script:has-text() instead
" :if(
" :if-not(
" :nth-ancestor(
" :watch-attrs(

" ╭────────────────────────╮
" │ uboPreParsingDirective │
" ╰────────────────────────╯
" https://github.com/gorhill/uBlock/wiki/Procedural-cosmetic-filters
" endif
" if
" include

" pre parsing if
" adguard
" adguard_app_windows
" adguard_ext_chromium
" adguard_ext_edge
" adguard_ext_firefox
" adguard_ext_opera
" cap_html_filtering
" cap_user_stylesheet
" env_chromium
" env_edge
" env_firefox
" env_mobile
" env_safari
" ext_ublock
" false

" ╭────────────────╮
" │ ubo Scriptlets │
" ╰────────────────╯
" acis
" abort-current-inline-script
" aopr
" abort-on-property-read
" aopw
" abort-on-property-write
" aeld
" addEventListener-defuser
" aell
" addEventListener-logger
" cookie-remover
" disable-newtab-links
" json-prune
" noeval
" noeval-silent
" noeval-if
" norafif
" no-requestAnimationFrame-if
" nosiif
" no-setInterval-if
" nostif
" no-setTimeout-if
" nowebrtc
" ra
" remove-attr
" rc
" remove-class
" set
" set-constant
" nano-sib
" nano-setInterval-booster
" nano-stb
" nano-setTimeout-booster
" webrtc-if
" nowoif
" window.open-defuser
" window.name-defuser
" overlay-buster
" alert-buster
" ampproject_v0
" fingerprint2
" nobab
" nofab
" popads-dummy
" popads
" gpt-defuser
" adfly-defuser
" damoh-defuser
" addthis_widget
" amazon_ads
" amazon_apstag
" monkeybroker
" doubleclick_instream_ad_status
" google-analytics_ga
" google-analytics_analytics
" google-analytics_inpage_linkid
" google-analytics_cx_api
" googletagservices_gpt
" googletagmanager_gtm
" googlesyndication_adsbygoogle
" scorecardresearch_beacon
" outbrain-widget
" hd-main
" disqus_forums_embed
" disqus_embed
" twitch-videoad
" // ********** DEPRECATED *************
" csp
" silent-noeval
" raf-if
" requestAnimationFrame-if
" sid
" setInterval-defuser
" sil
" setInterval-logger
" std
" setTimeout-defuser
" stl
" setTimeout-logger
" sharedWorker-defuser
" ampproject.org/v0
" bab-defuser
" fuckadblock
" popads.net
" golem.de
" upmanager-defuser
" chartbeat
" static.chartbeat.com/chartbeat
" ligatus_angular-tag
" ligatus.com/*/angular-tag
" addthis.com/addthis_widget
" amazon-adsystem.com/aax2/amzn_ads
" d3pkae9owd2lcf.cloudfront.net/mb105
" doubleclick.net/instream/ad_status
" google-analytics.com/ga
" google-analytics.com/analytics
" google-analytics.com/inpage_linkid
" google-analytics.com/cx/api
" googletagservices.com/gpt
" googletagmanager.com/gtm
" googlesyndication.com/adsbygoogle
" scorecardresearch.com/beacon
" widgets.outbrain.com/outbrain
" disqus.com/forums/*/embed
" disqus.com/embed

" Highlights
hi link abpHeader Comment
hi link abpComment Comment
hi link abpCommentKey Comment
hi link abpCommentValue SpecialComment
hi link abpBlocking ABPBlock
hi link abpBlockingSeparator Delimiter
hi link abpBlockingOption ABPOption
hi link abpBlockingException ABPBlockException
hi link abpBlockingExceptionSeparator Delimiter
hi link abpHiding ABPElemhide
hi link abpHidingSeparator Delimiter
hi link abpHidingExceptionSeparator Delimiter
hi link abpHidingOption ABPOption
hi link abpHidingException ABPElemhideException

" Colors
hi def link SpecialComment CocDisabled
hi def link ABPOption Conditional
hi def link ABPBlock Error
hi def link ABPBlockException MoreMsg
hi def link ABPElemhide Boolean
hi def link ABPElemhideException SpecialChar
