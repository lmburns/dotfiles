local lsp_installer = require("nvim-lsp-installer")

-- "coc-css",
-- "coc-diagnostic",
-- "coc-dlang",
-- "coc-fzf-preview",
-- "coc-lightbulb",
-- "coc-marketplace",
-- "coc-prettier",
-- "coc-rls",
-- "coc-snippets",
-- "coc-syntax",
-- "coc-tabnine",
-- "coc-tag",
-- "coc-vimlsp",
-- "coc-vimtex",
-- "coc-xml",
-- "coc-yank",

lsp_installer.setup(
    {
        ensure_installed = {
            "bashls",
            -- "clangd",
            -- "dockerls",
            -- "eslint",
            -- "gopls",
            -- "html",
            -- "jedi_language_server",
            -- "pyright",
            -- "jsonls",
            -- "perlnavigator",
            -- "r_language_server",
            -- "rust_analyzer",
            -- "rls",
            -- "solargraph",
            -- "solang",
            -- "sqls",
            "sumneko_lua"
            -- "taplo",
            -- "tsserver",
            -- "vimls",
            -- "yamlls",
            -- "zls"
        },
        automatic_installation = true,
        install_root_dir = vim.env.HOME .. "/.cache/lsp-servers",
        ui = {
            icons = {
                server_installed = "",
                server_pending = "➜",
                server_uninstalled = "◍"
            }
        },
        keymaps = {
            toggle_server_expand = "o",
            install_server = "i",
            update_server = "u",
            check_server_version = "c",
            update_all_servers = "U",
            check_outdated_servers = "C",
            uninstall_server = "X"
        }
    }
)
