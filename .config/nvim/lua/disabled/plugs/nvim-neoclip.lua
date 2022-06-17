local M = {}

local fn = vim.fn

local function is_whitespace(line)
    return fn.match(line, [[^\s*$]]) ~= -1
end

local function all(tbl, check)
    for _, entry in ipairs(tbl) do
        if not check(entry) then
            return false
        end
    end
    return true
end

function M.setup()
    require("neoclip").setup(
        {
            history = 10000,
            enable_persistent_history = true,
            length_limit = 1048576,
            continious_sync = false,
            db_path = fn.stdpath("data") .. "/databases/neoclip.sqlite3",
            filter = nil,
            preview = true,
            default_register = "+",
            default_register_macros = "q",
            enable_macro_history = true,
            content_spec_column = false,
            on_paste = {set_reg = false},
            on_replay = {set_reg = false},
            keys = {
                telescope = {
                    i = {
                        select = "<C-n>",
                        paste = "<C-j>",
                        paste_behind = "<c-k>",
                        delete = "<c-d>", -- delete an entry
                        replay = "<c-q>",
                        custom = {
                            ["<C-y>"] = function(opts)
                                require("common.yank").yank_reg(vim.v.register, opts.entry.contents[1])
                            end,
                            ["<CR>"] = function(opts)
                                require("common.yank").yank_reg(vim.v.register, opts.entry.contents[1])
                            end
                        }
                    },
                    n = {
                        select = "<C-n>",
                        paste = "p",
                        paste_behind = "P",
                        replay = "q",
                        delete = "d",
                        custom = {
                            ["<CR>"] = function(opts)
                                require("common.yank").yank_reg(vim.v.register, opts.entry.contents[1])
                            end
                        }
                    }
                }
            }
        }
    )
end

local function init()
    M.setup()
    require("telescope").load_extension("neoclip")
end

init()

return M
