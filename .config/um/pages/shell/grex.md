# grex --
{:data-section="shell"}
{:data-date="May 02, 2021"}
{:data-extra="Um Pages"}

## SYNOPSIS
Generate regex

## EXAMPLES

`$ grex a b c`
: `^[a-c]$`

`$ grex a c d e f`
: `^[ac-f]$`

`$ grex a b x de`
: `^(?:de|[abx])$`

`$ grex abc bc`
: `^a?bc$`

`$ grex a b bc`
: `^(?:bc?|a)$`

`$ grex [a-z]`
: `^\[a\-z\]$`

`$ grex -r b ba baa baaa`
: `^b(?:a{1,3})?$`

`$ grex -r b ba baa baaaa`
: `^b(?:a{1,2}|a{4})?$`

`$ grex y̆ a z`
: `^(?:y̆|[az])$`

`Note:`
: Grapheme y̆ consists of two Unicode symbols:
: U+0079 (Latin Small Letter Y)
: U+0306 (Combining Breve)

`$ grex "I ♥ cake" "I ♥ cookies"`
: `^I ♥ c(?:ookies|ake)$`

`Note:`
: Input containing blank space must be  surrounded by quotation marks.

## MORE EXAMPLES

`"I ♥♥♥ 36 and ٣ and 💩💩."` is the input for all these

`$ grex <INPUT>`
: `^I ♥♥♥ 36 and ٣ and 💩💩\.$`

`$ grex -e <INPUT>`
: `^I \u{2665}\u{2665}\u{2665} 36 and \u{663} and \u{1f4a9}\u{1f4a9}\.$`

`$ grex -e --with-surrogates <INPUT>`
: `^I \u{2665}\u{2665}\u{2665} 36 and \u{663} and \u{d83d}\u{dca9}\u{d83d}\u{dca9}\.$`

`$ grex -d <INPUT>`
: `^I ♥♥♥ \d\d and \d and 💩💩\.$`

`$ grex -s <INPUT>`
: `^I\s♥♥♥\s36\sand\s٣\sand\s💩💩\.$`

`$ grex -w <INPUT>`
: `^\w ♥♥♥ \w\w \w\w\w \w \w\w\w 💩💩\.$`

`$ grex -D <INPUT>`
: `^\D\D\D\D\D\D36\D\D\D\D\D٣\D\D\D\D\D\D\D\D$`

`$ grex -S <INPUT>`
: `^\S \S\S\S \S\S \S\S\S \S \S\S\S \S\S\S$`

`$ grex -dsw <INPUT>`
: `^\w\s♥♥♥\s\d\d\s\w\w\w\s\d\s\w\w\w\s💩💩\.$`

`$ grex -dswW <INPUT>`
: `^\w\s\W\W\W\s\d\d\s\w\w\w\s\d\s\w\w\w\s\W\W\W$`

`$ grex -r <INPUT>`
: `^I ♥{3} 36 and ٣ and 💩{2}\.$`

`$ grex -er <INPUT>`
: `^I \u{2665}{3} 36 and \u{663} and \u{1f4a9}{2}\.$`

`$ grex -er --with-surrogates <INPUT>`
: `^I \u{2665}{3} 36 and \u{663} and (?:\u{d83d}\u{dca9}){2}\.$`

`$ grex -dgr <INPUT>`
: `^I ♥{3} \d(\d and ){2}💩{2}\.$`

`$ grex -rs <INPUT>`
: `^I\s♥{3}\s36\sand\s٣\sand\s💩{2}\.$`

`$ grex -rw <INPUT>`
: `^\w ♥{3} \w(?:\w \w{3} ){2}💩{2}\.$`

`$ grex -Dr <INPUT>`
: `^\D{6}36\D{5}٣\D{8}$`

`$ grex -rS <INPUT>`
: `^\S \S(?:\S{2} ){2}\S{3} \S \S{3} \S{3}$`

`$ grex -rW <INPUT>`
: `^I\W{5}36\Wand\W٣\Wand\W{4}$`
``
`$ grex -drsw <INPUT>`
: `^\w\s♥{3}\s\d(?:\d\s\w{3}\s){2}💩{2}\.$`

`$ grex -drswW <INPUT>`
: `^\w\s\W{3}\s\d(?:\d\s\w{3}\s){2}\W{3}$`
