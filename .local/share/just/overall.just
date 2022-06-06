# justfile grammar: https://github.com/casey/just/blob/master/GRAMMAR.md
# cheatsheet: https://cheatography.com/linux-china/cheat-sheets/justfile/

cli:
  just --list               = list alphabetically
  just --summary            = more concise
  just --list --unsorted    = order they're in file
  just --list --list-prefix = tab separator
  just --evaluate           = evaluate vars
  just --show recipe_name   = show the recipe
  just --choose             = choose recipes where take no args
  just --chooser            = set chooser default fzf or $JUST_CHOOSER

set shell := ["python3", "-c"]
set shell := ["bash", "-uc"]
set shell := ["zsh", "-uc"]

# export all vars as env
set export
# load .env file
set dotenv-load

# POSITIONAL ARGS =====
  # recipe args passed as positional args to cmds
set positional-arguments
@foo bar:
  echo $0 # name of recipe
  echo $1

system-info:
    @echo "This is an {{arch()}} machine".
    echo "This here will show command"

alias b := build
build:
  echo 'Building!'

version := "0.2.7"
tardir  := "awesomesauce-" + version
tarball := tardir + ".tar.gz"

publish:
    rm -f {{tarball}}
    mkdir {{tardir}}
    cp README.md *.c {{tardir}}
    tar zcvf {{tarball}} {{tardir}}
    scp {{tarball}} me@server.com:release/
    rm -rf {{tarball}} {{tardir}}

foo:
    -cat foo # continue even if errors : prefix with hyphen
    echo 'Done!'

# BUILTIN FUNCTIONS ================================================
# retrieve env var w/ name key, abort if not there
aa := env_var(key)
# retrieve env var w/ name key, returning default if not there
env_var_or_default(key, default)
# retrieve path of cwd before just chdir'd before executing
invocation_directory()

rustfmt:
    find {{invocation_directory()}} -name \*.rs -exec rustfmt {} \;

# run from cwd
build:
    cd {{invocation_directory()}}; ./some_script_that_needs_to_be_run_from_here

# path of curr justfile
justfile()
# path of parent dir of curr justfile
justfile_directory()

script:
  ./{{justfile_directory()}}/scripts/some_script

# path of just executable (/bin/just)
just_executable()

executable:
    @echo The executable is at: {{just_executable()}}

# STRING MANIPULATION

string:
  @echo {{uppercase("hi")}}
  @echo {{lowercase("hi")}}
  @echo {{trim("hi")}}
  @echo {{replace(s, from, to)}}

path-manipulation:
  @echo {{extension("/food/bar")}}
  @echo {{file_name("/food/bar")}}
  @echo {{file_stem("/food/bar")}}
  @echo {{parent_directory("/food/bar")}}
  @echo {{without_extension("/food/bar")}}
  @echo {{join("/food/bar", "baz")}}
  @echo {{clean("/food//bar/")}}

# DOT ENV (hi.env)

DATABASE_ADDRESS=localhost:6379
SERVER_PORT=1337

serve:
  @echo "Starting server with database $DATABASE_ADDRESS on port $SERVER_PORT..."
  ./server --database $DATABASE_ADDRESS --port $SERVER_PORT


# === ANNOTATIONS =====================================================
hello:
  @ echo "command will not be echoed"
  - echo "ignore none-zero exit status and continue"

@hello2:
  echo "command will not be echoed"

# Invert command exit status by !  - shell feature
hello3:
  # if command succeeds(exit status is 0), exit just
  ! git branch | grep '* master'


# === BACKTICKS - COMMAND EVALUATION ==================================
localhost := `dumpinterfaces | cut -d: -f2 | sed 's/\/.*//' | sed 's/ //g'`

serve:
    ./serve {{localhost}} 8080

# This backtick evaluates the command `echo foo\necho bar\n`, which produces the value `foo\nbar\n`.
stuff := ```
    echo foo
    echo bar
  ```

done BRANCH=`git rev-parse --abbrev-ref HEAD`:
  git checkout master

sloc:
    @echo "`wc -l *.c` lines of code"

# backtick works anywhere:  string/variable/params


# === CONDITIONAL EXPRESSIONS ==============================================
foo := if "2" == "2" { "Good!" } else { "1984" }
foo := if "hello" != "goodbye" { "xyz" } else { "abc" }
# short-circuit (backticks not run when shouldn't)
foo := if env_var("RELEASE") == "true" { `get-something-from-release-database` } else { "dummy-value" }

bar:
  @echo "{{foo}}"

bar foo:
  echo {{ if foo == "bar" { "hello" } else { "goodbye" } }}

# regular expression match
fo := if "hi" =~ 'h.+' { "match" } else { "mismatch" }

test:
  if true; then echo 'True!'; fi
  for file in `ls .`; do echo $file; done
  while `server-is-dead`; do ping -c 1 server; done

foo bar:
  echo {{ if bar == "bar" { "hello" } else { "bye" } }}


# SETTING VARS FROM CLI ===============================================
os := "linux"
# $ just os=macos
# $ just --set os bsd


# ENV VARIABLES ========================================================
export RUST_BACKTRACE := "1"
test:
    cargo test

# equivalent

test $RUST_BACKTRACE="1":
    cargo test


# RECIPE PARAMETERS ======================================================
# param = target
build target:
    @echo 'Building {{target}}...'
    cd {{target}} && make

# $ just build my-awesome-project

# pass args to dependency
default: (build "main")
build target:
  @echo 'Building {{target}}...'
  cd {{target}} && make

# params may have default values
default := 'all'
test target tests=default:
    @echo 'Testing {{target}}:{{tests}}...'
    ./test --tests {{tests}} {{target}}

# $ just test server -- default values ommitted
# $ just test server unit -- or supplied

# concat
test triple=(arch + "-unknown-unknown"):

# variadic: put + or *
# + = one or more args and expand to string containing
backup +FILES:
  scp {{FILES}} me@server.com:

# * = zero or more args and expand to string containing
commit MESSAGE *FLAGS:
  git commit {{FLAGS}} -m "{{MESSAGE}}"

# variadic assigned default values; overridden by cli args
test +FLAGS='-q':
  cargo test {{FLAGS}}

# quote substitutions if contain spaces
search QUERY:
  lynx 'https://www.google.com/?q={{QUERY}}'

# exported as var
foo $bar:
  echo $bar


# RUNNING OTHER RECIPES ========================================
a:
  echo 'A!'
b: a
  echo 'B!'
  just c
c:
  echo 'C!'


# RECIPES AS SCRIPTS / OTHER LANGUAGES =================================
polygot: perl sh
perl:
  #!/usr/bin/env perl
  print "Larry Wall says Hi!\n";

sh:
  #!/usr/bin/env sh
  hello='Yo'
  echo "$hello from a shell script!"

foo:
  #!/usr/bin/env bash
  set -euxo pipefail # safer
  hello='Yo'

# MULTILINE =========================================================
# IF / FOR / WHILE
conditional:
  if true; then echo 'True!'; fi

conditional:
  if true; then \
      echo 'True!'; \
  fi

conditional:
  #!/usr/bin/env sh
  if true; then
      echo 'True!'
  fi

for:
    for file in `ls .`; do echo $file; done

for:
    for file in `ls .`; do \
        echo $file; \
    done

for:
    #!/usr/bin/env sh
    for file in `ls .`; do
        echo $file
    done

while:
    while `server-is-dead`; do ping -c 1 server; done

while:
    while `server-is-dead`; do \
        ping -c 1 server; \
    done

while:
    #!/usr/bin/env sh
    while `server-is-dead`; do
        do ping -c 1 server
    done

# PRIVATE RECIPES ================================================
# START WITH _ are omitted from just --list
test: _test-helper
  ./bin/test
_test-helper:
  ./bin/super-secret-test-helper-stuff

# QUIET RECIPES ================================================
# prefixed with @; inverts all the other @ (only lines starting with @ are echoed)
@quiet:
  echo hello
  echo goodbye
  @# all done!
