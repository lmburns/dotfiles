local M = {}

function M.setup()
    require("pretty-fold").setup(
        {
            fill_char = "•",
            keep_indentation = true,
            remove_fold_markers = true,
            process_comment_signs = "delete",
            sections = {
                left = {"content"},
                right = {
                    "+",
                    function()
                        return string.rep("-", vim.v.foldlevel)
                    end,
                    " ",
                    "number_of_folded_lines",
                    ": ",
                    "percentage",
                    " ",
                    function(config)
                        return config.fill_char:rep(3)
                    end
                }
            },
            -- List of patterns that will be removed from content foldtext section.
            stop_words = {
                "@brief%s*" -- (for C++) Remove '@brief' and all spaces after.
            },
            add_close_pattern = true, -- true, 'last_line' or false
            matchup_patterns = {
                {"{", "}"},
                {"%(", ")"}, -- % to escape lua pattern char
                {"%[", "]"} -- % to escape lua pattern char
            },
            ft_ignore = {"neorg"}

            --   fill_char = "━",
            --     keep_indentation = false,
            --     sections = {
            --         left = {
            --             "━━",
            --             function()
            --                 return string.rep(">", vim.v.foldlevel)
            --             end,
            --             "━━┫",
            --             "content",
            --             "┣"
            --         },
            --         right = {
            --             "┫ ",
            --             "number_of_folded_lines",
            --             ": ",
            --             "percentage",
            --             " ┣━━"
            --         }
            --     }

            -- keep_indentation = false,
            -- fill_char = "•",
            -- sections = {
            --     left = {
            --         "+",
            --         function()
            --             return string.rep("-", vim.v.foldlevel)
            --         end,
            --         " ",
            --         "number_of_folded_lines",
            --         ":",
            --         "content"
            --     }
            -- }
        }
    )

    require("pretty-fold").ft_setup(
        "lua",
        {
            matchup_patterns = {
                {"^%s*do$", "end"}, -- do ... end blocks
                {"^%s*if", "end"}, -- if ... end
                {"^%s*for", "end"}, -- for
                {"function%s*%(", "end"}, -- 'function( or 'function (''
                {"{", "}"},
                {"%(", ")"}, -- % to escape lua pattern char
                {"%[", "]"} -- % to escape lua pattern char
            }
        }
    )

    require("pretty-fold.preview").setup(
        {
            default_keybindings = false,
            border = "rounded"
        }
    )

    local keymap_amend = require("keymap-amend")
    local mapping = require("pretty-fold.preview").mapping
    keymap_amend("n", "l", mapping.show_close_preview_open_fold)
end

local function init()
    vim.opt.fillchars:append("fold:•")

    vim.defer_fn(
        function()
            M.setup()
        end,
        50
    )
end

init()

return M
