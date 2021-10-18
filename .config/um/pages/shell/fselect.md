# fselect -- *[ARGS] COLUMN[, COLUMN...] [from ROOT[, ROOT...]] [where EXPR] [order by COLUMNS] [limit N] [into FORMAT]*
{:data-section="shell"}
{:data-date="March 25, 2021"}
{:data-extra="Um Pages"}

## SYNOPSIS
SQL query for files

## KEYWORDS

* Commas for column separation aren't needed as well. Column aliasing (with or without *as* keyword) is not supported.

* *into* keyword specifies output format, not output table.

`name`
: Returns the name (with extension) of the file

`extension` or `ext`
: Returns the extension of the file

`path`
: Returns the path of the file

`abspath`
: Returns the absolute path of the file

`directory` or `dirname` or `dir`
: Returns the directory of the file

`absdir`
: Returns the absolute directory of the file

`size`
:  Returns the size of the file in bytes

`fsize` or `hsize`
: Returns the size of the file accompanied with the unit

`uid`
: Returns the UID of the owner

`gid`
: Returns the GID of the owner's group

`accessed`
: Returns the time the file was last accessed (YYYY-MM-DD HH:MM:SS)

`created`
: Returns the file creation date (YYYY-MM-DD HH:MM:SS)

`modified`
: Returns the time the file was last modified (YYYY-MM-DD HH:MM:SS)

`is_dir`
: Returns a boolean signifying whether the file path is a directory

`is_file`
: Returns a boolean signifying whether the file path is a file

`is_symlink`
: Returns a boolean signifying whether the file path is a symlink

`is_pipe` or `is_fifo`
: Returns a boolean signifying whether the file path is a FIFO or pipe file

`is_char` or `is_character`
: Returns a boolean signifying whether the file path is a character device or character special file

`is_block`
: Returns a boolean signifying whether the file path is a block or block special file

`is_socket`
: Returns a boolean signifying whether the file path is a socket file

`is_hidden`
: Returns a boolean signifying whether the file is a hidden file (e.g., files that start with a dot on *nix)

`has_xattrs`
: Returns a boolean signifying whether the file has extended attributes

`device`
: (Linux only) Returns the code of device the file is stored on

`inode`
: (Linux only) Returns the number of inode

`blocks`
: (Linux only) Returns the number of blocks (256 bytes) the file occupies

`hardlinks`
: (Linux only) Returns the number of hardlinks of the file

`mode`
: Returns the permissions of the owner, group, and everybody (similar to the first field in `ls -la`)

`user`
: Returns the name of the owner for this file

`user_read`
: Returns a boolean signifying whether the file can be read by the owner

`user_write`
: Returns a boolean signifying whether the file can be written by the owner

`user_exec`
: Returns a boolean signifying whether the file can be executed by the owner

`user_all`
: Returns a boolean signifying whether the file can be fully accessed by the owner

`group`
: Returns the name of the owner's group for this file

`group_read`
: Returns a boolean signifying whether the file can be read by the owner's group

`group_write`
: Returns a boolean signifying whether the file can be written by the owner's group

`group_exec`
: Returns a boolean signifying whether the file can be executed by the owner's group

`group_all`
: Returns a boolean signifying whether the file can be fully accessed by the group

`other_read`
: Returns a boolean signifying whether the file can be read by others

`other_write`
: Returns a boolean signifying whether the file can be written by others

`other_exec`
: Returns a boolean signifying whether the file can be executed by others

`other_all`
: Returns a boolean signifying whether the file can be fully accessed by the others

`suid`
: Returns a boolean signifying whether the file permissions have a SUID bit set

`sgid`
: Returns a boolean signifying whether the file permissions have a SGID bit set

`width`
: Returns the number of pixels along the width of the photo or MP4 file

`height`
: Returns the number of pixels along the height of the photo or MP4 file

`mime`
: Returns MIME type of the file

`is_binary`
: Returns a boolean signifying whether the file has binary contents

`is_text`
: Returns a boolean signifying whether the file has text contents

`line_count`
: Returns a number of lines in a text file

`exif_datetime`
: Returns date and time of taken photo

`exif_altitude` or `exif_alt`
: Returns GPS altitude of taken photo