# shebang are quiet by default

# DEFAULT RECIPES ================================================
default:
  @just --choose

# JUSTFILES IN OTHER DIRS =========================================
# first arg contains a /:
  # split at last /
  # part before last / treated as dir; start search there instead of cwd
  # after last slash treated as normal arg

# all equivalent
$ (cd foo && just build)
$ just foo/build
$ just foo/

# JUSTFILE SCRIPTS ==================================================
$ cat > script <<EOF
#!/usr/bin/env just --justfile

foo:
  echo foo
EOF
$ chmod +x script
$ ./script foo
echo foo
foo

################################################
alias t := test

alias c := check

bt := '0'

export RUST_BACKTRACE := bt

log := "warn"

export JUST_LOG := log

test:
	cargo test

fuzz:
	cargo +nightly fuzz run fuzz-compiler

run:
	cargo run

@spam:
	{ \
		figlet test; \
		cargo build --color always 2>&1; \
		cargo test  --color always -- --color always 2>&1; \
	} | less

# only run tests matching PATTERN
filter PATTERN:
	cargo test {{PATTERN}}

build:
	cargo build

fmt:
	cargo +nightly fmt --all

watch +COMMAND='test':
	cargo watch --clear --exec "{{COMMAND}}"

man:
	cargo build --features help4help2man
	help2man \
		--name 'save and run commands' \
		--manual 'Just Manual' \
		--no-info \
		target/debug/just \
		> man/just.1

view-man: man
	man man/just.1

version := `sed -En 's/version[[:space:]]*=[[:space:]]*"([^"]+)"/\1/p' Cargo.toml | head -1`

# add git log messages to changelog
changes:
	git log --pretty=format:%s >> CHANGELOG.md

check: clippy test forbid
	git diff --no-ext-diff --quiet --exit-code
	grep {{version}} CHANGELOG.md
	cargo +nightly generate-lockfile -Z minimal-versions
	cargo test
	git checkout Cargo.lock

publish-check: check man
	cargo outdated --exit-code 1

# publish to crates.io and push release tag to github
publish: publish-check
	git branch | grep '* master'
	git tag -a {{version}} -m 'Release {{version}}'
	git push github {{version}}
	cargo publish

push: check
	! git branch | grep '* master'
	git push github

pr: push
	gh pr create --web

# clean up feature branch BRANCH
done BRANCH=`git rev-parse --abbrev-ref HEAD`:
	git checkout master
	git diff --no-ext-diff --quiet --exit-code
	git pull --rebase github master
	git diff --no-ext-diff --quiet --exit-code {{BRANCH}}
	git branch -D {{BRANCH}}

# install just from crates.io
install:
	cargo install -f just

# install development dependencies
install-dev-deps:
	rustup install nightly
	rustup update nightly
	rustup run nightly cargo install -f clippy
	cargo install -f cargo-watch
	cargo install -f cargo-check
	cargo +nightly install cargo-fuzz

# install system development dependencies with homebrew
install-dev-deps-homebrew:
	brew install help2man

# everyone's favorite animate paper clip
clippy:
	cargo clippy --all --all-targets --all-features

forbid:
	./bin/forbid

