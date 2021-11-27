require'nvim-treesitter.configs'.setup {
  ensure_installed = { "c", "cpp", "go", "gomod", "rust", "python", "java" },
  -- "vim" "yaml" "toml" "ruby" "bash"
  ignore_install = {}, -- List of parsers to ignore installing
  highlight = {
    enable = true, -- false will disable the whole extension
    disable = {} -- list of language that will be disabled
  }
}
