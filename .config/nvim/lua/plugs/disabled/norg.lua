local M = {}

local neorg = require("common.utils").prequire("neorg")
local parser_configs = require("nvim-treesitter.parsers").get_parser_configs()

function M.setup()
    neorg.setup {
        load = {
            ["core.defaults"] = {},
            ["core.keybinds"] = {
                config = {
                    default_keybinds = true,
                    neorg_leader = "<Leader>o"
                }
            },
            ["core.integrations.telescope"] = {},
            -- ["core.norg.completion"] = {
            --     config = {
            --         engine = "nvim-cmp"
            --     }
            -- },
            ["core.norg.concealer"] = {
                config = {
                    conceals = false
                }
            },
            -- Allows for use of icons
            ["core.norg.dirman"] = {
                config = {
                    workspaces = {
                        main = ("%s/Documents/norg"):format(vim.env.HOME)
                        -- gtd = ("%s/Documents/norg/gtd"):format(vim.env.HOME)
                    }
                }
            }
            -- ["core.gtd.base"] = {
            --     config = {
            --         workspace = "gtd"
            --     }
            -- }
        }
    }
end

local function init()
    M.setup()

    parser_configs.norg = {
        install_info = {
            url = "https://github.com/vhyrro/tree-sitter-norg",
            files = {"src/parser.c", "src/scanner.cc"},
            branch = "main"
        }
    }

    parser_configs.norg_meta = {
        install_info = {
            url = "https://github.com/nvim-neorg/tree-sitter-norg-meta",
            files = {"src/parser.c"},
            branch = "main"
        }
    }

    parser_configs.norg_table = {
        install_info = {
            url = "https://github.com/nvim-neorg/tree-sitter-norg-table",
            files = {"src/parser.c"},
            branch = "main"
        }
    }
end

init()

return M