# count non-empty lines of code
sloc:
	@cat src/*.rs | sed '/^\s*$/d' | wc -l

replace FROM TO:
	sd '{{FROM}}' '{{TO}}' src/*.rs

test-quine:
	cargo run -- quine

# make a quine, compile it, and verify it
quine:
	mkdir -p tmp
	@echo '{{quine-text}}' > tmp/gen0.c
	cc tmp/gen0.c -o tmp/gen0
	./tmp/gen0 > tmp/gen1.c
	cc tmp/gen1.c -o tmp/gen1
	./tmp/gen1 > tmp/gen2.c
	diff tmp/gen1.c tmp/gen2.c
	rm -r tmp
	@echo 'It was a quine!'

quine-text := '
	int printf(const char*, ...);

	int main() {
		char *s =
			"int printf(const char*, ...);"
			"int main() {"
			"	 char *s = %c%s%c;"
			"  printf(s, 34, s, 34);"
			"  return 0;"
			"}";
		printf(s, 34, s, 34);
		return 0;
	}
'

render-readme:
	#!/usr/bin/env ruby
	require 'github/markup'
	$rendered = GitHub::Markup.render("README.adoc", File.read("README.adoc"))
	File.write('tmp/README.html', $rendered)

watch-readme:
	just render-readme
	fswatch -ro README.adoc | xargs -n1 -I{} just render-readme

generate-completions:
	./bin/generate-completions

# run all polyglot recipes
polyglot: _python _js _perl _sh _ruby
# (recipes that start with `_` are hidden from --list)

_python:
	#!/usr/bin/env python3
	print('Hello from python!')

_js:
	#!/usr/bin/env node
	console.log('Greetings from JavaScript!')

_perl:
	#!/usr/bin/env perl
	print "Larry Wall says Hi!\n";

_sh:
	#!/usr/bin/env sh
	hello='Yo'
	echo "$hello from a shell script!"

_ruby:
	#!/usr/bin/env ruby
	puts "Hello from ruby!"

# Print working directory, for demonstration purposes!
pwd:
	echo {{invocation_directory()}}

# use python3 to execute recipe lines and backticks
set shell := ["python3", "-c"]

# use print to capture result of evaluation
foos := `print("foo" * 4)`

foo:
  print("Snake snake snake snake.")
  print("{{foos}}")

##########################################################################################
##########################################################################################
### GRAMMER ############
##########################################################################################
##########################################################################################

BACKTICK            = `[^`]*`
INDENTED_BACKTICK   = ```[^(```)]*```
COMMENT             = #([^!].*)?$
DEDENT              = emitted when indentation decreases
EOF                 = emitted at the end of the file
INDENT              = emitted when indentation increases
LINE                = emitted before a recipe line
NAME                = [a-zA-Z_][a-zA-Z0-9_-]*
NEWLINE             = \n|\r\n
RAW_STRING          = '[^']*'
INDENTED_RAW_STRING = '''[^(''')]*'''
STRING              = "[^"]*" # also processes \n \r \t \" \\ escapes
INDENTED_STRING     = """[^("""]*""" # also processes \n \r \t \" \\ escapes
TEXT                = recipe text, only matches in a recipe body

|   alternation
()  grouping
_?  option (0 or 1 times)
_*  repetition (0 or more times)
_+  repetition (1 or more times)


justfile      : item* EOF

item          : recipe
              | alias
              | assignment
              | export
              | setting
              | eol

eol           : NEWLINE
              | COMMENT NEWLINE

alias         : 'alias' NAME ':=' NAME

assignment    : NAME ':=' expression eol

export        : 'export' assignment

setting       : 'set' 'dotenv-load' boolean?
              | 'set' 'export' boolean?
              | 'set' 'positional-arguments' boolean?
              | 'set' 'shell' ':=' '[' string (',' string)* ','? ']'

boolean       : ':=' ('true' | 'false')

expression    : 'if' condition '{' expression '}' 'else' '{' expression '}'
              | value '+' expression
              | value

condition     : expression '==' expression
              | expression '!=' expression

value         : NAME '(' sequence? ')'
              | BACKTICK
              | INDENTED_BACKTICK
              | NAME
              | string
              | '(' expression ')'

string        : STRING
              | INDENTED_STRING
              | RAW_STRING
              | INDENTED_RAW_STRING

sequence      : expression ',' sequence
              | expression ','?

recipe        : '@'? NAME parameter* variadic? ':' dependency* body?

parameter     : '$'? NAME
              | '$'? NAME '=' value

variadic      : '*' parameter
              | '+' parameter

dependency    : NAME
              | '(' NAME expression* ')'

body          : INDENT line+ DEDENT

line          : LINE (TEXT | interpolation)+ NEWLINE
              | NEWLINE

interpolation : '{{' expression '}}'
