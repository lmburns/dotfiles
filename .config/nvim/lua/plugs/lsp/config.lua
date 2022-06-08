local M = {}

function M.lightbulb()
    require("nvim-lightbulb").setup(
        {
            ignore = {"null-ls"},
            sign = {enabled = false},
            float = {enabled = true, win_opts = {border = "none"}},
            autocmd = {
                enabled = true
            }
        }
    )
end

return M
