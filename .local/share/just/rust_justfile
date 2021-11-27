set shell := ["zsh", "-euyc"]
set dotenv-load := true
set export
# F

CI := if env_var_or_default("CI", "1") == "0" { "--color=never" } else { "--color=always" }
version := `rg --color=never --pcre2 -oIN '^version = "\K(\d+\.?)+' Cargo.toml`

# rf := if env_var_or_default("rfd", "0") == "1" { join(env_var_or_default("RUSTFLAGS", ""), " -A dead_code") } else { env_var_or_default("RUSTFLAGS", "") }
# export RUSTFLAGS := rf

rl := ''
export RUST_LOG := rl

bt := '0'
export RUST_BACKTRACE := bt

log := "warn"
export JUST_LOG := log

defaut:
  @just --choose

alias e := edit
edit:
  @$EDITOR {{justfile()}}

alias r := run
run *ARGS:
  noglob cargo run {{CI}} -- {{ARGS}}

fmt:
  cargo fmt -- --check --files-with-diff {{CI}}

fmt-all:
  cargo fmt --all -- --check --files-with-diff {{CI}}

audit:
  cargo audit --deny warnings {{CI}}

check:
  cargo check --all-features {{CI}}

clippy:
  cargo clippy --all --all-targets --all-features {{CI}}

# cargo clippy --all-features {{CI}} -- --deny warnings --deny clippy::all

alias br := build-release
build-release:
  cargo build --release --all-features {{CI}}

test:
  cargo test {{CI}}

testn:
  cargo test {{CI}} -- --nocapture


###################################################################################
###################################################################################

man:
  help2man \
    --name 'tag files colorfully' \
    --manual 'Wutag Manual' \
    --no-info \
    target/debug/wutag \
    > man/wutag.1
  sed -i "s,\x1B\[[0-9;]*[a-zA-Z],,g" man/wutag.1

view-man: man
  man man/wutag.1

# sd '{{FROM}}' '{{TO}}' src/*.rs Cargo.toml

# replace FROM TO *GO:
#   ruplacer '{{FROM}}' '{{TO}}' {{GO}} src/*.rs
#
# update-version NEW *GO:
#   just replace {{version}} {{NEW}} {{GO}}
#   just man

@get-version:
  print -P "%F{12}%b{{version}}%f%b"

replace FROM TO:
  -fd -tf -e rs -e toml | sad '{{FROM}}' '{{TO}}'

@update-version NEW:
  -just replace {{version}} {{NEW}}

@update-version-1:
  -just replace {{version}} "$(perl -F'\.' -lane 'print join ".", @F[0..$#F-1], $F[-1] + 1' <<< $version)"

@lint:
  print -Pr "%F{2}%BChecking for FIXME/TODO...%b%f"
  rg -s '\bFIXME\b|\bFIX\b|\bDISCOVER\b|\bNOTE\b|\bNOTES\b|\bINFO\b|\bOPTIMIZE\b|\bXXX\b|\bEXPLAIN\b|\bTODO\b|\bHACK\b|\bBUG\b|\bBUGS\b' src/*.rs
  print -Pr $'\n'"%F{2}%BChecking for long lines...%b%f"
  rg --color=always '.{100}' src/*.rs

@code:
  tokei -ft rust -s lines

@code-overall:
  tokei -t rust

###################################################################################
###################################################################################

# detect if there's changes
no-changes:
  git diff --no-ext-diff --quiet --exit-code

# delete merged branches
d-merged:
  git branch --merged | egrep -v "(^\*|master|dev) | xargs git branch -d"

# generate changelog
cliff:
  git cliff --unreleased --strip all

# create and sign/verify tag
sign-tag TAG:
  git cliff --tag {{TAG}} > CHANGELOG.md
  git add -A && git commit -m "chore(release): prepare for {{TAG}}"
  git tag -sa {{TAG}} -m "Release {{TAG}}"
  git tag -v {{TAG}}

###################################################################################
###################################################################################

preview-readme:
  grip -b README.md

alias er := edit-readme
edit-readme:
  @$EDITOR ${$(cargo locate-project | jq -r '.root'):h}/README.md

edit-main:
  @$EDITOR ${$(cargo locate-project | jq -r '.root'):h}/src/main.rs

alias ee := edit-rust
edit-rust:
  #!/usr/bin/env zsh
  local -a files sel
  files=$(command fd -Hi -tf -d2 -e rs)
  sel=("$(
    print -rl -- "$files[@]" | \
    fzf --query="$1" \
      --multi \
      --select-1 \
      --exit-0 \
      --bind=ctrl-x:toggle-sort \
      --preview-window=':nohidden,right:65%:wrap' \
      --preview='([[ -f {} ]] && (bat --style=numbers --color=always {})) || \
                 ([[ -d {} ]] && (exa -TL 3 --color=always --icons {} | less)) || \
                 echo {} 2> /dev/null | head -200'
    )"
  ) || return
  [[ -n "$sel" ]] && ${EDITOR:-vim} "${sel[@]}"


# vim: ft=just:et:sw=0:ts=2:sts=2:fdm=marker:fmr={{{,}}}:
