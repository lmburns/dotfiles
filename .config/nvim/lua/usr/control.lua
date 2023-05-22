---@class PackerPlugin
---@field name string Name of plugin
---@field after string|string[] Specifies plugins to load before this plugin.
---@field requires string|string[]|string[][] Specifies plugin dependencies
---@field wants string|string[] Load the plugins if they're not already
---@field rocks string|string[] Specifies Luarocks dependencies for the plugin
---@field as string Specifies an alias under which to install the plugin
---@field config string|fun() Specifies code to run after this plugin is loaded.
---@field conf string [CUSTOM]: Specifies code to run after this plugin is loaded.
---@field setup string|fun() Specifies code to run before this plugin is loaded.
---@field run string|string[]|fun(v: PackerPlugin)|fun(v: PackerPlugin)[] Post-update/install hook
---@field installer fun() Specifies custom installer
---@field updater fun() Specifies custom updater
---@field lock boolean Skip updating this plugin in updates/syncs. Still cleans.
---@field frozen boolean Unsure: possibly same as lock
---@field opt boolean Manually marks a plugin as optional.
---@field cond string|fun(): boolean|string[] Specifies a conditional test to load this plugin
---@field cmd string|string[] Specifies commands which load this plugin.  Can be an autocmd pattern.
---@field ft string|string[] Specifies filetypes which load this plugin.
---@field keys string|string[]|string[][] Specifies maps which load this plugin
---@field event string|string[] Specifies autocommand events which load this plugin.
---@field fn string|string[] Specifies functions which load this plugin.
---@field module string|string[] Specifies Lua module names for require
---@field module_pattern string|string[] Specifies Lua pattern of Lua module names for require
---@field disable boolean Mark a plugin as inactive
---@field disablep boolean [CUSTOM]: Mark a plugin as inactive if it is disabled in `usr.control`
---@field rtp string Specifies a subdirectory of the plugin to add to runtimepath.
---@field patch boolean|string [CUSTOM]: Specifies a patch to apply to the plugin
---@field branch string Specifies a git branch to use
---@field commit string Specifies a git commit to use
---@field rev string Specifies a git commit to use
---@field tag string Specifies a git tag to use. Supports '*' for "latest tag"
---@field bufread boolean Manually specifying if a plugin needs BufRead after being loaded
---@field simple_load boolean Unsure: only load the plugin as if no args were passed
---@field url string URL to the Git repository
---@field install_path string Directory where plugin is to be installed
---@field manual_opt boolean Unsure
---@field only_config boolean Unsure
---@field short_name string Name of plugin minus the user
---@field desc string [CUSTOM]: Just a way of writing a description of the plugin

-- local control = {}
-- for plugin, tbl in pairs(_G.packer_plugins) do
--     control[plugin] = false
-- end
-- p(control)

local M = {
    ["Comment.nvim"] = false,
    ["FixCursorHold.nvim"] = false,
    ["JuliaFormatter.vim"] = false,
    ScratchPad = false,
    UnconditionalPaste = false,
    ["aerial.nvim"] = false,
    ["architext.nvim"] = false,
    ["arshlib.nvim"] = false,
    ["asyncrun.vim"] = false,
    ["better-escape.nvim"] = false,
    ["bufferize.vim"] = false,
    ["bufferline.nvim"] = false,
    catppuccin = false,
    ["close-buffers.nvim"] = false,
    ["coc-code-action-menu"] = false,
    ["coc-fzf"] = false,
    ["coc-kvs"] = false,
    ["coc.nvim"] = false,
    ["comment-box.nvim"] = false,
    ["crates.nvim"] = false,
    ["desktop-notify.nvim"] = false,
    ["dial.nvim"] = false,
    ["diffview.nvim"] = false,
    ["dressing.nvim"] = false,
    edge = false,
    ["eregex.vim"] = false,
    everforest = false,
    ["fsread.nvim"] = false,
    fzf = false,
    ["fzf-floaterm"] = false,
    ["fzf-lua"] = false,
    ["fzf.vim"] = false,
    ["fzy-lua-native"] = false,
    ["git-conflict.nvim"] = false,
    ["gitsigns.nvim"] = false,
    ["gruvbox-flat.nvim"] = false,
    ["gruvbox-material"] = false,
    hexmode = false,
    ["hlargs.nvim"] = false,
    ["hop.nvim"] = false,
    ["hotpot.nvim"] = false,
    ["iceberg.vim"] = false,
    ["id3.nvim"] = false,
    ["impatient.nvim"] = false,
    ["incline.nvim"] = false,
    ["indent-blankline.nvim"] = false,
    ["info.vim"] = false,
    ["iswap.nvim"] = false,
    ["kanagawa.nvim"] = false,
    kimbox = false,
    ["lazygit.nvim"] = false,
    ["legendary.nvim"] = false,
    ["lf-vim"] = false,
    ["lf.nvim"] = false,
    ["lf.vim"] = false,
    ["linediff.vim"] = false,
    ["link-visitor.nvim"] = false,
    ["listish.nvim"] = false,
    ["lualine.nvim"] = false,
    ["lush.nvim"] = false,
    ["luv-vimdocs"] = false,
    ["marks.nvim"] = false,
    ["material.nvim"] = false,
    melange = false,
    ["mellow.nvim"] = false,
    miramare = false,
    mkdx = false,
    ["move.nvim"] = false,
    ["neodark.vim"] = false,
    ["neodev.nvim"] = false,
    neoformat = false,
    neogen = false,
    neogit = false,
    neotest = false,
    ["neotest-go"] = false,
    ["neotest-plenary"] = false,
    ["neotest-python"] = false,
    ["neotest-vim-test"] = false,
    neovim = false,
    ["nightfox.nvim"] = false,
    ["nlua.nvim"] = false,
    ["nui.nvim"] = false,
    ["nvim-autopairs"] = false,
    ["nvim-bqf"] = false,
    ["nvim-colorizer.lua"] = false,
    ["nvim-dap"] = false,
    ["nvim-dap-python"] = false,
    ["nvim-dap-ui"] = false,
    ["nvim-dap-virtual-text"] = false,
    ["nvim-fundo"] = false,
    ["nvim-gps"] = false,
    ["nvim-hlslens"] = false,
    ["nvim-luapad"] = false,
    ["nvim-luaref"] = false,
    ["nvim-neoclip.lua"] = false,
    ["nvim-notify"] = false,
    ["nvim-scrollbar"] = false,
    ["nvim-treehopper"] = false,
    ["nvim-treesitter"] = false,
    ["nvim-treesitter-endwise"] = false,
    ["nvim-treesitter-refactor"] = false,
    ["nvim-treesitter-textobjects"] = false,
    ["nvim-ts-autotag"] = false,
    ["nvim-ts-context-commentstring"] = false,
    ["nvim-ts-rainbow"] = false,
    ["nvim-ufo"] = false,
    ["nvim-web-devicons"] = false,
    ["nvim.lua"] = false,
    nvim_context_vt = false,
    ["oceanic-material"] = false,
    ["one-small-step-for-vimkind"] = false,
    ["open-browser.vim"] = false,
    ["package-info.nvim"] = false,
    ["packer.nvim"] = false,
    ["paperplanes.nvim"] = false,
    playground = false,
    ["plenary.nvim"] = false,
    ["popup.nvim"] = false,
    ["possession.nvim"] = false,
    ["project.nvim"] = false,
    ["promise-async"] = false,
    ["registers.nvim"] = false,
    rnvimr = false,
    ["ron.vim"] = false,
    ["rose-pine"] = false,
    ["rust.vim"] = false,
    ["smart-splits.nvim"] = false,
    ["smartcolumn.nvim"] = false,
    sonokai = false,
    ["sort.nvim"] = false,
    spaceduck = false,
    ["specs.nvim"] = false,
    ["spread.nvim"] = false,
    ["sqlite.lua"] = false,
    ["substitute.nvim"] = false,
    ["suda.vim"] = false,
    ["syntax-tree-surfer"] = false,
    ["targets.vim"] = false,
    ["telescope-bookmarks.nvim"] = false,
    ["telescope-coc.nvim"] = false,
    ["telescope-dap.nvim"] = false,
    ["telescope-file-browser.nvim"] = false,
    ["telescope-frecency.nvim"] = false,
    ["telescope-fzf-native.nvim"] = false,
    ["telescope-ghq.nvim"] = false,
    ["telescope-github.nvim"] = false,
    ["telescope-heading.nvim"] = false,
    ["telescope-hop.nvim"] = false,
    ["telescope-packer.nvim"] = false,
    ["telescope-rualdi.nvim"] = false,
    ["telescope-smart-history.nvim"] = false,
    ["telescope-ultisnips.nvim"] = false,
    ["telescope-zoxide"] = false,
    ["telescope.nvim"] = false,
    ["template-string.nvim"] = false,
    ["tmux.nvim"] = false,
    ["todo-comments.nvim"] = false,
    ["toggleterm.nvim"] = false,
    ["tokyonight.nvim"] = false,
    ["treesitter-unit"] = false,
    ["trouble.nvim"] = false,
    ["twilight.nvim"] = false,
    ultisnips = false,
    undotree = false,
    ["urlview.nvim"] = false,
    ["vCoolor.vim"] = false,
    ["vim-SpellCheck"] = false,
    ["vim-asterisk"] = false,
    ["vim-cargo-make"] = false,
    ["vim-caser"] = false,
    ["vim-crystal"] = false,
    ["vim-devicons"] = false,
    ["vim-easy-align"] = false,
    ["vim-floaterm"] = false,
    ["vim-flog"] = false,
    ["vim-fugitive"] = false,
    ["vim-gh-line"] = false,
    ["vim-gnupg"] = false,
    ["vim-go"] = false,
    ["vim-grepper"] = false,
    ["vim-gutentags"] = false,
    ["vim-indent-object"] = false,
    ["vim-ingo-library"] = false,
    ["vim-just"] = false,
    ["vim-markdown"] = false,
    ["vim-matchup"] = false,
    ["vim-perl"] = false,
    ["vim-polyglot"] = false,
    ["vim-repeat"] = false,
    ["vim-rhubarb"] = false,
    ["vim-rustpeg"] = false,
    ["vim-sandwich"] = false,
    ["vim-slime"] = false,
    ["vim-snippets"] = false,
    ["vim-startuptime"] = false,
    ["vim-table-mode"] = false,
    ["vim-teal"] = false,
    ["vim-visual-multi"] = false,
    ["vim-xxdcursor"] = false,
    vimtex = false,
    vimwiki = false,
    vinfo = false,
    ["vista.vim"] = false,
    ["which-key.nvim"] = false,
    ["wilder.nvim"] = false,
    ["zen-mode.nvim"] = false,
    ["zig.vim"] = false
}

return M
