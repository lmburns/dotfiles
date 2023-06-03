# easy-align --
{:data-section="shell"}
{:data-date="January 11, 2023"}
{:data-extra="Um Pages"}

## SYNOPSIS

Vim extension that helps align text.

## OPTIONS

### INTRODUCTION

With the following lines of text,

```
apple   =red
grass+=green
sky-=   blue
```

try these commands:

- `vipga=`
    - `v`isual-select `i`nner `p`aragraph
    - Start EasyAlign command (`ga`)
    - Align around `=`
- `gaip=`
    - Start EasyAlign command (`ga`) for `i`nner `p`aragraph
    - Align around `=`

DEMO
----

### USING PREDEFINED ALIGNMENT RULES

An *alignment rule* is a predefined set of options for common alignment tasks,
which is identified by a single character, such as `<Space>`, `=`, `:`, `.`,
`|`, `&`, `#`, and `,`.

#### `=`

![Video](https://raw.githubusercontent.com/junegunn/i/master/easy-align/equals.gif)

- `=` Around the 1st occurrences
- `2=` Around the 2nd occurrences
- `*=` Around all occurrences
- `**=` Left/Right alternating alignment around all occurrences
- `<Enter>` Switching between left/right/center alignment modes

#### `<Space>`

![Video](https://raw.githubusercontent.com/junegunn/i/master/easy-align/spaces.gif)

- `<Space>` Around the 1st occurrences of whitespaces
- `2<Space>` Around the 2nd occurrences
- `-<Space>` Around the last occurrences
- `<Enter><Enter>2<Space>` Center-alignment around the 2nd occurrences

#### `,`

![Video](https://raw.githubusercontent.com/junegunn/i/master/easy-align/commas.gif)

- The predefined comma-rule places a comma right next to the preceding token
  without margin (`{'stick_to_left': 1, 'left_margin': 0}`)
- You can change it with `<Right>` arrow

### USING REGULAR EXPRESSION

![Video](https://raw.githubusercontent.com/junegunn/i/master/easy-align/regex.gif)

You can use an arbitrary regular expression by
- pressing `<Ctrl-X>` in interactive mode
- or using `:EasyAlign /REGEX/` command in visual mode or in normal mode with
  a range (e.g. `:%`)

### DIFFERENT WAYS TO START

![Video](https://raw.githubusercontent.com/junegunn/i/master/easy-align/modes.gif)

This demo shows how you can start interactive mode with visual selection or use
non-interactive `:EasyAlign` command.

### ALIGNING TABLE CELLS

![Video](https://raw.githubusercontent.com/junegunn/i/master/easy-align/tables.gif)

Check out various alignment options and "live interactive mode".

### SYNTAX-AWARE ALIGNMENT

![Video](https://raw.githubusercontent.com/junegunn/i/master/easy-align/yaml.gif)

Delimiters in strings and comments are ignored by default.

### USING BLOCKWISE-VISUAL MODE

![Video](https://raw.githubusercontent.com/junegunn/i/master/easy-align/blockwise-visual.gif)

You can limit the scope with blockwise-visual mode.

USAGE
-----

### FLOW OF EXECUTION

There are **two ways** to use easy-align.

#### 1. `<Plug>` MAPPINGS (INTERACTIVE MODE)

The recommended method is to use `<Plug>(EasyAlign)` mapping in normal and
visual mode. They are usually mapped to `ga`, but you can choose any key
sequences.

```vim
nmap ga <Plug>(EasyAlign)
xmap ga <Plug>(EasyAlign)
```

1. `ga` key in visual mode, or `ga` followed by a motion or a text
   object to start interactive mode
1. (Optional) Enter keys to cycle between alignment mode (left, right, or center)
1. (Optional) N-th delimiter (default: 1)
    - `1`         Around the 1st occurrences of delimiters
    - `2`         Around the 2nd occurrences of delimiters
    - ...
    - `*`         Around all occurrences of delimiters
    - `**`        Left-right alternating alignment around all delimiters
    - `-`         Around the last occurrences of delimiters (`-1`)
    - `-2`        Around the second to last occurrences of delimiters
    - ...
1. Delimiter key (a single keystroke; `<Space>`, `=`, `:`, `.`, `|`, `&`, `#`, `,`) or an arbitrary regular expression followed by `<CTRL-X>`

#### 2. USING `:EasyAlign` COMMAND

If you prefer command-line, use `:EasyAlign` command instead.

```vim
" Using predefined rules
:EasyAlign[!] [N-th] DELIMITER_KEY [OPTIONS]

" Using regular expression
:EasyAlign[!] [N-th] /REGEXP/ [OPTIONS]
```

### REGULAR EXPRESSION VS. PREDEFINED RULES

You can use regular expressions but it's usually much easier to use predefined
alignment rules that you can trigger with a single keystroke.

| Key       | Description/Use cases                                                |
| --------- | -------------------------------------------------------------------- |
| `<Space>` | General alignment around whitespaces                                 |
| `=`       | Operators containing equals sign (`=`, `==,` `!=`, `+=`, `&&=`, ...) |
| `:`       | Suitable for formatting JSON or YAML                                 |
| `.`       | Multi-line method chaining                                           |
| `,`       | Multi-line method arguments                                          |
| `&`       | LaTeX tables (matches `&` and `\\`)                                  |
| `#`       | Ruby/Python comments                                                 |
| `"`       | Vim comments                                                         |
| `<Bar>`   | Table markdown                                                       |

You can also define your own rules with `g:easy_align_delimiters` which will
be described in [the later section](#extending-alignment-rules).

----

### INTERACTIVE MODE

Interactive mode is started either with `<Plug>(EasyAlign)` mapping or with
`:EasyAlign` command with no argument.

#### EXAMPLES USING PREDEFINED RULES

| Keystrokes   | Description                        | Equivalent command    |
| ------------ | ---------------------------------- | --------------------- |
| `<Space>`    | Around 1st whitespaces             | `:'<,'>EasyAlign\ `   |
| `2<Space>`   | Around 2nd whitespaces             | `:'<,'>EasyAlign2\ `  |
| `-<Space>`   | Around the last whitespaces        | `:'<,'>EasyAlign-\ `  |
| `-2<Space>`  | Around the 2nd to last whitespaces | `:'<,'>EasyAlign-2\ ` |
| `:`          | Around 1st colon (`key:  value`)   | `:'<,'>EasyAlign:`    |
| `<Right>:`   | Around 1st colon (`key : value`)   | `:'<,'>EasyAlign:>l1` |
| `=`          | Around 1st operators with =        | `:'<,'>EasyAlign=`    |
| `3=`         | Around 3rd operators with =        | `:'<,'>EasyAlign3=`   |
| `*=`         | Around all operators with =        | `:'<,'>EasyAlign*=`   |
| `**=`        | Left-right alternating around =    | `:'<,'>EasyAlign**=`  |
| `<Enter>=`   | Right alignment around 1st =       | `:'<,'>EasyAlign!=`   |
| `<Enter>**=` | Right-left alternating around =    | `:'<,'>EasyAlign!**=` |

Instead of finishing the alignment with a delimiter key, you can type in
a regular expression if you press `<CTRL-/>` or `<CTRL-X>`.

#### ALIGNMENT OPTIONS IN INTERACTIVE MODE

While in interactive mode, you can set alignment options using special shortcut
keys listed below. The meaning of each option will be described in
[the following sections](#alignment-options).

| Key       | Option             | Values                                             |
| --------- | ------------------ | -------------------------------------------------- |
| `CTRL-F`  | `filter`           | Input string (`[gv]/.*/?`)                         |
| `CTRL-I`  | `indentation`      | shallow, deep, none, keep                          |
| `CTRL-L`  | `left_margin`      | Input number or string                             |
| `CTRL-R`  | `right_margin`     | Input number or string                             |
| `CTRL-D`  | `delimiter_align`  | left, center, right                                |
| `CTRL-U`  | `ignore_unmatched` | 0, 1                                               |
| `CTRL-G`  | `ignore_groups`    | `[]`, `['String']`, `['Comment']`, `['String', 'Comment']` |
| `CTRL-A`  | `align`            | Input string (`/[lrc]+\*{0,2}/`)                   |
| `<Left>`  | `stick_to_left`    | `{ 'stick_to_left': 1, 'left_margin': 0 }`         |
| `<Right>` | `stick_to_left`    | `{ 'stick_to_left': 0, 'left_margin': 1 }`         |
| `<Down>`  | `*_margin`         | `{ 'left_margin': 0, 'right_margin': 0 }`          |

#### LIVE INTERACTIVE MODE

If you're performing a complex alignment where multiple options should be
carefully adjusted, try "live interactive mode" where you can preview the result
of the alignment on-the-fly as you type in.

Live interactive mode can be started with either `<Plug>(LiveEasyAlign)` map
or `:LiveEasyAlign` command. Or you can switch to live interactive mode while
in ordinary interactive mode by pressing `<CTRL-P>`. (P for Preview)

In live interactive mode, you have to type in the same delimiter (or
`<CTRL-X>` on regular expression) again to finalize the alignment. This allows
you to preview the result of the alignment and freely change the delimiter
using backspace key without leaving the interactive mode.

### :EASYALIGN COMMAND

Instead of starting interactive mode, you can use non-interactive `:EasyAlign`
command.

```vim
" Using predefined alignment rules
"   :EasyAlign[!] [N-th] DELIMITER_KEY [OPTIONS]
:EasyAlign :
:EasyAlign =
:EasyAlign *=
:EasyAlign 3\

" Using arbitrary regular expressions
"   :EasyAlign[!] [N-th] /REGEXP/ [OPTIONS]
:EasyAlign /[:;]\+/
:EasyAlign 2/[:;]\+/
:EasyAlign */[:;]\+/
:EasyAlign **/[:;]\+/
```

A command can end with alignment options, [each of which will be discussed in
detail later](#alignment-options), in Vim dictionary format.

- `:EasyAlign * /[:;]\+/ { 'stick_to_left': 1, 'left_margin': 0 }`

`stick_to_left` of 1 means that the matched delimiter should be positioned right
next to the preceding token, and `left_margin` of 0 removes the margin on the
left. So we get:

    apple;: banana::   cake
    data;;  exchange:; format

You don't have to write complete names as long as they're distinguishable.

- `:EasyAlign * /[:;]\+/ { 'stl': 1, 'l': 0 }`

You can even omit spaces between the arguments.

- `:EasyAlign*/[:;]\+/{'s':1,'l':0}`

Nice. But let's make it even shorter. Option values can be written in shorthand
notation.

- `:EasyAlign*/[:;]\+/<l0`

The following table summarizes the shorthand notation.

| Option             | Expression     |
| ------------------ | -------------- |
| `filter`           | `[gv]/.*/`     |
| `left_margin`      | `l[0-9]+`      |
| `right_margin`     | `r[0-9]+`      |
| `stick_to_left`    | `<` or `>`     |
| `ignore_unmatched` | `iu[01]`       |
| `ignore_groups`    | `ig\[.*\]`     |
| `align`            | `a[lrc*]*`     |
| `delimiter_align`  | `d[lrc]`       |
| `indentation`      | `i[ksdn]`      |

### PARTIAL ALIGNMENT IN BLOCKWISE-VISUAL MODE

In blockwise-visual mode (`CTRL-V`), EasyAlign command aligns only the selected
text in the block, instead of the whole lines in the range.

Consider the following case where you want to align text around `=>` operators.

```ruby
my_hash = { :a => 1,
            :aa => 2,
            :aaa => 3 }
```

In non-blockwise visual mode (`v` / `V`), `<Enter>=` won't work since the
assignment operator in the first line gets in the way. So we instead enter
blockwise-visual mode (`CTRL-V`), and select the text *around*
`=>` operators, then press `<Enter>=`.

```ruby
my_hash = { :a   => 1,
            :aa  => 2,
            :aaa => 3 }
```

However, in this case, we don't really need blockwise visual mode
since the same can be easily done using the negative N-th parameter: `<Enter>-=`


Alignment options
-----------------

### List of options

| Option             | Type    | Default               | Description                                             |
| ------------------ | ------- | --------------------- | ------------------------------------------------------- |
| `filter`           | string  |                       | Line filtering expression: `g/../` or `v/../`           |
| `left_margin`      | number  | 1                     | Number of spaces to attach before delimiter             |
| `left_margin`      | string  | `' '`                 | String to attach before delimiter                       |
| `right_margin`     | number  | 1                     | Number of spaces to attach after delimiter              |
| `right_margin`     | string  | `' '`                 | String to attach after delimiter                        |
| `stick_to_left`    | boolean | 0                     | Whether to position delimiter on the left-side          |
| `ignore_groups`    | list    | ['String', 'Comment'] | Delimiters in these syntax highlight groups are ignored |
| `ignore_unmatched` | boolean | 1                     | Whether to ignore lines without matching delimiter      |
| `indentation`      | string  | `k`                   | Indentation method (*k*eep, *d*eep, *s*hallow, *n*one)  |
| `delimiter_align`  | string  | `r`                   | Determines how to align delimiters of different lengths |
| `align`            | string  | `l`                   | Alignment modes for multiple occurrences of delimiters  |

There are 4 ways to set alignment options (from lowest precedence to highest):

1. Some option values can be set with corresponding global variables
2. Option values can be specified in the definition of each alignment rule
3. Option values can be given as arguments to `:EasyAlign` command
4. Option values can be set in interactive mode using special shortcut keys

| Option name        | Shortcut key        | Abbreviated    | Global variable                 |
| ------------------ | ------------------- | -------------- | ------------------------------- |
| `filter`           | `CTRL-F`            | `[gv]/.*/`     |                                 |
| `left_margin`      | `CTRL-L`            | `l[0-9]+`      |                                 |
| `right_margin`     | `CTRL-R`            | `r[0-9]+`      |                                 |
| `stick_to_left`    | `<Left>`, `<Right>` | `<` or `>`     |                                 |
| `ignore_groups`    | `CTRL-G`            | `ig\[.*\]`     | `g:easy_align_ignore_groups`    |
| `ignore_unmatched` | `CTRL-U`            | `iu[01]`       | `g:easy_align_ignore_unmatched` |
| `indentation`      | `CTRL-I`            | `i[ksdn]`      | `g:easy_align_indentation`      |
| `delimiter_align`  | `CTRL-D`            | `d[lrc]`       | `g:easy_align_delimiter_align`  |
| `align`            | `CTRL-A`            | `a[lrc*]*`     |                                 |

### Filtering lines

With `filter` option, you can align lines that only match or do not match a
given pattern. There are several ways to set the pattern.

1. Press `CTRL-F` in interactive mode and type in `g/pat/` or `v/pat/`
2. In command-line, it can be written in dictionary format: `{'filter': 'g/pat/'}`
3. Or in shorthand notation: `g/pat/` or `v/pat/`

(You don't need to escape '/'s in the regular expression)

#### Examples

```vim
" Start interactive mode with filter option set to g/hello/
EasyAlign g/hello/

" Start live interactive mode with filter option set to v/goodbye/
LiveEasyAlign v/goodbye/

" Align the lines with 'hi' around the first colons
EasyAlign:g/hi/
```

### Ignoring delimiters in comments or strings

EasyAlign can be configured to ignore delimiters in certain syntax highlight
groups, such as code comments or strings. By default, delimiters that are
highlighted as code comments or strings are ignored.

```vim
" Default:
"   If a delimiter is in a highlight group whose name matches
"   any of the followings, it will be ignored.
let g:easy_align_ignore_groups = ['Comment', 'String']
```

For example, the following paragraph

```ruby
{
  # Quantity of apples: 1
  apple: 1,
  # Quantity of bananas: 2
  bananas: 2,
  # Quantity of grape:fruits: 3
  'grape:fruits': 3
}
```

becomes as follows on `<Enter>:` (or `:EasyAlign:`)

```ruby
{
  # Quantity of apples: 1
  apple:          1,
  # Quantity of bananas: 2
  bananas:        2,
  # Quantity of grape:fruits: 3
  'grape:fruits': 3
}
```

Naturally, this feature only works when syntax highlighting is enabled.

You can change the default rule by using one of these 4 methods.

1. Press `CTRL-G` in interactive mode to switch groups
2. Define global `g:easy_align_ignore_groups` list
3. Define a custom rule in `g:easy_align_delimiters` with `ignore_groups` option
4. Provide `ignore_groups` option to `:EasyAlign` command.
   e.g. `:EasyAlign:ig[]`

For example if you set `ignore_groups` option to be an empty list, you get

```ruby
{
  # Quantity of apples:  1
  apple:                 1,
  # Quantity of bananas: 2
  bananas:               2,
  # Quantity of grape:   fruits: 3
  'grape:                fruits': 3
}
```

If a pattern in `ignore_groups` is prepended by a `!`, it will have the opposite
meaning. For instance, if `ignore_groups` is given as `['!Comment']`, delimiters
that are *not* highlighted as Comment will be ignored during the alignment.

### Ignoring unmatched lines

`ignore_unmatched` option determines how EasyAlign command processes lines that
do not have N-th delimiter.

1. In left-alignment mode, they are ignored
2. In right or center-alignment mode, they are *not* ignored, and the last
   tokens from those lines are aligned as well as if there is an invisible
   trailing delimiter at the end of each line
3. If `ignore_unmatched` is 1, they are ignored regardless of the alignment mode
4. If `ignore_unmatched` is 0, they are *not* ignored regardless of the mode

Let's take an example.
When we align the following code block around the (1st) colons,

```ruby
{
  apple: proc {
    this_line_does_not_have_a_colon
  },
  bananas: 2,
  grapefruits: 3
}
```

this is usually what we want.

```ruby
{
  apple:       proc {
    this_line_does_not_have_a_colon
  },
  bananas:     2,
  grapefruits: 3
}
```

However, we can override this default behavior by setting `ignore_unmatched`
option to zero using one of the following methods.

1. Press `CTRL-U` in interactive mode to toggle `ignore_unmatched` option
2. Set the global `g:easy_align_ignore_unmatched` variable to 0
3. Define a custom alignment rule with `ignore_unmatched` option set to 0
4. Provide `ignore_unmatched` option to `:EasyAlign` command. e.g. `:EasyAlign:iu0`

Then we get,

```ruby
{
  apple:                             proc {
    this_line_does_not_have_a_colon
  },
  bananas:                           2,
  grapefruits:                       3
}
```

### Aligning delimiters of different lengths

Global `g:easy_align_delimiter_align` option and rule-wise/command-wise
`delimiter_align` option determines how matched delimiters of different lengths
are aligned.

```ruby
apple = 1
banana += apple
cake ||= banana
```

By default, delimiters are right-aligned as follows.

```ruby
apple    = 1
banana  += apple
cake   ||= banana
```

However, with `:EasyAlign=dl`, delimiters are left-aligned.

```ruby
apple  =   1
banana +=  apple
cake   ||= banana
```

And on `:EasyAlign=dc`, center-aligned.

```ruby
apple   =  1
banana +=  apple
cake   ||= banana
```

In interactive mode, you can change the option value with `CTRL-D` key.

### Adjusting indentation

By default :EasyAlign command keeps the original indentation of the lines. But
then again we have `indentation` option. See the following example.

```ruby
# Lines with different indentation
  apple = 1
    banana = 2
      cake = 3
        daisy = 4
     eggplant = 5

# Default: _k_eep the original indentation
#   :EasyAlign=
  apple       = 1
    banana    = 2
      cake    = 3
        daisy = 4
     eggplant = 5

# Use the _s_hallowest indentation among the lines
#   :EasyAlign=is
  apple    = 1
  banana   = 2
  cake     = 3
  daisy    = 4
  eggplant = 5

# Use the _d_eepest indentation among the lines
#   :EasyAlign=id
        apple    = 1
        banana   = 2
        cake     = 3
        daisy    = 4
        eggplant = 5

# Indentation: _n_one
#   :EasyAlign=in
apple    = 1
banana   = 2
cake     = 3
daisy    = 4
eggplant = 5
```

In interactive mode, you can change the option value with `CTRL-I` key.

### Alignments over multiple occurrences of delimiters

As stated above, "N-th" parameter is used to target specific occurrences of
the delimiter when it appears multiple times in each line.

To recap:

```vim
" Left-alignment around the FIRST occurrences of delimiters
:EasyAlign =

" Left-alignment around the SECOND occurrences of delimiters
:EasyAlign 2=

" Left-alignment around the LAST occurrences of delimiters
:EasyAlign -=

" Left-alignment around ALL occurrences of delimiters
:EasyAlign *=

" Left-right ALTERNATING alignment around all occurrences of delimiters
:EasyAlign **=

" Right-left ALTERNATING alignment around all occurrences of delimiters
:EasyAlign! **=
```

In addition to these, you can fine-tune alignments over multiple occurrences
of the delimiters with 'align' option. (The option can also be set in
interactive mode with the special key `CTRL-A`)

```vim
" Left alignment over the first two occurrences of delimiters
:EasyAlign = { 'align': 'll' }

" Right, left, center alignment over the 1st to 3rd occurrences of delimiters
:EasyAlign = { 'a': 'rlc' }

" Using shorthand notation
:EasyAlign = arlc

" Right, left, center alignment over the 2nd to 4th occurrences of delimiters
:EasyAlign 2=arlc

" (*) Repeating alignments (default: l, r, or c)
"   Right, left, center, center, center, center, ...
:EasyAlign *=arlc

" (**) Alternating alignments (default: lr or rl)
"   Right, left, center, right, left, center, ...
:EasyAlign **=arlc

" Right, left, center, center, center, ... repeating alignment
" over the 3rd to the last occurrences of delimiters
:EasyAlign 3=arlc*

" Right, left, center, right, left, center, ... alternating alignment
" over the 3rd to the last occurrences of delimiters
:EasyAlign 3=arlc**
```

### Extending alignment rules

Although the default rules should cover the most of the use cases,
you can extend the rules by setting a dictionary named `g:easy_align_delimiters`.

You may refer to the definitions of the default alignment rules
[here](https://github.com/junegunn/vim-easy-align/blob/2.9.6/autoload/easy_align.vim#L32-L46).

#### Examples

```vim
let g:easy_align_delimiters = {
\ '>': { 'pattern': '>>\|=>\|>' },
\ '/': {
\     'pattern':         '//\+\|/\*\|\*/',
\     'delimiter_align': 'l',
\     'ignore_groups':   ['!Comment'] },
\ ']': {
\     'pattern':       '[[\]]',
\     'left_margin':   0,
\     'right_margin':  0,
\     'stick_to_left': 0
\   },
\ ')': {
\     'pattern':       '[()]',
\     'left_margin':   0,
\     'right_margin':  0,
\     'stick_to_left': 0
\   },
\ 'd': {
\     'pattern':      ' \(\S\+\s*[;=]\)\@=',
\     'left_margin':  0,
\     'right_margin': 0
\   }
\ }
```

## OTHER OPTIONS

### Disabling `&foldmethod` during alignment

[It is reported](https://github.com/junegunn/vim-easy-align/issues/14) that
`&foldmethod` value of `expr` or `syntax` can significantly slow down the
alignment when editing a large, complex file with many folds. To alleviate this
issue, EasyAlign provides an option to temporarily set `&foldmethod` to `manual`
during the alignment task. In order to enable this feature, set
`g:easy_align_bypass_fold` switch to 1.

```vim
let g:easy_align_bypass_fold = 1
```

### Left/right/center mode switch in interactive mode

In interactive mode, you can choose the alignment mode you want by pressing
enter keys. The non-bang command, `:EasyAlign` starts in left-alignment mode
and changes to right and center mode as you press enter keys, while the bang
version first starts in right-alignment mode.

- `:EasyAlign`
  - Left, Right, Center
- `:EasyAlign!`
  - Right, Left, Center

If you do not prefer this default mode transition, you can define your own
settings as follows.

```vim
let g:easy_align_interactive_modes = ['l', 'r']
let g:easy_align_bang_interactive_modes = ['c', 'r']
```

==================================================================================

EASY-ALIGN EXAMPLES
===================

Open this document in your Vim and try it yourself.

This document assumes that you have the following mappings in your .vimrc.

```vim
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)
```

You can use either of the maps. Place the cursor on the paragraph and press

- `gaip` "(ga) start easy-align on (i)nner (p)aragraph"
- or `vipga` "(v)isual-select (i)nner (p)aragraph and (ga) start easy-align"

To enable syntax highlighting in the code blocks, define and call the following
function.

```vim
function! GFM()
  let langs = ['ruby', 'yaml', 'vim', 'c']

  for lang in langs
    unlet b:current_syntax
    silent! exec printf("syntax include @%s syntax/%s.vim", lang, lang)
    exec printf("syntax region %sSnip matchgroup=Snip start='```%s' end='```' contains=@%s",
                \ lang, lang, lang)
  endfor
  let b:current_syntax='mkd'

  syntax sync fromstart
endfunction
```

Alignment around whitespaces
----------------------------

You can align text around whitespaces with `<space>` delimiter key.

Start the interactive mode as described above (`gaip` or `vipga`) and try
these commands:

- `<space>`
- `2<space>`
- `*<space>`
- `-<space>`
- `-2<space>`
- `<Enter><space>`
- `<Enter>*<space>`
- `<Enter><Enter>*<space>`

### Example

```

Paul McCartney 1942
George Harrison 1943
Ringo Starr 1940
Pete Best 1941

```

Formatting table
----------------

Again, start the interactive mode and try these commands:

- `*|`
- `**|`
- `<Enter>*|`
- `<Enter>**|`
- `<Enter><Enter>*|`

### Example

```

| Option| Type | Default | Description |
|--|--|--|--|
| threads | Fixnum | 1 | number of threads in the thread pool |
|queues |Fixnum | 1 | number of concurrent queues |
|queue_size | Fixnum | 1000 | size of each queue |
|   interval | Numeric | 0 | dispatcher interval for batch processing |
|batch | Boolean | false | enables batch processing mode |
 |batch_size | Fixnum | nil | number of maximum items to be assigned at once |
 |logger | Logger | nil | logger instance for debug logs |

```


Alignment around =
------------------

The default rule for delimiter key `=` aligns around a whole family of
operators containing `=` character.

Try these commands in the interactive mode.

- `=`
- `*=`
- `**=`
- `<Enter>**=`
- `<Enter><Enter>*=`

### Example

```ruby

a =
a = 1
bbbb = 2
ccccccc = 3
ccccccccccccccc
ddd = 4
eeee === eee = eee = eee=f
fff = ggg += gg &&= gg
g != hhhhhhhh == 888
i   := 5
i     %= 5
i       *= 5
j     =~ 5
j   >= 5
aa      =>         123
aa <<= 123
aa        >>= 123
bbb               => 123
c     => 1233123
d   =>      123
dddddd &&= 123
dddddd ||= 123
dddddd /= 123
gg <=> ee

```

Formatting YAML (or JSON)
-------------------------

You can use `:`-rule here to align text around only the first occurrences of
colons. In this case, you don't want to align around all the colons: `*:`.

```yaml
mysql:
  # JDBC driver for MySQL database:
  driver: com.mysql.jdbc.Driver
  # JDBC URL for the connection (jdbc:mysql://HOSTNAME/DATABASE)
  url: jdbc:mysql://localhost/test
  database: test
  "user:pass":r00t:pa55
```

Formatting multi-line method chaining
-------------------------------------

Try `.` or `*.` on the following lines.

```ruby
my_object
      .method1().chain()
    .second_method().call()
      .third().call()
     .method_4().execute()
```

Notice that the indentation is adjusted to match the shortest one among those of
the lines starting with the delimiter.

```ruby
my_object
    .method1()      .chain()
    .second_method().call()
    .third()        .call()
    .method_4()     .execute()
```


USING BLOCKWISE-VISUAL MODE OR NEGATIVE N-TH PARAMETER
------------------------------------------------------

You can try either:
- select text around `=>` in blockwise-visual mode (`CTRL-V`) and `ga=`
- or `gaip-=`

```ruby
options = { :caching => nil,
            :versions => 3,
            "cache=blocks" => false }.merge(options)
```

COMMAS
------

There is also a predefined rule for commas, try `*,`.

```
aaa,   bb,c
d,eeeeeee
fffff, gggggggggg,
h, ,           ii
j,,k
```

IGNORING DELIMITERS IN COMMENTS OR STRINGS
------------------------------------------

Delimiters highlighted as comments or strings are ignored by default, try
`gaip*=` on the following lines.

```c
/* a */ b = c
aa >= bb
// aaa = bbb = cccc
/* aaaa = */ bbbb   === cccc   " = dddd = " = eeee
aaaaa /* bbbbb */      == ccccc /* != eeeee = */ === fffff

```

This only works when syntax highlighting is enabled.

ALIGNING IN-LINE COMMENTS
-------------------------

*Note: Since the current version provides '#'-rule as one of the default rules,
you can ignore this section.*

```ruby
apple = 1 # comment not aligned
banana = 'Gros Michel' # comment 2
```

So, how do we align the trailing comments in the above lines? Simply try
`-<space>`. The spaces in the comments are ignored, so the trailing comment in
each line is considered to be a single chunk.

But that doesn't work in the following case.

```ruby
apple = 1 # comment not aligned
apricot = 'DAD' + 'F#AD'
banana = 'Gros Michel' # comment 2
```

That is because the second line doesn't have trailing comment, and
the last (`-`) space for that line is the one just before `'F#AD'`.

So, let's define a custom mapping for `#`.

```vim
if !exists('g:easy_align_delimiters')
  let g:easy_align_delimiters = {}
endif
let g:easy_align_delimiters['#'] = { 'pattern': '#', 'ignore_groups': ['String'] }
```

Notice that the rule overrides `ignore_groups` attribute in order *not to ignore*
delimiters highlighted as comments.

Then on `#`, we get

```ruby
apple = 1         # comment not aligned
apricot = 'DAD' + 'F#AD'
banana = 'string' # comment 2
```

If you don't want to define the rule, you can do the same with the following
command:

```vim
" Using regular expression /#/
" - "ig" is a shorthand notation of "ignore_groups"
:EasyAlign/#/{'ig':['String']}

" Or more concisely with the shorthand notation;
:EasyAlign/#/ig['String']
```

In this case, the second line is ignored as it doesn't contain a `#` (The one
in `'F#AD'` is ignored as it's highlighted as String). If you don't want the
second line to be ignored, there are three options:

1. Set global `g:easy_align_ignore_unmatched` flag to 0
2. Use `:EasyAlign` command with `ignore_unmatched` option
3. Update the alignment rule with `ignore_unmatched` option

```vim
" 1. Set global g:easy_align_ignore_unmatched to zero
let g:easy_align_ignore_unmatched = 0


### SHORTCUTS

" 2. Using :EasyAlign command with ignore_unmatched option
" 2-1. Using predefined rule with delimiter key #
"      - "iu" is expanded to "*i*gnore_*u*nmatched"
:EasyAlign#{'iu':0}
" or
:EasyAlign#iu0

" 2-2. Using regular expression /#/
:EasyAlign/#/ig['String']iu0

" 3. Update the alignment rule with ignore_unmatched option
let g:easy_align_delimiters['#'] = {
  \ 'pattern': '#', 'ignore_groups': ['String'], 'ignore_unmatched': 0 }
```

Then we get,

```ruby
apple = 1                # comment not aligned
apricot = 'DAD' + 'F#AD'
banana = 'string'        # comment 2
```

ALIGNING C-STYLE VARIABLE DEFINITION
------------------------------------

Take the following example:

```c
const char* str = "Hello";
int64_t count = 1 + 2;
static double pi = 3.14;
```

We can align these lines with the predefined `=` rule. Select the lines and
press `ga=`

```c
const char* str  = "Hello";
int64_t count    = 1 + 2;
static double pi = 3.14;
```

Not bad. However, the names of the variables, `str`, `count`, and `pi` are not
aligned with each other. Can we do better? We can clearly see that simple
`<space>`-rule won't properly align those names.
So let's define an alignment rule than can handle this case.

```vim
let g:easy_align_delimiters['d'] = {
\ 'pattern': '\(const\|static\)\@<! ',
\ 'left_margin': 0, 'right_margin': 0
\ }
```

This new rule aligns text around spaces that are *not* preceded by
`const` or `static`. Let's select the lines and try `gad`.

```c
const char*   str = "Hello";
int64_t       count = 1 + 2;
static double pi = 3.14;
```

Okay, the names are now aligned. We select the lines again with `gv`, and then
press `ga=` to finish our alignment.

```c
const char*   str   = "Hello";
int64_t       count = 1 + 2;
static double pi    = 3.14;
```

So far, so good. However, this rule is not sufficient to handle more complex
cases involving C++ templates or Java generics. Take the following example:

```c
const char* str = "Hello";
int64_t count = 1 + 2;
static double pi = 3.14;
static std::map<std::string, float>*    scores = pointer;
```

We see that our rule above doesn't work anymore.

```c
const char*                  str = "Hello";
int64_t                      count = 1 + 2;
static double                pi = 3.14;
static std::map<std::string, float>*    scores = pointer;
```

So what do we do? Let's try to improve our alignment rule.

```vim
let g:easy_align_delimiters['d'] = {
\ 'pattern': ' \ze\S\+\s*[;=]',
\ 'left_margin': 0, 'right_margin': 0
\ }
```

Now the new rule has changed to align text around spaces that are followed
by some non-whitespace characters and then an equals sign or a semi-colon.
Try `vipgad`

```c
const char*                          str = "Hello";
int64_t                              count = 1 + 2;
static double                        pi = 3.14;
static std::map<std::string, float>* scores = pointer;
```

We're right on track, now press `gvga=` and voila!

```c
const char*                          str    = "Hello";
int64_t                              count  = 1 + 2;
static double                        pi     = 3.14;
static std::map<std::string, float>* scores = pointer;
```