`exif_latitude` or `exif_lat`
: Returns GPS latitude of taken photo

`exif_longitude` or `exif_lng` or `exif_lon`
: Returns GPS longitude of taken photo

`exif_make`
: Returns name of the camera manufacturer

`exif_model`
: Returns camera model

`exif_software`
: Returns software name with which the photo was taken

`exif_version`
: Returns the version of EXIF metadata

`mp3_title` or `title`
: Returns the title of the audio file taken from the file's metadata

`mp3_album` or `album`
: Returns the album name of the audio file taken from the file's metadata

`mp3_artist` or `artist`
: Returns the artist of the audio file taken from the file's metadata

`mp3_genre` or `genre`
: Returns the genre of the audio file taken from the file's metadata

`mp3_year`
: Returns the year of the audio file taken from the file's metadata

`mp3_freq` or `freq`
: Returns the sampling rate of audio or video file

`mp3_bitrate` or `bitrate`
: Returns the bitrate of the audio file in kbps

`duration`
: Returns the duration of audio file in seconds

`is_shebang`
: Returns a boolean signifying whether the file starts with a shebang (#!)

`is_empty`
: Returns a boolean signifying whether the file is empty or the directory is empty

`is_archive`
: Returns a boolean signifying whether the file is an archival file

`is_audio`
: Returns a boolean signifying whether the file is an audio file

`is_book`
: Returns a boolean signifying whether the file is a book

`is_doc`
: Returns a boolean signifying whether the file is a document

`is_image`
: Returns a boolean signifying whether the file is an image

`is_source`
: Returns a boolean signifying whether the file is source code

`is_video`
: Returns a boolean signifying whether the file is a video file

`sha1`
: Returns SHA-1 digest of a file

`sha2_256` or `sha256`
: Returns SHA2-256 digest of a file

`sha2_512` or `sha512`
: Returns SHA2-512 digest of a file

`sha3_512` or `sha3`
: Returns SHA-3 digest of a file

### ================================================x

## FUNCTIONS

### AGGREGATE FUNCTIONS

Queries using these functions return only one result row.

`AVG`
: Average of all values  `select avg(size) from /home/user/Downloads`

`COUNT`
: Number of all values  `select count(*) from /home/user/Downloads`

`MAX`
: Maximum value  `select max(size) from /home/user/Downloads`

`MIN`
: Minimum value  `select min(size) from /home/user where size gt 0`

`SUM`
: Sum of all values  `select sum(size) from /home/user/Downloads`

`STDDEV_POP, STDDEV or STD`
: Population standard deviation, the square root of variance  `select stddev_pop(size) from /home/user/Downloads`

`STDDEV_SAMP`
: Sample standard deviation, the square root of sample variance  `select stddev_samp(size) from /home/user/Downloads`

`VAR_POP or VARIANCE`
: Population variance  `select var_pop(size) from /home/user/Downloads`

`VAR_SAMP`
: Sample variance  `select var_samp(size) from /home/user/Downloads`

### ================================================x

### DATE FUNCTIONS

Used mostly for formatting results.

`CURRENT_DATE or CURDATE`
: Returns current date  `select modified, path where modified = CURDATE()`

`DAY`
: Extract day of the month  `select day(modified) from /home/user/Downloads`

`MONTH`
: Extract month of the year  `select month(name) from /home/user/Downloads`

`YEAR`
: Extract year of the date  `select year(name) from /home/user/Downloads`

`DOW or DAYOFWEEK`
: Returns day of the week (1 - Sunday, 2 - Monday, etc.)  `select name, modified, dow(modified) from /home/user/projects/FizzBuzz`

### ================================================x

### USER FUNCTIONS

These are only available on Unix platforms.

`CURRENT_UID`
: Current real UID  `select CURRENT_UID()`

`CURRENT_USER`
: Current real UID's name  `select CURRENT_USER()`

`CURRENT_GID`
: Current primary GID  `select CURRENT_GID()`

`CURRENT_GROUP`
: Current primary GID's name  `select CURRENT_GROUP()`

### ================================================x

### XATTR FUNCTIONS

Used to check if particular xattr exists, or to get its value.
Supported platforms are Linux, MacOS, FreeBSD, and NetBSD.

`HAS_XATTR`
: Check if xattr exists | `select "name, has_xattr(user.test) from /home/user"` |

`XATTR`
: Get value of xattr | `select "name, xattr(user.test) from /home/user"` |

### ================================================x

### STRING FUNCTIONS

Used mostly for formatting results.

`LENGTH or LEN`
: Length of string value  `select length(name) from /home/user/Downloads order by 1 desc limit 10`

`LOWER or LOWERCASE or LCASE`
: Convert value to lowercase  `select lower(name) from /home/user/Downloads`

`UPPER or UPPERCASE or UCASE`
: Convert value to uppercase  `select upper(name) from /home/user/Downloads`

`BASE64`
: Encode value to Base64  `select base64(name) from /home/user/Downloads`

`SUBSTRING or SUBSTR (str, pos, len)`
: Part of `str` value starting from `pos` of (optionally) `len` characters long. Negative `pos` means starting `pos` characters from the end of the string.   `select substr(name, 1, 8) from /home/user/Downloads`

`REPLACE (str, from, to)`
: Replace all occurrences of `from` by `to`  `select replace(name, metallica, MetaLLicA) from /home/user/Music/Rock`

`TRIM`
: Returns string with whitespaces at the beginning and the end stripped  `select trim(title), trim(artist), trim(album) from /home/user/Music into json`

`LTRIM`
: Returns string with whitespaces at the beginning stripped  `select ltrim(title) from /home/user/Music into json`

`RTRIM`
: Returns string with whitespaces at the end stripped  `select rtrim(title) from /home/user/Music into json`

### ================================================x

### OTHER FUNCTIONS

`HEX`
: Convert integer value to hexadecimal representation  `select name, size, hex(size), upper(hex(size)) from /home/user/Downloads`

`OCT`
: Convert integer value to octal representation  `select name, size, oct(size) from /home/user/Downloads`

`CONTAINS`
: `true` if file contains string, `false` if not  `select contains(TODO) from /home/user/Projects/foo/src`

`COALESCE`
: Returns first nonempty expression value  `select name, size, COALESCE(sha256, '---') from /home/user/Downloads`

`CONCAT`
: Returns concatenated string of expression values  `select CONCAT('Name is ', name, ' size is ', fsize, '!!!') from /home/user/Downloads`

`CONCAT_WS`
: Returns concatenated string of expression values with specified delimiter  `select name, fsize, CONCAT_WS('x', width, height) from /home/user/Images`

`RANDOM or RAND`
: Returns random integer (from zero to max int, from zero to *arg*, or from *arg1* to *arg2*)  `select path from /home/user/Music order by RAND()`

`FORMAT_SIZE`
: Returns formatted size of a file  `select name, FORMAT_SIZE(size, '%.0') from /home/user/Downloads order by size desc limit 10`

Let's try `FORMAT_SIZE` with different format specifiers:

`format_size(1678123)`
: Default output  1.60MiB

`format_size(1678123, ' ')`
: Put a space before units  1.60 MiB

`format_size(1678123, '%.0')`
: Round up decimal part  2MiB

`format_size(1678123, '%.1')`
: One place for decimal part  1.6MiB

`format_size(1678123, '%.2')`
: Two places for decimal part  1.60MiB

`format_size(1678123, '%.2 ')`
: Two places for decimal part, and put a space before units  1.60 MiB

`format_size(1678123, '%.2 d')`
: Use decimal divider, e.g. 1000-based units, not 1024-based  1.68 MB

`format_size(1678123, '%.2 c')`
: Use conventional format, e.g. 1024-based divider, but display 1000-based units  1.60 MB

`format_size(1678123, '%.2 k')`
: Display file size in specified unit, this time in kibibytes  1638.79 KiB

`format_size(1678123, '%.2 ck')`
: What is a kibibyte? Gimme conventional unit!  1638.79 KB

`format_size(1678123, '%.0 ck')`
: And drop this decimal part!  1639 KB

`format_size(1678123, '%.0 kb')`
: Use 1000-based kilobyte  1678 KB

`format_size(1678123, '%.0kb')`
: Don't put a space  1678KB

`format_size(1678123, '%.0s')`
: Use short units  2M

`format_size(1678123, '%.0 s')`
: Use short units with a space  2 M

### ================================================x

### FILE SIZE UNITS

`t` or `tib`
: tebibyte  1024 * 1024 * 1024 * 1024

`tb`
: terabyte  1000 * 1000 * 1000 * 1000

`g` or `gib`
: gibibyte  1024 * 1024 * 1024

`gb`
: gigabyte  1000 * 1000 * 1000

`m` or `mib`
: mebibyte  1024 * 1024

`mb`
: megabyte  1000 * 1000

`k` or `kib`
: kibibyte  1024

`kb`
: kilobyte  1000

* *fselect size, path from /home/user/tmp where size gt 2g*
* *fselect fsize, path from /home/user/tmp where size = 5mib*
* *fselect hsize, path from /home/user/tmp where size lt 8kb*

### ================================================x

### SEARCH ROOTS

`path` *[option N] [option] [option] [option...][, path2 [option...]]*

When you put a directory to search at, you can specify some options.

`mindepth` *N*
: Minimum search depth. Default is unlimited. Depth 1 means skip one directory level and search further.

`maxdepth` *N*
: Maximum search depth. Default is unlimited. Depth 1 means search the mentioned directory only. Depth 2 means search mentioned directory and its subdirectories. Synonym is `depth`.

`symlinks`
: If specified, search process will follow symlinks. Default is not to follow. Synonym is `sym`.

`archives`
: Search within archives. Only zip archives are supported. Default is not to include archived content into the search results. Synonym is `arc`.

`gitignore`
: Search respects `.gitignore` files found. Synonym is `git`.

`hgignore`
: Search respects `.hgignore` files found. Synonym is `hg`.

`dockerignore`
: Search respects `.dockerignore` files found. Synonym is `dock`.

`nogitignore`
: Disable `.gitignore` parsing during the search. Synonym is `nogit`.

`nohgignore`
: Disable `.hgignore` parsing during the search. Synonym is `nohg`.

`nodockerignore`
: Disable `.dockerignore` parsing during the search. Synonym is `nodock`.

`dfs`
: Depth-first search mode.

`bfs`
: Breadth-first search mode. This is the default.

`regexp`
: Use regular expressions to search within multiple roots. Synonym is `rx`.

### ================================================x

### OPERATORS

* `=` or `==` or `eq`
* `!=` or `<>` or `ne`
* `===`
* `!==`
* `>` or `gt`
* `>=` or `gte` or `ge`
* `<` or `lt`
* `<=` or `lte` or `le`
* `=~` or `~=` or `regexp` or `rx`
* `!=~` or `!~=` or `notrx`
* `like`
* `notlike`

### ================================================x

### DATE AND TIME SPECIFIERS

When you specify inexact date and time with `=` or `!=` operator, **fselect** understands it as an interval.

`fselect path from /home/user where modified = 2017-05-01`
: *2017-05-01* means all day long from 00:00:00 to 23:59:59.

* `fselect path from /home/user where modified = '2017-05-01 15'`
: *2017-05-01 15* means one hour from 15:00:00 to 15:59:59.

`fselect path from /home/user where modified ne '2017-05-01 15:10'`
: *2017-05-01 15:10* is a 1-minute interval from 15:10:00 to 15:10:59.

Other operators assume exact date and time, which could be specified in a more free way:

* *fselect "path from /home/user where modified === 'apr 1'"*
* *fselect "path from /home/user where modified gte 'last fri'"*
* *fselect path from /home/user where modified gte '01/05'*

### ================================================x

### MIME AND FILE TYPES

For MIME guessing use field `mime`. It returns a simple string with deduced MIME type,
which is not always accurate.

* `fselect path, mime, is_binary, is_text from /home/user`

`is_binary` and `is_text` return `true` or `false` based on MIME type detected.
Once again, this should not be considered as 100% accurate result,
or even possible at all to detect correct file type.

Other fields listed below **do NOT** use MIME detection.
Assumptions are being made based on file extension.

The lists below could be edited with the configuration file.

`is_archive`
: .7z, .bz2, .bzip2, .gz, .gzip, .lz, .rar, .tar, .xz, .zip

`is_audio`
: .aac, .aiff, .amr, .flac, .gsm, .m4a, .m4b, .m4p, .mp3, .ogg, .wav, .wma

`is_book`
: .azw3, .chm, .djvu, .epub, .fb2, .mobi, .pdf

`is_doc`
: .accdb, .doc, .docm, .docx, .dot, .dotm, .dotx, .mdb, .ods, .odt, .pdf, .potm, .potx, .ppt, .pptm, .pptx, .rtf, .xlm, .xls, .xlsm, .xlsx, .xlt, .xltm, .xltx, .xps

`is_image`
: .bmp, .gif, .heic, .jpeg, .jpg, .png, .tiff, .webp

`is_source`
: .asm, .bas, .c, .cc, .ceylon, .clj, .coffee, .cpp, .cs, .d, .dart, .elm, .erl, .go, .groovy, .h, .hh, .hpp, .java, .jl, .js, .jsp, .kt, .kts, .lua, .nim, .pas, .php, .pl, .pm, .py, .rb, .rs, .scala, .swift, .tcl, .vala, .vb

`is_video`
: .3gp, .avi, .flv, .m4p, .m4v, .mkv, .mov, .mp4, .mpeg, .mpg, .webm, .wmv

* `fselect is_archive, path from /home/user`
* `fselect is_audio, is_video, path from /home/user/multimedia`
* `fselect path from /home/user where is_doc != 1`
* `fselect path from /home/user where is_image = false`
* `fselect path from /home/user where is_video != true`

### ================================================x

### MP3 support

* Duration is measured in seconds.

* `fselect duration, bitrate, path from /home/user/music`
* `fselect mp3_year, album, title from /home/user/music where artist like %Vampire% and bitrate gte 320`
* `fselect bitrate, freq, path from /home/user/music where genre = Rap or genre = HipHop`

### ================================================x

### FILE HASHES

| Column                 | Meaning                   |
| ---                    | ---                       |
| `sha1`                 | SHA-1 digest of a file    |
| `sha2_256` or `sha256` | SHA2-256 digest of a file |
| `sha2_512` or `sha512` | SHA2-512 digest of a file |
| `sha3_512` or `sha3`   | SHA3-512 digest of a file |

* `fselect path, sha256, 256 from /home/user/archive limit 5`
* `fselect path from /home/user/Download where sha1 like cb23ef45%`

### ================================================x

### OUTPUT FORMATS

*... into FORMAT*

`tabs`
: default, columns are separated with tabulation

`lines`
: each column goes at a separate line

`list`
: columns are separated with NULL symbol, similar to `-print0` argument of `find`

`csv`
: comma-separated columns

`json`
: array of resulting objects with requested columns

`html`
: HTML document with table

* *fselect size, path from /home/user limit 5 into json*
* *fselect size, path from /home/user limit 5 into csv*
* *fselect size, path from /home/user limit 5 into html*
* *fselect path from /home/user into list | xargs -0 grep foobar*

## EXAMPLES

`fselect size, path from /home/user where name = '*.cfg' or name = '*.tmp'`
: temp or config full path and size

`fselect "name from /home/user/tmp where size > 0"`
: same

`fselect name from /home/user/tmp where size gt 0`
: same

`fselect "name from /tmp where (name = *.tmp and size = 0) or (name = *.cfg and size > 1000000)"`
: complex query

`fselect "MIN(size), MAX(size), AVG(size), SUM(size), COUNT(*) from /home/user/Downloads"`
: aggregate funcs

`fselect "LOWER(name), UPPER(name), LENGTH(name), YEAR(modified) from /home/user/Downloads"`
: formatting funcs

`fselect "MIN(YEAR(modified)) from /home/user"`
: year of oldest file

`fselect name from /home/user where path =~ '.*Rust.*'`
: rust regex

`fselect "name from . where path !=~ '^\./config'"`
: negate regex

`fselect "path from /home/user where name like '%report-2018-__-__???'"`
: classic LIKE

`fselect "path from /home/user where name === 'some_*_weird_*_name'"`
: exact match operator to search w/ regex disabled

`fselect path from /home/user where created = 2017-05-01`
: example

`fselect path from /home/user where modified = today`
: example

`fselect path from /home/user where accessed = yesterday`
: example

`fselect "path from /home/user where modified = 'apr 1'"`
: example

`fselect "path from /home/user where modified = 'last fri'"`
: find files by date
