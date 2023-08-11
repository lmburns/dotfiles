fun! plugs#ft#rust#commands() abort
endfun

fun! plugs#ft#rust#mappings() abort
endfun

fun! plugs#ft#rust#autocmds() abort
    augroup lmb__RustEnv
        au!
        au FileType rust
            \ call plugs#ft#rust#mappings()
            \ | call plugs#ft#rust#commands()
    augroup END
endfun

fun! plugs#ft#rust#setup() abort
    " let g:rustfmt_autosave = 1
    " let g:rustfmt_autosave_if_config_present = 1
    " let g:rustfmt_emit_files = 1
    " let g:rustfmt_fail_silently = 0
    " let g:rust_cargo_avoid_whole_workspace = 1
    " let g:rust_recent_nearest_cargo_toml = 0
    " let g:rust_recent_root_cargo_toml = 0

    let g:rust_recommended_style = 1
    let g:rust_bang_comment_leader = 1
    let g:rust_fold = 0
    let g:rust_set_foldmethod = 'indent'

    let g:rust_conceal = 0
    let g:rust_set_conceallevel = 1
    let g:rust_conceal_mod_path = 1
    let g:rust_conceal_pub = 0

    call plugs#ft#rust#autocmds()
endfun
