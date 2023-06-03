# neomutt --
{:data-section="shell"}
{:data-date="May 31, 20231"}
{:data-extra="Um Pages"}

## SYNOPSIS

Mail client

## DESCRIPTION

Best TUI mail client there is.

## SEARCH PATTERNS

### POSIX REGULAR EXPRESSIONS

|-----------------|---------------------------------------------------------------------------------------------------------------|
| Character class | Description                                                                                                   |
|=================|===============================================================================================================|
| [:alnum:]       | Alphanumeric characters                                                                                       |
| [:alpha:]       | Alphabetic characters                                                                                         |
| [:blank:]       | Space or tab characters                                                                                       |
| [:cntrl:]       | Control characters                                                                                            |
| [:digit:]       | Numeric characters                                                                                            |
| [:graph:]       | Characters that are both printable and visible. (A space is printable, but not visible, while an “a” is both) |
| [:lower:]       | Lower-case alphabetic characters                                                                              |
| [:print:]       | Printable characters (characters that are not control characters)                                             |
| [:punct:]       | Punctuation characters (characters that are not letter, digits, control characters, or space characters)      |
| [:space:]       | Space characters (such as space, tab and formfeed, to name a few)                                             |
| [:upper:]       | Upper-case alphabetic characters                                                                              |
| [:xdigit:]      | Characters that are hexadecimal digits                                                                        |
|-----------------|---------------------------------------------------------------------------------------------------------------|


### REGULAR EXPRESSION REPETITION OPERATORS

|----------|--------------------------------------------------------------------------|
| Operator | Description                                                              |
|==========|==========================================================================|
| ?        | The preceding item is optional and matched at most once                  |
| *        | The preceding item will be matched zero or more times                    |
| +        | The preceding item will be matched one or more times                     |
| {n}      | The preceding item is matched exactly n times                            |
| {n,}     | The preceding item is matched n or more times                            |
| {,m}     | The preceding item is matched at most m times                            |
| {n,m}    | The preceding item is matched at least n times, but no more than m times |
|----------|--------------------------------------------------------------------------|

### GNU REGULAR EXPRESSION EXTENSIONS

|------------|-----------------------------------------------------------------------|
| Expression | Description                                                           |
|============|=======================================================================|
| \y         | Matches the empty string at either the beginning or the end of a word |
| \B         | Matches the empty string within a word                                |
| \<         | Matches the empty string at the beginning of a word                   |
| \>         | Matches the empty string at the end of a word                         |
| \w         | Matches any word-constituent character (letter, digit, or underscore) |
| \W         | Matches any character that is not word-constituent                    |
| \`         | Matches the empty string at the beginning of a buffer (string)        |
| \'         | Matches the empty string at the end of a buffer                       |
|------------|-----------------------------------------------------------------------|


┌─────────────┬───────────────────────────────────────────────────────────────────────────────────────────────────┐
│ Pattern     │ Description                                                                                       │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~A          │ all messages                                                                                      │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ =B STRING   │ messages which contain STRING in the whole message. If IMAP is enabled, searches for STRING on    │
│             │ the server, rather than downloading each message and searching it locally.                        │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ =b STRING   │ messages which contain STRING in the message body. If IMAP is enabled, searches for STRING on the │
│             │ server, rather than downloading each message and searching it locally.                            │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~B EXPR     │ messages which contain EXPR in the whole message                                                  │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~b EXPR     │ messages which contain EXPR in the message body                                                   │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ %C GROUP    │ messages either “To:” or “Cc:” to any member of GROUP                                             │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ %c GROUP    │ messages carbon-copied to any member of GROUP                                                     │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~C EXPR     │ messages either “To:” or “Cc:” EXPR                                                               │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~c EXPR     │ messages carbon-copied to EXPR                                                                    │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~D          │ deleted messages                                                                                  │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~d MIN-MAX  │ messages with “date-sent” in a date range                                                         │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ %e GROUP    │ messages which contain a member of GROUP in the “Sender:” field                                   │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~E          │ expired messages                                                                                  │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~e EXPR     │ messages which contain EXPR in the “Sender:” field                                                │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ %f GROUP    │ messages originating from any member of GROUP                                                     │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~F          │ flagged messages                                                                                  │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~f EXPR     │ messages originating from EXPR                                                                    │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~G          │ cryptographically encrypted messages                                                              │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~g          │ cryptographically signed messages                                                                 │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ =h STRING   │ messages which contain STRING in the message header. If IMAP is enabled, searches for STRING on   │
│             │ the server, rather than downloading each message and searching it locally; STRING must be of the  │
│             │ form “Header: substring” (see below).                                                             │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~H EXPR     │ messages with spam attribute matching EXPR                                                        │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~h EXPR     │ messages which contain EXPR in the message header                                                 │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~i EXPR     │ messages which match EXPR in the “Message-ID:” field                                              │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~I QUERY    │ messages whose Message-ID field is included in the results returned from an external search pro‐  │
│             │ gram, when the program is run with QUERY as its argument. See $external_search_command            │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~k          │ messages containing PGP key material                                                              │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ %L GROUP    │ messages either originated or received by any member of GROUP                                     │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~L EXPR     │ messages either originated or received by EXPR                                                    │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~l          │ messages addressed to a known mailing list                                                        │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~m <MAX     │ messages with numbers less than MAX                                                               │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~m >MIN     │ messages with numbers greater than MIN                                                            │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~m MIN,MAX  │ messages with offsets (from selected message) in the range MIN to MAX                             │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~m MIN-MAX  │ message in the range MIN to MAX                                                                   │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~m N        │ just message number N                                                                             │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~N          │ new messages                                                                                      │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~n MIN-MAX  │ messages with a score in the range MIN to MAX                                                     │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~O          │ old messages                                                                                      │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~P          │ messages from you (consults $from, alternates, and local account/hostname information)            │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~p          │ messages addressed to you (consults $from, alternates, and local account/hostname information)    │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~Q          │ messages which have been replied to                                                               │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~R          │ read messages                                                                                     │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~r MIN-MAX  │ messages with “date-received” in a date range                                                     │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~S          │ superseded messages                                                                               │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~s EXPR     │ messages having EXPR in the “Subject:” field                                                      │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~T          │ tagged messages                                                                                   │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~t EXPR     │ messages addressed to EXPR                                                                        │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~U          │ unread messages                                                                                   │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~u          │ messages addressed to a subscribed mailing list                                                   │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~V          │ cryptographically verified messages                                                               │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~v          │ message is part of a collapsed thread.                                                            │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~X MIN-MAX  │ messages with MIN to MAX attachments                                                              │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~x EXPR     │ messages which contain EXPR in the “References:” or “In-Reply-To:” field                          │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~y EXPR     │ messages which contain EXPR in their keywords                                                     │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~Y EXPR     │ messages whose tags match EXPR                                                                    │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~z MIN-MAX  │ messages with a size in the range MIN to MAX                                                      │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ =/ STRING   │ IMAP custom server-side search for STRING. Currently only defined for Gmail. See section “Gmail   │
│             │ Patterns” in NeoMutt manual.                                                                      │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~=          │ duplicated messages (see $duplicate_threads)                                                      │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~#          │ broken threads (see $strict_threads)                                                              │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~$          │ unreferenced message (requires threaded view)                                                     │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~(PATTERN)  │ messages in threads containing messages matching PATTERN, e.g. all threads containing messages    │
│             │ from you: ~(~P)                                                                                   │
├─────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ~<(PATTERN) │ messages whose immediate parent matches PATTERN, e.g. replies to your messages: ~<(~P)            │
├─────────────┴───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Where EXPR is a regular expression, and GROUP is an address group.                                              │
│                                                                                                                 │
│       - The message number ranges (introduced by “~m”) are even more general and powerful than the other types  │
│         of ranges. Read on and see section “Message Ranges” in manual.                                          │
│       - The forms “<MAX”, “>MIN”, “MIN-” and “-MAX” are allowed, too.                                           │
│       - The suffixes “K” and “M” are allowed to specify kilobyte and megabyte respectively.                     │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

### == INDEX FORMATS ===================================================================================================

Default: `%4C %Z %{%b %d} %-15.15L (%?l?%4l&%4c?) %s`

This variable allows you to customize the message index display to your personal taste.

"Format strings" are similar to the strings used in the C function printf(3) to format output (see
the man page  for  more  de‐ tails).   For  an  explanation  of the `%?` construct, see the
`status_format` description.  The following sequences are defined in

##### NEOMUTT FORMATS:
`%a`     Address of the author
`%A`     Reply-to address (if present; otherwise: address of author)
`%b`     Filename of the original message folder (think mailbox)
`%B`     Same as `%K`
`%C`     Current message number
`%c`     Number of characters (bytes) in the body of the message (see *formatstrings*-size)
`%cr`    Number of characters (bytes) in the raw message, including the header (see *formatstrings*-size)
`%D`     Date and time of message using date_format and local timezone
`%d`     Date and time of message using date_format and sender's timezone
`%e`     Current message number in thread
`%E`     Number of messages in current thread
`%F`     Author name, or recipient name if the message is from you
`%Fp`    Like `%F`, but plain. No contextual formatting is applied to recipient name
`%f`     Sender (address + real name), either `From:` or `Return-Path:`
`%g`     Newsgroup name (if compiled with NNTP support)
`%g`     Message tags (e.g. notmuch tags/imap flags)
`%Gx`    Individual message tag (e.g. notmuch tags/imap flags)
`%H`     Spam attribute(s) of this message
`%I`     Initials of author
`%i`     Message-id of the current message
`%J`     Message tags (if present, tree unfolded, and != parent's tags)
`%K`     The list to which the letter was sent (if any; otherwise: empty)
`%L`     If an address in the "To:" or "Cc:" header field matches an address Defined by the user's
       "subscribe" command, this displays "To <list-name>", otherwise the same as `%F`
`%l`     number of lines in the unprocessed message (may not work with maildir, mh, and IMAP folders)
`%M`     Number of hidden messages if the thread is collapsed
`%m`     Total number of message in the mailbox
`%N`     Message score
`%n`     Author's real name (or address if missing)
`%O`     Original save folder where NeoMutt would formerly have Stashed the message: list name or
       recipient name If not sent to a list
`%P`     Progress indicator for the built-in pager (how much of the file has been displayed)
`%q`     Newsgroup name (if compiled with NNTP support)
`%R`     Comma separated list of "Cc:" recipients
`%R`     Comma separated list of "Cc:" recipients
`%r`     Comma separated list of "To:" recipients
`%S`     Single character status of the message ("N"/"O"/"D"/"d"/"!"/"r"/"*")
`%s`     Subject of the message
`%T`     The appropriate character from the $to_chars string
`%t`     "To:" field (recipients)
`%u`     User (login) name of the author
`%v`     First name of the author, or the recipient if the message is from you
`%W`     Name of organization of author ("Organization:" field)
`%x`     "X-Comment-To:" field (if present and compiled with NNTP support)
`%X`     Number of MIME attachments (please see the "attachments" section for possible speed effects)
`%Y`     "X-Label:" field, if present, and (1) not at part of a thread tree, (2) at the top of
        a thread,  or  (3)  "X-Label:"  is different from Preceding message's "X-Label:"
`%y`     "X-Label:" field, if present
`%Z`     A  three  character  set  of message status flags.  The first character is new/read/replied flags ("n"/"o"/"r"/"O"/"N").
`       `The second is deleted or encryption flags ("D"/"d"/"S"/"P"/"s"/"K").  The third is either tagged/flagged  ("*"/"!"),  or
`       `one of the characters Listed in $to_chars.
`%zc`    Message crypto flags
`%zs`    Message status flags
`%zt`    Message tag flags
`%@name@`
`       `insert and evaluate format-string from the matching "index-format-hook" command
`%{fmt}` the date and time of the message is converted to sender's time zone, and "fmt" is expanded
        by the library function *strftime(3)*; if the first character inside the braces is a bang
        (`!`), the date is formatted ignoring any  locale  settings. Note that the sender's time
        zone might only be available as a numerical offset, so `%Z` behaves like `%z`.
`%[fmt]` the  date  and  time  of  the message is converted to the local time zone, and "fmt" is
        expanded by the library function *strftime(3)*; if the first character inside the brackets is a bang
        (`!`), the date is formatted ignoring any locale  settings.
`%(fmt)` the local date and time when the message was received, and "fmt" is expanded by the library
        function *strftime(3)*; if the first character inside the parentheses is a bang (`!`), the
        date is formatted ignoring any locale settings.
`%>X`    right justify the rest of the string and pad with character `X`
`%|X`    pad to the end of the line with character `X`
`%*X`    soft-fill with character `X` as pad
